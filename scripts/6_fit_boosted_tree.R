# fit boosted tree

# load packages
library(tidyverse)
library(tidymodels)
library(here)
library(doMC)
library(xgboost)

# prefer tidymodels
tidymodels_prefer()

# load training data & controls
load(here("data/data_split/birth_fold.rda"))

# load pre-processing/feature engineering/recipe
load(here("recipes/birth_rec1b.rda"))

# parallel processing ----
num_cores <- parallel::detectCores(logical = TRUE)
registerDoMC(cores = num_cores - 2)

# model specifications ----
bt_spec <- 
  boost_tree(
    mtry = tune(), 
    min_n = tune(),
    learn_rate = tune(),
    trees = tune()
  ) %>%
  set_engine("xgboost") %>%
  set_mode("regression")

# define workflows ----
bt_wflow <-
  workflow() %>%
  add_model(bt_spec) %>% 
  add_recipe(birth_rec1b)

# hyperparameter tuning values ----

# check ranges for hyperparameters
hardhat::extract_parameter_set_dials(bt_spec)

# change hyperparameter ranges
bt_param <- extract_parameter_set_dials(bt_spec) %>% 
  update(
    mtry = mtry(c(1, 30)),
    min_n = min_n(c(2, 50)),
    learn_rate = learn_rate(range = c(-5, -0.2)),
    trees = trees(c(1, 3000))
  )

# build tuning grid
set.seed(1234234)
bt_grid <- grid_random(bt_param, size = 100)

# fit workflows/models ----
# set seed
set.seed(840983)
bt_tuned <- bt_wflow %>% 
  tune_grid(
    birth_fold, 
    grid = bt_grid, 
    control = control_resamples(save_workflow = TRUE)
  )

# write out results (fitted/trained workflows) ----
save(bt_tuned, file = here("results/bt_tuned.rda"))
