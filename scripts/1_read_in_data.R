# read in data and check quality

# load packages
library(tidyverse)
library(here)

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

# set seed
set.seed(1293847982)

birth_data <- birth_original %>% 
  slice_sample(n = 60000) %>% 
  select(vars)

save(birth_data, file = here("data/birth_data.rda"))




