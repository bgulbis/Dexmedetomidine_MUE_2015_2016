# proposal.R
# 
# estimate number of patients available for study

source("library.R")

# get list of patients from charge data
dexmed <- read_edw_data(proposal.dir, "patients", "charges") %>%
    distinct(pie.id)

# make list of encounters for EDW
edw.pie <- concat_encounters(dexmed$pie.id, 500)
print(edw.pie)
