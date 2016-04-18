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

# remove any patients who were in PICU
tmp.pedi <- data.locations %>%
    filter(str_detect(location, regex("children|pediatric", ignore_case = TRUE))) %>%
    distinct(pie.id)

data.demographics <- anti_join(data.demographics, tmp.pedi, by = "pie.id")

# get dexmedetomidine data 
cont.meds <- c("dexmedetomidine", "lorazepam", "midazolam", "propofol", 
               "ketamine", "fentanyl", "hydromorphone", "morphine")
ref.cont.meds <- data_frame(name = cont.meds, type = "med", group = "cont")

raw.meds.sched <- read_edw_data(dir.data, "meds_sched")

tmp.meds.cont <- read_edw_data(dir.data, "meds_continuous", check.distinct = FALSE) %>%
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

# identify which units patients were in while on dexmedetomidine
tmp.dexmed <- select(data.meds.cont, pie.id:stop.datetime) %>%
    filter(med == "dexmedetomidine") 

data.demographics <- semi_join(data.demographics, data.meds.cont.sum, by = "pie.id")

data.demographics <- semi_join(data.demographics, tmp.dexmed, by = "pie.id")

data.dexmed <- tmp.dexmed %>%
    semi_join(data.demographics, by = "pie.id") %>%
    rowwise %>%
    mutate(location = lookup_location(pie.id, start.datetime)) %>%
    ungroup

# get data for first dexmed course
data.dexmed.first <- group_by(data.dexmed, pie.id) %>%
    filter(drip.count == min(drip.count))

# get raw data for all eligible patients
raw.measures <- read_edw_data(dir.data, "measures")

tmp.height <- filter(raw.measures, measure == "Height",
                     measure.units == "cm") %>%
    semi_join(data.demographics, by = "pie.id") %>%
    group_by(pie.id) %>%
    summarize(height = first(measure.result))

data.demographics <- inner_join(data.demographics, tmp.height, by = "pie.id")

# a few patients didn't have a weight when dexmed was started, but had one
# recorded within 8 hours
tmp.weight <- filter(raw.measures, measure == "Weight",
                     measure.units == "kg") %>%
    semi_join(data.demographics, by = "pie.id") %>%
    inner_join(data.dexmed.first, by = "pie.id") %>%
    filter(measure.datetime <= start.datetime + hours(8)) %>%
    group_by(pie.id) %>%
    summarize(weight = last(measure.result))

data.demographics <- left_join(data.demographics, tmp.weight, by = "pie.id")

# raw.labs <- read_edw_data(dir.data, "labs")
# raw.icu.assess <- read_edw_data(dir.data, "icu_assess")
raw.vent.settings <- read_edw_data(dir.data, "vent_settings")
raw.vent.start <- read_edw_data(dir.data, "vent_start")
# raw.vitals <- read_edw_data(dir.data, "vitals")
# raw.uop <- read_edw_data(dir.data, "uop")

# remove all excluded patients
data.dexmed <- semi_join(data.dexmed, data.demographics, by = "pie.id")
data.dexmed.first <- semi_join(data.dexmed.first, data.demographics, by = "pie.id")
data.facility <- semi_join(data.facility, data.demographics, by = "pie.id")
data.meds.cont <- semi_join(data.meds.cont, data.demographics, by = "pie.id")
data.meds.cont <- semi_join(data.meds.cont.sum, data.demographics, by = "pie.id")
data.locations <- semi_join(data.locations, data.demographics, by = "pie.id")

save_rds(dir.save, "^data")
