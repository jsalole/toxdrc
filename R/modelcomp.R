#' Compare model fits and select best model
#'
#' @description
#' Data is fitted to provided models, typically from the drc package. Models
#'  fitted successfully are compared using multiple goodness-of-fit scores,
#'  and organized using the score given as the `metric` argument.
#'
#' For a continuous response the default `model_list` holds a single model, so
#'  by default this fits `LL.4` rather than choosing between candidates.
#'  Supply more than one entry to make `metric` meaningful. For a quantal
#'  endpoint the default holds two, `LL.2` and `LL.3u`, which differ in
#'  whether background response in the controls is estimated.
#'
#' @param dataset A dataframe, containing the columns `Conc` and `Response`.
#' @param Conc Bare (unquoted) column name in `dataset` that groups the
#'  `Response` variable.
#' @param Response Bare (unquoted) column name in `dataset` containing
#'  the response variable. For a quantal endpoint this is the affected
#'  fraction, between 0 and 1.
#' @param N Bare (unquoted) column name in `dataset` giving the number of
#'  organisms in each group. Required when `type = "binomial"` and ignored
#'  otherwise.
#' @param model_list Named list, or NULL. Model functions to be tested. NULL,
#'  the default, selects a list appropriate to `type`: `LL.4` for a continuous
#'  response, and `LL.2` together with `LL.3u` for a quantal one. Supply your
#'  own list to override, e.g. `list("LL.4" = LL.4(), "W1.4" = W1.4())`. Most
#'  models from the drc package are compatible; use `drc::getMeanFunctions()`
#'  for more options. Each entry must be named for the model function it
#'  holds. See details for formatting.
#' @param metric Character. Criterion used to select the best
#'  model. Choices are `"IC"`, `"Res var"`, `"Lack of fit"`. Defaults
#'  to "IC". See details for how each is ordered. `"Res var"` is not
#'  available when `type = "binomial"`.
#' @param type Character. `"continuous"` for a measured response, or
#'  `"binomial"` for a quantal endpoint, which is fitted with
#'  `drc::drm(type = "binomial")` and weighted by `N`.
#' @param list_obj Optional. List object used for integration with
#'  [runtoxdrc()].
#' @param quiet Logical. Indicates if results should be hidden. Defaults
#'  to FALSE.

#' @importFrom drc LL.4 LN.4 W1.4 W2.4
#'
#' @returns A fitted drm model. If `list_obj` is provided, returns this within
#' the list as `list_obj$best_model`, along with the model name
#'  (`list_obj$best_model_name`), and the model comparison dataframe
#'  (`list_obj$model_df`). If model fitting fails, returns NULL.
#'
#' @examples
#' toxresult2 <- toxresult[!toxresult$Conc %in% c ("Control", "Blank"),]
#' toxresult2$Conc <- as.numeric(toxresult2$Conc)
#' modelcomp(toxresult2, Conc, RFU, metric = "IC")
#'
#' @seealso [drc::getMeanFunctions()] for compatible models and their
#'  shorthand for `model_list`.
#'
#' @details
#' The `model_list` argument requires a specific style. The argument must be a
#'  named list, where each name is the shorthand of the model function held in
#'  that entry, and each entry is the *result* of calling that function. An
#'  example of this is `list("LL.4" = LL.4(), "W1.4" = W1.4())`.
#'
#' The names are not cosmetic: they are used to label the comparison table and
#'  to retrieve the winning model, so a name that disagrees with the function it
#'  holds is rejected rather than silently ignored.
#'
#' Models that fail to converge are retained in the comparison table as `NA`
#'  rows and are never selected as the best model.
#'
#' **Ordering of `metric`.** `"IC"` and `"Res var"` are ordered ascending,
#'  since a smaller value indicates the better model. `"Lack of fit"` is
#'  ordered descending, because it is a goodness-of-fit p-value where a larger
#'  value means less evidence against the model. Note that this differs from
#'  [drc::mselect()], which sorts every criterion ascending.
#'
#'
#' @export
#'
#'

