#' Condense results
#'
#' Summarize the nested list returned by [runtoxdrc()] into a single data
#'  frame, one row per point estimate.
#'
#' Entries that produced point estimates contribute one row per row of their
#'  `effectmeasure` frame. Entries that did not, because no effect was
#'  detected or no model could be fitted, contribute a single row with the
#'  point-estimate columns set to NA.
#'
#' Both cases must produce the same columns. Expanding `effectmeasure` into its
#'  own columns for one entry while emitting a literal `effectmeasure` column
#'  for another gives `rbind()` mismatched frames and an error, so the column
#'  template is resolved once up front rather than per entry.
#'
#' @param results_list The list of per-subset results from [runtoxdrc()].
#' @param fields_of_interest Character. Fields to carry into the summary. The
#'  special value `"effectmeasure"` is expanded into its own columns.
#'
#' @returns A data frame with one row per point estimate.
#'
#' @noRd
#'
condense_results <- function(results_list, fields_of_interest) {
  # Column template for the expanded effectmeasure block, taken from the first
  # entry that has one. NULL when no entry produced estimates, in which case
  # "effectmeasure" stays a single NA column.
  ecx_template <- NULL

  for (entry in results_list) {
    ecx <- entry[["effectmeasure"]]
    if (is.data.frame(ecx) && ncol(ecx) > 0) {
      ecx_template <- names(ecx)
      break
    }
  }

  # Reduce a field to something that fits in a single cell.
  flatten_field <- function(value) {
    if (is.null(value) || length(value) == 0) {
      return(NA)
    }
    if (length(value) == 1) {
      return(value)
    }
    paste(value, collapse = ",")
  }

  # Build one output row. `ecx_row` is a single row of effectmeasure, or NULL
  # to emit NA placeholders for the point-estimate columns.
  build_row <- function(entry, ecx_row) {
    row_values <- list()

    for (field in fields_of_interest) {
      if (identical(field, "effectmeasure")) {
        if (is.null(ecx_template)) {
          row_values[[field]] <- NA
        } else if (is.null(ecx_row)) {
          row_values[ecx_template] <- NA
        } else {
          row_values <- c(row_values, as.list(ecx_row))
        }
        next
      }

      if (!(field %in% names(entry))) {
        row_values[[field]] <- NA
        next
      }

      row_values[[field]] <- flatten_field(entry[[field]])
    }

    as.data.frame(row_values, check.names = FALSE, stringsAsFactors = FALSE)
  }

  condensed_results_list <- lapply(results_list, function(entry) {
    ecx <- entry[["effectmeasure"]]

    if (is.data.frame(ecx) && nrow(ecx) > 0) {
      row_blocks <- lapply(
        seq_len(nrow(ecx)),
        function(i) build_row(entry, ecx[i, , drop = FALSE])
      )
      return(do.call(rbind, row_blocks))
    }

    build_row(entry, NULL)
  })

  condensed_results_list <- Filter(
    function(x) !is.null(x) && nrow(x) > 0,
    condensed_results_list
  )

  if (length(condensed_results_list) == 0) {
    return(data.frame())
  }

  do.call(rbind, condensed_results_list)
}
