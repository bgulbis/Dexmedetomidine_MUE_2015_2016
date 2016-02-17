# proposal.R
# 
# estimate number of patients available for study

library(dplyr)
library(BGTools)

proposal.dir <- "proposal_data"

dexm.tmc <- list.files(proposal.dir, pattern = "dexmed - TMC", full.names = TRUE) %>%
    lapply(read.csv, colClasses = "character") %>%
    bind_rows %>%
    distinct

dexm.other <- list.files(proposal.dir, pattern = "dexmed - Other", full.names = TRUE) %>%
    lapply(read.csv, colClasses = "character") %>%
    bind_rows %>%
    distinct
