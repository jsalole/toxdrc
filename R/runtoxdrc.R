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
  IDcols,
  Rep,
  outlier.test = FALSE,
  cv.flag = TRUE,
  cvflag.lvl = 30,
  pctl.test = FALSE,
  pctl.lvl = 10,
  pctl.label = 0,
  ref.label = "Control",
  blank.correction = FALSE,
  blank.label = "Blank",
  normalize.resp = FALSE,
  relative.label = 0,
  avg.resp = TRUE,
  toxic.lvl = 0.7,
  toxic.type = c("rel", "abs"),
  comp.group = 0,
  target.group = NULL,
  non.toxic = c("skip", "continue"),
  model.list = NULL,
  model.metric = c("IC", "Res var", "Lack of fit"),
  EDx = 0.5,
  EDargs = NULL,
  output = c("summary", "full")
) {
  split_list <- split(dataset, interaction(dataset[IDcols], drop = TRUE))

  results_list <- lapply(names(split_list), function(name) {
    subset <- split_list[[name]]
    result <- list(dataset = subset)
    result$ID <- name

    if (outlier.test) {
      result <- removeoutliers(
        dataset = result$dataset,
        Conc = {{ Conc }},
        Response = {{ Response }},
        list_obj = result
      )
    }

    if (cv.flag) {
      result$dataset <- flagCV(
        dataset = result$dataset,
        Conc = {{ Conc }},
        Response = {{ Response }},
        max_val = cvflag.lvl
      )
    }

    if (pctl.test) {
      result <- pctl(
        dataset = result$dataset,
        Conc = {{ Conc }},
        reference_group = ref.label,
        positive_group = pctl.label,
        Response = {{ Response }},
        max_diff = pctl.lvl,
        list_obj = result
      )
    }

    if (blank.correction) {
      result <- blankcorrect(
        dataset = result$dataset,
        Conc = {{ Conc }},
        blank_group = blank.label,
        Response = {{ Response }},
        list_obj = result
      )
      Response <- rlang::sym("c_response")
    }

    if (normalize.resp) {
      result <- normalizeresponse(
        dataset = result$dataset,
        Conc = {{ Conc }},
        reference_group = relative.label,
        Response = {{ Response }},
        list_obj = result
      )
      Response <- rlang::sym("normalized_response")
    }

    if (avg.resp) {
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
      reference_group = comp.group,
      target_group = target.group,
      Response = {{ Response }},
      list_obj = result
    )

    if (!result$effect && non.toxic == "skip") {
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
      model_list = model.list,
      metric = model.metric,
      list_obj = result
    )

    result <- getECx(
      dataset = result$dataset,
      model = result$model,
      EDx = EDx,
      metadata = result$metadata,
      list_obj = result,
      EDargs = EDargs
    )

    return(result)
  })

  #should test if this give the wanted result. It is just a way to avoid a red button call that will likley bottleneck the number of EDx that can be provided.
  names(results_list) <- names(split_list)

  if (output == "summary") {
    summary_df <- dplyr::bind_rows(lapply(results_list, function(x) x$metadata))
    return(summary_df)
  } else {
    return(results_list)
  }
}
