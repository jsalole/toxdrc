#' Check for groups with high CV
#'
#' This function calculates the coefficent of variation (CV) of each of the groups, and flags if 'max_val' is exceeded.
#'
#' @param dataset A dataframe.
#' @param Conc Unquoted column name of 'dataset' that groups observations to calculate CV in (e.g. Conc).
#' @param Response Unquoted column name of 'dataset' with observations to calculate CV in (e.g. RFU).
#' @param max_val The maximum CV before a group is flagged.
#' @param update_dataset Logical. If TRUE, adds rows to supplied 'dataset' to return. If FALSE, dataset is not changed and results are printed.
#'
#' @returns An modified `dataset` with `$CVflag` if update_dataset is set to TRUE. If FALSE, a summary dataframe is printed indicating the CV of each `Conc` supplied with a note if they are flagged.
#'
#'
#' @export
#'
#' @examples
flagCV <- function(dataset, Conc, Response, max_val = 30, update_dataset = FALSE) {
  updated_dataset <- dataset %>%
    dplyr::mutate(
      CV = NA_real_,
      CVflag = ""
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
          CVflag = ifelse(cv_percent > max_val, "*", "")
        )
    }) %>%
    dplyr::ungroup()

  updated_dataset <- as.data.frame(updated_dataset)

  if (!update_dataset) {
    summary_df <- updated_dataset %>%
      dplyr::group_by({{Conc}}) %>%
      dplyr::summarise(
        CV = unique(CV),
        CVflag = unique(CVflag),
        .groups = "drop"
      )
    print(summary_df)
    return(dataset)
  } else {
    return(updated_dataset)
  }
}
