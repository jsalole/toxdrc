# ============================================================
# Shared argument validation helpers
# ============================================================
#
# These are internal. They exist so that every exported function reports the
# same class of mistake the same way, and so that tests can match on a
# condition class rather than on error wording.
#
# Every condition inherits from "toxdrc_error", with a more specific class
# naming the kind of problem (e.g. "toxdrc_error_missing_column").

#' Raise a classed toxdrc error
#'
#' @param message Character vector. The first element is the headline; named
#'  elements are formatted as bullets by rlang.
#' @param class Character. Specific condition class, without the `toxdrc_`
#'  prefix.
#' @param ... Additional data stored on the condition.
#'
#' @noRd
#'
toxdrc_abort <- function(message, class, ...) {
  rlang::abort(
    message = message,
    class = c(paste0("toxdrc_error_", class), "toxdrc_error"),
    ...
  )
}


#' Check that a dataset is a usable data frame
#'
#' @param dataset The object to check.
#' @param arg Character. Argument name to report.
#'
#' @noRd
#'
check_dataset <- function(dataset, arg = "dataset") {
  if (missing(dataset) || is.null(dataset)) {
    toxdrc_abort(
      c(
        paste0("`", arg, "` is required."),
        "i" = "Supply a data frame in long format, one row per observation."
      ),
      class = "missing_dataset"
    )
  }

  if (!is.data.frame(dataset)) {
    toxdrc_abort(
      c(
        paste0("`", arg, "` must be a data frame."),
        "x" = paste0("Received an object of class <", class(dataset)[1], ">."),
        "i" = "Matrices and lists must be converted first, e.g. with as.data.frame()."
      ),
      class = "bad_dataset"
    )
  }

  if (nrow(dataset) == 0) {
    toxdrc_abort(
      c(
        paste0("`", arg, "` has no rows."),
        "i" = "Check whether an earlier filtering step removed every observation."
      ),
      class = "empty_dataset"
    )
  }

  invisible(dataset)
}


#' Check that a tidy-selected column exists in a dataset
#'
#' Only checks when the supplied expression is a plain column name. Anything
#' more complex (`RFU * 2`, `.data$RFU`) is left alone, since it cannot be
#' matched against `names(dataset)` without evaluating it.
#'
#' @param dataset A data frame.
#' @param quo A quosure, normally captured with `rlang::enquo()`.
#' @param arg Character. Argument name to report.
#'
#' @returns Invisibly, the column name, or NULL when the expression was not a
#'  plain name.
#'
#' @noRd
#'
check_column <- function(dataset, quo, arg) {
  nm <- rlang::as_label(quo)

  # An omitted argument labels as "" or "<empty>"; catch that before the
  # pattern test below, which would otherwise skip it as unresolvable.
  if (!nzchar(nm) || identical(nm, "NULL") || identical(nm, "<empty>")) {
    toxdrc_abort(
      c(
        paste0("`", arg, "` is required."),
        "i" = "Give the column name unquoted, e.g. Response = RFU."
      ),
      class = "missing_column"
    )
  }

  # Only a bare column name can be checked against names(dataset).
  if (!grepl("^[A-Za-z.][A-Za-z0-9._]*$", nm)) {
    return(invisible(NULL))
  }

  if (!nm %in% names(dataset)) {
    toxdrc_abort(
      c(
        paste0("Column \"", nm, "\" (given as `", arg, "`) was not found."),
        "x" = paste0(
          "Available columns: ",
          paste(names(dataset), collapse = ", "),
          "."
        ),
        "i" = "Column names are case sensitive."
      ),
      class = "missing_column",
      column = nm
    )
  }

  invisible(nm)
}


