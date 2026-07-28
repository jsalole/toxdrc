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
#'  the response variable. For a quantal endpoint this is the affected
#'  fraction, between 0 and 1.
#' @param N Bare (unquoted) column name in `dataset` giving the number of
#'  organisms in each group. Required when `type = "binomial"` and ignored
#'  otherwise.
#' @param type Character. `"continuous"` averages the response within each
#'  group. `"binomial"` pools it instead, weighting each replicate by `N` and
#'  returning the combined group size, so that a proportion from 30 of 60
#'  counts for more than one from 1 of 4.
#' @param IDcols Optional. Character vector of columns used to identify the
#'  data. These columns are preserved in the collapsed `dataset`, taking the
#'  first non-blank value in each group, so their values should be constant
#'  within a `Conc` group. Naming a column that does not exist is an error.
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
#'   dataset = toxresult,
#'   Conc = Conc,
#'   Response = RFU,
#'   IDcols = c("TestID", "Test_Number", "Dye", "Type", "Replicate")
#' )
#'
averageresponse <- function(
  dataset,
  Conc,
  Response,
  N = NULL,
  IDcols = NULL,
  type = c("continuous", "binomial"),
  list_obj = NULL,
  quiet = FALSE
) {
  type <- match.arg(type)

  check_dataset(dataset)
  check_column(dataset, rlang::enquo(Conc), "Conc")
  check_column(dataset, rlang::enquo(Response), "Response")
  check_idcols(dataset, IDcols)
  check_flag(quiet, "quiet")
  check_list_obj(list_obj)

  binomial <- identical(type, "binomial")
  n_quo <- rlang::enquo(N)

  if (binomial) {
    if (rlang::quo_is_null(n_quo)) {
      toxdrc_abort(
        c(
          "`N` is required when `type = \"binomial\"`.",
          "i" = "Replicate proportions are pooled by group size, which cannot be done without it."
        ),
        class = "missing_counts"
      )
    }
    check_column(dataset, n_quo, "N")
    check_counts(dataset, n_quo)
  }

  pre_average_dataset <- dataset

  # Group by Conc and average Response, collapsing to one row per level while
  # preserving the first non-missing value of each IDcol.
  #
  # Quantal replicates are pooled rather than averaged. Taking the mean of the
  # proportions weights every replicate equally, so 1 of 4 and 30 of 60 would
  # count the same. Pooling recovers the underlying totals: the combined
  # proportion is sum(affected) / sum(N), which is the weighted mean, and the
  # combined group size is sum(N) so the fit still knows how much evidence
  # sits behind the point.

  averaged_dataset <- if (binomial) {
    dataset %>%
      dplyr::group_by({{ Conc }}) %>%
      dplyr::summarise(
        mean_response = sum({{ Response }} * {{ N }}, na.rm = TRUE) /
          sum({{ N }}, na.rm = TRUE),
        N = sum({{ N }}, na.rm = TRUE),
        dplyr::across(
          all_of(IDcols),
          ~ first_nonmissing(.),
          .names = "{.col}"
        ),
        .groups = "drop"
      )
  } else {
    dataset %>%
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
  }

  averaged_dataset <- as.data.frame(averaged_dataset)

  if (!quiet) {
    print(averaged_dataset)
  }

  # Output as a list, either a new list, or attached to supplied list_obj
  if (is.null(list_obj)) {
    return(as.data.frame(averaged_dataset))
  }

  list_obj$dataset <- as.data.frame(averaged_dataset)
  list_obj$pre_average_dataset <- as.data.frame(pre_average_dataset)
  list_obj
}
