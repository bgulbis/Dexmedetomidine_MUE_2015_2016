# 4-manual.R

source("0-library.R")

tmp <- get_rds(dir.save)

tmp.identify <- read_edw_data(dir.data, "identifiers", "id")

tmp.manual <- select(tmp.identify, fin)

library(readr)
write_csv(tmp.manual, paste(dir.save, "manual.csv", sep = "/"))
          