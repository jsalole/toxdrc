#' Check for groups with high CV
#'
#' This function calculates the coefficient of variation (CV) of each of the groups, and flags if 'max_val' is exceeded.
#'
#' @param dataset A dataframe.
#' @param Conc Unquoted column name of 'dataset' that groups observations to calculate CV in (e.g. Conc).
#' @param Response Unquoted column name of 'dataset' with observations to calculate CV in (e.g. RFU).
#' @param max_val The maximum CV before a group is flagged.
#' @param list_obj Optional existing list object, used for integration with `runtoxdrc`.
#' @param quiet Logical. Whether results should be hidden. Default: FALSE.

#'
#' @returns Prints a summary dataframe is printed indicating the CV of each `Conc` supplied with a note if they are flagged. The flag is updated in `dataset`. If list_object is supplied, returns modified `dataset` and test results `CVresults` in this growing list object.
#'
#' @export
#'
#' @examples df <- data.frame(x = rep(1:2, each = 3), y = c(10, 11, 9, 20, 40, 60))
#' flagCV(dataset = df, Conc = x, Response = y, max_val = 30)
#'
flagCV <- function(
  dataset,
  Conc,
  Response,
  max_val = 30,
  list_obj = NULL,
  quiet = FALSE
) {
  updated_dataset <- dataset %>%
    dplyr::group_by({{ Conc }}) %>%
    dplyr::mutate(
      CV = (sd({{ Response }}, na.rm = TRUE) /
        mean({{ Response }}, na.rm = TRUE)) *
        100,
      CVflag = ifelse(CV > max_val, "*", "")
    ) %>%
    dplyr::ungroup()

  updated_dataset <- as.data.frame(updated_dataset)

  # CVflag + CV set to null to avoid following error : flagCV: no visible binding for global variable ‘CV’
  #flagCV: no visible binding for global variable ‘CVflag’
  #Undefined global functions or variables:
  # CV CVflag

  CV <- NULL
  CVflag <- NULL

  summary_df <- updated_dataset %>%
    dplyr::group_by({{ Conc }}) %>%
    dplyr::summarise(
      CV = unique(CV),
      CVflag = unique(CVflag),
      .groups = "drop"
    )

  summary_df <- as.data.frame(summary_df)

  if (!quiet) {
    print(summary_df)
  }

  updated_dataset <- updated_dataset %>%
    dplyr::select(-c("CV"))

  if (!is.null(list_obj)) {
    if (!is.list(list_obj)) {
      stop("Provided list_obj must be a list.")
    }
    list_obj$dataset <- updated_dataset
    list_obj$CVresults <- summary_df
    return(list_obj)
  }
  return(updated_dataset)
}
