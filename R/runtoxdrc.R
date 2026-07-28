#' Point estimation pipeline
#'
#' @description
#' `runtoxdrc()` is the pipeline for function in the toxdrc package. This
#'  function allows the automated analysis of large datasets, while
#'  maintaining a consistent process for each subset of data.
#'
#' @param dataset A dataframe, containing the columns `Conc` and `Response`.
#' @param Conc Bare (unquoted) column name in `dataset` that groups the
#'  `Response` variable.
#' @param Response Bare (unquoted) column name in `dataset` containing
#'  the response variable. For a quantal endpoint this is the affected
#'  fraction, or the number affected if
#'  `endpoint = toxdrc_endpoint(response.type = "count")`.
#' @param N Bare (unquoted) column name in `dataset` giving the number of
#'  organisms in each group. Required for a quantal endpoint and ignored
#'  otherwise.
#' @param endpoint Endpoint options, declaring whether the response is
#'  continuous or quantal, overriding the preset. See [toxdrc_endpoint()] for
#'  more detail and defaults.
#' @param IDcols Optional. Character. Columns given as a vector used in the
#'  identification of data. These columns are preserved in the modified
#'  `dataset` with the first non-blank value. These values should be
#'  identical within observations grouped by `Conc`.
#' @param quiet Logical. Indicates if results should be hidden. Defaults
#'  to FALSE.
#' @param preset A configuration set from [toxdrc_preset()], or the name of
#'  one such as `"quantal"`. Supplies defaults for every configuration block
#'  left unset below. Defaults to `"continuous"`, which is where this
#'  function's own defaults come from.
#' @param qc Quality control and filtering options, overriding the preset.
#'  See [toxdrc_qc()] for more detail and defaults.
#' @param normalization Normalization options, overriding the preset. See
#'  [toxdrc_normalization()] for more detail and defaults.
#' @param toxicity Toxicity threshold and response-level options, overriding
#'  the preset. See [toxdrc_toxicity()] for more detail and defaults.
#' @param modelling Model selection, fitting criteria, and EDx calculation
#'  options, overriding the preset. See [toxdrc_modelling()] for more detail
#'  and defaults.
#' @param output Settings for output, overriding the preset. See
#'  [toxdrc_output()] for more detail and defaults.
#'
#' @importFrom dplyr pull filter mutate
#'
#' @section Quantal endpoints:
#' Setting `endpoint = toxdrc_endpoint(type = "binomial")` fits models with
#'  `drc::drm(type = "binomial")`, weighted by `N`, and defaults to comparing
#'  `LL.2` against `LL.3u`. Replicates are pooled by group size rather than
#'  averaged.
#'
#' Three preprocessing steps are refused for quantal data, because they assume
#'  a continuous response on an unbounded scale: `blank.correction`,
#'  `normalize.resp`, and `outlier.test`. Each raises an error naming the
#'  alternative. `"Res var"` is likewise unavailable as `model.metric`, since a
#'  binomial fit has no residual variance.
#'
#' Setting `modelling = toxdrc_modelling(interpolate = TRUE)` handles the
#'  degenerate case where no concentration produced a partial effect. There the
#'  slope is unidentifiable, so no model can be fitted at all, and the estimate
#'  comes from log-linear interpolation between the bracketing concentrations
#'  instead. Such entries are marked with `best_model_name = "interpolated"`
#'  and carry no confidence interval. See [interpolateECx()].
#'
#' @returns By default, returns a list of lists with each subset of data having
#'  its own entry. Each subset contains dataframes, models, and other objects
#'  that track the pipeline process. If `output = list(condense = TRUE)`, the
#'  results are summarized into a single dataframe containing the `IDcols` and
#'  model information of each data subset.
#'
#' @examples
#' \donttest{
#'   analyzed_data <- runtoxdrc(
#'  dataset = cellglow,
#'  Conc = Conc,
#'  Response = RFU,
#'  IDcols = c("Test_Number", "Dye", "Replicate", "Type"),
#'  quiet = TRUE,
#'  normalization = toxdrc_normalization(
#'    blank.correction = TRUE,
#'    normalize.resp = TRUE
#'  ),
#'  modelling = toxdrc_modelling(EDx = c(0.2, 0.5, 0.7))
#')
#' }
#'
#' @export
#'
#' @seealso [toxdrc_preset()] for ready-made configurations, and
#'  [config_runtoxdrc()] for the individual settings they are built from.
#'
runtoxdrc <- function(
  dataset,
  Conc,
  Response,
  N = NULL,
  IDcols = NULL,
  quiet = FALSE,
  preset = NULL,
  endpoint = NULL,
  qc = NULL,
  normalization = NULL,
  toxicity = NULL,
  modelling = NULL,
  output = NULL
) {
  # Configuration blocks default to NULL so that "not supplied" can be told
  # apart from "supplied with the default value". Anything left NULL comes
  # from the preset, which defaults to "continuous" — the same settings the
  # arguments used to carry directly.
  defaults <- resolve_preset(preset)

  if (is.null(endpoint)) endpoint <- defaults$endpoint
  if (is.null(qc)) qc <- defaults$qc
  if (is.null(normalization)) normalization <- defaults$normalization
  if (is.null(toxicity)) toxicity <- defaults$toxicity
  if (is.null(modelling)) modelling <- defaults$modelling
  if (is.null(output)) output <- defaults$output

  check_dataset(dataset)
  check_column(dataset, rlang::enquo(Conc), "Conc")
  check_column(dataset, rlang::enquo(Response), "Response")
  check_idcols(dataset, IDcols)
  check_flag(quiet, "quiet")

  check_config(endpoint, "endpoint", "toxdrc_endpoint")
  check_config(qc, "qc", "toxdrc_qc")
  check_config(normalization, "normalization", "toxdrc_normalization")
  check_config(toxicity, "toxicity", "toxdrc_toxicity")
  check_config(modelling, "modelling", "toxdrc_modelling")
  check_config(output, "output", "toxdrc_output")

  binomial <- identical(endpoint$type, "binomial")
  n_quo <- rlang::enquo(N)

  if (binomial) {
    if (rlang::quo_is_null(n_quo)) {
      toxdrc_abort(
        c(
          "`N` is required when the endpoint is quantal.",
          "x" = "Without group sizes, a response of 0.1 from 1 of 10 and from 10 of 100 are weighted identically.",
          "i" = "Give the column holding the number of organisms per group, e.g. N = Total."
        ),
        class = "missing_counts"
      )
    }

    check_column(dataset, n_quo, "N")
    check_counts(dataset, n_quo)

    # A count response is converted to a proportion once, up front, so every
    # later stage sees the same thing regardless of how the data arrived.
    if (identical(endpoint$response.type, "count")) {
      dataset <- dataset %>%
        dplyr::mutate({{ Response }} := {{ Response }} / {{ N }})
    }

    check_proportion(dataset, rlang::enquo(Response))

    # Steps that assume a continuous response on an unbounded scale. Refused
    # rather than skipped, so results are never quietly wrong.
    reject_for_binomial(
      normalization$blank.correction,
      "blank.correction",
      "Subtracting a blank value from an affected fraction has no meaning.",
      "Quantal data needs no blank correction; background response belongs in the model, which is what LL.3u estimates."
    )

    reject_for_binomial(
      normalization$normalize.resp,
      "normalize.resp",
      "Dividing a proportion by a control proportion can exceed 1 and break the fit.",
      "The quantal equivalent is Abbott's correction, (p - p0) / (1 - p0). Fitting LL.3u estimates the control response instead."
    )

    reject_for_binomial(
      qc$outlier.test,
      "outlier.test",
      "Grubbs' test assumes a normally distributed response, and proportions are not.",
      "Inspect group sizes instead; a binomial fit already weights small groups less."
    )
  }

  if (is.null(IDcols)) {
    split_list <- list(all = dataset)
  } else {
    split_list <- split(dataset, interaction(dataset[IDcols], drop = TRUE))
  }

  results_list <- lapply(names(split_list), function(name) {
    subset <- split_list[[name]]
    result <- list(dataset = subset)
    result$ID <- name

    if (qc$outlier.test) {
      result <- removeoutliers(
        dataset = result$dataset,
        Conc = {{ Conc }},
        Response = {{ Response }},
        list_obj = result,
        quiet = quiet
      )
    }

    if (qc$cv.flag) {
      result$dataset <- flagCV(
        dataset = result$dataset,
        Conc = {{ Conc }},
        Response = {{ Response }},
        max_val = qc$cvflag.lvl,
        quiet = quiet
      )
    }

    if (qc$pctl.test) {
      result <- pctl(
        dataset = result$dataset,
        Conc = {{ Conc }},
        reference_group = qc$ref.label,
        positive_group = qc$pctl.label,
        Response = {{ Response }},
        max_diff = qc$pctl.lvl,
        list_obj = result,
        quiet = quiet
      )
    }

    if (normalization$blank.correction) {
      result <- blankcorrect(
        dataset = result$dataset,
        Conc = {{ Conc }},
        blank_group = normalization$blank.label,
        Response = {{ Response }},
        list_obj = result,
        quiet = quiet
      )
      Response <- rlang::sym("c_response")
    }

    if (normalization$normalize.resp) {
      result <- normalizeresponse(
        dataset = result$dataset,
        Conc = {{ Conc }},
        reference_group = normalization$relative.label,
        Response = {{ Response }},
        list_obj = result,
        quiet = quiet
      )
      Response <- rlang::sym("normalized_response")
    }

    if (qc$avg.resp) {
      result <- averageresponse(
        dataset = result$dataset,
        Conc = {{ Conc }},
        Response = {{ Response }},
        N = !!n_quo,
        IDcols = IDcols,
        type = endpoint$type,
        list_obj = result,
        quiet = quiet
      )
      Response <- rlang::sym("mean_response")

      # Pooling renames the combined group size to N, so later stages must
      # look there rather than at the original column.
      if (binomial) {
        n_quo <- rlang::quo(N)
      }
    }

    result <- checktoxicity(
      dataset = result$dataset,
      Conc = {{ Conc }},
      reference_group = toxicity$comp.group,
      target_group = toxicity$target.group,
      effect = toxicity$toxic.lvl,
      type = toxicity$toxic.type,
      direction = toxicity$toxic.direction,
      Response = {{ Response }},
      list_obj = result,
      quiet = quiet
    )

    # this line causes problems in the code. Need to rework output to be true of getmetadata

    if (!result$effect) {
      result <- getmetadata(
        dataset = result$dataset,
        IDcols = IDcols,
        list_obj = result,
        quiet = quiet
      )
      return(result)
    }

    result$nonnumericgroups <- result$dataset %>%
      filter(is.na(suppressWarnings(as.numeric({{ Conc }})))) %>%
      pull({{ Conc }}) %>%
      unique()

    if (!quiet) {
      print(result$nonnumericgroups)
    }

    result$dataset <- result$dataset %>%
      mutate({{ Conc }} := suppressWarnings(as.numeric({{ Conc }}))) %>%
      filter(!is.na({{ Conc }}))

    # A quantal test with no partial responses carries no slope information,
    # so no model can be fitted however few parameters it has. Interpolating
    # between the bracketing concentrations is the standard treatment, and is
    # substituted for modelling rather than attempted after it fails.
    if (binomial && isTRUE(modelling$interpolate)) {
      responses <- dplyr::pull(result$dataset, {{ Response }})
      control_response <- result$dataset %>%
        dplyr::filter({{ Conc }} == min({{ Conc }}, na.rm = TRUE)) %>%
        dplyr::pull({{ Response }})

      degenerate <- !has_partial_effect(
        responses,
        control = if (length(control_response) > 0) {
          mean(control_response, na.rm = TRUE)
        } else {
          0
        },
        tol = modelling$partial.tol
      )

      if (degenerate) {
        if (!quiet) {
          message(
            "No concentration produced a partial effect; ",
            "estimating by log-linear interpolation instead of fitting."
          )
        }

        result <- interpolateECx(
          dataset = result$dataset,
          Conc = {{ Conc }},
          Response = {{ Response }},
          EDx = modelling$EDx,
          type = modelling$type,
          partial.tol = modelling$partial.tol,
          list_obj = result,
          quiet = quiet
        )

        # Provenance. best_model_name already travels into the condensed
        # output, so this marks the estimate without adding a column.
        result <- assign_field(result, "best_model_name", "interpolated")
        result <- assign_field(result, "model", NULL)
        result <- assign_field(result, "model_df", NULL)

        return(result)
      }
    }

    result <- modelcomp(
      dataset = result$dataset,
      Conc = {{ Conc }},
      Response = {{ Response }},
      N = !!n_quo,
      model_list = modelling$model.list,
      metric = modelling$model.metric,
      type = endpoint$type,
      list_obj = result,
      quiet = quiet
    )

    result <- getECx(
      dataset = result$dataset,
      model = result$model,
      EDx = modelling$EDx,
      level = modelling$level,
      type = modelling$type,
      quiet = quiet,
      list_obj = result,
      interval = modelling$interval,
      EDargs.supplement = modelling$EDargs.supplement
    )

    return(result)
  })

  names(results_list) <- names(split_list)

  if (output$condense) {
    results_list <- condense_results(
      results_list = results_list,
      fields_of_interest = output$sections
    )
  }

  return(results_list)
}
