#' Normalize a response variable relative to control
#'
#' This function normalizes the specified response variable by the mean response at Conc = 0 (control samples).
#' Also returns the control mean, SD, and CV (%).
#'
#' @param dataset A data frame containing the data.
#' @param Conc Unquoted column name for concentration (e.g., Conc).
#' @param Response Unquoted column name for the response variable to normalize (e.g., RFU).
#' @param list_obj Optional existing list object to update.
#'
#' @return A list containing:
#' \describe{
#'   \item{dataset}{The dataset with a new \code{normalized_response} column.}
#'   \item{normalize_response_summary}{Summary tibble of control mean, SD, and CV.}
#' }
#' @export
#'
normalize_response <- function(dataset, Conc, Response, list_obj = NULL) {
  requireNamespace("dplyr", quietly = TRUE)
  
  dataset <- dataset %>%
    dplyr::mutate(
      {{Response}} := as.numeric({{Response}})
    )
  
  ctrl0_rows <- dataset %>% dplyr::filter({{Conc}} == 0)
  
  if (nrow(ctrl0_rows) == 0) {
    stop('No "Control" (Conc = 0) rows found for normalization.')
  }
  
  ctl0_mean <- mean(dplyr::pull(ctrl0_rows, {{Response}}), na.rm = TRUE)
  ctl0_sd <- sd(dplyr::pull(ctrl0_rows, {{Response}}), na.rm = TRUE)
  
  ctl0_cv <- if (!is.na(ctl0_mean) && !is.na(ctl0_sd) && ctl0_mean != 0) {
    (ctl0_sd / ctl0_mean) * 100
  } else {
    NA_real_
  }
  
  dataset <- dataset %>%
    dplyr::mutate(
      normalized_response = {{Response}} / ctl0_mean
    )
  
  summary_df <- tibble::tibble(
    ctl0_mean = ctl0_mean,
    ctl0_sd = ctl0_sd,
    ctl0_cv = ctl0_cv
  )
  
  if (is.null(list_obj)) {
    return(list(
      dataset = dataset,
      normalize_response_summary = summary_df
    ))
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

