library(dplyr)
library(tidyr)
library(readr)
library(testthat)

# Needed to load the function for testing in GitHub.
source(testthat::test_path("../../R/extract-meds.R"))

wide_fixture <- read_csv(
  test_path("../../data/test-fixtures/meds_wide_fixture.csv"),
  col_types = cols(.default = col_character())
)
test_that("one row per filled slot", {
  expect_equal(nrow(extract_meds(wide_fixture)), 3)
})

test_that("values stay with the right patient and slot", {
  out <- extract_meds(wide_fixture)
  expect_equal(out$medication_name[out$patient_id == "P3"], "lisinopril 10 mg")
  p1 <- out$medication_name[out$patient_id == "P1"]
expected_p1 <- c("metformin 500 mg", "amlodipine 5 mg")
expect_equal(sort(p1), sort(expected_p1),
             info = paste("P1 got:", toString(p1)))
})