# 4-manual.R

source("0-library.R")

tmp <- get_rds(dir.save)

tmp.manual <- read_edw_data(dir.data, "identifiers", "id") %>%
    inner_join(data.dexmed.first, by = "pie.id") %>%
    select(fin, location, arrive.datetime, start.datetime)

library(readr)
write_csv(tmp.manual, paste(dir.save, "manual.csv", sep = "/"))
          