#' Check that IDcols name real columns
#'
#' @param dataset A data frame.
#' @param IDcols Character vector, or NULL.
#' @param arg Character. Argument name to report.
#' @param required Logical. Whether NULL is an error.
#'
#' @noRd
#'
check_idcols <- function(dataset, IDcols, arg = "IDcols", required = FALSE) {
  if (is.null(IDcols)) {
    if (required) {
      toxdrc_abort(
        c(
          paste0("`", arg, "` is required."),
          "i" = "Supply a character vector of identifying column names."
        ),
        class = "missing_idcols"
      )
    }
    return(invisible(NULL))
  }

  if (!is.character(IDcols)) {
    toxdrc_abort(
      c(
        paste0("`", arg, "` must be a character vector of column names."),
        "x" = paste0("Received an object of class <", class(IDcols)[1], ">."),
        "i" = "Quote the names, e.g. IDcols = c(\"Replicate\", \"Dye\")."
      ),
      class = "bad_idcols"
    )
  }

  missing_cols <- setdiff(IDcols, names(dataset))

  if (length(missing_cols) > 0) {
    toxdrc_abort(
      c(
        paste0(
          "`", arg, "` names ", length(missing_cols),
          " column(s) not present in the dataset."
        ),
        "x" = paste0("Not found: ", paste(missing_cols, collapse = ", "), "."),
        "i" = paste0(
          "Available columns: ",
          paste(names(dataset), collapse = ", "),
          "."
        )
      ),
      class = "missing_idcols_columns",
      missing = missing_cols
    )
  }

  invisible(IDcols)
}


#' Check that a grouping label is present in the grouping column
#'
#' Catches the common case of a reference, blank, or control label that does
#' not match how the level is spelled in the data, which otherwise propagates
#' silently as NaN.
#'
#' @param dataset A data frame.
#' @param quo Quosure for the grouping column.
#' @param value The label to look for.
#' @param arg Character. Argument name to report.
#'
#' @noRd
#'
check_group <- function(dataset, quo, value, arg) {
  if (is.null(value)) {
    return(invisible(NULL))
  }

  levels_present <- unique(dplyr::pull(dataset, !!quo))
  found <- as.character(value) %in% as.character(levels_present)

  if (!all(found)) {
    absent <- as.character(value)[!found]
    all_levels <- as.character(unique(levels_present))
    shown <- all_levels[seq_len(min(20L, length(all_levels)))]

    toxdrc_abort(
      c(
        paste0(
          "`", arg, "` value(s) not found in the grouping column: ",
          paste0("\"", absent, "\"", collapse = ", "),
          "."
        ),
        "i" = paste0(
          "Levels present: ",
          paste0("\"", shown, "\"", collapse = ", "),
          if (length(all_levels) > 20) ", ..." else "",
          "."
        ),
        "i" = "Labels are compared as text, so 0 and \"0\" both match, but \"control\" and \"Control\" do not."
      ),
      class = "missing_group",
      group = absent
    )
  }

  invisible(value)
}


#' Check a numeric scalar, optionally within bounds
#'
#' @param x The value to check.
#' @param arg Character. Argument name to report.
#' @param min,max Optional inclusive bounds.
#' @param allow_null Logical. Whether NULL passes.
#' @param allow_vector Logical. Whether length > 1 passes.
#'
#' @noRd
#'
check_number <- function(
  x,
  arg,
  min = NULL,
  max = NULL,
  allow_null = FALSE,
  allow_vector = FALSE
) {
  if (is.null(x)) {
    if (allow_null) {
      return(invisible(NULL))
    }
    toxdrc_abort(
      paste0("`", arg, "` must be a number, not NULL."),
      class = "bad_number"
    )
  }

  if (!is.numeric(x)) {
    toxdrc_abort(
      c(
        paste0("`", arg, "` must be numeric."),
        "x" = paste0("Received an object of class <", class(x)[1], ">.")
      ),
      class = "bad_number"
    )
  }

  if (!allow_vector && length(x) != 1) {
    toxdrc_abort(
      c(
        paste0("`", arg, "` must be a single number."),
        "x" = paste0("Received a vector of length ", length(x), ".")
      ),
      class = "bad_number"
    )
  }

  if (any(is.na(x))) {
    toxdrc_abort(
      paste0("`", arg, "` must not be NA."),
      class = "bad_number"
    )
  }

  if (!is.null(min) && any(x < min)) {
    toxdrc_abort(
      c(
        paste0("`", arg, "` must be at least ", min, "."),
        "x" = paste0("Received ", paste(x[x < min], collapse = ", "), ".")
      ),
      class = "out_of_range"
    )
  }

  if (!is.null(max) && any(x > max)) {
    toxdrc_abort(
      c(
        paste0("`", arg, "` must be at most ", max, "."),
        "x" = paste0("Received ", paste(x[x > max], collapse = ", "), ".")
      ),
      class = "out_of_range"
    )
  }

  invisible(x)
}


