# ============================================================
# Top-level overview page for configuration helpers
# ============================================================

#' Configuration helpers for `runtoxdrc()`
#'
#' A top-level overview of the modular configuration functions used by [runtoxdrc()].
#'
#' These helpers provide default lists of parameters for customizing different
#' stages of the `runtoxdrc()` workflow. Users can modify only the parameters
#' they need without manually handling all arguments in `runtoxdrc()`.
#'
#' @details
#' **Available configuration functions:**
#' \itemize{
#'   \item [`toxdrc_qc()`] — Quality control and filtering options
#'   \item [`toxdrc_normalization()`] — Blank correction and normalization
#'   \item [`toxdrc_toxicity()`] — Toxicity threshold and response-level options
#'   \item [`toxdrc_modelling()`] — Model selection, fitting criteria, and EDx calculation
#' }
#'
#' Each of these functions returns a **named list of configuration parameters**
#' suitable for passing directly to [runtoxdrc()].
#'
#' @seealso
#' [runtoxdrc()],
#' [toxdrc_qc()],
#' [toxdrc_normalization()],
#' [toxdrc_toxicity()],
#' [toxdrc_modelling()]
#'
#' @examples
#' # Overview page example
#' ?config_runtoxdrc
#'
#' # Example: create a custom QC list and pass it to runtoxdrc()
#' qc_config <- toxdrc_qc(outlier.test = TRUE, cvflag.lvl = 20)
#' runtoxdrc(cellglow, qc = qc_config)
#'
#' @name config_runtoxdrc
config_runtoxdrc <- function() {}


# ============================================================
# Quality control configuration helper
# ============================================================

#' Quality control configuration for `runtoxdrc()`
#'
#' Defines how quality control is applied to the response data before model fitting.
#'
#' @param outlier.test Logical. Indicates if outliers should be identified. Default: FALSE.
#' @param cv.flag Logical. Flag CVs of the response variable. Default: TRUE.
#' @param cvflag.lvl Numeric. Percent at which CVs are considered high. Default: 30.
#' @param pctl.test Logical. Indicates if positive control/solvent effects should be evaluated. Default: FALSE.
#' @param pctl.lvl Numeric. Percent difference in response `ref.label` and `pctl.label` at which tests are flagged. Default: 10.
#' @param ref.label Character. Label used for the true control level. Default: "Control".
#' @param pctl.label Character. Label used for the positive control level. Default: 0.
#' @param avg.resp Logical. Indicates if responses should be averaged at each concentration. Default: TRUE.
#'
#' @return A named list containing the quality control configuration for use in [runtoxdrc()].
#'
#' @examples
#' toxdrc_qc()
#' toxdrc_qc(outlier.test = TRUE, cvflag.lvl = 20)
#'
#' @seealso [config_runtoxdrc], [runtoxdrc()]
#' @export
toxdrc_qc <- function(
  outlier.test = FALSE,
  cv.flag = TRUE,
  cvflag.lvl = 30,
  pctl.test = FALSE,
  pctl.lvl = 10,
  ref.label = "Control",
  pctl.label = 0,
  avg.resp = TRUE
) {
  list(
    outlier.test = outlier.test,
    cv.flag = cv.flag,
    cvflag.lvl = cvflag.lvl,
    pctl.test = pctl.test,
    pctl.lvl = pctl.lvl,
    ref.label = ref.label,
    pctl.label = pctl.label,
    avg.resp = avg.resp
  )
}


# ============================================================
# Normalization configuration helper
# ============================================================

#' Normalization configuration for `runtoxdrc()`
#'
#' Defines how normalization steps are applied to the response data before model fitting.
#'
#' @param blank.correction Logical. Indicates if the response variable should be blank corrected. Default: FALSE.
#' @param blank.label Character. Label used for the blank level. Default: "Blank".
#' @param normalize.resp Logical. Indicates if response variable should be normalized to a given group. Default: FALSE.
#' @param relative.label Character/Numeric. Label or value used for the group values will be normalized to. Default: 0.
#'
#' @return A named list containing normalization configuration for use in [runtoxdrc()].
#'
#' @examples
#' toxdrc_normalization()
#' toxdrc_normalization(blank.correction = TRUE, relative.label = "Control")
#'
#' @seealso [config_runtoxdrc], [runtoxdrc()]
#' @export
toxdrc_normalization <- function(
  blank.correction = FALSE,
  blank.label = "Blank",
  normalize.resp = FALSE,
  relative.label = 0
) {
  list(
    blank.correction = blank.correction,
    blank.label = blank.label,
    normalize.resp = normalize.resp,
    relative.label = relative.label
  )
}


