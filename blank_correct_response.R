#' Blank correct a response variable
#'
#' This function subtracts the mean Blank response from the specified Response variable.
#'
#' @param dataset A data frame containing the data.
#' @param Conc Unquoted column name for concentration (e.g., Conc).
#' @param Response Unquoted column name for the raw response variable (e.g., RFU).
#' @param list_obj Optional existing list object to update.
#'
#' @return A list containing:
#' \describe{
#'   \item{dataset}{The dataset with a new \code{c_response} column.}
#'   \item{blank_correct_summary}{Summary tibble of Blank mean and SD.}
#' }
#' @export
#'
blank_correct_response <- function(dataset, Conc, Response, list_obj = NULL) {
  requireNamespace("dplyr", quietly = TRUE)
  
  dataset <- dataset %>%
    dplyr::mutate(
      {{Response}} := as.numeric({{Response}})
    )
  
  blank_rows <- dataset %>% dplyr::filter({{Conc}} == "Blank")
  
  if (nrow(blank_rows) == 0) {
    stop('No "Blank" rows found for background correction.')
  }
  
  blank_mean <- mean(dplyr::pull(blank_rows, {{Response}}), na.rm = TRUE)
  blank_sd <- sd(dplyr::pull(blank_rows, {{Response}}), na.rm = TRUE)
  
  blank_cv <- if (!is.na(blank_mean) && !is.na(blank_sd) && blank_mean != 0) {
    (blank_sd / blank_mean) * 100
  } else {
    NA_real_
  }
  
  # Remove Control and Blank samples for moving forward
  dataset <- dataset %>%
    dplyr::filter(!{{Conc}} %in% c("Control", "Blank"))
  
  dataset <- dataset %>%
    dplyr::mutate(
      c_response = {{Response}} - blank_mean
    )
  
  summary_df <- tibble::tibble(
    blank_mean = blank_mean,
    blank_sd = blank_sd,
    blank_cv = blank_cv
  )
  
  if (is.null(list_obj)) {
    return(list(
      dataset = dataset,
      blank_correct_summary = summary_df
    ))
  } else {
    if (is.list(list_obj)) {
      list_obj$dataset <- dataset
      list_obj$blank_correct_summary <- summary_df
      return(list_obj)
    } else {
      stop("Provided list_obj must be a list.")
    }
  }
}

