# ccs.diagnosis.R

library(dplyr)

ccs.diagnosis <- read.csv("data-raw/icd9_ccs_diagnosis.csv", colClasses="character") %>%
    transmute(ccs.code = as.numeric(CCS.CATEGORY),
              icd9.code = ICD9.CODE.FRMT,
              icd9.description = ICD.9.CM.CODE.DESCRIPTION)
