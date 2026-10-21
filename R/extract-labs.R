
extract_labs<- function(wide) {
    # Used to load data - replaced with function paramaeter
    # source("R/load-data.R")
    # wide<-load_data()

    # names(wide)

    labs_wide <- wide %>%
    select(starts_with("lab__") | starts_with("patient_id"))

    #Select just what you want.
    labs_long <- labs_wide %>%
    select(patient_id, starts_with("lab__"))
    names(labs_long)

    # pivot_longer
    labs_long<-labs_long %>%
    pivot_longer(-patient_id,
                names_to = c("group", "slot", ".value"),
                names_sep = "__") %>%
    filter(!is.na(loinc_code)) 

    #Drop unneeded columns
    labs_long <- labs_long %>%
    select(-group)

     names(labs_long)

    #Rename potentially confusing columns after a join
    labs_long <- labs_long %>%
        rename(
        lab_name   = name,
        lab_value = value,
        lab_slot = slot,
        lab_date = date
    )

    # names(labs_long)

    # Add ID
    labs_long <- labs_long %>%
    mutate(lab_id = row_number())

    # Move Lab ID first then patient_id
    labs_long <- labs_long %>%
    relocate(lab_id, patient_id)
}