# ============================================================
# Toxicity configuration helper
# ============================================================

#' Toxicity configuration for `runtoxdrc()`
#'
#' Defines how toxicity is determined before and during model fitting.
#'
#' @param toxic.lvl Numeric. Cutoff point to determine if modelling occurs. Default: 0.7.
#' @param toxic.type Character. Indicates if `toxic.lvl` is absolute ("abs") or relative ("rel") to some group. Default: "rel".
#' @param toxic.direction Character. Indicates if toxicity is a higher ("above") or lower ("below"). Default: "below".
#' @param comp.group Character/Numeric. Label used for the group values will be compared to if `toxic.type` is "rel". Default: 0.
#' @param target.group Character/Numeric. Optional. Restrict comparisons to given group(s). Default: NULL.
#'
#' @return A named list containing toxicity determination settings for use in [runtoxdrc()].
#'
#' @examples
#' toxdrc_toxicity()
#' toxdrc_toxicity(toxic.lvl = 0.5, toxic.direction = "above")
#'
#' @seealso [config_runtoxdrc], [runtoxdrc()]
#' @export
toxdrc_toxicity <- function(
  toxic.lvl = 0.7,
  toxic.type = c("rel", "abs"),
  toxic.direction = c("below", "above", "different"),
  comp.group = 0,
  target.group = NULL
) {
  list(
    toxic.lvl = toxic.lvl,
    toxic.type = match.arg(toxic.type),
    toxic.direction = match.arg(toxic.direction),
    comp.group = comp.group,
    target.group = target.group
  )
}


# ============================================================
# Modelling configuration helper
# ============================================================

#' Modelling configuration for `runtoxdrc()`
#'
#' Defines how dose-response models are fitted, selected, and how effective dose (EDx)
#' point estimates are calculated.
#'
#' @param model.list Named list of model functions to be fitted. Defaults: `"LL.4"`, `"LN.4"`, `"W1.4"`, `"W2.4"`.
#' @param model.metric Character. Criterion used to select the best model. Choices: `"IC"`, `"Res var"`, `"Lack of fit"`. Default: "IC".
#' @param EDx Numeric. The effective dose level to estimate (e.g., 0.5 for ED50). Default: 0.5.
#' @param interval Character. Method for calculating confidence intervals of EDx. Choices: `"tfls"`, `"fls"`, `"delta"`, `"none"`. Default: "tfls".
#' @param level Numeric. Confidence level for the interval calculation. Default: 0.95.
#' @param type Character. Whether EDx is calculated as `"absolute"` or `"relative"`. Default: "absolute".
#' @param quiet Logical. Whether EDx results should be printed. Default: FALSE.
#' @param EDargs.supplement List. Optional user-supplied list of additional or overriding ED arguments. Can include `interval`, `level`, `type`, or other arguments compatible with `drc::ED()`.
#'
#' @return A named list containing model fitting and selection settings for use in [runtoxdrc()].
#'
#' @examples
#' toxdrc_modelling()
#' toxdrc_modelling(EDargs.supplement = list(interval = "delta", level = 0.9))
#'
#' @seealso [config_runtoxdrc], [runtoxdrc()], [drc::ED()]
#' @export
toxdrc_modelling <- function(
  model.list = list(
    "LL.4" = LL.4(),
    "LN.4" = LN.4(),
    "W1.4" = W1.4(),
    "W2.4" = W2.4()
  ),
  model.metric = c("IC", "Res var", "Lack of fit"),
  EDx = 0.5,
  interval = c("tfls", "fls", "delta", "none"),
  level = 0.95,
  type = c("absolute", "relative"),
  quiet = FALSE,
  EDargs.supplement = list()
) {
  EDargs <- list(
    interval = match.arg(interval),
    level = level,
    type = match.arg(type),
    display = !quiet
  )

  if (length(EDargs.supplement) > 0) {
    EDargs <- utils::modifyList(EDargs, EDargs.supplement)
  }

  list(
    model.list = model.list,
    model.metric = match.arg(model.metric),
    EDx = EDx,
    EDargs = EDargs
  )
}
