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

raw.meds.cont <- read_edw_data(dir.data, "meds_continuous", check.distinct = FALSE) 

tmp.meds.cont <- tidy_data(raw.meds.cont, "meds_cont", ref.data = ref.cont.meds, 
                           sched.data = raw.meds.sched) 

# get dexmed infusion information, separate into distinct infusions if off for >
# 12 hours
tmp.meds.cont.run <- calc_runtime(tmp.meds.cont)

# summarize drip information
data.meds.cont <- summarize_cont_meds(tmp.meds.cont.run) %>%
    filter(cum.dose > 0,
           duration > 0) 

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

data.locations <- semi_join(data.locations, data.demographics, by = "pie.id")

data.dexmed <- tmp.dexmed %>%
    semi_join(data.demographics, by = "pie.id") %>%
    full_join(data.locations, by = "pie.id") %>%
    mutate(overlap = int_overlaps(interval(start.datetime, stop.datetime),
                                  interval(arrive.datetime, depart.datetime))) %>%
    filter(overlap == TRUE)

# find the unit where each dexmed course was started
data.dexmed.start <- data.dexmed %>%
    group_by(pie.id, drip.count) %>%
    arrange(arrive.datetime) %>%
    filter(arrive.datetime == first(arrive.datetime))

# get data for first dexmed course
data.dexmed.first <- group_by(data.dexmed.start, pie.id) %>%
    filter(drip.count == min(drip.count))

# sedatives --------------------------------------------
# check for simultaneous infusion of other sedative agents
tmp <- select(data.dexmed.start, pie.id, dexmed.count = drip.count, 
              start.datetime, stop.datetime)

data.sedatives <- filter(tmp.meds.cont.run, med != "dexmedetomidine") %>%
    semi_join(data.demographics, by = "pie.id") %>%
    inner_join(tmp, by = "pie.id") %>%
    mutate(overlap = int_overlaps(interval(rate.start, rate.stop),
                                  interval(start.datetime, stop.datetime))) %>%
    filter(overlap == TRUE) %>%
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
    rename(vent.start = start.datetime,
           vent.stop = stop.datetime)

data.vent <- tmp.vent.times %>%
    group_by(pie.id) %>%
    summarize(vent.num = n(),
              vent.duration = sum(as.numeric(vent.duration)))

tmp.dexmed.vent <- select(data.dexmed.start, pie.id, drip.count:stop.datetime) %>%
    inner_join(tmp.vent.times, by = "pie.id") %>%
    ungroup %>%
    mutate(overlap = int_overlaps(interval(start.datetime, stop.datetime),
                                  interval(vent.start, vent.stop))) %>%
    filter(overlap == TRUE) %>%
    mutate(dexm.vent = as.period(lubridate::intersect(
                                    interval(start.datetime, stop.datetime),
                                    interval(vent.start, vent.stop)),
                                 "hours") / hours(1)) %>%
    group_by(pie.id) %>%
    summarize(dexm.vent.duration = sum(dexm.vent))

data.vent <- left_join(data.vent, tmp.dexmed.vent, by = "pie.id") 
data.vent$dexm.vent.duration[is.na(data.vent$dexm.vent.duration)] <- 0

data.vent <- full_join(data.vent, data.demographics["pie.id"], by = "pie.id") %>%
    mutate(vent = ifelse(is.na(vent.duration), FALSE, TRUE))

# safety bradycardia -----------------------------------

raw.vitals <- read_edw_data(dir.data, "vitals") %>%
    semi_join(data.demographics, by = "pie.id") %>%
    mutate(vital.result = as.numeric(vital.result))

# tmp <- select(raw.vitals, vital) %>% distinct
tmp.med <- select(data.dexmed, pie.id, start.datetime, stop.datetime, drip.count)

tmp.hr <- filter(raw.vitals, str_detect(vital, "(heart|pulse) rate")) %>%
    left_join(tmp.med, by = "pie.id") %>%
    mutate(hr.low = vital.result < 55) 

