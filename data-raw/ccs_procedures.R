# ccs.procedures.R

library(dplyr)
library(devtools)

ccs.procedures <- read.csv("data-raw/icd9_ccs_procedure.csv", colClasses="character") %>%
    transmute(ccs.procedure.code = as.numeric(CCS.CATEGORY),
              ccs.procedure.description = CCS.CATEGORY.DESCRIPTION,
              icd9.procedure.code = ICD9.CODE.FRMT,
              icd9.procedure.description = ICD.9.CM.CODE.DESCRIPTION)

devtools::use_data(ccs.procedures, internal = TRUE, overwrite = TRUE)
