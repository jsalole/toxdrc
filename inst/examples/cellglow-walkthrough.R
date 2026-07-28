# A walkthrough of the toxdrc pipeline using the bundled cellglow data.
#
# Run from the package root after devtools::load_all(), or after installing
# the package with library(toxdrc).

library(toxdrc)

# ---------------------------------------------------------------------------
# 1. The simplest useful run
# ---------------------------------------------------------------------------
# cellglow is fluorescence in arbitrary units, with a "Blank" level and a
# solvent control at Conc == 0, so it is exactly what the "normalized" preset
# is for: blank correct, express relative to the control, then fit.

result <- runtoxdrc(
  dataset  = cellglow,
  Conc     = Conc,
  Response = RFU,
  IDcols   = c("Test_Number", "Dye", "Replicate", "Type"),
  preset   = "normalized",
  quiet    = TRUE
)

length(result)        # one entry per unique combination of IDcols
names(result)[1:3]

# ---------------------------------------------------------------------------
# 2. Look inside a single entry
# ---------------------------------------------------------------------------

entry <- result[[1]]

names(entry)          # every stage that ran leaves something behind
entry$effect          # did the response cross the toxicity threshold?
entry$blank_stats     # mean, sd and CV of the blank level
entry$best_model_name # which model won
entry$effectmeasure   # the point estimate, with confidence interval

# The fitted model is a normal drc object, so drc's own tools work on it.
plot(entry$model, main = entry$ID)
summary(entry$model)

# ---------------------------------------------------------------------------
# 3. The summary table
# ---------------------------------------------------------------------------
# This is the quickest way to see whether the whole pipeline behaved: one row
# per point estimate across every subset.

summary_table <- runtoxdrc(
  dataset  = cellglow,
  Conc     = Conc,
  Response = RFU,
  IDcols   = c("Test_Number", "Dye", "Replicate", "Type"),
  preset   = "normalized",
  quiet    = TRUE,
  output   = toxdrc_output(condense = TRUE)
)

head(summary_table)
nrow(summary_table)

# Sanity checks worth eyeballing:
table(summary_table$best_model_name)      # which models were selected
sum(is.na(summary_table$Estimate))        # subsets with no usable estimate
range(summary_table$Estimate, na.rm = TRUE)

# ---------------------------------------------------------------------------
# 4. Presets are just configuration, and can be overridden
# ---------------------------------------------------------------------------

toxdrc_preset("normalized")   # print it to see every setting

# Keep the preset but ask for three effect levels instead of one. Anything
# passed explicitly replaces that block of the preset; the rest still applies.
multi <- runtoxdrc(
  dataset   = cellglow,
  Conc      = Conc,
  Response  = RFU,
  IDcols    = c("Test_Number", "Dye", "Replicate", "Type"),
  preset    = "normalized",
  quiet     = TRUE,
  modelling = toxdrc_modelling(EDx = c(0.1, 0.5, 0.9)),
  output    = toxdrc_output(condense = TRUE)
)

head(multi[, c("ID", "Effect Measure", "Estimate")])

# ---------------------------------------------------------------------------
# 5. Individual functions still work on their own
# ---------------------------------------------------------------------------
# Nothing requires the pipeline; every stage is usable directly.

one_test <- subset(
  cellglow,
  Test_Number == cellglow$Test_Number[1] & Dye == "aB" & Replicate == "A"
)

corrected <- blankcorrect(one_test, Conc = Conc, blank_group = "Blank",
                          Response = RFU, quiet = TRUE)
normalized <- normalizeresponse(corrected, Conc = Conc, reference_group = 0,
                                Response = c_response, quiet = TRUE)
head(normalized)

# ---------------------------------------------------------------------------
# 6. Errors should tell you what went wrong
# ---------------------------------------------------------------------------
# Each of these fails on purpose. Run them to check the messages are useful.

try(runtoxdrc(cellglow, Conc = Conc, Response = Fluorescence))
try(runtoxdrc(cellglow, Conc = Conc, Response = RFU,
              IDcols = c("Dye", "Plate")))
try(runtoxdrc(cellglow, Conc = Conc, Response = RFU,
              normalization = toxdrc_normalization(blank.correction = TRUE,
                                                   blank.label = "BLANK")))

# ---------------------------------------------------------------------------
# 7. The quantal path
# ---------------------------------------------------------------------------
# cellglow is continuous. acutetox is the quantal counterpart: three simulated
# substances, each exercising a different route through the quantal preset.
# Build it first if needed with source("data-raw/acutetox.R").

quantal_summary <- runtoxdrc(
  dataset  = acutetox,
  Conc     = Conc,
  Response = Prop,
  N        = Total,
  IDcols   = c("Test_Number", "Substance"),
  preset   = "quantal",
  quiet    = TRUE,
  output   = toxdrc_output(condense = TRUE)
)

quantal_summary[, c("ID", "best_model_name", "Effect Measure", "Estimate")]

# Expected, one row per substance:
#
#   Graded      LL.2 or LL.3u   estimate near 10, the generating ED50
#   Steep       "interpolated"  17.889 exactly, being sqrt(10 * 32)
#   Background  LL.3u           estimate near 10
#
# Background picking LL.3u over LL.2 is the model comparison detecting the
# 10 percent control mortality, which LL.2 cannot represent.

# The same data supplied as counts rather than proportions gives identical
# estimates; only the input layout differs.
runtoxdrc(
  dataset  = acutetox,
  Conc     = Conc,
  Response = Affected,
  N        = Total,
  IDcols   = c("Test_Number", "Substance"),
  preset   = "quantal",
  endpoint = toxdrc_endpoint(type = "binomial", response.type = "count"),
  quiet    = TRUE,
  output   = toxdrc_output(condense = TRUE)
)[, c("ID", "Estimate")]

# Relative versus absolute effect levels. With control mortality the two
# genuinely differ: relative measures halfway down the fitted curve, absolute
# measures where half the organisms are affected.
background <- acutetox[acutetox$Substance == "Background", ]

runtoxdrc(background, Conc, Prop, N = Total, preset = "quantal", quiet = TRUE,
          modelling = toxdrc_modelling(type = "relative"))[[1]]$effectmeasure
runtoxdrc(background, Conc, Prop, N = Total, preset = "quantal", quiet = TRUE,
          modelling = toxdrc_modelling(type = "absolute"))[[1]]$effectmeasure
