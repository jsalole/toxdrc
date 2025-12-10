#' Normalize response variable
#'
#' @description
#' Express a response variable relative to a reference group.
#'
#' @param dataset A dataframe, containing the columns `Conc` and `Response`.
#' @param Conc Bare (unquoted) column name in `dataset` that groups the
#'  `Response` variable.
#' @param reference_group Label used for the group values will be
#'  normalized to. Defaults to 0.
#' @param Response Bare (unquoted) column name in `dataset` containing
#'  the response variable.
#' @param list_obj Optional. List object used for integration with
#'  [runtoxdrc()].
#' @param quiet Logical. Indicates if results should be hidden. Defaults
#'  to FALSE.

#' @returns A modified `dataset` with an additional column,
#'  `normalized response`. If `list_obj` is provided, returns this within
#'   a list as `list_obj$dataset`, along with summary statistics surrounding
#'   the reference group as `list_obj$normalize_response_summary`.
#'
#' @export
#'
#' @examples
#' normalizeresponse(
#'  dataset = toxresult,
#'  Conc = Conc,
#'  Response = RFU
#' )
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
