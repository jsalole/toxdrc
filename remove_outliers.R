#' Remove outliers using Grubbs' test
#'
#' This function removes statistical outliers within each concentration group based on Grubbs' test.
#' It returns a list containing the cleaned dataset and removed rows.
#'
#' @param dataset A data frame containing the data to clean.
#' @param Conc Unquoted column name for the concentration variable.
#' @param Response Unquoted column name for the response variable (e.g., RFU).
#' @param list_obj Optional existing list object to update.
#' @param ID Optional ID name to track sample identity.
#'
#' @return A list with elements \code{dataset} (cleaned data) and \code{removed_data} (removed rows).
#' @export
#'
remove_outliers <- function(dataset, Conc, Response, list_obj = NULL) {
  requireNamespace("dplyr", quietly = TRUE)
  requireNamespace("purrr", quietly = TRUE)
  requireNamespace("outliers", quietly = TRUE)
  
  results <- dataset %>%
    dplyr::group_by({{Conc}}) %>%
    dplyr::group_split() %>%
    purrr::map(~ {
      subset_data <- .x
      removed_rows <- tibble::tibble()  # To collect removed rows
      
      if (nrow(subset_data) <= 2) {
        return(list(
          cleaned = subset_data,
          removed = removed_rows
        ))
      }
      
      while (nrow(subset_data) > 2) {
        test_response <- dplyr::pull(subset_data, {{Response}})
        
        test_result <- tryCatch(
          outliers::grubbs.test(test_response),
          error = function(e) {
            warning("Grubbs test failed: ", e$message)
            return(NULL)
          }
        )
        
        if (is.null(test_result) || test_result$p.value >= 0.05) {
          break
        } else {
          z_scores <- scale(test_response)
          outlier_index <- which.max(abs(z_scores))
          
          removed_rows <- dplyr::bind_rows(removed_rows, subset_data[outlier_index, , drop = FALSE])
          subset_data <- subset_data[-outlier_index, , drop = FALSE]
        }
      }
      
      list(
        cleaned = subset_data,
        removed = removed_rows
      )
    })
  
  # After map(), combine everything
  cleaned_all <- purrr::map_dfr(results, "cleaned")
  removed_all <- purrr::map_dfr(results, "removed")
  
  if (is.null(list_obj)) {
    return(list(
      dataset = cleaned_all,
      remove_outliers_removed_data = removed_all
    ))
  } else {
    if (is.list(list_obj)) {
      list_obj$dataset <- cleaned_all
      list_obj$remove_outliers_removed_data <- removed_all
      return(list_obj)
    } else {
      stop("Provided list_obj must be a list.")
    }
  }
}
