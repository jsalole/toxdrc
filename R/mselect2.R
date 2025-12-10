#' A modified mselect function from drc
#'
#' Insertion at 56-58 allows mselect to work within pipelines.
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
  icfct = AIC
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

    # Fill in baseline model
    retMat[1, 1] <- logLik(object)
    retMat[1, 2] <- icfct(object)
    retMat[1, 3] <- modelFit(object)[2, 5]

    if (contData) {
      tryRV <- try(summary(object)$resVar, silent = TRUE)
      retMat[1, 4] <- if (!inherits(tryRV, "try-error")) tryRV else NA
    }

    if (nested) {
      retMat[1, nestedInd] <- NA
    }

    fctList2 <- rep("", lenFL + 1)
    fctList2[1] <- object$fct$name

    if (!is.null(fctList)) {
      prevObj <- object
      for (i in 1:lenFL) {
        # allows fx to be used inside pipelines and other functions
        tempObj <- try(
          update(object, fct = fctList[[i]], data = object$origData),
          silent = TRUE
        )
        fctList2[i + 1] <- fctList[[i]]$name

        if (!inherits(tempObj, "try-error")) {
          retMat[i + 1, 1] <- logLik(tempObj)
          retMat[i + 1, 2] <- icfct(tempObj)
          retMat[i + 1, 3] <- modelFit(tempObj)[2, 5]

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
    if (sorted != "no") {
      return(retMat[order(retMat[, sorted]), ])
    } else {
      return(retMat)
    }
  })
}
