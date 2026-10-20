
#Load the data
extract_meds <- function(wide) {
    #Pull out meds
    meds_wide <- wide %>%
    select(starts_with("medication__") | starts_with("patient_id"))

    #Make long
    meds_long <- meds_wide %>%
    select(patient_id, starts_with("medication__")) %>%
    pivot_longer(-patient_id,
                names_to = c("group", "slot", ".value"),
                names_sep = "__") %>%
    filter(!is.na(rxnorm_code)) 

    #Drop unneeded columns
    meds_long <- meds_long %>%
    select(-group)

    #Rename potentially confusing columns after a join
    meds_long <- meds_long %>%
        rename(
        medication_name   = name,
        medication_status = status
    )

    # Add ID
    meds_long <- meds_long %>%
    mutate(medication_id = row_number())

    # Move Medication ID first then patient_id
    meds_long <- meds_long %>%
    relocate(medication_id, patient_id)
}