#' Check a length-one logical
#'
#' @param x The value to check.
#' @param arg Character. Argument name to report.
#'
#' @noRd
#'
check_flag <- function(x, arg) {
  if (!is.logical(x) || length(x) != 1 || is.na(x)) {
    toxdrc_abort(
      c(
        paste0("`", arg, "` must be TRUE or FALSE."),
        "x" = paste0(
          "Received ",
          if (is.null(x)) "NULL" else paste0("<", class(x)[1], "> of length ", length(x)),
          "."
        )
      ),
      class = "bad_flag"
    )
  }

  invisible(x)
}


#' Check an optional list_obj argument
#'
#' @param list_obj The value to check.
#' @param arg Character. Argument name to report.
#'
#' @noRd
#'
check_list_obj <- function(list_obj, arg = "list_obj") {
  if (is.null(list_obj)) {
    return(invisible(NULL))
  }

  if (!is.list(list_obj) || is.data.frame(list_obj)) {
    toxdrc_abort(
      c(
        paste0("`", arg, "` must be a list."),
        "x" = paste0("Received an object of class <", class(list_obj)[1], ">."),
        "i" = paste0(
          "`", arg,
          "` is used to accumulate pipeline results and is normally supplied ",
          "by runtoxdrc()."
        )
      ),
      class = "bad_list_obj"
    )
  }

  invisible(list_obj)
}


#' Reject a pipeline step that cannot be applied to quantal data
#'
#' Several preprocessing steps assume a continuous response measured on an
#' unbounded scale. Applied to proportions they are either meaningless or
#' actively wrong, so they are refused rather than silently skipped.
#'
#' @param requested Logical. Whether the step was asked for.
#' @param step Character. The configuration setting that requested it.
#' @param why Character. Why it does not apply.
#' @param instead Character. What to do instead.
#'
#' @noRd
#'
reject_for_binomial <- function(requested, step, why, instead) {
  if (!isTRUE(requested)) {
    return(invisible(NULL))
  }

  toxdrc_abort(
    c(
      paste0("`", step, "` cannot be used with quantal data."),
      "x" = why,
      "i" = instead,
      "i" = "Set endpoint = toxdrc_endpoint(type = \"continuous\") if the response is not a proportion."
    ),
    class = "step_not_applicable",
    step = step
  )
}


#' Check that a column holds usable proportions
#'
#' @param dataset A data frame.
#' @param quo Quosure for the response column.
#' @param arg Character. Argument name to report.
#'
#' @noRd
#'
check_proportion <- function(dataset, quo, arg = "Response") {
  values <- dplyr::pull(dataset, !!quo)
  values <- suppressWarnings(as.numeric(values))
  observed <- values[!is.na(values)]

  if (length(observed) == 0) {
    toxdrc_abort(
      c(
        paste0("`", arg, "` holds no numeric values."),
        "i" = "Quantal responses must be the affected fraction of each group."
      ),
      class = "bad_proportion"
    )
  }

  if (any(observed < 0) || any(observed > 1)) {
    outside <- observed[observed < 0 | observed > 1]

    toxdrc_abort(
      c(
        paste0("`", arg, "` must be a proportion between 0 and 1."),
        "x" = paste0(
          length(outside), " value(s) outside that range, including ",
          paste(utils_head(outside, 3), collapse = ", "),
          "."
        ),
        "i" = if (any(outside > 1) && max(outside) <= 100) {
          "Values look like percentages; divide by 100, or supply counts with response.type = \"count\"."
        } else {
          "Supply counts with response.type = \"count\" if this column is the number affected."
        }
      ),
      class = "bad_proportion"
    )
  }

  invisible(values)
}


