#' Average response variable
#'
#'  Average the response variable by group or exposure condition.
#' @param dataset A dataframe.
#' @param Conc Unquoted column name of `dataset` that groups observations (e.g. Conc).
#' @param Response Unquoted column name of `dataset` with observations (e.g. RFU).
#' @param quiet Logical. Whether results should be hidden. Default: FALSE.
#' @param IDcols Optional. Columns given as a vector `c("column1", "column2")` used in the identification of data or important metadata. These columns are preserved in the returned dataset with the first value (not NA, NULL, or blank) of these columns within each level of `Conc`. Examples of this are metric type (mortality, indicator name), test information (well plate size, test time, test ID). These values should be identical within a testing group.
#' @param list_obj Optional existing list object, used for integration with `runtoxdrc`.
#'
#' @returns A modified dataset with one row for each level of `Conc`. The averaged response is given for each level, in addition to the value. If `list_obj` provided, returns this within a list. This is primarly for integration wit `runtoxdrc` as it saves the `pre_average_dataset` to the growing list to track changes. If no `list_obj` provided it returns the edited `dataset`.
#'
#'
#'@importFrom dplyr all_of
#' @export
#'
#' @examples
#' averageresponse(
#'      toxresult,
#'      Conc = Conc,
#'      Response = RFU,
#'      IDcols = c("TestID", "Test_Number", "Dye", "Type", "Replicate"),
#'      quiet = FALSE
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
