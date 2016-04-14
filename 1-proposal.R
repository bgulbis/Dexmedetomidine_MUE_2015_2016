# 1-proposal.R
# 
# estimate number of patients available for study

source("0-library.R")

# get list of patients from charge data
charges.dexmed <- read_edw_data(dir.proposal, "patients", "charges") %>%
    distinct(pie.id)

# make list of encounters for EDW
edw.pie <- concat_encounters(charges.dexmed$pie.id, 750)
print(edw.pie)
