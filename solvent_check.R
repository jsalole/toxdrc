#' Check validity between Control and Solvent Control groups
#'
#' This function checks whether the difference between solvent control (Conc == 0)
#' and control (Conc == "Control") is within an acceptable threshold.
#'
#' @param dataset A data frame containing the data.
#' @param Conc Unquoted column name for the concentration variable.
#' @param Response Unquoted column name for the response variable.
#' @param ID Optional unquoted column name for sample ID (for tracking).
#' @param list_obj Optional existing list object to update.
#' @param flag_lvl Numeric value; allowable relative difference (default = 0.1 for 10%).
#'
#' @return A list containing:
#' \describe{
#'   \item{dataset}{The modified dataset with a Validity column.}
#'   \item{validity_summary}{A small tibble summarizing the check.}
#' }
#' @export
#'
solvent_check <- function(dataset, Conc, Response, ID = NULL, list_obj = NULL, flag_lvl = 0.1) {
  requireNamespace("dplyr", quietly = TRUE)
  
  dataset <- dataset %>%
    dplyr::mutate(
      Validity = ""
    )
  
  # Check if both necessary groups exist
  if (!("Control" %in% dplyr::pull(dataset, {{Conc}})) || !(0 %in% dplyr::pull(dataset, {{Conc}}))) {
    stop('Both "Control" and "0" concentration groups are required for validity check.')
  }
  
  # Calculate means
  sctl_resp <- mean(dplyr::pull(dataset %>% dplyr::filter({{Conc}} == 0), {{Response}}), na.rm = TRUE)
  ctl_resp <- mean(dplyr::pull(dataset %>% dplyr::filter({{Conc}} == "Control"), {{Response}}), na.rm = TRUE)
  
  percent_diff <- abs(ctl_resp - sctl_resp) / ctl_resp
  
  # Prepare summary
  summary_df <- tibble::tibble(
    solvent_control_mean = sctl_resp,
    control_mean = ctl_resp,
    percent_difference = percent_diff
  )
  
  if (!is.null(ID)) {
    summary_df <- summary_df %>%
      dplyr::mutate(ID = as.character(dplyr::pull(dataset, {{ID}})[1]))
  }
  
  # Flag if percent difference is too high
  if (percent_diff > flag_lvl) {
    dataset <- dataset %>%
      dplyr::mutate(
        Validity = paste0(Validity, "*")
      )
  }
  
  # Output logic
  if (is.null(list_obj)) {
    return(list(
      dataset = dataset,
      validity_summary = summary_df
    ))
  } else {
    if (is.list(list_obj)) {
      list_obj$dataset <- dataset
      list_obj$validity_summary <- summary_df
      return(list_obj)
    } else {
      stop("Provided list_obj must be a list.")
    }
  }
}
  
  