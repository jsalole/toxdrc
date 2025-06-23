#' Flag concentrations with high Coefficient of Variation (CV)
#'
#' This function calculates the CV for each concentration group and flags groups exceeding a threshold.
#'
#' @param dataset A data frame containing the data.
#' @param Conc Unquoted column name for the concentration variable.
#' @param Response Unquoted column name for the response variable (e.g., RFU).
#' @param flag_lvl Numeric value; CV percentage above which to flag (default = 30).
#'
#' @return A modified dataset with new columns \code{CV} and \code{Note}.
#' @export
#'
cv_flag <- function(dataset, Conc, Response, flag_lvl = 30) {
  requireNamespace("dplyr", quietly = TRUE)
  requireNamespace("purrr", quietly = TRUE)
  
  dataset <- dataset %>%
    dplyr::mutate(
      CV = NA_real_,
      Note = ""
    ) %>%
    dplyr::group_by({{Conc}}) %>%
    dplyr::group_split() %>%
    purrr::map_dfr(~ {
      subset_data <- .x
      
      mean_val <- mean(dplyr::pull(subset_data, {{Response}}), na.rm = TRUE)
      sd_val <- sd(dplyr::pull(subset_data, {{Response}}), na.rm = TRUE)
      cv_percent <- (sd_val / mean_val) * 100
      
      subset_data %>%
        dplyr::mutate(
          CV = cv_percent,
          Note = ifelse(cv_percent > flag_lvl, "!", "")
        )
    }) %>%
    dplyr::ungroup()
  
  return(dataset)
}

