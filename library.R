# library.R

library(dplyr)
library(BGTools)
library(stringr)
library(lubridate)

proposal.dir <- "proposal_data"
screen.dir <- "screen_data"

gzip_files(proposal.dir)
gzip_files(screen.dir)