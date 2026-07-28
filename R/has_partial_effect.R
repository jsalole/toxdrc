#' Does any concentration show a usable partial effect?
#'
#' A dose-response model needs at least one concentration where the response
#'  is neither absent nor complete; without one, the slope is unidentifiable no
#'  matter how few parameters the model has. This is the condition that makes
#'  interpolation the appropriate estimator rather than a fallback for a
#'  fitting failure.
#'
#' The tolerance exists because a response one or two organisms above control
#'  is technically partial but carries almost no information about the slope.
#'  With the default of 0.2 and a control response of 0, a group must be
#'  between 20\% and 80\% affected to count.
#'
#' @param props Numeric. Affected proportion for each concentration.
#' @param control Numeric. Affected proportion of the control group, used as
#'  the floor against which a partial effect is judged. Defaults to 0.
#' @param tol Numeric. How far a proportion must sit from both the control
#'  response and complete effect to count as partial.
#'
#' @returns TRUE if at least one concentration shows a partial effect.
#'
#' @noRd
#'
has_partial_effect <- function(props, control = 0, tol = 0.2) {
  props <- props[!is.na(props)]

  if (length(props) == 0) {
    return(FALSE)
  }

  if (is.na(control)) {
    control <- 0
  }

  any(props > control + tol & props < 1 - tol)
}
