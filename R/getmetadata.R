#' Generate metadata from a dataframe
#'
#' @description
#' Collects identifying or important values from an expeirmental replicate.
#'
#' @param dataset A dataframe.
#' @param IDcols Optional. Character. Columns given as a vector used in the
#'  identification of data. These columns are preserved in the modified
#'  `dataset` with the first non-blank value. These values should be
#'  identical within observations grouped by `Conc`.
#' @param list_obj Optional. List object used for integration with
#'  [runtoxdrc()].
#' @param quiet Logical. Indicates if results should be hidden. Defaults
#'  to FALSE.

#' @returns A 1 row dataframe of the identifying parameters of an experimental
#'  replicate. If `list_obj` is provided, returns this within a list as
#'  `list_obj$metadata`.
#'
#' @export
#'
#'
getmetadata <- function(dataset, IDcols, list_obj = NULL, quiet = FALSE) {
  metadata <- dplyr::slice(dataset, 1) %>%
    dplyr::select(all_of(IDcols))

  if (!quiet) {
    print(metadata)
  }

  if (!is.null(list_obj)) {
    if (!is.list(list_obj)) {
      stop("Provided list_obj must be a list.")
    }
    list_obj$metadata <- metadata
    return(list_obj)
  }

  return(metadata)
}
