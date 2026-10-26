library(dplyr)
library(tidyr)
library(testthat)

# Needed to load the function for testing in GitHub.
source(testthat::test_path("../../R/extract-problems.r"))

# ---- Step 1: Write down what the database table expects -------------------
# These are copied from the `problems` table in create-db.r.
# If the table changes, update this list too.
expected_problems <- data.frame(
  column   = c("problem_id", "patient_id", "problem_slot", "snomed_code",
               "problem_name", "problem_onset_date", "problem_status"),
  sql_type = c("INT", "VARCHAR(10)", "INT", "VARCHAR(20)",
               "VARCHAR(150)", "DATE", "VARCHAR(20)"),
  not_null = c(TRUE, TRUE, FALSE, TRUE,
               FALSE, FALSE, FALSE),
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
# Like the real data, everything is text. P2 has no problems at all, so the
# function should drop that empty slot.
wide_fixture <- tibble(
  patient_id              = c("P1", "P2"),
  problem__1__snomed_code = c("44054006", NA),
  problem__1__display     = c("Type 2 diabetes mellitus", NA),
  problem__1__onset_date  = c("2018-06-15", NA),
  problem__1__status      = c("Active", NA)
)

# ---- Step 4: Run the function ---------------------------------------------
problems_out <- extract_problems(wide_fixture)

# ---- Test 1: column names --------------------------------------------------
test_that("problems column names match the problems table", {
  # sort() because column ORDER does not matter when appending by name
  expect_equal(
    sort(names(problems_out)),
    sort(expected_problems$column),
    info = paste0(
      "\nData frame has: ", toString(sort(names(problems_out))),
      "\nSQL table has:  ", toString(sort(expected_problems$column))
    )
  )
})

# ---- Test 2: NOT NULL columns ---------------------------------------------
test_that("columns that are NOT NULL in the table contain no NA values", {
  required <- expected_problems$column[expected_problems$not_null]

  for (col in required) {
    n_missing <- sum(is.na(problems_out[[col]]))
    expect_equal(
      n_missing, 0,
      info = paste0("Column '", col, "' is NOT NULL in SQL but has ",
                    n_missing, " missing value(s).")
    )
  }
})

# ---- Test 3: data types ----------------------------------------------------
test_that("every value can be stored as the table's SQL type", {
  for (i in seq_len(nrow(expected_problems))) {
    col  <- expected_problems$column[i]
    type <- expected_problems$sql_type[i]
    vals <- problems_out[[col]][!is.na(problems_out[[col]])]
    ok   <- fits_sql_type(vals, type)

    expect_true(
      all(ok),
      info = paste0("Column '", col, "' should fit SQL type ", type,
                    ". Bad value(s): ", toString(vals[!ok]))
    )
  }
})
