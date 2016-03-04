# screen.R

source("library.R")

# exclude these locations
excl.hosp <- c("Memorial Hermann Center for Advanced Heart Failure", 
               "Memorial Hermann Children's Hospital", 
               "Memorial Hermann Clinics", "Memorial Hermann Radiology")

# exclude outpatients and pediatric patients
raw.demograph <- read_edw_data(screen.dir, "demographics") %>%
    distinct %>%
    filter(age >= 18,
           !(facility %in% excl.hosp),
           visit.type == "Inpatient") %>%
    mutate(group = ifelse(facility == "Memorial Hermann Hospital", "tmc", 
                          "mhhs")) %>%
    mutate(group = factor(group))

# get list of eligible patients
edw.pie <- concat_encounters(raw.demograph$pie.id, 750)
print(edw.pie)
