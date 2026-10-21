
extract_problems<- function(wide) {
    # Used to load data - replaced with function paramaeter
    # source("R/load-data.R")
    # wide<-load_data()

    # names(wide)

    problems_wide <- wide %>%
    select(starts_with("problem__") | starts_with("patient_id"))

    #Select just what you want.
    problems_long <- problems_wide %>%
    select(patient_id, starts_with("problem__"))

    # names(problems_long)

    # pivot_longer
    problems_long<-problems_long %>%
    pivot_longer(-patient_id,
                names_to = c("group", "slot", ".value"),
                names_sep = "__") %>%
    filter(!is.na(snomed_code)) 

    #Drop unneeded columns
    problems_long <- problems_long %>%
    select(-group)

    # names(problems_long)

    #Rename potentially confusing columns after a join
    problems_long <- problems_long %>%
        rename(
        problem_name   = display,
        problem_status = status,
        problem_slot = slot,
        problem_onset_date = onset_date
    )

    # names(problems_long)

    # Add ID
    problems_long <- problems_long %>%
    mutate(problem_id = row_number())

    # Move Problem ID first then patient_id
    problems_long <- problems_long %>%
    relocate(problem_id, patient_id)
}
