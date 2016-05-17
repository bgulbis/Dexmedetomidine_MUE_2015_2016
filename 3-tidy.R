# 3-tidy.R

source("0-library.R")

tmp <- get_rds(dir.save)

# remove any patients that were not admitted / discharged during FY15
data.visits <- read_edw_data(dir.data, "facility", "visits") %>%
    semi_join(tidy.demographics, by = "pie.id") %>%
    filter(admit.datetime >= mdy_hm("07-01-2014 00:00"),
           discharge.datetime <= mdy_hms("06-30-2015 23:59:59"))

data.demographics <- semi_join(tidy.demographics, data.visits, by = "pie.id")

# find ICU stays
data.locations <- read_edw_data(dir.data, "locations") %>%
    semi_join(data.demographics, by = "pie.id") %>%
    tidy_data("locations")

# remove any patients who were in PICU
tmp.pedi <- data.locations %>%
    filter(str_detect(location, regex("children|pediatric", ignore_case = TRUE))) %>%
    distinct(pie.id)

data.demographics <- anti_join(data.demographics, tmp.pedi, by = "pie.id")

# dexmedetomidine --------------------------------------
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

# sedatives --------------------------------------------
# check for simultaneous infusion of other sedative agents
tmp <- select(data.dexmed, -med, -drip.count, -location)
data.sedatives <- filter(tmp.meds.cont.run, med != "dexmedetomidine") %>%
    semi_join(data.demographics, by = "pie.id") %>%
    inner_join(tmp, by = "pie.id") %>%
    filter(rate.start < stop.datetime,
           rate.stop > start.datetime) %>%
    ungroup %>%
    select(pie.id, med) %>%
    mutate(med = factor(med, levels = cont.meds),
           value = TRUE) %>%
    distinct %>%
    spread(med, value, fill = FALSE, drop = FALSE) %>%
    select(-dexmedetomidine) %>%
    full_join(data.demographics["pie.id"], by = "pie.id") %>%
    mutate_each(funs(ifelse(is.na(.), FALSE, .)), -pie.id)

# measures ---------------------------------------------
raw.measures <- read_edw_data(dir.data, "measures")

data.measures <- filter(raw.measures, measure == "Height",
                     measure.units == "cm") %>%
    semi_join(data.demographics, by = "pie.id") %>%
    group_by(pie.id) %>%
    summarize(height = first(measure.result))

# a few patients didn't have a weight when dexmed was started, but had one
# recorded within 8 hours
tmp.weight <- filter(raw.measures, measure == "Weight",
                     measure.units == "kg") %>%
    semi_join(data.demographics, by = "pie.id") %>%
    inner_join(data.dexmed.first, by = "pie.id") %>%
    filter(measure.datetime <= start.datetime + hours(8)) %>%
    group_by(pie.id) %>%
    summarize(weight = last(measure.result))

data.measures <- full_join(data.measures, tmp.weight, by = "pie.id")

# vent data --------------------------------------------
tmp.vent.times <- read_edw_data(dir.data, "vent_start") %>%
    semi_join(data.demographics, by = "pie.id") %>%
    tidy_data("vent_times", visit.times = data.visits) %>%
    rename(vent.start.datetime = start.datetime,
           vent.stop.datetime = stop.datetime)

data.vent <- tmp.vent.times %>%
    group_by(pie.id) %>%
    summarize(vent.num = n(),
              vent.duration = sum(as.numeric(vent.duration)))

# function used to figure out dexmedetomidine and vent time overlap
dexmedVent <- function(dexm, vent) {
    if (dexm < vent) {
        vent
    } else {
        dexm
    }
}

tmp.dexmed.vent <- full_join(data.dexmed, tmp.vent.times, by = "pie.id") %>%
    filter(start.datetime < vent.stop.datetime,
           stop.datetime > vent.start.datetime) %>%
    rowwise %>%
    mutate(dur.start = dexmedVent(start.datetime, vent.start.datetime),
           dur.stop = dexmedVent(stop.datetime, vent.stop.datetime),
           dexm.vent = difftime(dur.stop, dur.start, units = "hours")) %>%
    group_by(pie.id) %>%
    summarize(dexm.vent.duration = sum(as.numeric(dexm.vent))) 

data.vent <- left_join(data.vent, tmp.dexmed.vent, by = "pie.id") 
data.vent$dexm.vent.duration[is.na(data.vent$dexm.vent.duration)] <- 0

data.vent <- full_join(data.vent, data.demographics["pie.id"], by = "pie.id") %>%
    mutate(vent = ifelse(is.na(vent.duration), FALSE, TRUE))

# safety outcomes --------------------------------------

