# proposal.R
# 
# estimate number of patients available for study

source("library.R")

# get list of patients from charge data
dexmed <- read_data(proposal.dir, "patients") %>%
    transmute(pie.id = PowerInsight.Encounter.Id,
              cdm = Cdm.Code,
              cdm.desc = factor(Cdm.Desc),
              service.date = ymd_hms(Service.Date),
              inst.code = factor(Institution.Code),
              inst.name = factor(Institution.Desc)) %>%
    distinct(pie.id) 

# make list of encounters for EDW
edw.pie <- concat_encounters(dexmed$pie.id, 500)
print(edw.pie)

