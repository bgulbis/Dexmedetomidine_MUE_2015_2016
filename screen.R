# screen.R

source("library.R")

# exclude these locations
excl.hosp <- c("Memorial Hermann Center for Advanced Heart Failure", 
               "Memorial Hermann Children's Hospital", 
               "Memorial Hermann Clinics", "Memorial Hermann Radiology")

# get data for potential patients
raw.demograph <- read_edw_data(screen.dir, "demographics") 

# exclude outpatients and pediatric patients
data.demograph <- raw.demograph %>%
    distinct %>%
    filter(age >= 18,
           !(facility %in% excl.hosp),
           visit.type == "Inpatient") %>%
    mutate(group = ifelse(facility == "Memorial Hermann Hospital", "tmc", 
                          "mhhs")) %>%
    mutate(group = factor(group))

# get list of eligible patients to use in EDW queries
pts.eligible <- data.demograph$pie.id
edw.pie <- concat_encounters(pts.eligible, 750)
print(edw.pie)

rm(raw.demograph)

# remove any patients that were not admitted / discharged during FY15
raw.admit.dc <- read_edw_data(data.dir, "admit_dc")

data.admit.dc <- raw.admit.dc %>%
    filter(admit.datetime >= mdy("07-01-2014"),
           discharge.datetime <= mdy("06-30-2015"))

pts.eligible <- data.admit.dc$pie.id

data.demograph <- filter(data.demograph, pie.id %in% pts.eligible)

rm(raw.admit.dc)

# find ICU stays
raw.locations <- read_edw_data(data.dir, "locations")

data.locations <- raw.locations %>%
    filter(pie.id %in% pts.eligible) %>%
    calc_unit_los

rm(raw.locations)

# get dexmedetomidine data 
ref.dexmed <- data.frame(name = "dexmedetomidine", type = "med", group = "cont", 
                         stringsAsFactors = FALSE)

raw.meds.cont <- read_edw_data(data.dir, "meds_continuous")
raw.meds.sched <- read_edw_data(data.dir, "meds_sched")

tmp.dexmed <- tidy_data("meds_cont", ref.data = ref.dexmed, 
                           cont.data = raw.meds.cont, 
                           sched.data = raw.meds.sched,
                           patients = data.demograph) 

# fill_rate <- function(rate, units) {
#     lapply(seq_along(rate), function(i) ifelse(is.na(units[i]), TRUE, FALSE))
# }

# get time between each row
tmp.run <- calc_runtime(tmp.dexmed)

tmp.sum <- summarize_cont_meds(tmp.run)


# data.dexmed <- calc_runtime(tmp.dexmed) %>%
#     summarize_cont_meds

# tmp.bolus <- anti_join(data.demograph, data.dexmed, by = "pie.id")
# 
# tmp.sched <- raw.meds.sched %>%
#     filter(str_detect(med, "dexmed"))

# get raw data for all eligible patients
# raw.measures <- read_edw_data(data.dir, "ht_wt", "measures")
# raw.labs <- read_edw_data(data.dir, "labs")
# raw.icu.assess <- read_edw_data(data.dir, "icu_assess")
# raw.vent <- read_edw_data(data.dir, "vent")
# raw.vitals <- read_edw_data(data.dir, "vitals")
# raw.uop <- read_edw_data(data.dir, "uop")

