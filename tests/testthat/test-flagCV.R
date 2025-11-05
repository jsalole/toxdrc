highCV_toxresult <- toxresult
highCV_toxresult$RFU[15:17] <- c(1000, 5000, 10000)
highCV_toxresult_f <- highCV_toxresult %>%
  dplyr::group_by(Conc) %>%
  mutate(
    meanRFU = mean(RFU),
    sdRFU = sd(RFU),
    CV = sdRFU / meanRFU * 100
  ) %>%
  dplyr::select(-c("meanRFU", "sdRFU")) %>%
  dplyr::ungroup() %>%
  mutate(
    CVflag = ifelse(CV > 30, "*", "")
  ) %>%
  dplyr::select((-c("CV")))
highCV_toxresult_f <- as.data.frame(highCV_toxresult_f)

lowCV_toxresult <- toxresult %>%
  dplyr::group_by(Conc) %>%
  mutate(
    meanRFU = mean(RFU),
    sdRFU = sd(RFU),
    CV = sdRFU / meanRFU * 100
  ) %>%
  dplyr::select(-c("meanRFU", "sdRFU")) %>%
  dplyr::ungroup() %>%
  mutate(
    CVflag = ifelse(CV > 30, "*", "")
  ) %>%
  dplyr::select((-c("CV")))

lowCV_toxresult <- as.data.frame(lowCV_toxresult)

test_that("flags high CV concs", {
  expect_equal(
    flagCV(
      dataset = highCV_toxresult,
      Conc = Conc,
      Response = RFU,
      max_val = 30
    ),
    highCV_toxresult_f
  )
})

test_that("no flag for low CV", {
  expect_equal(
    flagCV(
      dataset = toxresult,
      Conc = Conc,
      Response = RFU,
      max_val = 30
    ),
    lowCV_toxresult
  )
})
