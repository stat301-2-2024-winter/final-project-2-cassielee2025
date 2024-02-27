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
load(here("recipes/birth_rec1b.rda"))

# parallel processing ----
num_cores <- parallel::detectCores(logical = TRUE)
registerDoMC(cores = num_cores / 2)

# model specifications ----
rf_spec <- 
  rand_forest(
    mtry = tune(), 
    min_n = tune(),
    trees = tune()
  ) %>%
  set_engine("ranger") %>%
  set_mode("regression")

# define workflows ----
rf_wflow <- 
  workflow() %>% 
  add_model(rf_spec) %>% 
  add_recipe((birth_rec1b))

# hyperparameter tuning values ----

# check ranges for hyperparameters
hardhat::extract_parameter_set_dials(rf_spec)

# change hyperparameter ranges
rf_param <- extract_parameter_set_dials(rf_spec) %>% 
  update(
    mtry = mtry(c(1, 30)),
    min_n = min_n(c(2, 50)),
    trees = trees(c(1, 3000))
  )

# build tuning grid
set.seed(84935)
rf_grid <- grid_latin_hypercube(rf_param, size = 50)

# fit workflows/models ----
# set seed
set.seed(840983)
rf_tuned <- rf_wflow %>% 
  tune_grid(
    birth_fold, 
    grid = rf_grid, 
    control = control_resamples(save_workflow = TRUE)
  )

# write out results (fitted/trained workflows) ----
save(rf_tuned, file = here("results/rf_tuned.rda"))