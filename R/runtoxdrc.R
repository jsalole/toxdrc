#' A pipeline for dose response curve modelling and analysis.
#'
#'
#' @importFrom dplyr pull filter mutate
#'
#' @export
#'
runtoxdrc <- function(
  dataset,
  Conc,
  Response,
  IDcols = NULL,
  qc = drc_qc(),
  normalization = drc_normalization(),
  toxicity = drc_toxicity(),
  modeling = drc_modeling()
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
        list_obj = result
      )
    }

    if (qc$cv.flag) {
      result$dataset <- flagCV(
        dataset = result$dataset,
        Conc = {{ Conc }},
        Response = {{ Response }},
        max_val = qc$cvflag.lvl
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
        list_obj = result
      )
    }

    if (normalization$blank.correction) {
      result <- blankcorrect(
        dataset = result$dataset,
        Conc = {{ Conc }},
        blank_group = normalization$blank.label,
        Response = {{ Response }},
        list_obj = result
      )
      Response <- rlang::sym("c_response")
    }

    if (normalization$normalize.resp) {
      result <- normalizeresponse(
        dataset = result$dataset,
        Conc = {{ Conc }},
        reference_group = normalization$relative.label,
        Response = {{ Response }},
        list_obj = result
      )
      Response <- rlang::sym("normalized_response")
    }

    if (qc$avg.resp) {
      result <- averageresponse(
        dataset = result$dataset,
        Conc = {{ Conc }},
        Response = {{ Response }},
        IDcols = IDcols,
        list_obj = result
      )
      Response <- rlang::sym("mean_response")
    }

    result <- checktoxicity(
      dataset = result$dataset,
      Conc = {{ Conc }},
      reference_group = toxicity$comp.group,
      target_group = toxicity$target.group,
      effect = toxicity$toxic.lvl,
      type = toxicity$type,
      direction = toxicity$toxic.direction,
      Response = {{ Response }},
      list_obj = result
    )

    if (!result$effect) {
      result <- getmetadata(
        dataset = result$dataset,
        IDcols = IDcols,
        list_obj = result
      )
      return(result)
    }

    result$nonnumericgroups <- result$dataset %>%
      filter(is.na(suppressWarnings(as.numeric({{ Conc }})))) %>%
      pull({{ Conc }}) %>%
      unique()

    print(result$nonnumericgroups)

    result$dataset <- result$dataset %>%
      mutate({{ Conc }} := suppressWarnings(as.numeric({{ Conc }}))) %>%
      filter(!is.na({{ Conc }}))

    result <- modelcomp(
      dataset = result$dataset,
      Conc = {{ Conc }},
      Response = {{ Response }},
      model_list = modelling$model.list,
      metric = modelling$model.metric,
      list_obj = result
    )

    result <- getECx(
      dataset = result$dataset,
      model = result$model,
      EDx = modelling$EDx,
      metadata = result$metadata,
      list_obj = result,
      EDargs = modelling$EDargs
    )

    return(result)
  })

  #should test if this give the wanted result. It is just a way to avoid a red button call that will likley bottleneck the number of EDx that can be provided.
  names(results_list) <- names(split_list)

  return(results_list)
}