# TODO: accept a plain character vector of model shorthands, e.g.
# c("LL.4", "W1.4"), and build the named list internally. Now that entry names
# are required to match the function they hold, this is a direct mapping.
modelcomp <- function(
  dataset,
  Conc,
  Response,
  N = NULL,
  model_list = NULL,
  metric = c("IC", "Res var", "Lack of fit"),
  type = c("continuous", "binomial"),
  list_obj = NULL,
  quiet = FALSE
) {
  metric <- match.arg(metric)
  type <- match.arg(type)

  check_dataset(dataset)
  check_column(dataset, rlang::enquo(Conc), "Conc")
  check_column(dataset, rlang::enquo(Response), "Response")
  check_flag(quiet, "quiet")
  check_list_obj(list_obj)

  # drc reports a failed optimisation by printing through try(), which uses
  # cat() to stderr rather than raising a condition, so neither
  # suppressWarnings() nor suppressMessages() touches it. A model that fails
  # to converge is already recorded as an NA row in the comparison table and
  # can never be selected, so the printed "Error" is noise rather than news.
  # try() takes its destination from an option, which is the least invasive
  # place to redirect it.
  if (quiet) {
    null_con <- file(tempfile(), open = "wt")
    old_opts <- options(try.outFile = null_con)
    on.exit(
      {
        options(old_opts)
        close(null_con)
      },
      add = TRUE
    )
  }

  binomial <- identical(type, "binomial")
  n_quo <- rlang::enquo(N)
  has_n <- !rlang::quo_is_null(n_quo)

  if (binomial) {
    if (!has_n) {
      toxdrc_abort(
        c(
          "`N` is required when `type = \"binomial\"`.",
          "x" = "Without group sizes, a response of 0.1 from 1 of 10 and from 10 of 100 are weighted identically.",
          "i" = "Give the column holding the number of organisms per group, e.g. N = Total."
        ),
        class = "missing_counts"
      )
    }
    check_column(dataset, n_quo, "N")
    check_counts(dataset, n_quo)
    check_proportion(dataset, rlang::enquo(Response))
  }

  # "Res var" is a residual variance, which only exists for a continuous fit.
  # Caught here rather than letting mselect2() subscript a column that was
  # never created.
  if (binomial && identical(metric, "Res var")) {
    toxdrc_abort(
      c(
        "`metric = \"Res var\"` is not available for quantal data.",
        "x" = "A binomial fit has no residual variance to report.",
        "i" = "Use metric = \"IC\" or metric = \"Lack of fit\"."
      ),
      class = "metric_not_available",
      metric = metric
    )
  }

  if (is.null(model_list)) {
    model_list <- default_model_list(type)
  }

  # Guarantees that names(model_list) can be used to look a model back up from
  # the rownames of the comparison table below.
  model_list <- validate_model_list(model_list)

  best_model_name <- NULL
  best_model <- NULL
  model_df <- NULL

  ds <- dataset %>%
    dplyr::rename(
      Response = {{ Response }},
      Conc = {{ Conc }}
    )

  # The weights column is renamed into the fitting frame rather than passed as
  # a local vector. drm() records `weights = N` in the model call, and
  # mselect2() refits with update(), which re-evaluates that call against
  # object$origData. A bare vector would not be found there; a column of the
  # data will be. Same reasoning as the literal formula below.
  if (binomial) {
    ds <- ds %>% dplyr::rename(N = !!n_quo)
  }

  # mselect2() needs a fitted model as its baseline, so take the first entry
  # that converges. Every model in model_list is still compared below,
  # regardless of which one seeded the comparison.
  #
  # drm() is called directly rather than through safe_drm() on purpose.
  # mselect2() refits each candidate with update(), which re-evaluates the
  # model's stored call. safe_drm() passes its own argument names through to
  # drm(), so the stored call reads `drm(formula, data = data, fct = fct)`;
  # update() cannot resolve `formula` from its own frame and every refit fails,
  # silently producing an all-NA comparison table. Calling drm() here keeps the
  # formula literal in the stored call.
  #
  # The two branches are written out rather than assembled with do.call() for
  # the same reason: do.call() would store a call full of evaluated objects,
  # and update() needs something it can re-evaluate.
  fit_one <- function(fct) {
    tryCatch(
      if (binomial) {
        drm(
          Response ~ Conc,
          data = ds,
          weights = N,
          fct = fct,
          type = "binomial"
        )
      } else {
        drm(Response ~ Conc, data = ds, fct = fct)
      },
      error = function(e) NULL
    )
  }

  baseline_name <- NULL
  baseline_fit <- NULL

  for (name in names(model_list)) {
    baseline_fit <- fit_one(model_list[[name]])
    if (!is.null(baseline_fit)) {
      baseline_name <- name
      break
    }
  }

  if (is.null(baseline_fit)) {
    warning(
      "No model in `model_list` could be fitted to this data ",
      "(tried: ", paste(names(model_list), collapse = ", "), ").",
      call. = FALSE
    )
  } else {
    model_df <- mselect2(
      baseline_fit,
      model_list,
      sorted = metric,
      include_baseline = FALSE
    )

    # Defensive: never let a row that is not a supplied model reach the
    # lookup below.
    model_df <- model_df[
      rownames(model_df) %in% names(model_list),
      ,
      drop = FALSE
    ]
  }

  if (!is.null(model_df) && nrow(model_df) > 0) {
    if (!quiet) {
      print(model_df)
    }

    # Models that failed to converge are kept in the table as NA rows so the
    # user can see they were attempted, but must never be selected. The table
    # is already sorted, so the first scored row is the best model.
    scored <- which(!is.na(model_df[, metric]))

    if (length(scored) == 0) {
      warning(
        "No model in `model_list` produced a usable '", metric, "' score ",
        "for this data.",
        call. = FALSE
      )
    } else {
      best_model_name <- rownames(model_df)[scored[1]]

      # The baseline is already fitted; only refit if a different model won.
      best_model <- if (identical(best_model_name, baseline_name)) {
        baseline_fit
      } else {
        fit_one(model_list[[best_model_name]])
      }

      if (is.null(best_model)) {
        warning(
          "Model '", best_model_name, "' scored best on '", metric,
          "' but could not be refitted; returning no model.",
          call. = FALSE
        )
        best_model_name <- NULL
      }

      if (!quiet) {
        print(best_model)
      }
    }
  }

  if (!is.null(list_obj)) {
    # assign_field() is used rather than `$<-` so the names stay present with a
    # NULL value when nothing could be fitted. `list_obj$model <- NULL` would
    # delete the element, leaving entries with inconsistent shapes.
    list_obj <- assign_field(list_obj, "model_df", model_df)
    list_obj <- assign_field(list_obj, "best_model_name", best_model_name)
    list_obj <- assign_field(list_obj, "model", best_model)
    return(list_obj)
  }

  if (!quiet && !is.null(best_model)) {
    print(best_model)
    plot(best_model)
  }
  return(best_model)
}
