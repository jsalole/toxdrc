NT_toxresult <- toxresult
NT_toxresult$RFU <- c(10001:10024)


test_that("non-toxic check toxicity, rel", {
  expect_equal(
    checktoxicity(
      NT_toxresult,
      Conc = Conc,
      Response = RFU,
      effect = 0.7,
      type = "rel",
      reference_group = "Control"
    ),
    FALSE
  )
})

test_that("non-toxic check toxicity, abs", {
  expect_equal(
    checktoxicity(
      NT_toxresult,
      Conc = Conc,
      Response = RFU,
      effect = 10000,
      type = "abs"
    ),
    FALSE
  )
})

test_that("toxic check toxicity, abs", {
  expect_equal(
    checktoxicity(
      toxresult,
      Conc = Conc,
      Response = RFU,
      effect = 8000,
      type = "abs"
    ),
    TRUE
  )
})

# problem
test_that("toxic check toxicity, rel", {
  expect_equal(
    checktoxicity(
      toxresult,
      Conc = Conc,
      Response = RFU,
      effect = 0.5,
      type = "relative"
    ),
    TRUE
  )
})
