# ============================================================
# Top-level overview page for configuration helpers
# ============================================================

#' Configuration functions for the runtoxdrc pipeline
#'
#' @description
#' An overview of the modular configuration functions used by
#'  [runtoxdrc()]. These configuration functions provide default
#'  lists of parameters for customizing different stages of the
#'  pipeline to reduce the number of arguments required in
#' [runtoxdrc()]. Each function returns a named list of
#'  configuration parameters suitable for passing directly to
#'  [runtoxdrc()].
#'
#' @details
#' **Available configuration functions:**
#' \itemize{
#'   \item [toxdrc_qc()] — Quality control and filtering options
#'   \item [toxdrc_normalization()] — Blank correction and normalization
#'   \item [toxdrc_toxicity()] — Toxicity threshold and response-level options
#'   \item [toxdrc_modelling()] — Model selection, fitting criteria, and EDx calculation
#'   \item [toxdrc_output()] — Output settings
#' }
#'
#' @usage NULL
#'
#' @seealso
#' [runtoxdrc()],
#' [toxdrc_qc()],
#' [toxdrc_normalization()],
#' [toxdrc_toxicity()],
#' [toxdrc_modelling()],
#' [toxdrc_output()]
#'
#'
#' @name config_runtoxdrc
config_runtoxdrc <- function() {}


# ============================================================
# Quality control configuration helper
# ============================================================

#' Set quality control options for the runtoxdrc pipeline.
#'
#' @description
#' Control outlier detection, CV calculation, averaging of response
#'   variable, and testing for positive control effects.
#'
#' @param outlier.test Logical. Indicates if outliers should be
#'  tested for and removed. Defaults to FALSE.
#' @param cv.flag Logical. Indicates if groups of the response
#'  variable should be flagged if the CV exceeds `cvflag.lvl`.
#'  Defaults to TRUE.
#' @param cvflag.lvl Numeric. The percent beyond which CV values are
#'  flagged. Defaults to 30.
#' @param pctl.test Logical. Indicates if positive control/solvent
#'  effects should be tested for. Defaults to FALSE.
#' @param pctl.lvl Numeric. Percent difference of the response in the
#'  `ref.label` and `pctl.label` groups beyond which tests are
#'  flagged. Defaults to 10.
#' @param ref.label Label used for the true control level.
#'  Defaults to "Control".
#' @param pctl.label Label used for the positive control
#'  level. Defaults to 0.
#' @param avg.resp Logical. Indicates if responses should be averaged
#'  within each group. Defaults to TRUE.
#'
#' @return A named list containing the quality control configuration
#'  for use in [runtoxdrc()].
#'
#' @examples
#' toxdrc_qc(outlier.test = TRUE, cvflag.lvl = 20)
#'
#' @seealso [config_runtoxdrc], [runtoxdrc()], [pctl()], [removeoutliers()], [flagCV()]
#'
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

#' Set normalization configuration for the runtoxdrc pipeline.
#'
#' @description
#' Control blank correction and normalization of the response variable.
#'
#' @param blank.correction Logical. Indicates if the response variable
#'  should be blank corrected. Defaults to FALSE.
#' @param blank.label Character. Label used for the blank level.
#'  Defaults to "Blank".
#' @param normalize.resp Logical. Indicates if response variable should
#'  be normalized to a given group. Defaults to FALSE.
#' @param relative.label Label used for the group values will be
#'  normalized to. Defaults to 0.
#'
#' @return A named list containing normalization configuration for use in
#'  [runtoxdrc()].
#'
#' @examples
#' toxdrc_normalization(blank.correction = TRUE, relative.label = "Control")
#'
#' @seealso [config_runtoxdrc], [runtoxdrc()], [blankcorrect()], [normalizeresponse()]
#'
#' @export
#'
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

