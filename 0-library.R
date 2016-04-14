# 0-library.R

library(dplyr)
library(BGTools)
library(stringr)
library(lubridate)

source("0-dirs.R")

gzip_files(dir.proposal)
gzip_files(dir.screen)
gzip_files(dir.data)
