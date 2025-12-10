#' Check for groups with high CV
#'
#' @description
#' This function calculates the coefficient of variation (CV) of each
#'  of the exposure conditions, and flags them if they exceed a set value.
#'
#' @param dataset dataset A dataframe, containing the columns `Conc` and `Response`.
#' @param Conc Bare (unquoted) column name in `dataset` that groups the
#'  `Response` variable.
#' @param Response Bare (unquoted) column name in `dataset` containing
#'  the response variable.
#' @param max_val Numeric. The percent beyond which CV values are
#'  flagged. Defaults to 30.
#' @param list_obj Optional. List object used for integration with
#'  [runtoxdrc()].
#' @param quiet Logical. Indicates if results should be hidden. Defaults
#'  to FALSE.
#'
#' @returns A modified `dataset` with an additional column, `CVflag`. If
#'  `list_obj` is provided, returns this within a list as
#'  `list_obj$dataset`, along with a summary of the CV results as
#'  `list_obj$CVresults`.
#'
#'
#' @export
#'
#' @examples
#' df <- data.frame(x = rep(1:2, each = 3), y = c(10, 11, 9, 20, 40, 60))
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
