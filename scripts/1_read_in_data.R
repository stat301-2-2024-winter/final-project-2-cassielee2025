# read in data and check quality

# load packages
library(tidyverse)
library(here)

# original dataset ----

# read in data and clean names
birth_original <- read_csv(here("data/US_births(2018).csv")) %>% 
  janitor::clean_names()

# create list of variables to select
vars <- c(
  "dbwt",
  "attend",
  "bfacil",
  "bmi",
  "cig_0",
  "dlmp_mm",
  "dmar",
  "dob_mm",
  "dob_tt",
  "dob_wk",
  "fagecomb",
  "feduc",
  "illb_r",
  "ilop_r",
  "ilp_r",
  "ld_indl",
  "mager",
  "mbstate_rec",
  "meduc",
  "m_ht_in",
  "no_infec",
  "no_mmorb",
  "no_risks",
  "pay",
  "pay_rec",
  "precare",
  "previs",
  "priordead",
  "priorlive",
  "priorterm",
  "p_wgt_r",
  "rdmeth_rec",
  "restatus",
  "rf_cesar",
  "rf_cesarn",
  "sex",
  "wtgain"
)
  
# filter out incomplete observations
birth_complete <- birth_original %>% 
  select(all_of(vars)) %>% 
  mutate(
    dbwt = na_if(dbwt, 9999),
    attend = na_if(attend, 9),
    bfacil = na_if(bfacil, 9),
    bmi = na_if(bmi, 99.9),
    cig_0 = na_if(cig_0, 99),
    dlmp_mm = na_if(dlmp_mm, 99),
    dob_tt = na_if(dob_tt, 9999),
    fagecomb = na_if(fagecomb, 99),
    feduc = na_if(feduc, 9),
    illb_r = na_if(illb_r, 888),
    illb_r = na_if(illb_r, 999),
    ilop_r = na_if(ilop_r, 888),
    ilop_r = na_if(ilop_r, 999),
    ilp_r = na_if(ilp_r, 888),
    ilp_r = na_if(ilp_r, 999),
    ld_indl = na_if(ld_indl, "U"),
    mbstate_rec = na_if(mbstate_rec, 3),
    meduc = na_if(meduc, 9),
    m_ht_in = na_if(m_ht_in, 99),
    no_infec  = na_if(no_infec, 9),
    no_mmorb = na_if(no_mmorb, 9),
    no_risks = na_if(no_risks, 9),
    pay  = na_if(pay, 9),
    pay_rec = na_if(pay_rec, 9),
    precare = na_if(precare, 99),
    previs = na_if(previs, 99),
    priordead = na_if(priordead, 99),
    priorlive = na_if(priorlive, 99),
    priorterm = na_if(priorterm, 99),
    p_wgt_r = na_if(p_wgt_r, 999),
    rdmeth_rec = na_if(rdmeth_rec, 9),
    rf_cesar = na_if(rf_cesar, "U"),
    # convert number of cesarean to from character to numeric
    rf_cesarn = as.numeric(rf_cesarn),
    rf_cesarn = na_if(rf_cesarn, 99),
    wtgain = na_if(wtgain, 99)
  ) %>% 
  drop_na()

# show proper read in
show_birth_read_in <- birth_complete %>%
  slice(1:10)

# subset data ----

# set seed
set.seed(1293847982)

birth_data <- birth_complete %>% 
  slice_sample(n = 60000)

# check variable types and create new variable from variables that contain multiple
# types of information
birth_data <- birth_data %>% 
  # change categorical variables from numeric/character to factor
  mutate(
    attend = factor(attend),
    bfacil = factor(bfacil),
    dlmp_mm = factor(dlmp_mm),
    dmar = factor(dmar),
    dob_mm = factor(dob_mm),
    dob_wk = factor(dob_wk),
    feduc = factor(feduc),
    ld_indl = factor(ld_indl),
    mbstate_rec = factor(mbstate_rec),
    meduc = factor(meduc),
    no_infec = factor(no_infec),
    no_mmorb = factor(no_mmorb),
    no_risks = factor(no_risks),
    pay = factor(pay),
    pay_rec = factor(pay_rec),
    rdmeth_rec = factor(rdmeth_rec),
    restatus = factor(restatus),
    rf_cesar = factor(rf_cesar), 
    sex = factor(sex)
  ) %>%
  # for illb_r, ilop_r, ilp_r, 000-003 is plural delivery, not describing an interval
  mutate(
    # if illb_r, ilop_r, ilp_r is between 000-003, label as true (plural delivery)
    plural_del = if_else(
      illb_r %in% c(000, 001, 002, 003) |
      ilop_r %in% c(000, 001, 002, 003) |
      ilp_r %in% c(000, 001, 002, 003),
      TRUE,
      FALSE
    ),
    # if illb_r, ilop_r, ilp_r is between 000-003, change to NA
    illb_r = na_if(illb_r, 000),
    illb_r = na_if(illb_r, 001),
    illb_r = na_if(illb_r, 002),
    illb_r = na_if(illb_r, 003),
    ilop_r = na_if(ilop_r, 000),
    ilop_r = na_if(ilop_r, 001),
    ilop_r = na_if(ilop_r, 002),
    ilop_r = na_if(ilop_r, 003),
    ilp_r = na_if(ilop_r, 000),
    ilp_r = na_if(ilop_r, 001),
    ilp_r = na_if(ilop_r, 002),
    ilp_r = na_if(ilop_r, 003),
  ) %>% 
  # for precare, 00 is no prenatal care, not describing when prenatal care began
  mutate(
    # if there precare is 00, label as false
    any_precare = if_else(precare == 00, FALSE, TRUE),
    # if there precare is 00, change to NA
    precare = na_if(precare, 00)
  )

# data quality check ----
data_quality_check <- birth_data %>% 
  skimr::skim_without_charts() %>% 
  select(skim_variable, n_missing, complete_rate) %>%
  arrange(complete_rate) %>% 
  slice(1:5)

# save subsetted data ----
save(birth_data, file = here("data/birth_data.rda"))

# save memo1 outputs ----
save(show_birth_read_in, file = here("memos/memo1_outputs/show_birth_read_in.rda"))
save(data_quality_check, file = here("memos/memo1_outputs/data_quality_check.rda"))


