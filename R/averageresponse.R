#' Average response variable
#'
#' @description
#' `averageresponse()` averages a given response variable by the
#'  experimental group, such as concentration or exposure length.
#'
#' @param dataset A dataframe, containing the columns `Conc` and `Response`.
#' @param Conc Bare (unquoted) column name in `dataset` that groups the
#'  `Response` variable.
#' @param Response Bare (unquoted) column name in `dataset` containing
#'  the response variable.
#' @param IDcols Character. Columns given as a vector used in the
#'  identification of data. These columns are preserved in the modified
#'  `dataset` with the first non-blank value. These values should be
#'  identical within observations grouped by `Conc`.
#' @param list_obj Optional. List object used for integration with
#'  [runtoxdrc()].
#' @param quiet Logical. Indicates if results should be hidden. Defaults
#'  to FALSE.
#'
#' @returns A collapsed `dataset` with one row for each level of `Conc`.
#'  If `list_obj` is provided, returns this within a list as
#'  `list_obj$dataset`, along with an unmodified copy as
#'  `list_obj$pre_average_dataset`.
#'
#'@importFrom dplyr all_of
#'
#' @export
#'
#' @examples
#' averageresponse(
#'      dataset = toxresult,
#'      Conc = Conc,
#'      Response = RFU,
#'      IDcols = c("TestID", "Test_Number", "Dye", "Type", "Replicate"),
#'    )
#'
averageresponse <- function(
  dataset,
  Conc,
  Response,
  IDcols = NULL,
  list_obj = NULL,
  quiet = FALSE
) {
  pre_average_dataset <- dataset

  # The specified columns are checked to see if they exist and warns user if any are not found. Moves forward with valid column names.
  if (!is.null(IDcols)) {
    missing_cols <- IDcols[!IDcols %in% names(dataset)]
    if (length(missing_cols) > 0) {
      warning(
        "Some specified IDcols not found in dataset: ",
        paste(missing_cols, collapse = ", ")
      )
      IDcols <- IDcols[IDcols %in% names(dataset)] # Only keep valid columns
    }
  }

  # Groups dataset by $Conc, and averages $Response. Collapses to 1 row per concentration level, and preserves first non-NA value from specified columns.

  averaged_dataset <- dataset %>%
    dplyr::group_by({{ Conc }}) %>%
    dplyr::summarise(
      mean_response = mean({{ Response }}, na.rm = TRUE),
      dplyr::across(
        all_of(IDcols),
        ~ first_nonmissing(.),
        .names = "{.col}"
      ),
      .groups = "drop"
    )

  averaged_dataset <- as.data.frame(averaged_dataset)

  if (!quiet) {
    print(averaged_dataset)
  }

  # Output as a list, either a new list, or attached to supplied list_obj
  if (is.null(list_obj)) {
    return(as.data.frame(averaged_dataset))
  } else {
    if (is.list(list_obj)) {
      list_obj$dataset <- as.data.frame(averaged_dataset)
      list_obj$pre_average_dataset <- as.data.frame(pre_average_dataset)
      return(list_obj)
    } else {
      stop("Provided list_obj must be a list.")
    }
  }
}
