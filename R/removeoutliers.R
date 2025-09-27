#' Remove outliers iteratively using Grubbs' test.
#'
#' This function removes statistical outliers from each testing group by iteratively applying Grubbs' test.
#'
#' @param dataset A dataframe.
#' @param Conc Unquoted column name of 'dataset' that groups observations to determine outliers (e.g. Conc).
#' @param Response Unquoted column name of 'dataset' with observations to determine outliers in (e.g. RFU).
#' @param list_obj Optional existing list object, used for integration with 'runtoxdrc'.
#'
#' @returns An modified 'dataset' with outliers removed. If 'list_obj' provided, updates this within a list; primarly for code 'runtoxdrc' and adds '$removed_outliers' to the list to track changes. If no 'list_obj' provided, prints the removed rows and returns the edited 'dataset'.
#' @export
#'
#' @examples
#'
#' df <- data.frame(x = rep(1:2, each = 3),y = c(3, 5, 7, 3, 4, 30))
#' removeoutliers(dataset = df, Conc = x, Response = y)

removeoutliers <- function(dataset, Conc, Response, list_obj = NULL) {

  results <- dataset %>%
    dplyr::group_by({{Conc}}) %>%
    dplyr::group_split() %>%
    purrr::map(~ {
      subset_data <- .x
      removed_rows <- data.frame()  # To collect removed rows

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
  cleaned_all <- as.data.frame(purrr::map_dfr(results, "cleaned"))
  removed_all <- as.data.frame(purrr::map_dfr(results, "removed"))

  if (is.null(list_obj)) {
    print("Removed Rows")
    print(removed_all)
    dataset = cleaned_all
    return(dataset)
  } else {
    if (is.list(list_obj)) {
      list_obj$dataset <- cleaned_all
      list_obj$removed_outliers <- removed_all
      return(list_obj)
    } else {
      stop("Provided list_obj must be a list.")
    }
  }
}
