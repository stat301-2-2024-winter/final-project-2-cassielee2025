# split data and fold

# random processes in this script are noted with set.seed()

# load packages ----
library(tidyverse)
library(tidymodels)
library(here)

# prefer tidymodels
tidymodels_prefer()

# load model data
load(here("data/data_split/birth_model_data.rda"))

# initial split ----

# set seed
set.seed(892374934)

birth_split <- birth_model_data %>% 
  initial_split(prop = 0.75, strata = dbwt)

split_dimensions <- birth_split %>% 
  dim()

# save splitting dimensions
save(split_dimensions, file = here("memos/memo2_outputs/split_dimensions.rda"))

# extract training and testing sets
birth_train <- birth_split %>% 
  training()

birth_test <- birth_split %>% 
  testing()

# vfold cross validation resampling ----

# set seed
set.seed(9813274)

birth_fold <- birth_train %>% 
  vfold_cv(v = 5, repeats = 5, strata = dbwt)

# save data splits 
save(birth_train, file = here("data/data_split/birth_train.rda"))
save(birth_test, file = here("data/data_split/birth_test.rda"))
save(birth_fold, file = here("data/data_split/birth_fold.rda"))
