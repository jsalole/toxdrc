# toxdrc 2.0.0

This release adds support for quantal endpoints, introduces configuration presets, and changes how model selection works. As model selection has changed, results with the new version may be slightly different. The changes are listed in order of importance.

* **The `model.list` argument had no effect.** `toxdrc_modelling()` accepted
  `model.list` but omitted it from the list it returned, so `modelcomp()` always
  fell back to its internal defaults. Custom model lists are now used in its place.

* **The default model list for continuous data is now `LL.4` alone**, rather
  than `LL.4`, `LN.4`, `W1.4` and `W2.4`. Model comparison is opt-in. To restore 
  comparisons, supply more than one entry to `model.list` to restore it.

* `getECx()` now defaults to `type = "relative"`, matching
  `toxdrc_modelling()`. Previously the two disagreed, so calling the function
  directly and running the pipeline gave different answers from the same
  arguments.

## Breaking changes

* `runtoxdrc()` gained the `N`, `endpoint` and `preset` arguments, and its
  configuration arguments now default to `NULL` so that a preset can supply
  them. Named calls are unaffected; positional calls after `quiet` will shift.

* `model.list` must be a named list whose names match the model each entry
  holds, for example `list("LL.4" = LL.4())`. Its default is now `NULL` and is selected
  based on endpoint type.

* Naming a column in `IDcols` that does not exist is now an error. Previously
  `averageresponse()` warned and continued, so the column was quietly absent
  from the results.

* A reference, blank or control label that does not match the data is now an
  error. Previously it resulted in `NaN` through the threshold calculation.

* Configuration helpers validate their arguments, so calls such as
  `toxdrc_qc(cv.flag = "yes")` or `toxdrc_modelling(level = 95)` now fail
  rather than being accepted. 

## New features

* **Quantal endpoints.** Set `endpoint = toxdrc_endpoint(type = "binomial")`
  and give the group sizes with `N` to fit binary data such as mortality.
  Models are fitted with `drc::drm(type = "binomial")`, weighted by group size,
  and default to comparing `LL.2` against `LL.3u`. Replicates are pooled by
  group size rather than averaged, so a proportion from 30 of 60 counts for
  more than one from 1 of 4. The response may be given as a proportion or, with
  `response.type = "count"`, as the number affected.

  Blank correction, normalization and Grubbs' outlier removal are refused for
  quantal data, each with an error naming the alternative. `"Res var"` is
  unavailable as `model.metric`, since a binomial fit has no residual variance.

* **`interpolateECx()`** estimates an effect concentration by log-linear
  interpolation between the bracketing concentrations, for quantal tests where
  no concentration produced a partial effect and no model can be fitted. The
  EC50 is the geometric mean of the two, which does not depend on the unknown
  shape of the curve. Enable it in the pipeline with
  `toxdrc_modelling(interpolate = TRUE)`; such estimates are marked
  `best_model_name = "interpolated"` and carry no confidence interval. Effect
  levels other than 50% are computed with a warning, since with no partial
  responses they largely restate the bracketing concentrations.

* **`toxdrc_preset()`** returns complete configurations for common designs:
  `"continuous"`, `"quantal"`, and `"normalized"` for blank-corrected data
  expressed relative to a control. Pass one as `preset` to `runtoxdrc()`;
  anything given explicitly overrides it. Presets are ordinary lists and can be
  printed to see every setting. Contact the package authours for support with 
  additional presets.

* **`acutetox`**, a simulated acute lethality dataset with a quantal endpoint.
  Its three substances exercise a normal fit, the no-partial-response case that
  triggers interpolation, and control mortality that favours `LL.3u`. Counts are
  constructed deterministically from known curves, so the generating values can
  be recovered exactly. See `data-raw/acutetox.R`.

## Bug fixes

* `getECx()` returned a bare data frame when `drc::ED()` failed, even when
  `list_obj` was supplied, so `runtoxdrc()` received the wrong object for that
  subset. It now returns the list.

* The placeholder returned when no estimate could be produced had different
  column names from a successful result, because `data.frame()` renamed
  "Effect Measure" and "Std. Error" by default.

* Condensing results failed when a run produced both subsets with point
  estimates and subsets without, because the two produced different columns.

* Fields such as `model` and `model_df` disappeared from an entry when nothing
  could be fitted, because assigning `NULL` to a list element removes it. They
  are now present and `NULL`.

* `mselect2()` returned the baseline model twice, once in its own right and
  once as a member of the comparison list, and collapsed to a vector when only
  one model was supplied.

* A failed lack-of-fit test aborted the whole run. `drc::modelFit()` performs
  its own optimisation and can fail on data the model itself fitted; it is now
  caught and recorded as `NA`.

* `runtoxdrc()` failed when `IDcols` was not supplied. The whole dataset is now
  treated as a single subset.

* Model comparison was fragile in a way that could silently produce a table of
  `NA` scores. `mselect2()` refits candidates with `update()`, which
  re-evaluates the model's stored call, so models must be fitted in a way that
  leaves that call resolvable.

* With `quiet = TRUE`, drc's own reports of failed optimisations are no longer
  printed. They are written directly to the console rather than raised as
  conditions, so neither `suppressWarnings()` nor `suppressMessages()` affected
  them.

## Documentation and internals

* Errors are raised as classed conditions inheriting from `toxdrc_error`, so
  they can be caught and tested by class rather than by matching message text.
  Messages name the offending value and, where useful, the alternative.

* Function documentation revised throughout, including corrected cross
  references and several malformed help pages.

* Test coverage expanded substantially, including the previously untested
  internals and the numerical plausibility of estimates rather than only their
  structure.


# toxdrc 1.0.1

* Initial documented release.
