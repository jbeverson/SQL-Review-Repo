#
#
#
#
#
#
#| label: setup
library(DBI)
library(RMariaDB)
#
#
#
#
#
#
#
#
patients_df <- dbGetQuery(con, "
  SELECT patient_id, first_name, last_name, date_of_birth
  FROM patients;
  ")

# Check number of rows returned and distinct patients. They should match.
tibble::tibble(
  rows              = nrow(patients_df),
  distinct_patients = n_distinct(patients_df$patient_id)
)
#
#
#
#
#
#
patients_df <- dbGetQuery(con, "
  SELECT patient_id, first_name, last_name, date_of_birth
  FROM patients
  ORDER BY date_of_birth
  LIMIT 5;
  ")

patients_df
#
#
#
#
labs_df <- dbGetQuery(con, "
  SELECT DISTINCT loinc_code, lab_name
  FROM labs;
  ")

# Check number of rows returned and distinct labs. They should be different.
tibble::tibble(
  rows              = nrow(labs_df),
  distinct_patients = n_distinct(labs_df$loinc_code)
)
#
#
#
#
labs_df <- dbGetQuery(con, "
  SELECT loinc_code,
  COUNT(*) AS row_count
  FROM labs;
  GROUP BY loinc_code
  ")

labs_df

ggplot(labs_df, aes(x = row_count, y = reorder(loinc_code, row_count))) + 
geom_col()
#
#
#
#
pt_lab_count <- dbGetQuery(con, 
    "SELECT patient_id, COUNT(*) AS n_labs
    FROM labs
    GROUP BY patient_id
    ORDER BY n_labs DESC, patient_id;
    ")

# Check number of rows returned and distinct labs. They should be different.
tibble::tibble(
  rows              = nrow(pt_lab_count$patient_id),
  distinct_patients = n_distinct(pt_lab_count$patient_id)
)

#
#
#
#
#
#