#' Toxicity configuration for for the runtoxdrc pipeline.
#'
#' @description
#' Defines how toxicity is determined for model fitting.
#'
#' @param toxic.lvl Numeric. Cutoff point to determine if modelling occurs.
#'  Defaults to 0.7.
#' @param toxic.type Character. Indicates if `effect` is `"relative"` to
#'  `reference group` or an `"absolute"` value. Defaults to relative.
#' @param toxic.direction Character. Indicates if an effect occurs `"below"`
#'  or `"above"`. Defaults to below.
#' @param comp.group Label used for reference group.
#' @param target.group Optional. Limits the compairison to certain
#'  exposure conditions.
#' @return A named list containing toxicity determination settings for use
#'  in [runtoxdrc()].
#'
#' @examples
#' toxdrc_toxicity(toxic.lvl = 0.5, toxic.direction = "above")
#'
#' @seealso [config_runtoxdrc], [runtoxdrc()], [checktoxicity()]
#' @export
toxdrc_toxicity <- function(
  toxic.lvl = 0.7,
  toxic.type = c("relative", "absolute"),
  toxic.direction = c("below", "above"),
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

#' Modelling configuration for for the runtoxdrc pipeline.
#'
#' @description
#' Defines how dose-response models are fitted, selected, and how point
#'  estimates (EDx) are calculated.
#'
#' @param model.list List. Model functions to be tested. Defaults to
#'  include `"LL.4"`, `"LN.4"`, `"W1.4"`, `"W2.4"`. Most models from the drc
#'  package are compatible; use `drc::getMeanFunctions()` for a more options. See
#' [modelcomp()] for more information around formatting.
#' @param model.metric Character. Criterion used to select the best
#'  model. Choices are `"IC"`, `"Res var"`, `"Lack of fit"`. Defaults
#'  to "IC".
#' @param EDx Numeric. The effective dose level to estimate. Defaults
#'  to 0.5.
#' @param interval Character. Method for calculating confidence intervals
#'  of EDx. Choices: `"tfls"`, `"fls"`, `"delta"`, `"none"`. Defaults
#'  to "tfls". See `drc::ED()` for more information.
#' @param level Numeric. Confidence level for the interval calculation.
#'  Defaults to 0.95.
#' @param type Character. Indicates if EDx is `"absolute"` or
#'  `"relative"` to the curve. Defaults to absolute.
#' @param quiet Logical. Indicates if results should be hidden. Defaults
#'  to FALSE.
#' @param EDargs.supplement List. Optional user-supplied list of additional arguments
#'  compatible with `drc::ED()`.
#'
#' @return A named list containing model fitting and selection settings
#'  for use in [runtoxdrc()].
#'
#' @examples
#' toxdrc_modelling(EDargs.supplement = list(interval = "delta", level = 0.9))
#'
#' @seealso [config_runtoxdrc], [runtoxdrc()], [drc::ED()], [getMeanFunctions()], [modelcomp()]
#'
#' @export
#'

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
  type = c("relative", "absolute"),
  quiet = FALSE,
  EDargs.supplement = list()
) {
  list(
    model.metric = match.arg(model.metric),
    EDx = EDx,
    interval = match.arg(interval),
    level = level,
    type = match.arg(type),
    quiet = quiet,
    EDargs.supplement = EDargs.supplement
  )
}

# ============================================================
# Output configuration helper
# ============================================================

#' #' Output configuration for for the runtoxdrc pipeline.
#'
#' @description
#' Defines how [runtoxdrc()] output is returned.
#'
#'
#' @param condense Logical. Indicates if the results should be
#' summarized into a single dataframe. Defaults to TRUE.
#' @param sections Character. Columns given as a vector that should be
#'  present in the summary. Defaults to
#'  `c("ID", "effectmeasure", "best_model_name", "effect")`.
#'
#' @return A named list containing output configuration for use
#'  in [runtoxdrc()].
#'
#' @examples
#' toxdrc_output()
#' toxdrc_output(condense = TRUE)
#'
#' @seealso [config_runtoxdrc], [runtoxdrc()]
#' @export

toxdrc_output <- function(
  condense = FALSE,
  sections = c("ID", "effectmeasure", "best_model_name", "effect")
) {
  list(
    condense = condense,
    sections = sections
  )
}
