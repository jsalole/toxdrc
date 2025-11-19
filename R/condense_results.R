condense_results <- function(results_list, fields_of_interest) {
  condensed_results_list <- lapply(names(results_list), function(entry_ID) {
    entry <- results_list[[entry_ID]]

    if ("effectmeasure" %in% names(entry)) {
      effect_measure_df <- entry$effectmeasure

      # Create 1 output row for each row of effectmeasure
      row_blocks <- lapply(seq_len(nrow(effect_measure_df)), function(i) {
        row_values <- list()

        for (field in fields_of_interest) {
          # Field not present
          if (!(field %in% names(entry))) {
            row_values[[field]] <- NA
            next
          }

          value <- entry[[field]]

          if (field == "effectmeasure") {
            # Insert THIS row of effectmeasure
            row_values <- c(
              row_values,
              as.list(effect_measure_df[i, , drop = FALSE])
            )
          } else if (length(value) == 1) {
            # Scalar: copy as-is
            row_values[[field]] <- value
          } else {
            # Non-scalar: collapse to string
            row_values[[field]] <- paste(value, collapse = ",")
          }
        }

        # Return a 1-row data.frame for this effectmeasure row
        as.data.frame(row_values, check.names = FALSE)
      })

      # Bind all rows for this entry
      return(do.call(rbind, row_blocks))
    }

    # Case: no effectmeasure in entry → return a single-row summary
    row_values <- list()

    for (field in fields_of_interest) {
      if (!(field %in% names(entry))) {
        row_values[[field]] <- NA
        next
      }

      value <- entry[[field]]

      if (field == "effectmeasure") {
        row_values[[field]] <- NA
      } else if (length(value) == 1) {
        row_values[[field]] <- value
      } else {
        row_values[[field]] <- paste(value, collapse = ",")
      }
    }

    as.data.frame(row_values, check.names = FALSE)
  })

  # Bind all entries into one big data.frame
  do.call(rbind, condensed_results_list)
}