# bradycardia is > 2 HR's < 55 while on dexmed, and they had < 2 HR's < 55
# during 24-hours prior to starting dexmed
tmp.hr.prior <- tmp.hr %>%
    filter(vital.datetime > start.datetime - days(1),
           vital.datetime < start.datetime) %>%
    group_by(pie.id, drip.count) %>%
    summarize(hr.prior.mean = mean(vital.result),
              hr.prior.low = sum(hr.low))
    
tmp.hr.during <- tmp.hr %>%
    filter(vital.datetime >= start.datetime,
           vital.datetime <= stop.datetime) %>%
    group_by(pie.id, drip.count) %>%
    summarize(hr.during.mean = mean(vital.result),
              hr.during.low = sum(hr.low))

# check for atropine use
tmp.atropine <- raw.meds.sched %>%
    semi_join(data.demographics, by = "pie.id") %>%
    filter(str_detect(med, "^atropine$")) %>%
    left_join(tmp.med, by = "pie.id") %>%
    group_by(pie.id, drip.count) %>%
    mutate(atrop.dexmed = med.datetime > start.datetime & 
               med.datetime < stop.datetime + hours(12)) %>%
    summarize(atropine = sum(atrop.dexmed)) %>%
    mutate(atropine = atropine > 0)
    
data.safety.hr <- full_join(tmp.hr.prior, tmp.hr.during, 
                            by = c("pie.id", "drip.count")) %>%
    full_join(tmp.atropine, by = c("pie.id", "drip.count")) %>%
    mutate(low.hr = hr.prior.low < 2 & hr.during.low > 2,
           bradycardia = low.hr == TRUE | atropine == TRUE,
           hr.change.mean = hr.during.mean - hr.prior.mean)

data.safety.hr$atropine[is.na(data.safety.hr$atropine)] <- FALSE
data.safety.hr$bradycardia[is.na(data.safety.hr$bradycardia)] <- FALSE

# safety hypotension -----------------------------------
tmp.bp <- filter(raw.vitals, str_detect(vital, "(mean arterial|systolic)")) %>%
    left_join(tmp.med, by = "pie.id") %>%
    mutate(vital = str_replace_all(vital, "(mean arterial pressure)", "map"),
           vital = str_replace_all(vital, " \\(invasive\\)", ""),
           vital = str_replace_all(vital, "(.*systolic.*)", "sbp"),
           low.bp = ifelse(vital == "map", vital.result < 60, vital.result < 80))

# for hypotension, use > 2 low sbp/map's if < 2 low values during 24-hours prior
# to starting dexmed
tmp.bp.prior <- tmp.bp %>%
    filter(vital.datetime > start.datetime - days(1),
           vital.datetime < start.datetime) %>%
    group_by(pie.id, vital, drip.count) %>%
    summarize(bp.prior.mean = mean(vital.result),
              bp.prior.low = sum(low.bp))

tmp.bp.during <- tmp.bp %>%
    filter(vital.datetime >= start.datetime,
           vital.datetime <= stop.datetime) %>%
    group_by(pie.id, vital, drip.count) %>%
    summarize(bp.during.mean = mean(vital.result),
              bp.during.low = sum(low.bp))

# check for use of vasopressors
vasopressors <- c("dopamine", "norepinephrine", "epinephrine", "phenylephrine", 
                  "vasopressin")
ref.vasop <- data_frame(name = vasopressors, type = "med", group = "cont")

tmp.vasop <- raw.meds.cont %>%
    tidy_data("meds_cont", ref.data = ref.vasop, sched.data = raw.meds.sched) %>%
    calc_runtime %>%
    summarize_cont_meds

tmp.vasop.dexmed <- tmp.vasop %>%
    select(pie.id, med, vasop.start = start.datetime, vasop.stop = stop.datetime) %>%
    inner_join(data.dexmed.start[c("pie.id", "drip.count", "start.datetime", 
                                   "stop.datetime")], by = "pie.id") %>%
    mutate(vasopressor = int_overlaps(interval(start.datetime, stop.datetime),
                                 interval(vasop.start, vasop.stop))) %>%
    filter(vasopressor == TRUE,
           vasop.start > start.datetime) %>%
    distinct(pie.id, drip.count, vasopressor)

