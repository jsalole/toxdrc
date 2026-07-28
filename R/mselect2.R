#' A modified mselect function from drc
#'
#' Differs from [drc::mselect()] in three ways:
#'
#' * `update()` is called with `data = object$origData`, which allows the
#'   function to be used inside pipelines and other functions where the
#'   original data object is not visible in the calling frame.
#' * Ordering is metric-aware. `drc::mselect()` sorts every criterion in
#'   ascending order, which is correct for `"IC"` and `"Res var"` (lower is
#'   better) but inverted for `"Lack of fit"`, which is a goodness-of-fit
#'   p-value where a *higher* value indicates the better-fitting model.
#' * `include_baseline` allows the row for `object` itself to be dropped. When
#'   `object` was fitted with one of the models already in `fctList`, keeping
#'   it produces a duplicated row.
#'
#' @param object A fitted drm model used as the baseline.
#' @param fctList List of model functions to compare against. If named, the
#'  names are used as rownames of the returned matrix; otherwise each model's
#'  internal `$name` is used.
#' @param nested Logical. Include a nested F test column.
#' @param sorted Character. Criterion used to order the returned matrix, or
#'  `"no"` to leave it unsorted.
#' @param linreg Logical. Append linear, quadratic, and cubic fits.
#' @param icfct Function used to compute the information criterion.
#' @param include_baseline Logical. Retain the row for `object` itself.
#'  Defaults to TRUE, matching [drc::mselect()].
#'
#' @returns A matrix of goodness-of-fit scores, one row per model.
#'
#' @seealso [drc::mselect()]
#'
#'
#' @importFrom drc modelFit mselect
#' @importFrom stats AIC anova lm logLik update
#'
#' @noRd

#'
mselect2 <- function(
  object,
  fctList = NULL,
  nested = FALSE,
  sorted = c("IC", "Res var", "Lack of fit", "no"),
  linreg = FALSE,
  icfct = AIC,
  include_baseline = TRUE
) {
  suppressWarnings({
    sorted <- match.arg(sorted)

    if (!is.logical(nested)) {
      stop("'nested' argument takes only the values: FALSE, TRUE")
    }

    contData <- identical(object$type, "continuous")
    nestedInd <- 3 + contData + nested

    lenFL <- length(fctList)
    retMat <- matrix(0, lenFL + 1, 3 + contData + nested)

    # modelFit() runs its own optimisation to fit the saturated model for the
    # lack-of-fit test, so it can fail on data the model itself fitted
    # perfectly well. Its failure is not a reason to abandon the comparison,
    # so it is caught the same way summary()$resVar already was.
    lack_of_fit <- function(fit) {
      value <- try(modelFit(fit)[2, 5], silent = TRUE)
      if (inherits(value, "try-error")) NA_real_ else value
    }

    # Fill in baseline model
    retMat[1, 1] <- logLik(object)
    retMat[1, 2] <- icfct(object)
    retMat[1, 3] <- lack_of_fit(object)

    if (contData) {
      tryRV <- try(summary(object)$resVar, silent = TRUE)
      retMat[1, 4] <- if (!inherits(tryRV, "try-error")) tryRV else NA
    }

    if (nested) {
      retMat[1, nestedInd] <- NA
    }

    # drc derives $name from match.call(), so it is only the model shorthand
    # when the mean function was called bare; drc::LL.4() records "::".
    # Callers that need reliable labels should pass a named fctList.
    shorthand <- function(x) {
      if (!is.character(x) || length(x) == 0) NA_character_ else x[1]
    }

    fctList2 <- rep("", lenFL + 1)
    fctList2[1] <- shorthand(object$fct$name)

    if (!is.null(fctList)) {
      prevObj <- object
      for (i in 1:lenFL) {
        # allows fx to be used inside pipelines and other functions
        tempObj <- try(
          update(object, fct = fctList[[i]], data = object$origData),
          silent = TRUE
        )
        fctList2[i + 1] <- if (!is.null(names(fctList)) &&
          nzchar(names(fctList)[i])) {
          names(fctList)[i]
        } else {
          shorthand(fctList[[i]]$name)
        }

        if (!inherits(tempObj, "try-error")) {
          retMat[i + 1, 1] <- logLik(tempObj)
          retMat[i + 1, 2] <- icfct(tempObj)
          retMat[i + 1, 3] <- lack_of_fit(tempObj)

          if (contData) {
            tryRV2 <- try(summary(tempObj)$resVar, silent = TRUE)
            retMat[i + 1, 4] <- if (!inherits(tryRV2, "try-error")) {
              tryRV2
            } else {
              NA
            }
          }

          if (nested) {
            retMat[i + 1, nestedInd] <- anova(
              prevObj,
              tempObj,
              details = FALSE
            )[
              2,
              5
            ]
          }
        } else {
          retMat[i + 1, ] <- NA
        }
        prevObj <- tempObj
      }
    }

    rownames(retMat) <- as.vector(unlist(fctList2))

    cnames <- c("logLik", "IC", "Lack of fit")
    if (contData) {
      cnames <- c(cnames, "Res var")
    }
    if (nested) {
      cnames <- c(cnames, "Nested F test")
    }
    colnames(retMat) <- cnames

    # The baseline row duplicates whichever fctList entry `object` was fitted
    # with. Drop it unless the caller asked for drc::mselect() parity.
    if (!include_baseline && lenFL > 0) {
      retMat <- retMat[-1, , drop = FALSE]
    }

    # Optional linear regression models
    if (linreg) {
      drcData <- as.data.frame(object$data[, c(2, 1)])
      names(drcData) <- c("yVec", "xVec")

      linFitList <- list(
        lm(yVec ~ xVec, data = drcData),
        lm(yVec ~ xVec + I(xVec^2), data = drcData),
        lm(yVec ~ xVec + I(xVec^2) + I(xVec^3), data = drcData)
      )

      linModMat <- matrix(
        unlist(lapply(linFitList, function(listObj) {
          c(logLik(listObj), icfct(listObj), NA, (summary(listObj)$sigma)^2)
        })),
        3,
        4,
        byrow = TRUE
      )

      rownames(linModMat) <- c("Lin", "Quad", "Cubic")
      colnames(linModMat) <- cnames[1:4]

      if (nested) {
        retMat <- retMat[, 1:4]
      }

      retMat <- rbind(retMat, linModMat)
    }
    # "Res var" only exists for a continuous fit, so a binomial baseline
    # would otherwise fail with a subscript error from the ordering below.
    if (sorted != "no" && !sorted %in% colnames(retMat)) {
      toxdrc_abort(
        c(
          paste0("Criterion \"", sorted, "\" is not available for this fit."),
          "x" = paste0(
            "Available criteria: ",
            paste(colnames(retMat), collapse = ", "),
            "."
          ),
          "i" = "A binomial fit has no residual variance to report."
        ),
        class = "metric_not_available",
        metric = sorted
      )
    }

    if (sorted != "no") {
      # "Lack of fit" is a goodness-of-fit p-value: a larger value means less
      # evidence against the model, so the best fit sorts to the top under
      # decreasing order. "IC" and "Res var" are the other way around.
      decreasing <- identical(sorted, "Lack of fit")
      ord <- order(retMat[, sorted], decreasing = decreasing, na.last = TRUE)
      return(retMat[ord, , drop = FALSE])
    } else {
      return(retMat)
    }
  })
}
