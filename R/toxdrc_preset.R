#' Ready-made configurations for common study designs
#'
#' @description
#' `toxdrc_preset()` returns a complete set of configuration objects for a
#'  kind of study, suitable for passing to [runtoxdrc()] as `preset`. The
#'  point is less to save typing than to record which combinations of settings
#'  belong together, which is not obvious from the individual configuration
#'  helpers.
#'
#' @details
#' A preset is an ordinary named list of the same objects [runtoxdrc()] takes
#'  individually, so it can be printed, inspected, and modified. Anything
#'  passed explicitly to [runtoxdrc()] overrides the corresponding entry,
#'  which makes a preset a starting point rather than a black box.
#'
#' **Available presets:**
#'
#' \describe{
#'   \item{`"continuous"`}{A measured response on an arbitrary scale, fitted
#'     with `LL.4`. No preprocessing. This is the source of [runtoxdrc()]'s
#'     own defaults, so using it changes nothing; it exists so the baseline
#'     has a name and cannot drift from the defaults it defines.}
#'   \item{`"quantal"`}{A binary endpoint such as mortality, with few
#'     organisms per group. Fitted as binomial data weighted by `N`, comparing
#'     `LL.2` against `LL.3u` so that background response in the controls is
#'     accounted for only if the data call for it. Log-linear interpolation is
#'     enabled, which covers the common case of a test with no partial
#'     responses, where no model can be fitted at all. Requires the `N`
#'     argument to [runtoxdrc()].
#'
#'     Effect levels are relative, which for a quantal fit is algebraically
#'     Abbott's correction: the EC50 is the concentration affecting half of
#'     the organisms that would otherwise have survived, rather than half of
#'     all organisms. The two are identical unless there is control mortality,
#'     and so differ only when `LL.3u` is selected. Pass
#'     `modelling = toxdrc_modelling(type = "absolute")` to report raw
#'     response levels instead.}
#'   \item{`"normalized"`}{A continuous response in arbitrary units, blank
#'     corrected and expressed relative to a control group. Because
#'     normalization puts the control at 1 and complete effect at 0 by
#'     construction, the toxicity threshold is absolute rather than relative,
#'     and the models fix those bounds instead of estimating them: `LL.2`
#'     fixes both, and `LL.3` estimates the upper limit for data where
#'     responses run above 1 through noise or stimulation.}
#' }
#'
#' Presets set `blank.label` and `relative.label` to their defaults, since
#'  they cannot know how your groups are labelled. Override the whole
#'  `normalization` block if yours differ; see examples.
#'
#' @param name Character. Which preset to return.
#'
#' @returns A named list of configuration objects, with class
#'  `toxdrc_preset`, containing `endpoint`, `qc`, `normalization`,
#'  `toxicity`, `modelling`, and `output`.
#'
#' @examples
#' toxdrc_preset("quantal")
#'
#' # A preset is a starting point. To keep its settings but change the group
#' # labels, pass a replacement for that block only.
#' \donttest{
#' runtoxdrc(
#'   dataset       = cellglow,
#'   Conc          = Conc,
#'   Response      = RFU,
#'   IDcols        = c("Test_Number", "Dye", "Replicate", "Type"),
#'   quiet         = TRUE,
#'   preset        = toxdrc_preset("normalized"),
#'   normalization = toxdrc_normalization(
#'     blank.correction = TRUE,
#'     normalize.resp   = TRUE,
#'     blank.label      = "Blank",
#'     relative.label   = 0
#'   )
#' )
#' }
#'
#' @importFrom drc LL.3
#'
#' @seealso [runtoxdrc()], [config_runtoxdrc]
#'
#' @export
#'
toxdrc_preset <- function(name = c("continuous", "quantal", "normalized")) {
  name <- match.arg(name)

  preset <- switch(
    name,

    continuous = list(
      endpoint      = toxdrc_endpoint(),
      qc            = toxdrc_qc(),
      normalization = toxdrc_normalization(),
      toxicity      = toxdrc_toxicity(),
      modelling     = toxdrc_modelling(),
      output        = toxdrc_output()
    ),

    quantal = list(
      endpoint = toxdrc_endpoint(type = "binomial"),
      # CV across replicate proportions is computable but not very
      # informative: binomial variance is structural, p(1-p)/n, rather than a
      # nuisance to flag. Grubbs' outlier removal assumes normality and is
      # refused for quantal data anyway.
      qc = toxdrc_qc(cv.flag = FALSE, outlier.test = FALSE),
      normalization = toxdrc_normalization(),
      # The response is already an affected fraction, so the threshold is
      # read directly rather than relative to a control, and effect increases
      # with dose.
      toxicity = toxdrc_toxicity(
        toxic.lvl       = 0.2,
        toxic.type      = "absolute",
        toxic.direction = "above",
        comp.group      = 0
      ),
      # model.list is left NULL so it resolves to the binomial default,
      # LL.2 and LL.3u, and cannot drift from it.
      #
      # type is stated rather than inherited, because it decides what the
      # reported LC50 means. For a quantal fit the relative effect level is
      # algebraically Abbott's correction: with the lower limit at the control
      # response c and the upper fixed at 1, solving
      # p = c + 0.5 * (1 - c) is the same as (p - c) / (1 - c) = 0.5, the
      # concentration affecting half of the organisms that would otherwise
      # have survived. Absolute would instead report raw 50 percent mortality,
      # background deaths included. The two coincide whenever there is no
      # control mortality, which is why this only matters when LL.3u wins.
      modelling = toxdrc_modelling(
        type        = "relative",
        interpolate = TRUE,
        partial.tol = 0.2
      ),
      output = toxdrc_output()
    ),

    normalized = list(
      endpoint      = toxdrc_endpoint(),
      qc            = toxdrc_qc(),
      normalization = toxdrc_normalization(
        blank.correction = TRUE,
        normalize.resp   = TRUE
      ),
      # Normalization puts the control at 1, so 0.7 of control is simply an
      # absolute threshold of 0.7.
      toxicity = toxdrc_toxicity(
        toxic.lvl       = 0.7,
        toxic.type      = "absolute",
        toxic.direction = "below"
      ),
      # Both bounds are known by construction rather than estimated: the
      # control is 1 because the data were divided by it, and complete effect
      # is 0. LL.2 fixes both; LL.3 estimates the upper limit as a fallback
      # for responses that run above 1.
      modelling = toxdrc_modelling(
        model.list = list("LL.2" = LL.2(), "LL.3" = LL.3())
      ),
      output = toxdrc_output()
    )
  )

  preset$name <- name
  class(preset) <- c("toxdrc_preset", "list")
  preset
}


