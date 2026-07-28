#' Validate a user-supplied model list
#'
#' Checks that `model_list` is a non-empty, uniquely named list of drc mean
#'  functions, and that each name matches the model function it holds. The
#'  name agreement is what allows downstream code to look a model back up by
#'  the rownames of the comparison table returned by [mselect2()].
#'
#' drc derives `$name` from `match.call()`, so it only holds the model
#'  shorthand when the mean function was called bare: `LL.4()` gives `"LL.4"`,
#'  but `drc::LL.4()` gives `"::"`, with the shorthand lost entirely. The
#'  agreement check is therefore skipped when `$name` is a namespace operator,
#'  since there is nothing meaningful to compare against. In every case `$name`
#'  is overwritten with the entry's label so downstream code sees a consistent
#'  value.
#'
#' @param model_list The list to validate.
#' @param arg Character. Name of the argument being validated, used in error
#'  messages so the same helper can serve `modelcomp(model_list =)` and
#'  `toxdrc_modelling(model.list =)`.
#'
#' @returns The validated `model_list`, with each `$name` set to the entry's
#'  label.
#'
#' @noRd
#'
validate_model_list <- function(model_list, arg = "model_list") {
  example <- "list(\"LL.4\" = LL.4(), \"W1.4\" = W1.4())"

  if (!is.list(model_list) || is.data.frame(model_list)) {
    toxdrc_abort(
      c(
        paste0("`", arg, "` must be a list of drc model functions."),
        "x" = paste0(
          "Received an object of class <", class(model_list)[1], ">."
        ),
        "i" = paste0("Expected format: ", example)
      ),
      class = "bad_model_list"
    )
  }

  if (length(model_list) == 0) {
    toxdrc_abort(
      c(
        paste0("`", arg, "` is empty."),
        "i" = "Supply at least one model function.",
        "i" = paste0("Expected format: ", example)
      ),
      class = "empty_model_list"
    )
  }

  nms <- names(model_list)

  if (is.null(nms) || any(is.na(nms)) || any(!nzchar(nms))) {
    unnamed <- if (is.null(nms)) {
      seq_along(model_list)
    } else {
      which(is.na(nms) | !nzchar(nms))
    }
    toxdrc_abort(
      c(
        paste0(
          "Every entry in `", arg,
          "` must be named with the shorthand of the model it holds."
        ),
        "x" = paste0(
          "Unnamed entries at position(s): ",
          paste(unnamed, collapse = ", "),
          "."
        ),
        "i" = paste0("Expected format: ", example)
      ),
      class = "unnamed_model_list"
    )
  }

  if (anyDuplicated(nms)) {
    toxdrc_abort(
      c(
        paste0("Names in `", arg, "` must be unique."),
        "x" = paste0(
          "Duplicated: ",
          paste(unique(nms[duplicated(nms)]), collapse = ", "),
          "."
        )
      ),
      class = "duplicate_model_names"
    )
  }

  for (i in seq_along(model_list)) {
    entry <- model_list[[i]]
    nm <- nms[i]

    if (!is.list(entry) || !is.function(entry$fct)) {
      toxdrc_abort(
        c(
          paste0("`", arg, "[[\"", nm, "\"]]` is not a drc model function."),
          "x" = paste0(
            "Received an object of class <", class(entry)[1], ">."
          ),
          "i" = paste0(
            "Entries must be the result of calling a model function, e.g. \"",
            nm, "\" = ", nm, "() rather than \"", nm, "\" = ", nm, "."
          )
        ),
        class = "bad_model_entry",
        entry = nm
      )
    }

    internal <- entry$name

    if (!is.character(internal) || length(internal) == 0) {
      toxdrc_abort(
        c(
          paste0("`", arg, "[[\"", nm, "\"]]` has no usable model name."),
          "i" = paste0(
            "drc model functions carry their shorthand in `$name`; a custom ",
            "mean function must set it to be used here."
          )
        ),
        class = "unnamed_model_entry",
        entry = nm
      )
    }

    internal <- internal[1]

    # A namespaced call (drc::LL.4()) records "::" instead of the shorthand,
    # so there is nothing to compare against and the entry is taken on trust.
    checkable <- !internal %in% c("::", ":::")

    if (checkable && !identical(nm, internal)) {
      toxdrc_abort(
        c(
          paste0("Name mismatch in `", arg, "`."),
          "x" = paste0(
            "Entry is named \"", nm, "\" but holds the model \"", internal,
            "\"."
          ),
          "i" = paste0(
            "Each entry must be named for the function it holds, e.g. \"",
            internal, "\" = ", internal, "()."
          )
        ),
        class = "model_name_mismatch",
        entry = nm,
        model = internal
      )
    }

    model_list[[i]]$name <- nm
  }

  model_list
}
