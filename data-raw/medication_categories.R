# medication_categories.R

library(dplyr)
library(devtools)

med.categories <- read.csv("data-raw/medication_categories.csv", colClasses="character") %>%
    transmute(med.category = Drug.Catalog,
              med.name = Generic.Drug.Name)

devtools::use_data(med.categories, internal = TRUE, overwrite = TRUE)
