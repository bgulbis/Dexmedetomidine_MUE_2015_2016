# 0-library.R

library(dplyr)
library(BGTools)
library(stringr)
library(lubridate)

proposal.dir <- "proposal_data"
screen.dir <- "screen_data"
data.dir <- "data"

gzip_files(proposal.dir)
gzip_files(screen.dir)
gzip_files(data.dir)
