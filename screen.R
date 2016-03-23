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

data.demograph <- semi_join(data.demograph, data.admit.dc, by = "pie.id")

rm(raw.admit.dc)

# find ICU stays
raw.locations <- read_edw_data(data.dir, "locations")

data.locations <- raw.locations %>%
    filter(pie.id %in% pts.eligible) %>%
    calc_unit_los

rm(raw.locations)

# get dexmedetomidine data 
cont.meds <- c("dexmedetomidine", "lorazepam", "midazolam", "propofol", 
               "ketamine", "fentanyl", "hydromorphone", "morphine")
ref.cont.meds <- data_frame(name = cont.meds, type = "med", group = "cont")

raw.meds.cont <- read_edw_data(data.dir, "meds_continuous")
raw.meds.sched <- read_edw_data(data.dir, "meds_sched")

tmp.meds.cont <- tidy_data("meds_cont", ref.data = ref.cont.meds, 
                           cont.data = raw.meds.cont, 
                           sched.data = raw.meds.sched,
                           patients = data.demograph) 

rm(raw.meds.cont)

# get dexmed infusion information, separate into distinct infusions if off for >
# 12 hours
tmp.meds.cont.run <- calc_runtime(tmp.meds.cont)

# summarize drip information
data.meds.cont <- summarize_cont_meds(tmp.meds.cont.run)

data.meds.cont.sum <- data.meds.cont %>%
    group_by(pie.id, med) %>%
    summarize(num.infusions = n(),
              cum.dose = sum(cum.dose, na.rm = TRUE),
              cum.duration = sum(duration, na.rm = TRUE),
              cum.run.time = sum(run.time, na.rm = TRUE),
              time.wt.avg = sum(auc, na.rm = TRUE) / sum(duration, na.rm = TRUE))

data.demograph <- semi_join(data.demograph, data.meds.cont.sum, by = "pie.id")

# get raw data for all eligible patients
# raw.measures <- read_edw_data(data.dir, "ht_wt", "measures")
# raw.labs <- read_edw_data(data.dir, "labs")
# raw.icu.assess <- read_edw_data(data.dir, "icu_assess")
# raw.vent <- read_edw_data(data.dir, "vent")
# raw.vitals <- read_edw_data(data.dir, "vitals")
# raw.uop <- read_edw_data(data.dir, "uop")
