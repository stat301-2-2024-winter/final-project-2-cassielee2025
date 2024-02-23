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
  "cig_0",
  "fagecomb",
  "feduc",
  "illb_r",
  "ilp_r",
  "mager",
  "meduc",
  "m_ht_in",
  "no_infec",
  "no_mmorb",
  "no_risks",
  "precare",
  "previs",
  "priordead",
  "priorlive",
  "priorterm",
  "p_wgt_r",
  "rf_cesarn",
  "sex",
  "wtgain"
)

# filter out incomplete observations
birth_complete <- birth_original %>% 
  select(all_of(vars)) %>% 
  mutate(
    dbwt = na_if(dbwt, 9999),
    cig_0 = na_if(cig_0, 99),
    fagecomb = na_if(fagecomb, 99),
    feduc = na_if(feduc, 9),
    illb_r = na_if(illb_r, 999),
    ilp_r = na_if(ilp_r, 999),
    meduc = na_if(meduc, 9),
    m_ht_in = na_if(m_ht_in, 99),
    no_infec  = na_if(no_infec, 9),
    no_mmorb = na_if(no_mmorb, 9),
    no_risks = na_if(no_risks, 9),
    precare = na_if(precare, 99),
    previs = na_if(previs, 99),
    priordead = na_if(priordead, 99),
    priorlive = na_if(priorlive, 99),
    priorterm = na_if(priorterm, 99),
    p_wgt_r = na_if(p_wgt_r, 999),
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
  slice_sample(n = 30000)

# check variable types and create new variable from variables that contain multiple
# types of information
birth_data <- birth_data %>% 
  ## change categorical variables from numeric/character to factor
  mutate(
    feduc = factor(feduc),
    meduc = factor(meduc),
    no_infec = factor(no_infec),
    no_mmorb = factor(no_mmorb),
    no_risks = factor(no_risks),
    sex = factor(sex)
  ) %>%
  
  ## is this a person's first birth or first pregnancy?
  mutate(
    # if illb_r is 888, true (first birth)
    first_birth = if_else(illb_r == 888, TRUE, FALSE),
    
    # if ilp_r is 888, true (first pregnancy)
    first_preg = if_else(ilp_r == 888, TRUE, FALSE)
  ) %>%
  
  ## for illb_r or ilp_r, 000-003 is plural delivery, not describing an interval
  # was this a plural delivery?
  mutate(
    # if illb_r or ilp_r is between 000-003, label as true (plural delivery)
    plural_del = if_else(
      illb_r %in% c(000, 001, 002, 003) |
        ilp_r %in% c(000, 001, 002, 003),
      TRUE,
      FALSE
    ),
    # if illb_r or ilp_r is between 000-003, change to NA
    illb_r = na_if(illb_r, 000),
    illb_r = na_if(illb_r, 001),
    illb_r = na_if(illb_r, 002),
    illb_r = na_if(illb_r, 003),
    ilp_r = na_if(ilp_r, 000),
    ilp_r = na_if(ilp_r, 001),
    ilp_r = na_if(ilp_r, 002),
    ilp_r = na_if(ilp_r, 003),
  ) %>% 
  
  ## for precare, 00 is no prenatal care, not describing when prenatal care began
  # did the person receive prenatal care
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
