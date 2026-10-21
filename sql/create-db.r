library(DBI)

con <- dbConnect(
  RMariaDB::MariaDB(),
  host     = "hank.test",
  user     = "root",
  bigint   = "integer"        # COUNT(*) comes back as integer, not integer64
)

dbExecute(con, "CREATE DATABASE IF NOT EXISTS ehr_synth CHARACTER SET utf8mb4")
dbExecute(con, "USE ehr_synth")

# Drop in reverse order so foreign keys don't block it (makes the script re-runnable)
for (t in c("labs", "medications", "problems", "patients")) {
  dbExecute(con, paste("DROP TABLE IF EXISTS", t))
}

dbExecute(con, "
CREATE TABLE patients (
  patient_id VARCHAR(10) PRIMARY KEY,
  first_name VARCHAR(50), middle_name VARCHAR(50), last_name VARCHAR(50),
  name_suffix VARCHAR(10), previous_name VARCHAR(100),
  birth_sex VARCHAR(3), date_of_birth DATE NOT NULL, date_of_death DATE,
  race VARCHAR(100), ethnicity VARCHAR(50), tribal_affiliation VARCHAR(100),
  sexual_orientation VARCHAR(50), gender_identity VARCHAR(50),
  preferred_language VARCHAR(50),
  current_address_line1 VARCHAR(100), current_address_city VARCHAR(50),
  current_address_state CHAR(2), current_address_postal_code VARCHAR(10),
  previous_address_line1 VARCHAR(100), previous_address_city VARCHAR(50),
  previous_address_state CHAR(2), previous_address_postal_code VARCHAR(10),
  phone_number VARCHAR(20), phone_number_type VARCHAR(10),
  email_address VARCHAR(100),
  related_person_name VARCHAR(100), related_person_relationship VARCHAR(30),
  occupation VARCHAR(60), occupation_industry VARCHAR(60)
) ENGINE = InnoDB")

dbExecute(con, "
CREATE TABLE problems (
  problem_id INT PRIMARY KEY,
  patient_id VARCHAR(10) NOT NULL,
  snomed_code VARCHAR(20) NOT NULL,
  problem_display VARCHAR(150),
  onset_date DATE,
  problem_status VARCHAR(20),
  FOREIGN KEY (patient_id) REFERENCES patients (patient_id)
) ENGINE = InnoDB")

dbExecute(con, "
CREATE TABLE medications (
  medication_id INT PRIMARY KEY,
  slot INT,
  patient_id VARCHAR(10) NOT NULL,
  rxnorm_code VARCHAR(20) NOT NULL,
  medication_name VARCHAR(150),
  sig VARCHAR(150),
  start_date DATE,
  medication_status VARCHAR(20),
  FOREIGN KEY (patient_id) REFERENCES patients (patient_id)
) ENGINE = InnoDB")

dbExecute(con, "
CREATE TABLE labs (
  lab_id INT PRIMARY KEY,
  patient_id VARCHAR(10) NOT NULL,
  loinc_code VARCHAR(20) NOT NULL,
  lab_name VARCHAR(150),
  result_value DECIMAL(10,2),
  result_unit VARCHAR(20),
  ref_low DECIMAL(10,2),
  ref_high DECIMAL(10,2),
  result_flag CHAR(1),
  result_date DATE,
  FOREIGN KEY (patient_id) REFERENCES patients (patient_id)
) ENGINE = InnoDB")




dbAppendTable(con, "patients",    patients)
dbAppendTable(con, "medications", meds_long)
#dbAppendTable(con, "problems",    problems_long)
#dbAppendTable(con, "labs",        labs_long)