raw.vitals <- read_edw_data(dir.data, "vitals") %>%
    semi_join(data.demographics, by = "pie.id") %>%
    mutate(vital.result = as.numeric(vital.result))

# tmp <- select(raw.vitals, vital) %>% distinct
tmp.med <- select(data.dexmed, pie.id, start.datetime, stop.datetime, drip.count)

tmp.hr <- filter(raw.vitals, str_detect(vital, "(heart|pulse) rate")) %>%
    left_join(tmp.med, by = "pie.id") %>%
    mutate(hr.low = vital.result <= 55) 

# calculate mean/min/max HR during 48 hours prior to starting dexmed to evaluate
# for new bradycardia
tmp.hr.prior <- tmp.hr %>%
    filter(vital.datetime > start.datetime - days(1),
           vital.datetime < start.datetime) %>%
    group_by(pie.id, drip.count) %>%
    summarize(hr.prior.mean = mean(vital.result),
              hr.prior.min = min(vital.result),
              hr.prior.max = max(vital.result),
              hr.prior.low = sum(hr.low))
    
tmp.hr.during <- tmp.hr %>%
    filter(vital.datetime >= start.datetime,
           vital.datetime <= stop.datetime) %>%
    group_by(pie.id, drip.count) %>%
    summarize(hr.during.mean = mean(vital.result),
              hr.during.min = min(vital.result),
              hr.during.max = max(vital.result),
              hr.during.low = sum(hr.low))

# check for atropine use
tmp.atropine <- raw.meds.sched %>%
    semi_join(data.demographics, by = "pie.id") %>%
    filter(str_detect(med, "^atropine$")) %>%
    left_join(tmp.med, by = "pie.id") %>%
    group_by(pie.id, drip.count) %>%
    mutate(atrop.dexmed = med.datetime > start.datetime & med.datetime < stop.datetime + hours(12)) %>%
    summarize(atropine = sum(atrop.dexmed)) %>%
    mutate(atropine = atropine > 0)
    

tmp.hr.dexmed <- full_join(tmp.hr.prior, tmp.hr.during, by = c("pie.id", "drip.count")) %>%
    full_join(tmp.atropine, by = c("pie.id", "drip.count")) %>%
    mutate(low.hr = hr.prior.low < 2 & hr.during.low > 2,
           bradycard = low.hr == TRUE | atropine == TRUE,
           hr.change.mean = hr.during.mean - hr.prior.mean)

tmp.hr.dexmed$atropine[is.na(tmp.hr.dexmed$atropine)] <- FALSE
tmp.hr.dexmed$bradycard[is.na(tmp.hr.dexmed$bradycard)] <- FALSE

tmp <- group_by(tmp.hr.dexmed, pie.id, drip.count) %>%
    summarize(num = n()) %>%
    filter(num > 1)

# hypotension
tmp.bp <- filter(raw.vitals, str_detect(vital, "(mean arterial|systolic)")) %>%
    left_join(tmp.med, by = "pie.id") %>%
    mutate(vital = str_replace_all(vital, "(mean arterial pressure)", "map"),
           vital = str_replace_all(vital, " \\(invasive\\)", ""),
           vital = str_replace_all(vital, "(.*systolic.*)", "sbp"))

tmp.bp.prior <- tmp.bp %>%
    filter(vital.datetime > start.datetime - days(2),
           vital.datetime < start.datetime) %>%
    group_by(pie.id, vital, drip.count) %>%
    summarize(bp.prior.mean = mean(vital.result),
              bp.prior.min = min(vital.result),
              bp.prior.max = max(vital.result))

tmp.bp.during <- tmp.bp %>%
    filter(vital.datetime >= start.datetime,
           vital.datetime <= stop.datetime) %>%
    group_by(pie.id, vital, drip.count) %>%
    summarize(bp.during.mean = mean(vital.result),
              bp.during.min = min(vital.result),
              bp.during.max = max(vital.result))


# raw.labs <- read_edw_data(dir.data, "labs")
# raw.icu.assess <- read_edw_data(dir.data, "icu_assess")
# raw.vent.settings <- read_edw_data(dir.data, "vent_settings")
# raw.uop <- read_edw_data(dir.data, "uop")

# remove all excluded patients
data.dexmed <- semi_join(data.dexmed, data.demographics, by = "pie.id")
data.dexmed.first <- semi_join(data.dexmed.first, data.demographics, by = "pie.id")
data.visits <- semi_join(data.visits, data.demographics, by = "pie.id")
data.meds.cont <- semi_join(data.meds.cont, data.demographics, by = "pie.id")
data.meds.cont.sum <- semi_join(data.meds.cont.sum, data.demographics, by = "pie.id")
data.locations <- semi_join(data.locations, data.demographics, by = "pie.id")

save_rds(dir.save, "^data")
