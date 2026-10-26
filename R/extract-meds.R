
#Load the data
extract_meds <- function(wide) {
    #Pull out meds

    # source("R/load-data.R")
    # wide<-load_data()

    meds_wide <- wide %>%
    select(starts_with("medication__") | starts_with("patient_id"))

    names(meds_wide)
    
    #Make long - group
    meds_long <- meds_wide %>%
        pivot_longer(-patient_id, # Pivot every column EXCEPT patient_id
                    # Split each column name at __. 
                    # First two parameters make it longer by first parts of column names.
                    # .value stays as the longer column names.
                    names_to = c("group", "slot", ".value"), 
                    # Indicates the delimiter to split by.
                    names_sep = "__") 

    # Filter out null values           
        meds_long <- meds_long %>%
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

    # Add ID / Primary Key
    meds_long <- meds_long %>%
        mutate(medication_id = row_number())

    # Move Medication ID first then patient_id
    meds_long <- meds_long %>%
        relocate(medication_id, patient_id)
}