data.safety.bp <- full_join(tmp.bp.prior, tmp.bp.during, 
                            by = c("pie.id", "vital", "drip.count")) %>%
    full_join(tmp.vasop.dexmed, by = c("pie.id", "drip.count")) %>%
    mutate(low.bp = bp.prior.low < 2 & bp.during.low > 2,
           hypotension = low.bp == TRUE | vasopressor == TRUE,
           bp.change.mean = bp.during.mean - bp.prior.mean)

data.safety.bp$vasopressor[is.na(data.safety.bp$vasopressor)] <- FALSE
data.safety.bp$hypotension[is.na(data.safety.bp$hypotension)] <- FALSE

# create combined safety table
data.safety <- full_join(data.safety.bp, data.safety.hr, by = "pie.id") %>%
    group_by(pie.id) %>%
    summarize(hypotension = sum(hypotension),
              bradycardia = sum(bradycardia)) %>%
    mutate(hypotension = hypotension >= 1,
           bradycardia = bradycardia >= 1)

# sofa score -------------------------------------------

raw.labs <- read_edw_data(dir.data, "labs")
raw.icu.assess <- read_edw_data(dir.data, "icu_assess")
raw.vent.settings <- read_edw_data(dir.data, "vent_settings")
raw.uop <- read_edw_data(dir.data, "uop")

tmp.sofa.labs <- raw.labs %>%
    semi_join(data.demographics, by = "pie.id") %>%
    filter(lab %in% c("platelet", "bili total", "creatinine lvl")) %>%
    mutate(lab.result = as.numeric(lab.result)) %>%
    filter(!is.na(lab.result)) %>%
    group_by(pie.id, lab) %>%
    arrange(lab.datetime) %>%
    inner_join(data.dexmed.first, by = "pie.id") %>%
    filter(lab.datetime > arrive.datetime,
           lab.datetime < arrive.datetime + days(1)) %>%
    summarize(max = max(lab.result),
              min = min(lab.result)) %>%
    mutate(lab.result = ifelse(lab == "platelet", min, max)) %>%
    select(-max, -min) %>%
    spread(lab, lab.result) %>%
    rename(bili.total = `bili total`,
           creatinine = `creatinine lvl`)

tmp.sofa.map <- raw.vitals %>%
    semi_join(data.demographics, by = "pie.id") %>%
    filter(str_detect(vital, "mean arterial")) %>%
    group_by(pie.id) %>%
    arrange(vital.datetime) %>%
    inner_join(data.dexmed.first, by = "pie.id") %>%
    filter(vital.datetime > arrive.datetime,
           vital.datetime < arrive.datetime + days(1)) %>%
    summarize(map = min(vital.result)) 

sofa.vasop <- c("dopamine", "dobutamine", "norepinephrine")
sofa.vasop <- data_frame(name = sofa.vasop, type = "med", group = "cont")

tmp.sofa.vasop <- raw.meds.cont %>%
    semi_join(data.demographics, by = "pie.id") %>%
    tidy_data("meds_cont", ref.data = sofa.vasop, sched.data = raw.meds.sched) %>%
    calc_runtime %>%
    group_by(pie.id, med) %>%
    arrange(rate.start) %>%
    inner_join(data.dexmed.first[c("pie.id", "arrive.datetime")], by = "pie.id") %>%
    filter(rate.start > arrive.datetime,
           rate.start < arrive.datetime + days(1)) %>%
    summarize(med.rate = max(med.rate)) %>%
    mutate(med = factor(med, levels = sofa.vasop$name)) %>%
    spread(med, med.rate, drop = FALSE)

tmp.sofa.gcs <- raw.icu.assess %>%
    semi_join(data.demographics, by = "pie.id") %>%
    filter(assessment == "glasgow coma score") %>%
    mutate(assess.result = as.numeric(assess.result)) %>%
    group_by(pie.id) %>%
    arrange(assess.datetime) %>%
    inner_join(data.dexmed.first, by = "pie.id") %>%
    filter(assess.datetime > arrive.datetime,
           assess.datetime < arrive.datetime + days(1)) %>%
    summarize(gcs = min(assess.result))

