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
registerDoMC(cores = num_cores / 2)

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
bt_wflow4 <-
  workflow() %>%
  add_model(bt_spec) %>% 
  add_recipe(birth_rec1b)

# hyperparameter tuning values ----

# check ranges for hyperparameters
hardhat::extract_parameter_set_dials(bt_spec)

# change hyperparameter ranges
bt_param4 <- extract_parameter_set_dials(bt_spec) %>% 
  update(
    mtry = mtry(c(10, 15)),
    trees = trees(c(2000, 3000)),
    min_n = min_n(c(20,30)),
    learn_rate = learn_rate(c(-2, -2.8))
  )

# build tuning grid
set.seed(6836)
bt_grid4 <- grid_random(bt_param4, size = 100)

# fit workflows/models ----
# set seed
set.seed(32732)
bt_tuned4 <- bt_wflow4 %>% 
  tune_grid(
    birth_fold, 
    grid = bt_grid4, 
    control = control_resamples(save_workflow = TRUE)
  )


# get metrics
bt4_metrics <- bt_tuned4 %>% 
  collect_metrics() %>% 
  filter(.metric == "rmse") %>% 
  slice_min(mean)

# write out results (fitted/trained workflows) ----
save(bt_tuned4, file = here("results/bt_tuned4.rda"))
save(bt4_metrics, file = here("results/bt4_metrics.rda"))

