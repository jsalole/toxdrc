#' Collects identifying values of an expeirmental replicate.
#'
#' @param dataset A dataframe.
#' @param IDcols Optional. Columns given as a vector `c("column1", "column2")` used in the identification of data or important metadata. These columns are preserved in the returned dataset with the first value (not NA, NULL, or blank) of these columns within each level of `Conc`. Examples of this are metric type (mortality, indicator name), test information (well plate size, test time, test ID). These values should be identical within a testing group.
#' @param list_obj Optional existing list object, used for integration with `runtoxdrc`.
#'
#' @returns A 1 row dataframe of the identifying parameters of an experimental replicate. If list_obj is provided, attaches this to list_obj$metadata.
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
