# medication_classes.R

library(dplyr)
library(devtools)

med.classes <- read.csv("data-raw/medication_classes.csv", colClasses="character") %>%
    transmute(med.class = Drug.Catalog,
              med.name = Generic.Drug.Name)

devtools::use_data(med.classes, internal = TRUE, overwrite = TRUE)
