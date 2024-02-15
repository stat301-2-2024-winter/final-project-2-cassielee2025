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

# extract training and testing sets
birth_train <- birth_split %>% 
  training()

birth_test <- birth_split %>% 
  testing()

# vfold cross validation resampling ----

# how many folds and repeats?
# training set has 30,000 observations
# if i do 10 folds, 27,0000 observations for training 3,000 for getting metrics
# if i do 5 folds and 5 repeats, that is 25 models
# it takes my computer 1.25 minutes to run 50 rf models with 300 training observations and 14 predictors
# so it should take about 225 (3.75) to run 25 rf models with 30,000 training observations
# that should be ok???

# set seed
set.seed(9813274)

birth_fold <- birth_train %>% 
  vfold_cv(v = 5, repeats = 5, strata = dbwt)

# save data splits 
save(birth_train, file = here("data/data_split/birth_train.rda"))
save(birth_test, file = here("data/data_split/birth_test.rda"))
save(birth_fold, file = here("data/data_split/birth_fold.rda"))