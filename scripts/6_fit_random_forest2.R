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
load(here("recipes/birth_rec2b.rda"))

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
rf_wflow2 <- 
  workflow() %>% 
  add_model(rf_spec) %>% 
  add_recipe((birth_rec2b))

# hyperparameter tuning values ----

# check ranges for hyperparameters
hardhat::extract_parameter_set_dials(rf_spec)

# change hyperparameter ranges
rf_param2 <- extract_parameter_set_dials(rf_spec) %>% 
  update(
    mtry = mtry(c(1, 30)),
    min_n = min_n(c(2, 50)),
    trees = trees(c(1, 3000))
  )

# build tuning grid
set.seed(8339)
rf_grid2 <- grid_latin_hypercube(rf_param2, size = 50)

# fit workflows/models ----
# set seed
set.seed(87634)
rf_tuned2 <- rf_wflow2 %>% 
  tune_grid(
    birth_fold, 
    grid = rf_grid2, 
    control = control_resamples(save_workflow = TRUE)
  )

# write out results (fitted/trained workflows) ----
save(rf_tuned2, file = here("results/rf_tuned2.rda"))