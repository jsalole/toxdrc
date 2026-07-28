#' Default model list for an endpoint type
#'
#' Both [modelcomp()] and [toxdrc_modelling()] need to know what to fit when
#'  the user supplies no `model_list`, and the right answer depends on the
#'  endpoint. Resolving it in one place stops the two defaults drifting apart.
#'
#' Continuous data defaults to the four-parameter log-logistic model, which
#'  estimates both plateaus from the data.
#'
#' Quantal data defaults to two models. `LL.2` fixes the lower limit at 0 and
#'  the upper at 1, which is the right assumption when the response genuinely
#'  spans none-affected to all-affected, and its two parameters make it far
#'  more likely to converge on sparse data than `LL.4`. `LL.3u` keeps the
#'  upper limit at 1 but estimates the lower, which accommodates background
#'  response in the controls. Comparing the two lets the data say whether
#'  control response needs accounting for.
#'
#' @param type Character. `"continuous"` or `"binomial"`.
#'
#' @returns A named list of drc mean functions.
#'
#' @importFrom drc LL.2 LL.3u
#'
#' @noRd
#'
default_model_list <- function(type = c("continuous", "binomial")) {
  type <- match.arg(type)

  if (identical(type, "binomial")) {
    return(list("LL.2" = LL.2(), "LL.3u" = LL.3u()))
  }

  list("LL.4" = LL.4())
}
