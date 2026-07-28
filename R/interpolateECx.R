#' Estimate a point estimate by log-linear interpolation
#'
#' @description
#' `interpolateECx()` estimates an effect concentration by interpolating
#'  between the observed concentrations that bracket the target response,
#'  linearly on log concentration. It is intended for quantal data where no
#'  concentration produced a partial effect, so no dose-response model can be
#'  fitted.
#'
#' @details
#' Interpolating linearly on log concentration is the standard treatment of a
#'  test with no partial responses. Between the highest concentration with no
#'  effect, `A`, and the lowest with complete effect, `B`, the estimate is
#'
#'  \deqn{EC_p = A \times (B/A)^p}
#'
#'  so the EC50 is \eqn{\sqrt{A \times B}}, the geometric mean of the two.
#'  That value is the geometric midpoint and does not depend on the shape of
#'  the underlying curve, which is what makes it defensible when the shape is
#'  unknown.
#'
#'  The same is not true of other effect levels. An EC10 estimated this way
#'  lands just above `A`, and an EC90 just below `B`, so both largely restate
#'  the bracketing concentrations rather than estimating anything from them.
#'  Where they fall between `A` and `B` is a consequence of the straight-line
#'  assumption, which is precisely what the data cannot support. Requesting a
#'  level other than 0.5 when no partial responses exist therefore raises a
#'  warning.
#'
#'  Interpolation never extrapolates. If the target response is not bracketed
#'  by two observed concentrations, the estimate is NA.
#'
#'  Because the estimate comes from two points rather than a fitted model,
#'  there is no standard error and no confidence interval. Those columns are
#'  returned as NA so the output matches [getECx()].
#'
#' @param dataset A dataframe, containing the columns `Conc` and `Response`.
#' @param Conc Bare (unquoted) column name in `dataset` giving concentration.
#'  Non-numeric and non-positive levels are dropped, since the interpolation
#'  works on log concentration. Control rows are still used to establish the
#'  background response.
#' @param Response Bare (unquoted) column name in `dataset` giving the
#'  affected fraction, between 0 and 1.
#' @param EDx Numeric. The effect level(s) to estimate. Defaults to 0.5.
#' @param type Character. `"relative"` expresses `EDx` relative to the
#'  background response, targeting `control + EDx * (1 - control)`, which is
#'  the interpolation equivalent of an Abbott correction and matches
#'  [getECx()]. `"absolute"` treats `EDx` as the target proportion directly,
#'  so `EDx = 0.5` finds the concentration affecting half the organisms
#'  regardless of control response. Defaults to relative. With no control
#'  response the two coincide.
#' @param partial.tol Numeric. How far a proportion must sit from both the
#'  control response and complete effect to count as a partial effect, used
#'  only to decide whether to warn. Defaults to 0.2.
#' @param list_obj Optional. List object used for integration with
#'  [runtoxdrc()].
#' @param quiet Logical. Indicates if results should be hidden. Defaults
#'  to FALSE.
#'
#' @returns A dataframe of point estimates with the same columns as
#'  [getECx()]: `Effect Measure`, `Estimate`, `Std. Error`, `Lower` and
#'  `Upper`, the last three being NA. If `list_obj` is provided, returns this
#'  within a list as `list_obj$effectmeasure`.
#'
#' @examples
#' # No partial responses: nothing affected at 10, everything at 30.
#' quantal <- data.frame(
#'   Conc = c(0, 10, 30, 100),
#'   Prop = c(0, 0, 1, 1)
#' )
#' interpolateECx(quantal, Conc = Conc, Response = Prop, quiet = TRUE)
#' # EC50 is sqrt(10 * 30) = 17.32
#'
#' @seealso [getECx()] for model-based estimation, and [runtoxdrc()] for
#'  using this automatically when a quantal test has no partial responses.
#'
#' @export
#'
interpolateECx <- function(
  dataset,
  Conc,
  Response,
  EDx = 0.5,
  type = c("relative", "absolute"),
  partial.tol = 0.2,
  list_obj = NULL,
  quiet = FALSE
) {
  type <- match.arg(type)

  check_dataset(dataset)
  check_column(dataset, rlang::enquo(Conc), "Conc")
  check_column(dataset, rlang::enquo(Response), "Response")
  check_number(EDx, "EDx", min = 0, max = 1, allow_vector = TRUE)
  check_number(partial.tol, "partial.tol", min = 0, max = 0.5)
  check_flag(quiet, "quiet")
  check_list_obj(list_obj)
  check_proportion(dataset, rlang::enquo(Response))

  ds <- dataset %>%
    dplyr::rename(
      Response = {{ Response }},
      Conc = {{ Conc }}
    )

  ds$Conc <- suppressWarnings(as.numeric(as.character(ds$Conc)))
  ds <- ds[!is.na(ds$Conc) & !is.na(ds$Response), , drop = FALSE]

  if (nrow(ds) == 0) {
    toxdrc_abort(
      c(
        "No usable concentration and response pairs remain.",
        "i" = "Concentrations must be numeric to be interpolated."
      ),
      class = "no_interpolation_data"
    )
  }

  # One point per concentration; replicates are averaged before interpolating.
  agg <- stats::aggregate(Response ~ Conc, data = ds, FUN = mean)
  agg <- agg[order(agg$Conc), , drop = FALSE]

  # The lowest concentration establishes the background response. It is not
  # itself interpolable when it is zero, since log(0) is undefined.
  control <- agg$Response[1]

  usable <- agg[agg$Conc > 0, , drop = FALSE]

  if (nrow(usable) < 2) {
    toxdrc_abort(
      c(
        "At least two positive concentrations are needed to interpolate.",
        "x" = paste0("Found ", nrow(usable), "."),
        "i" = "Interpolation works on log concentration, so zero and negative levels are excluded."
      ),
      class = "no_interpolation_data"
    )
  }

  x <- log10(usable$Conc)
  y <- usable$Response

  targets <- if (identical(type, "relative")) {
    control + EDx * (1 - control)
  } else {
    EDx
  }

  partial <- has_partial_effect(y, control = control, tol = partial.tol)

  if (!partial && any(abs(EDx - 0.5) > .Machine$double.eps^0.5)) {
    warning(
      "No concentration produced a partial effect, so only the EC50 is ",
      "supported by the data. Other levels were interpolated on the ",
      "assumption of a straight line between the bracketing concentrations, ",
      "and largely restate those concentrations.",
      call. = FALSE
    )
  }

  estimates <- vapply(
    targets,
    function(target) interpolate_one(x, y, target),
    numeric(1)
  )

  EDdf <- empty_ecx(EDx)
  EDdf$Estimate <- estimates

  if (!quiet) {
    print(EDdf)
  }

  if (is.null(list_obj)) {
    return(EDdf)
  }

  list_obj$effectmeasure <- EDdf
  list_obj
}


