# =============
# LANDING PAGE
# =============

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
#'   \item [`drc_qc()`] — Quality control and filtering options
#'   \item [`drc_normalization()`] — Blank correction and normalization
#'   \item [`drc_toxicity()`] — Toxicity threshold and response-level options
#'   \item [`drc_modeling()`] — Model selection, fitting criteria, and EDx calculation
#' }
#'
#' Each of these functions returns a **named list of configuration parameters**
#' suitable for passing directly to [runtoxdrc()].
#'
#' @seealso
#' [runtoxdrc()],
#' [drc_qc()],
#' [drc_normalization()],
#' [drc_toxicity()],
#' [drc_modeling()]
#'
#' @examples
#' # Overview page example
#' ?config_runtoxdrc
#'
#' # Example: create a custom QC list and pass it to runtoxdrc()
#' qc_config <- drc_qc(outlier.test = TRUE, cvflag.lvl = 20)
#' runtoxdrc(cellglow, qc = qc_config)
#'
#' @name config_runtoxdrc
#' @docType package
NULL


#' Configuration helper functions for `runtoxdrc()`
#'
#' These helper functions provide modular configuration lists for customizing
#' different stages of the `runtoxdrc()` workflow, including data quality control,
#' normalization, model fitting, toxicity evaluation, and result averaging.
#'
#' Each helper returns a named list with default options. Users can modify
#' only the parameters they need, without manually handling all arguments
#' in `runtoxdrc()`.
#'
#' @details
#' **Available configuration functions:**
#' \itemize{
#'   \item [`drc_qc()`] — Quality control and filtering options
#'   \item [`drc_normalization()`] — Blank correction and normalization
#'   \item [`drc_modeling()`] — Model selection and fitting criteria
#'   \item [`drc_toxicity()`] — Toxicity threshold and response-level options
#'   \item [`drc_averaging()`] — Data averaging and aggregation options
#' }
#'
#' @return Each function returns a named list of configuration parameters.
#'
#' @seealso [runtoxdrc()]
#'
#' @examples
#' # Default QC configuration
#' drc_qc()
#'
#' # Example: enable outlier test and adjust CV flag threshold
#' drc_qc(outlier.test = TRUE, cvflag.lvl = 20)
#'
#' # Example: pass to runtoxdrc
#' runtoxdrc(cellglow, qc = drc_qc(outlier.test = TRUE))
#'
#'
#' @rdname config_runtoxdrc
#'
#' @description
#' **Quality control configuration**
#'
#' Defines how quality control is applied to the response data before model fitting.
#'
#' @param outlier.test Logical. Indicates if outliers should be identified.
#' @param cv.flag Logical. Indicates if CVs of the response variable should be calculated within each Conc group and flagged (if exceeding `cvflag.lvl`).
#' @param cvflag.lvl Numeric. The % at which CVs are considered high.
#' @param pctl.test Logical. Indicates if positive control/solvent effects should be evaluated.
#' @param pctl.lvl Character. The % difference in the response `ref.label` and `pctl.label` at which tests are flagged.
#' @param ref.label Character. Label used for the true control level.
#' @param pctl.label Character. Label used for the positive control level.
#' @param avg.resp Logical. Indicates if responses should be averaged at each Conc level.

#' @return A list containing quality control settings for use in [runtoxdrc()].
#'
drc_qc <- function(
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

#' @rdname config_runtoxdrc
#'
#' @description
#' **Normalization configuration**
#'
#' Defines how normalization steps are applied to the response data before model fitting.
#'
#' @param blank.correction Logical. Indicates if the response variable should be blank corrected.
#' @param blank.label Character. Label used for the blank level.
#' @param normalize.resp Logical. Indicates if response variable should be normalized to a given group.
#' @param relative.label Character. Label used for the group values will be normalized to.

#' @return A list containing normalization settings for use in [runtoxdrc()].

drc_normalization <- function(
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

#' @rdname config_runtoxdrc
#'
#' @description
#' **Toxicity configuration**
#'
#' Defines how toxicity is determined before and during model fitting.
#'
#' @param toxic.lvl. Numeric. A cutoff point to determine if modelling occurs. The response variable must Indicates if the response variable should be blank corrected.
#' @param toxic.type Character. Indicates if `toxic.lvl` is an absolute ("abs") value or relative ("rel") to some group.
#' @param toxic.direction Character. Indicates if toxicity is indicated by a higher ("above") or lower ("below") response, or  a change in either direction ("different").
#' @param comp.group Character. Label used for the group values will be compared to, if `toxic.type` is set to relative ("rel").
#' @param target.group Character. If NULL, all groups are evaluated to determine toxicity. Giving group name(s) will restrict compairisons to given groups.

#' @return A list containing toxicity determination settings for use in [runtoxdrc()].

drc_toxicity <- function(
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

#' @rdname config_runtoxdrc
#'
#' @description
#' **Modelling configuration**
#'
#' Defines how models are fitted, selected, and point estimates are estimated.
#'
#' @param model.list A named list of model functions to be fitted. Defaults include
#'   `"LL.4"`, `"LN.4"`, `"W1.4"`, and `"W2.4"`.
#' @param model.metric Character. Criterion used to select the best model. Choices are
#'   `"IC"` (information criterion), `"Res var"` (residual variance), or `"Lack of fit"`.
#'   Defaults to `"IC"`.
#' @param EDx Numeric. The effective dose level to estimate (e.g., 0.5 for ED50). Default is 0.5.
#' @param interval Character. Method for calculating confidence intervals of EDx. Choices are
#'   `"tfls"`, `"fls"`, `"delta"`, or `"none"`. Default is `"tfls"`.
#' @param level Numeric. Confidence level for the interval calculation. Default is 0.95.
#' @param type Character. Whether EDx is calculated as `"absolute"` or `"relative"`. Default is `"absolute"`.
#' @param EDargs.supplement List. Optional. User-supplied list of additional or overriding ED arguments.
#'   These will be merged with defaults. Can include elements like `interval`, `level`, `type`, or other arguments from `drc::ED()`.
#'
#' @seealso [drc::ED()]

#' @return A list containing model fitting and selection settings for use in [runtoxdrc()].

drc_modeling <- function(
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
  EDargs.supplement = list()
) {
  if (length(EDargs.supplement) > 0) {
    EDargs <- utils::modifyList(EDargs, EDargs.supplement)
  }

  list(
    model.list = model.list,
    model.metric = match.arg(model.metric),
    EDx = EDx,
    EDargs = list(
      interval = match.arg(interval),
      level = level,
      type = match.arg(type)
    )
  )
}
