#' Generate metadata from a dataframe
#'
#' @description
#' Collects identifying or important values from an experimental replicate.
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
#'
#' @returns A 1 row dataframe of the identifying parameters of an experimental
#'  replicate. If `list_obj` is provided, returns this within a list as
#'  `list_obj$metadata`.
#'
#' @export
#'
#'
getmetadata <- function(
  dataset,
  IDcols = NULL,
  list_obj = NULL,
  quiet = FALSE
) {
  check_dataset(dataset)
  # NULL is allowed: runtoxdrc() may be run without IDcols, in which case the
  # metadata frame simply has no columns.
  check_idcols(dataset, IDcols)
  check_flag(quiet, "quiet")
  check_list_obj(list_obj)

  metadata <- dplyr::slice(dataset, 1) %>%
    dplyr::select(all_of(IDcols))

  if (!quiet) {
    print(metadata)
  }

  if (!is.null(list_obj)) {
    list_obj$metadata <- metadata
    return(list_obj)
  }

  return(metadata)
}
