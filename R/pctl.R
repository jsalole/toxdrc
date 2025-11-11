#' Procedure control check
#'
#' This function evaluates the difference between two groups with the intention of evaluating validity criteria. This can be used for solvent controls, and similar control groups commonly used in toxicity testing, or even to compare more abstract concepts (order of testing, time of day, etc) to validate a method. Careful consideration should be given the max_diff value. The default is set to 10% difference.
#'
#' @param dataset A dataframe.
#' @param Conc Unquoted column name of `dataset` with groups to compare (e.g. reference/true control, solvent/positive control)
#' @param reference_group Quoted name OR value of reference group, or true control (i.e. "Control", 0)
#' @param positive_group Quoted name OR value of procedural group, or positive control (i.e. "ctl+", 0)
#' @param Response Unquoted column name of `dataset` with observations to compare (e.g. RFU).
#' @param max_diff The maximum % difference between groups before they are flagged.
#' @param list_obj Optional existing list object, used for integration with `runtoxdrc`.
#' @param quiet Logical. Whether results should be hidden. Default: FALSE.

#' @returns Prints a summary dataframe is printed indicating the percent difference of the control groups. The flag is updated in `dataset`. If list_object is supplied, returns modified `dataset` and test results `pctlresults` in this growing list object.
#' @export
#'
#' @examples df <- data.frame(x = rep(1:2, each = 3), y = c(10, 11, 9, 20, 40, 60))
#' pctl(dataset = df, Conc = x, reference_group = 1,
#'      positive_group = 2, Response = y, max_diff = 10)
#'

pctl <- function(
  dataset,
  Conc,
  reference_group = "Control",
  positive_group = 0,
  Response,
  max_diff = 10,
  list_obj = NULL,
  quiet = FALSE
) {
  dataset <- dataset %>%
    dplyr::mutate(
      Validity = ""
    )

  # Check if both necessary groups exist
  if (
    !(reference_group %in% dplyr::pull(dataset, {{ Conc }})) ||
      !(positive_group %in% dplyr::pull(dataset, {{ Conc }}))
  ) {
    stop('Both reference and positive groups are required for check.')
  }

  # Calculate means
  pctl_resp <- mean(
    dplyr::pull(
      dataset %>% dplyr::filter({{ Conc }} == positive_group),
      {{ Response }}
    ),
    na.rm = TRUE
  )
  ref_resp <- mean(
    dplyr::pull(
      dataset %>% dplyr::filter({{ Conc }} == reference_group),
      {{ Response }}
    ),
    na.rm = TRUE
  )

  percent_diff <- abs((ref_resp - pctl_resp) / ref_resp) * 100

  # Prepare summary
  summary_df <- data.frame(
    p_ctl_mean = c(pctl_resp),
    ref_ctl_mean = c(ref_resp),
    percent_difference = c(percent_diff)
  )

  if (!quiet) {
    print(summary_df)
  }

  # Flag if percent difference is too high
  if (percent_diff > max_diff) {
    dataset$Validity <- "*"
  }

  # Output logic
  if (!is.null(list_obj)) {
    if (!is.list(list_obj)) {
      stop("Provided list_obj must be a list.")
    }
    list_obj$dataset <- dataset
    list_obj$pctlresults <- summary_df
    return(list_obj)
  }
  return(dataset)
}
