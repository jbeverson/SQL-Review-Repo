extract_patient <- function(wide) {
    # Drop unnecessary columns
    patient <- wide %>%
    select(!starts_with(c("medication__", "problem__", "lab__")))
    
    #Check columns
    names(patient)

    # Drop additional unnecessary columns.
    patient <- patient %>%
    select(!starts_with("n_"))

    # Change to date
    patient <- patient %>%
    mutate(
        date_of_birth = as.Date(date_of_birth),
        date_of_death = as.Date(date_of_death)
    )

    # Check NA by birth
    sum(is.na(patient$date_of_birth))
    
    # Check for duplicates - when ran
    stopifnot("patient_id must be unique" = !anyDuplicated(patient$patient_id), !anyNA(patient$patient_id))

    # Function returns last valu.
    patient
}