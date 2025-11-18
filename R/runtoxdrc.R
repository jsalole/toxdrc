#' A pipeline for dose response curve modelling and analysis.
#'
#' @param dataset A dataframe.
#' @param Conc Unquoted column name of `dataset` of independent variable.
#' @param Response Unquoted column name of `dataset` of dependant variable.
#' @param IDcols Optional. Columns given as a vector `c("column1", "column2")` used in the identification of data or important metadata. These columns are preserved in the returned dataset with the first value (not NA, NULL, or blank) of these columns within each level of `Conc`. Examples of this are metric type (mortality, indicator name), test information (well plate size, test time, test ID). These values should be identical within a testing group.
#' @param quiet Logical. Indicates if intermediate results are printed. Default: False.
#' @param qc Quality control and filtering options. See `toxdrc_qc()` for defaults.
#' @param normalization Normalization options. See `toxdrc_normalization()`.
#' @param toxicity Toxicity threshold and response-level options. See `toxdrc_toxicity()` for defaults
#' @param modelling Model selection, fitting criteria, and EDx calculation options. See `toxdrc_modelling()` for defaults.
#'
#' @importFrom dplyr pull filter mutate
#'
#' @export
#'
#' @seealso [config_runtoxdrc()]
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
  modelling = toxdrc_modelling()
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

    toxic.direction = "above",
    toxic.lvl = 50,
    toxic.type = "abs"


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

  #should test if this give the wanted result. It is just a way to avoid a red button call that will likley bottleneck the number of EDx that can be provided.
  names(results_list) <- names(split_list)

  return(results_list)
}
