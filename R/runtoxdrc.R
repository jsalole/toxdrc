#' Point estmation pipeline
#'
#' @description
#' `runtoxdrc()` is the pipeline for function in the toxdrc package. This
#'  function allows the automated analysis of large datasets, while
#'  maintaining a consistent process for each suset of data.
#'
#' @param dataset A dataframe, containing the columns `Conc` and `Response`.
#' @param Conc Bare (unquoted) column name in `dataset` that groups the
#'  `Response` variable.
#' @param Response Bare (unquoted) column name in `dataset` containing
#'  the response variable.
#' @param IDcols Optional. Character. Columns given as a vector used in the
#'  identification of data. These columns are preserved in the modified
#'  `dataset` with the first non-blank value. These values should be
#'  identical within observations grouped by `Conc`.
#' @param quiet Logical. Indicates if results should be hidden. Defaults
#'  to FALSE.
#' @param qc Quality control and filtering options. See [toxdrc_qc()]
#'  for more detail and defaults.
#' @param normalization Normalization options. See [toxdrc_normalization()]
#'  for more detail and defaults.
#' @param toxicity Toxicity threshold and response-level options. See
#'  [toxdrc_toxicity()] for more detail and defaults.
#' @param modelling Model selection, fitting criteria, and EDx calculation
#'  options. See [toxdrc_modelling()] for more detail and defaults.
#' @param output Settings for output. See [toxdrc_output()] for more detail
#'  and defaults.
#'
#' @importFrom dplyr pull filter mutate
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
#' @seealso [config_runtoxdrc()] for configuration settings of the pipeline.
#'
runtoxdrc <- function(
  dataset,
  Conc,
  Response,
  IDcols = NULL,
  quiet = FALSE,
  qc = toxdrc_qc(),
  normalization = toxdrc_normalization(),
  toxicity = toxdrc_toxicity(),
  modelling = toxdrc_modelling(),
  output = toxdrc_output()
) {
  split_list <- split(dataset, interaction(dataset[IDcols], drop = TRUE))

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
        IDcols = IDcols,
        list_obj = result,
        quiet = quiet
      )
      Response <- rlang::sym("mean_response")
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

    result <- modelcomp(
      dataset = result$dataset,
      Conc = {{ Conc }},
      Response = {{ Response }},
      model_list = modelling$model.list,
      metric = modelling$model.metric,
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
