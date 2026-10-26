library(dplyr)
library(tidyr)
library(testthat)

# Needed to load the function for testing in GitHub.
source(testthat::test_path("../../R/extract-labs.R"))

# ---- Step 1: Write down what the database table expects -------------------
# These are copied from the `labs` table in create-db.r.
# If the table changes, update this list too.
expected_labs <- data.frame(
  column   = c("lab_id", "lab_slot", "patient_id", "loinc_code", "lab_name",
               "lab_value", "unit", "ref_low", "ref_high", "flag", "lab_date"),
  sql_type = c("INT", "INT", "VARCHAR(10)", "VARCHAR(20)", "VARCHAR(150)",
               "DECIMAL", "VARCHAR(20)", "DECIMAL", "DECIMAL", "CHAR(1)",
               "DATE"),
  not_null = c(TRUE, FALSE, TRUE, TRUE, FALSE,
               FALSE, FALSE, FALSE, FALSE, FALSE,
               FALSE),
  stringsAsFactors = FALSE
)

# ---- Step 2: A helper that asks "does this value fit this SQL type?" ------
# Our data is text, so we check the text could be stored in the SQL column.
fits_sql_type <- function(x, sql_type) {
  x <- x[!is.na(x)]
  if (sql_type == "INT")     return(!is.na(suppressWarnings(as.integer(x))))
  if (sql_type == "DECIMAL") return(!is.na(suppressWarnings(as.numeric(x))))
  if (sql_type == "DATE")    return(!is.na(as.Date(x, format = "%Y-%m-%d")))
  # VARCHAR(n) / CHAR(n): the text must not be longer than n
  max_len <- as.integer(sub(".*\\((\\d+)\\)", "\\1", sql_type))
  nchar(x) <= max_len
}

# ---- Step 3: Build a tiny "wide" input ------------------------------------
# Like the real data, everything is text. P2 has no labs at all, so the
# function should drop that empty slot.
wide_fixture <- tibble(
  patient_id          = c("P1", "P2"),
  lab__1__loinc_code  = c("4548-4", NA),
  lab__1__name        = c("Hemoglobin A1c", NA),
  lab__1__value       = c("7.2", NA),
  lab__1__unit        = c("%", NA),
  lab__1__ref_low     = c("4.0", NA),
  lab__1__ref_high    = c("5.6", NA),
  lab__1__flag        = c("H", NA),
  lab__1__date        = c("2023-03-01", NA)
)

# ---- Step 4: Run the function ---------------------------------------------
labs_out <- extract_labs(wide_fixture)

# ---- Test 1: column names --------------------------------------------------
test_that("labs column names match the labs table", {
  # sort() because column ORDER does not matter when appending by name
  expect_equal(
    sort(names(labs_out)),
    sort(expected_labs$column),
    info = paste0(
      "\nData frame has: ", toString(sort(names(labs_out))),
      "\nSQL table has:  ", toString(sort(expected_labs$column))
    )
  )
})

# ---- Test 2: NOT NULL columns ---------------------------------------------
test_that("columns that are NOT NULL in the table contain no NA values", {
  required <- expected_labs$column[expected_labs$not_null]

  for (col in required) {
    n_missing <- sum(is.na(labs_out[[col]]))
    expect_equal(
      n_missing, 0,
      info = paste0("Column '", col, "' is NOT NULL in SQL but has ",
                    n_missing, " missing value(s).")
    )
  }
})

# ---- Test 3: data types ----------------------------------------------------
test_that("every value can be stored as the table's SQL type", {
  for (i in seq_len(nrow(expected_labs))) {
    col  <- expected_labs$column[i]
    type <- expected_labs$sql_type[i]
    vals <- labs_out[[col]][!is.na(labs_out[[col]])]
    ok   <- fits_sql_type(vals, type)

    expect_true(
      all(ok),
      info = paste0("Column '", col, "' should fit SQL type ", type,
                    ". Bad value(s): ", toString(vals[!ok]))
    )
  }
})