resp <- c("pao2", "fio2 (%)", "spo2 percent", "poc a o2 sat", "poc a po2", 
          "poc a %fio2")
tmp.sofa.resp <- raw.vent.settings %>%
    semi_join(data.demographics, by = "pie.id") %>%
    filter(vent.event %in% resp) %>%
    mutate(vent.result = as.numeric(vent.result),
           vent.event = str_replace_all(vent.event, ".*(fio2).*", "fio2"),
           vent.event = str_replace_all(vent.event, "(spo2 percent|poc a o2 sat)", "spo2"),
           vent.event = str_replace_all(vent.event, "poc a po2", "pao2")) %>%
    group_by(pie.id, vent.event) %>%
    arrange(vent.datetime) %>%
    inner_join(data.dexmed.first, by = "pie.id") %>%
    filter(vent.datetime > arrive.datetime,
           vent.datetime < arrive.datetime + days(1)) %>%
    summarize(max = max(vent.result),
              min = min(vent.result)) %>%
    mutate(vent.result = ifelse(vent.event == "pao2", min, max)) %>%
    select(-max, -min) %>%
    spread(vent.event, vent.result) 

tmp.sofa.uop <- raw.uop %>%
    semi_join(data.demographics, by = "pie.id") %>%
    filter(uop.event != "urine count") %>%
    mutate(uop.result = as.numeric(uop.result)) %>%
    group_by(pie.id) %>%
    arrange(uop.datetime) %>%
    inner_join(data.dexmed.first, by = "pie.id") %>%
    mutate(arrive = floor_date(arrive.datetime, unit = "hour")) %>%
    filter(uop.datetime >= arrive,
           uop.datetime <= arrive + days(1)) %>%
    summarize(uop = sum(uop.result))
    
data.sofa <- select(data.demographics, pie.id) %>%
    left_join(tmp.sofa.resp, by = "pie.id") %>%
    left_join(tmp.sofa.labs, by = "pie.id") %>%
    left_join(tmp.sofa.map, by = "pie.id") %>%
    left_join(tmp.sofa.vasop, by = "pie.id") %>%
    left_join(tmp.sofa.gcs, by = "pie.id") %>%
    left_join(tmp.sofa.uop, by = "pie.id")

# RASS -------------------------------------------------

tmp.rass <- raw.icu.assess %>%
    semi_join(data.demographics, by = "pie.id") %>%
    filter(assessment == "rass score") %>%
    mutate(assess.result = as.numeric(assess.result)) %>%
    inner_join(data.dexmed.start[c("pie.id", "start.datetime", "stop.datetime")], 
               by = "pie.id") %>%
    rename(lab.datetime = assess.datetime) %>%
    group_by(pie.id) %>%
    arrange(lab.datetime)

tmp.rass.prior <- tmp.rass %>%
    filter(lab.datetime < start.datetime) %>%
    mutate(lab.start = first(lab.datetime)) %>%
    calc_lab_runtime

tmp.rass.during <- tmp.rass %>%
    filter(lab.datetime >= start.datetime,
           lab.datetime <= stop.datetime) %>%
    mutate(lab.start = first(lab.datetime)) %>%
    calc_lab_runtime

tmp.rass.after <- tmp.rass %>%
    filter(lab.datetime > stop.datetime) %>%
    mutate(lab.start = first(lab.datetime)) %>%
    calc_lab_runtime
    

# finish -----------------------------------------------
concat_encounters(data.demographics$pie.id)
    
# remove all excluded patients
data.dexmed <- semi_join(data.dexmed, data.demographics, by = "pie.id")
data.dexmed.first <- semi_join(data.dexmed.first, data.demographics, by = "pie.id")
data.dexmed.start <- semi_join(data.dexmed.start, data.demographics, by = "pie.id")
data.visits <- semi_join(data.visits, data.demographics, by = "pie.id")
data.meds.cont <- semi_join(data.meds.cont, data.demographics, by = "pie.id")
data.meds.cont.sum <- semi_join(data.meds.cont.sum, data.demographics, by = "pie.id")
data.locations <- semi_join(data.locations, data.demographics, by = "pie.id")

save_rds(dir.save, "^data")
