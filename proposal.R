# proposal.R
# 
# estimate number of patients available for study

library(dplyr)
library(BGTools)
library(stringr)

proposal.dir <- "proposal_data"

dexmed <- read_data(proposal.dir, "patients") %>%
    distinct(PowerInsight.Encounter.Id)

tmc <- filter(dexmed, Institution.Code == "A")
mhhs <- filter(dexmed, Institution.Code == "B")

tmp <- tmc$PowerInsight.Encounter.Id
tmc.pie <- split(tmp, ceiling(seq_along(tmp)/500))
tmc.pie <- lapply(tmc.pie, str_c, collapse=";")
print(tmc.pie)

tmp <- mhhs$PowerInsight.Encounter.Id
mhhs.pie <- split(tmp, ceiling(seq_along(tmp)/500))
mhhs.pie <- lapply(mhhs.pie, str_c, collapse=";")
print(mhhs.pie)

screen.dir <- "screen_data"

raw.demograph <- read_edw_data(screen.dir, "demograph", "demographics") %>%
    distinct %>%
    filter(age >= 18) 

# dexm.tmc <- list.files(proposal.dir, pattern = "dexmed - TMC", full.names = TRUE) %>%
#    lapply(read.csv, colClasses = "character") %>%
#    bind_rows %>%
#    distinct

# dexm.other <- list.files(proposal.dir, pattern = "dexmed - Other", full.names = TRUE) %>%
#    lapply(read.csv, colClasses = "character") %>%
#    bind_rows %>%
#    distinct
