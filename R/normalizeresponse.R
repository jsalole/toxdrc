#' Normalize response variables
#'
#' Score responses as a percentage of a reference group.
#'
#' @param dataset A dataframe.
#' @param Conc Unquoted column name of `dataset` that groups observations (e.g. Conc).
#' @param reference_group Quoted name OR value of reference group to normalize response to (i.e. "ctl", 0)
#' @param Response Unquoted column name of `dataset` with observations (e.g. RFU).
#' @param quiet Logical. Whether EDx results should be printed. Default: FALSE.
#' @param list_obj Optional existing list object, used for integration with `runtoxdrc`.
#' @param quiet Logical. Whether results should be hidden. Default: FALSE.

#' @returns A modified `dataset` with a `normalized_response` column. If `list_obj` provided, updates this within a list. This is primarly for integration wit `runtoxdrc` as it adds `normalize_response_summary` to the growing list to track changes. If no `list_obj` provided, prints the summary and returns the edited `dataset`.
#' @export
#'
#' @examples
#' df <- data.frame(x = rep(1:2, each = 3), y = c(100, 110, 90, 40, 50, 60))
#normalizeresponse(dataset = df, Conc = x, reference_group = 1, Response = y)
#
normalizeresponse <- function(
  dataset,
  Conc,
  reference_group = "0",
  Response,
  list_obj = NULL,
  quiet = FALSE
) {
  dataset <- dataset %>%
    dplyr::mutate(
      {{ Response }} := as.numeric({{ Response }})
    )

  ref_rows <- dataset %>% dplyr::filter({{ Conc }} == reference_group)

  if (nrow(ref_rows) == 0) {
    stop('No reference rows found for normalization.')
  }

  ref_mean <- mean(dplyr::pull(ref_rows, {{ Response }}), na.rm = TRUE)
  ref_sd <- sd(dplyr::pull(ref_rows, {{ Response }}), na.rm = TRUE)

  ref_cv <- if (!is.na(ref_mean) && !is.na(ref_sd) && ref_mean != 0) {
    (ref_sd / ref_mean) * 100
  } else {
    NA_real_
  }

  dataset <- dataset %>%
    dplyr::mutate(
      normalized_response = {{ Response }} / ref_mean
    )

  summary_df <- data.frame(
    ref_mean = ref_mean,
    ref_sd = ref_sd,
    ref_cv = ref_cv
  )

  if (!quiet) {
    print(summary_df)
    print(dataset)
  }
  if (is.null(list_obj)) {
    return(dataset)
  } else {
    if (is.list(list_obj)) {
      list_obj$dataset <- dataset
      list_obj$normalize_response_summary <- summary_df
      return(list_obj)
    } else {
      stop("Provided list_obj must be a list.")
    }
  }
}
