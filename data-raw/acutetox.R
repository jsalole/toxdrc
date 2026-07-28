# Generation script for the `acutetox` example dataset.
#
# Run from the package root to regenerate data/acutetox.rda:
#     source("data-raw/acutetox.R")
#
# The data are SIMULATED, not measured. Counts are computed deterministically
# from known log-logistic curves rather than sampled at random, so the dataset
# is identical across R versions and tests can assert exact recovery of the
# generating values. Replicate variation is a fixed offset of 0, +1 and -1
# affected organisms, clamped to the group size.
#
# Design: 20 organisms per group, six concentrations on a roughly half-log
# series, three replicates, three substances. Each substance exercises a
# different path through the "quantal" preset.
#
#   Graded (101)
#     e = 10, slope = 0.9, no control mortality.
#     Pooled response 0, 0.10, 0.25, 0.50, 0.75, 0.90.
#     Three concentrations fall inside the partial-effect band, so a model
#     fits and interpolation does not trigger. LC50 is 10 by construction.
#
#   Steep (102)
#     No partial responses anywhere: nothing affected at or below 10,
#     everything affected at 32 and above. The slope is unidentifiable, so no
#     model can be fitted and log-linear interpolation applies instead.
#     Expected EC50 is sqrt(10 * 32) = 17.88854.
#
#   Background (103)
#     e = 10, slope = 0.9, with 10 percent control mortality.
#     The lower limit is not zero, so LL.3u has a reason to be preferred over
#     LL.2. Note the absolute 50 percent point is 7.804, not 10: the e
#     parameter is where the curve is halfway between its limits, which is not
#     halfway between 0 and 1 once the lower limit is raised.

acutetox <- data.frame(
  TestID = c(
    "101_Graded_A", "101_Graded_A", "101_Graded_A", "101_Graded_A",
    "101_Graded_A", "101_Graded_A", "101_Graded_B", "101_Graded_B",
    "101_Graded_B", "101_Graded_B", "101_Graded_B", "101_Graded_B",
    "101_Graded_C", "101_Graded_C", "101_Graded_C", "101_Graded_C",
    "101_Graded_C", "101_Graded_C", "102_Steep_A", "102_Steep_A",
    "102_Steep_A", "102_Steep_A", "102_Steep_A", "102_Steep_A",
    "102_Steep_B", "102_Steep_B", "102_Steep_B", "102_Steep_B",
    "102_Steep_B", "102_Steep_B", "102_Steep_C", "102_Steep_C",
    "102_Steep_C", "102_Steep_C", "102_Steep_C", "102_Steep_C",
    "103_Background_A", "103_Background_A", "103_Background_A",
    "103_Background_A", "103_Background_A", "103_Background_A",
    "103_Background_B", "103_Background_B", "103_Background_B",
    "103_Background_B", "103_Background_B", "103_Background_B",
    "103_Background_C", "103_Background_C", "103_Background_C",
    "103_Background_C", "103_Background_C", "103_Background_C"
  ),
  Test_Number = c(
    101, 101, 101, 101, 101, 101, 101, 101, 101, 101, 101, 101,
    101, 101, 101, 101, 101, 101, 102, 102, 102, 102, 102, 102,
    102, 102, 102, 102, 102, 102, 102, 102, 102, 102, 102, 102,
    103, 103, 103, 103, 103, 103, 103, 103, 103, 103, 103, 103,
    103, 103, 103, 103, 103, 103
  ),
  Substance = c(
    "Graded", "Graded", "Graded", "Graded", "Graded", "Graded",
    "Graded", "Graded", "Graded", "Graded", "Graded", "Graded",
    "Graded", "Graded", "Graded", "Graded", "Graded", "Graded",
    "Steep", "Steep", "Steep", "Steep", "Steep", "Steep", "Steep",
    "Steep", "Steep", "Steep", "Steep", "Steep", "Steep", "Steep",
    "Steep", "Steep", "Steep", "Steep", "Background", "Background",
    "Background", "Background", "Background", "Background",
    "Background", "Background", "Background", "Background",
    "Background", "Background", "Background", "Background",
    "Background", "Background", "Background", "Background"
  ),
  Replicate = c(
    "A", "A", "A", "A", "A", "A", "B", "B", "B", "B", "B", "B",
    "C", "C", "C", "C", "C", "C", "A", "A", "A", "A", "A", "A",
    "B", "B", "B", "B", "B", "B", "C", "C", "C", "C", "C", "C",
    "A", "A", "A", "A", "A", "A", "B", "B", "B", "B", "B", "B",
    "C", "C", "C", "C", "C", "C"
  ),
  Conc = c(
    0, 1, 3.2, 10, 32, 100, 0, 1, 3.2, 10, 32, 100, 0, 1, 3.2, 10,
    32, 100, 0, 1, 3.2, 10, 32, 100, 0, 1, 3.2, 10, 32, 100, 0, 1,
    3.2, 10, 32, 100, 0, 1, 3.2, 10, 32, 100, 0, 1, 3.2, 10, 32,
    100, 0, 1, 3.2, 10, 32, 100
  ),
  Affected = c(
    0, 2, 5, 10, 15, 18, 0, 3, 6, 11, 16, 19, 0, 1, 4, 9, 14, 17,
    0, 0, 0, 0, 20, 20, 0, 0, 0, 0, 20, 20, 0, 0, 0, 0, 20, 20, 2,
    4, 7, 11, 15, 18, 3, 5, 8, 12, 16, 19, 1, 3, 6, 10, 14, 17
  ),
  Total = c(
    20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20,
    20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20,
    20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20,
    20, 20, 20, 20, 20, 20
  ),
  stringsAsFactors = FALSE
)

# Affected fraction, for the default response.type = "proportion" path.
# The Affected and Total columns support response.type = "count" directly.
acutetox$Prop <- acutetox$Affected / acutetox$Total

stopifnot(
  nrow(acutetox) == 54,
  all(acutetox$Affected >= 0 & acutetox$Affected <= acutetox$Total),
  all(acutetox$Prop >= 0 & acutetox$Prop <= 1)
)

save(
  acutetox,
  file = "data/acutetox.rda",
  version = 2,
  compress = "xz"
)