#' Check that a column holds usable group sizes
#'
#' @param dataset A data frame.
#' @param quo Quosure for the counts column.
#' @param arg Character. Argument name to report.
#'
#' @noRd
#'
check_counts <- function(dataset, quo, arg = "N") {
  values <- dplyr::pull(dataset, !!quo)
  values <- suppressWarnings(as.numeric(values))
  observed <- values[!is.na(values)]

  if (length(observed) == 0) {
    toxdrc_abort(
      c(
        paste0("`", arg, "` holds no numeric values."),
        "i" = "This column must give the number of organisms in each group."
      ),
      class = "bad_counts"
    )
  }

  if (any(observed <= 0)) {
    toxdrc_abort(
      c(
        paste0("`", arg, "` must be a positive group size."),
        "x" = paste0(
          sum(observed <= 0),
          " value(s) are zero or negative."
        ),
        "i" = "A group with no organisms carries no information and cannot be weighted."
      ),
      class = "bad_counts"
    )
  }

  if (any(abs(observed - round(observed)) > .Machine$double.eps^0.5)) {
    toxdrc_abort(
      c(
        paste0("`", arg, "` must be whole numbers."),
        "i" = "Group sizes are counts of organisms, so fractional values indicate the wrong column."
      ),
      class = "bad_counts"
    )
  }

  invisible(values)
}


#' First n elements, without depending on utils
#'
#' @noRd
#'
utils_head <- function(x, n) {
  x[seq_len(min(n, length(x)))]
}


#' Check a runtoxdrc configuration argument
#'
#' Catches the common mistake of passing a bare value where a configuration
#' list is expected, e.g. `qc = TRUE` instead of `qc = toxdrc_qc(...)`, and
#' the mistake of passing the config function itself rather than calling it.
#'
#' @param config The supplied configuration object.
#' @param arg Character. Argument name to report.
#' @param helper Character. Name of the function that builds this config.
#'
#' @noRd
#'
check_config <- function(config, arg, helper) {
  expected <- names(do.call(helper, list()))

  if (!is.list(config) || is.data.frame(config)) {
    toxdrc_abort(
      c(
        paste0("`", arg, "` must be a list built by ", helper, "()."),
        "x" = paste0("Received an object of class <", class(config)[1], ">."),
        "i" = paste0(
          "Example: ", arg, " = ", helper, "(", expected[1], " = ...)."
        )
      ),
      class = "bad_config"
    )
  }

  missing_settings <- setdiff(expected, names(config))

  if (length(missing_settings) > 0) {
    toxdrc_abort(
      c(
        paste0("`", arg, "` is missing required settings."),
        "x" = paste0(
          "Not found: ",
          paste(missing_settings, collapse = ", "),
          "."
        ),
        "i" = paste0(
          "Build the list with ", helper,
          "() rather than by hand, so defaults are filled in."
        )
      ),
      class = "incomplete_config",
      missing = missing_settings
    )
  }

  invisible(config)
}


#' Assign a possibly-NULL value into a list without dropping the name
#'
#' `list_obj$field <- NULL` removes the element. This keeps the name present
#' with a NULL value, so downstream code sees a consistent shape whether or
#' not a step produced a result.
#'
#' @param list_obj A list.
#' @param field Character. Element name.
#' @param value The value to store, possibly NULL.
#'
#' @noRd
#'
assign_field <- function(list_obj, field, value) {
  list_obj[field] <- list(value)
  list_obj
}
