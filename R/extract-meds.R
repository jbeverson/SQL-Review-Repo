#load data
source("R/load-data.R")
wide<-load_data()

#Keep only meds and Foreign key
meds_wide <- wide %>%
    select(starts_with("medication__") | starts_with("patient_id"))
names(meds_wide)

med_long<-meds_wide %>%
    pivot_longer(-patient_id, # don't pivot FK
    #Split each column name at __. 
    # Save the first part returned to group
    # save the second part to slot
    # save the third part to other values
    names_to=c("group", "slot", ".value"),
    names_sep= "__"
    )

# filter out null values
meds_long<-med_long %>%
    filter(!is.na(rxnorm_code))

meds_long<-meds_long %>%
    select(-group)

meds_long<-meds_long%>%
    mutate(medication_id = row_number())

meds_long<-meds_long%>%
    rename(
        medication_name = name,
        medication_status = status
    )
names(meds_long)

#Move our PK to the front
meds_long<-meds_long %>%
    relocate(medication_id,patient_id)
