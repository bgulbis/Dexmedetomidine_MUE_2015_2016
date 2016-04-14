# 3-tidy.R

source("0-library.R")

tmp <- get_rds(dir.save)

# remove any patients that were not admitted / discharged during FY15
data.facility <- read_edw_data(dir.data, "facility") %>%
    semi_join(data.demographics, by = "pie.id") %>%
    filter(admit.datetime >= mdy("07-01-2014"),
           discharge.datetime <= mdy("06-30-2015"))

data.demographics <- semi_join(data.demographics, data.facility, by = "pie.id")

# find ICU stays
data.locations <- read_edw_data(dir.data, "locations") %>%
    semi_join(data.demographics, by = "pie.id") %>%
    tidy_data("locations")

# get dexmedetomidine data 
cont.meds <- c("dexmedetomidine", "lorazepam", "midazolam", "propofol", 
               "ketamine", "fentanyl", "hydromorphone", "morphine")
ref.cont.meds <- data_frame(name = cont.meds, type = "med", group = "cont")

raw.meds.sched <- read_edw_data(dir.data, "meds_sched")

tmp.meds.cont <- read_edw_data(dir.data, "meds_continuous") %>%
    tidy_data("meds_cont", ref.data = ref.cont.meds, sched.data = raw.meds.sched) 

# get dexmed infusion information, separate into distinct infusions if off for >
# 12 hours
tmp.meds.cont.run <- calc_runtime(tmp.meds.cont)

# summarize drip information
data.meds.cont <- summarize_cont_meds(tmp.meds.cont.run) %>%
    filter(cum.dose > 0,
           duration > 0) %>%
    ungroup

data.meds.cont.sum <- data.meds.cont %>%
    group_by(pie.id, med) %>%
    summarize(num.infusions = n(),
              cum.dose = sum(cum.dose, na.rm = TRUE),
              cum.duration = sum(duration, na.rm = TRUE),
              cum.run.time = sum(run.time, na.rm = TRUE),
              time.wt.avg = sum(auc, na.rm = TRUE) / sum(duration, na.rm = TRUE))

data.demographics <- semi_join(data.demographics, data.meds.cont.sum, by = "pie.id")

lookup_location <- function(pt, start) {
    x <- filter(data.locations, pie.id == pt,
                start >= arrive.datetime,
                start <= depart.datetime)
    # x <- filter(data.locations, pie.id == pt,
    #             arrive.datetime <= start) %>%
    #     arrange(arrive.datetime) %>%
    #     group_by(pie.id) %>%
    #     summarize(location = last(location))

    if (length(x$location) < 1) {
        "Unable to match location"
    } else {
        x$location
    }
}

# identify which units patients were in while on dexmedetomidine
tmp.dexmed <- select(data.meds.cont, pie.id:stop.datetime) %>%
    filter(med == "dexmedetomidine") 

data.demographics <- semi_join(data.demographics, tmp.dexmed, by = "pie.id")

data.meds.cont <- semi_join(data.meds.cont, data.demographics, by = "pie.id")

data.locations <- semi_join(data.locations, data.demographics, by = "pie.id")

tmp.dexmed <- tmp.dexmed %>%
    rowwise %>%
    mutate(location = lookup_location(pie.id, start.datetime)) %>%
    ungroup
    
# tmp <- filter(tmp.dexmed, location == "Unable to match location")

# get raw data for all eligible patients
# raw.measures <- read_edw_data(dir.data, "ht_wt", "measures")
# raw.labs <- read_edw_data(dir.data, "labs")
# raw.icu.assess <- read_edw_data(dir.data, "icu_assess")
# raw.vent <- read_edw_data(dir.data, "vent")
# raw.vitals <- read_edw_data(dir.data, "vitals")
# raw.uop <- read_edw_data(dir.data, "uop")
