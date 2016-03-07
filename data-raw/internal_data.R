# internal_data.R
#
# data to be used internally in package

library(dplyr)
library(devtools)

ccs.diagnosis <- read.csv("data-raw/icd9_ccs_diagnosis.csv", colClasses="character") %>%
    transmute(ccs.code = as.numeric(CCS.CATEGORY),
              ccs.description = CCS.CATEGORY.DESCRIPTION,
              icd9.code = ICD9.CODE.FRMT,
              icd9.description = ICD.9.CM.CODE.DESCRIPTION)

ccs.procedures <- read.csv("data-raw/icd9_ccs_procedure.csv", colClasses="character") %>%
    transmute(ccs.code = as.numeric(CCS.CATEGORY),
              ccs.description = CCS.CATEGORY.DESCRIPTION,
              icd9.code = ICD9.CODE.FRMT,
              icd9.description = ICD.9.CM.CODE.DESCRIPTION)

med.classes <- read.csv("data-raw/medication_classes.csv", colClasses="character") %>%
    transmute(med.class = Drug.Catalog,
              med.name = Generic.Drug.Name)

devtools::use_data(ccs.diagnosis, ccs.procedures, med.classes, internal = TRUE, overwrite = TRUE)
