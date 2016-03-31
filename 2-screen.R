# 2-screen.R

source("0-library.R")

# exclude these locations
excl.hosp <- c("Memorial Hermann Center for Advanced Heart Failure", 
               "Memorial Hermann Children's Hospital", 
               "Memorial Hermann Clinics", "Memorial Hermann Radiology")

# get data for potential patients; exclude outpatients and pediatric patients
data.demographics <- read_edw_data(screen.dir, "demographics") %>%
    filter(age >= 18,
           !(facility %in% excl.hosp),
           visit.type == "Inpatient") %>%
    mutate(group = ifelse(facility == "Memorial Hermann Hospital", "tmc", 
                          "mhhs")) 

edw.pie <- concat_encounters(data.demographics$pie.id, 750)
print(edw.pie)
