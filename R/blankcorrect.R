#' Blank correct response variable
#'
#' @description
#' `blankcorrect()` subtracts a calculated correction value
#'   from all responses.
#'
#' @param dataset A dataframe, containing the columns `Conc` and `Response`.
#' @param Conc Bare (unquoted) column name in `dataset` that groups the
#'  `Response` variable.
#' @param blank_group Character. Name of the `Conc` level to calculate the
#'  correction value from.
#' @param Response Bare (unquoted) column name in `dataset` containing
#'  the response variable.
#' @param list_obj Optional. List object used for integration with
#'  [runtoxdrc()].
#' @param quiet Logical. Indicates if results should be hidden. Defaults
#'  to FALSE.
#'
#' @returns A modified `dataset` with an additional column, `c_response`. If
#'  `list_obj` is provided, returns this within a list as
#'  `list_obj$dataset`, along with statistics of the correction value as
#'  `list_obj$blank_stats`.
#'
#' @export
#'
#' @examples
#' blankcorrect(
#'      dataset = toxresult,
#'      Conc = Conc,
#'      blank_group = "Blank",
#'      Response = RFU
#'    )
#'
blankcorrect <- function(
  dataset,
  Conc,
  blank_group = "Blank",
  Response,
  list_obj = NULL,
  quiet = FALSE
) {
  dataset <- dataset %>%
    dplyr::mutate(
      {{ Response }} := as.numeric({{ Response }})
    )

  blank_rows <- dataset %>% dplyr::filter({{ Conc }} == blank_group)

  if (nrow(blank_rows) == 0) {
    stop('No blank_group rows found for background correction.')
  }

  blank_mean <- mean(dplyr::pull(blank_rows, {{ Response }}), na.rm = TRUE)
  blank_sd <- sd(dplyr::pull(blank_rows, {{ Response }}), na.rm = TRUE)

  blank_cv <- if (!is.na(blank_mean) && !is.na(blank_sd) && blank_mean != 0) {
    (blank_sd / blank_mean) * 100
  } else {
    NA_real_
  }

  dataset <- dataset %>%
    dplyr::mutate(
      c_response = {{ Response }} - blank_mean
    )

  summary_df <- data.frame(
    blank_mean = blank_mean,
    blank_sd = blank_sd,
    blank_cv = blank_cv
  )

  if (!quiet) {
    print(summary_df)
  }

  if (is.null(list_obj)) {
    return(dataset)
  } else {
    if (is.list(list_obj)) {
      list_obj$dataset <- dataset
      list_obj$blank_stats <- summary_df
      return(list_obj)
    } else {
      stop("Provided list_obj must be a list.")
    }
  }
}