#' Print a toxdrc preset
#'
#' @param x A `toxdrc_preset`.
#' @param ... Ignored.
#'
#' @returns `x`, invisibly.
#'
#' @export
#'
print.toxdrc_preset <- function(x, ...) {
  cat("<toxdrc preset: ", x$name, ">\n", sep = "")

  blocks <- setdiff(names(x), "name")

  for (block in blocks) {
    settings <- x[[block]]
    shown <- vapply(
      settings,
      function(value) {
        if (is.null(value)) {
          "NULL"
        } else if (is.list(value)) {
          paste0("<", paste(names(value), collapse = ", "), ">")
        } else {
          paste(format(value), collapse = ", ")
        }
      },
      character(1)
    )

    cat("\n$", block, "\n", sep = "")
    cat(paste0("  ", format(names(shown)), "  ", shown, collapse = "\n"))
    cat("\n")
  }

  invisible(x)
}


#' Resolve a preset argument to a list of configuration objects
#'
#' Accepts a preset object or the name of one, so `preset = "quantal"` works
#' as shorthand.
#'
#' @param preset A `toxdrc_preset`, a character name, or NULL.
#'
#' @noRd
#'
resolve_preset <- function(preset) {
  if (is.null(preset)) {
    return(toxdrc_preset("continuous"))
  }

  if (is.character(preset)) {
    if (length(preset) != 1) {
      toxdrc_abort(
        c(
          "`preset` must name a single preset.",
          "x" = paste0("Received ", length(preset), " values.")
        ),
        class = "bad_preset"
      )
    }
    return(toxdrc_preset(preset))
  }

  if (!inherits(preset, "toxdrc_preset")) {
    toxdrc_abort(
      c(
        "`preset` must come from toxdrc_preset().",
        "x" = paste0("Received an object of class <", class(preset)[1], ">."),
        "i" = "Example: preset = toxdrc_preset(\"quantal\"), or preset = \"quantal\"."
      ),
      class = "bad_preset"
    )
  }

  preset
}
