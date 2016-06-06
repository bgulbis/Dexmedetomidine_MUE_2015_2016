# 4-manual.R

source("0-library.R")

tmp <- get_rds(dir.save)

# write data for manual review -------------------------
tmp.manual <- read_edw_data(dir.data, "identifiers", "id") %>%
    inner_join(data.dexmed.first, by = "pie.id") %>%
    select(fin, location, arrive.datetime, start.datetime)

library(readr)
write_csv(tmp.manual, paste(dir.save, "manual.csv", sep = "/"))

# read in manual data ----------------------------------
tmp.id <- read_edw_data(dir.data, "identifiers", "id")

library(readxl)
data.manual <- read_excel(paste(dir.manual, "manual_data.xlsx", sep = "/")) %>%
    mutate(fin = as.character(fin)) %>%
    inner_join(tmp.id, by = "fin") %>%
    select(pie.id, icu.reason, dexmed.indication)

save_rds(dir.save, "^data")
