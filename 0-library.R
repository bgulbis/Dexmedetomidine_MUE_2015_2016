# 0-library.R

library(dplyr)
library(BGTools)
library(stringr)
library(lubridate)
library(tidyr)

source("0-dirs.R")

gzip_files(dir.proposal)
gzip_files(dir.screen)
gzip_files(dir.data)

lookup_location <- function(pt, start) {
    x <- filter(data.locations, pie.id == pt,
                start >= arrive.datetime,
                start <= depart.datetime)
    
    if (length(x$location) < 1) {
        "Unable to match location"
    } else {
        x$location
    }
}
