#' Blank correct a response variable.
#'
#' @param dataset A dataframe.
#' @param Conc Unquoted column name of 'dataset' that groups observations.
#' @param blank_group Quoted name of the Blank group, e.g. ("Blank").
#' @param Response Unquoted column name of the response variable to be adjusted.
#' @param list_obj Optional existing list object, used for integration with `runtoxdrc`.
#'
#' @returns A modified dataframe with an additional column, `c_response`.
#' @export
#'
#' @examples
#' blankcorrect(
#'      toxresult,
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
