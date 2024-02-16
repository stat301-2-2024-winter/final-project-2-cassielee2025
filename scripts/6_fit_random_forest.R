# fit random forest

# load packages
library(tidyverse)
library(tidymodels)
library(here)
library(doMC)

# prefer tidymodels
tidymodels_prefer()

# load training data & controls
load(here("data/data_split/birth_fold.rda"))

# load pre-processing/feature engineering/recipe
load(here("recipes/birth_rec2.rda"))

# parallel processing ----
num_cores <- parallel::detectCores(logical = TRUE)
registerDoMC(cores = num_cores - 1)

# model specifications ----
rf_rec <- 
  rand_forest(
    mtry = tune(), 
    min_n = tune(),
    trees = tune()
  ) %>%
  set_engine("ranger") %>%
  set_mode("regression")