#' Interpolate a single target response
#'
#' Finds the first pair of adjacent points that bracket `target` and returns
#' the concentration at which a straight line between them crosses it. Returns
#' NA rather than extrapolating when the target lies outside the observed
#' responses, or when the bracketing responses are equal and the line is flat.
#'
#' @param x Numeric. Log10 concentrations, ascending.
#' @param y Numeric. Responses at those concentrations.
#' @param target Numeric. The response to solve for.
#'
#' @returns The interpolated concentration, on the original scale.
#'
#' @noRd
#'
interpolate_one <- function(x, y, target) {
  if (is.na(target) || target < min(y) || target > max(y)) {
    return(NA_real_)
  }

  # An exact hit needs no interpolation.
  exact <- which(y == target)
  if (length(exact) > 0) {
    return(10^x[exact[1]])
  }

  brackets <- which(
    (y[-length(y)] < target & y[-1] > target) |
      (y[-length(y)] > target & y[-1] < target)
  )

  if (length(brackets) == 0) {
    return(NA_real_)
  }

  i <- brackets[1]

  if (y[i + 1] == y[i]) {
    return(NA_real_)
  }

  log_ec <- x[i] +
    (target - y[i]) * (x[i + 1] - x[i]) / (y[i + 1] - y[i])

  10^log_ec
}
