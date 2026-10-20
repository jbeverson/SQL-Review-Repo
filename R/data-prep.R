library(tidyverse)

wide_fixture <- tibble(
  patient_id = c("P1", "P2", "P3"),
  medication__1__rxnorm_code = c("861007", NA, "314076"),
  medication__1__name        = c("metformin 500 mg", NA, "lisinopril 10 mg"),
  medication__1__sig         = c("1 tab BID", NA, "1 tab daily"),
  medication__1__start_date  = c("2020-01-01", NA, "2019-05-05"),
  medication__1__status      = c("Active", NA, "Active"),
  medication__2__rxnorm_code = c("197361", NA, NA),
  medication__2__name        = c("amlodipine 5 mg", NA, NA),
  medication__2__sig         = c("1 tab daily", NA, NA),
  medication__2__start_date  = c("2021-02-02", NA, NA),
  medication__2__status      = c("Active", NA, NA)
)

readr::write_csv(wide_fixture, "data/test-fixtures/meds_wide_fixture.csv")