# fit boosted tree using lightgbm

# load packages
library(tidyverse)
library(tidymodels)
library(here)
library(doMC)
library(bonsai)

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
  set_engine("lightgbm") %>%
  set_mode("regression")

# define workflows ----
bt_wflow3 <-
  workflow() %>%
  add_model(bt_spec) %>% 
  add_recipe(birth_rec1b)

# hyperparameter tuning values ----

# check ranges for hyperparameters
hardhat::extract_parameter_set_dials(bt_spec)

# change hyperparameter ranges
bt_param3 <- extract_parameter_set_dials(bt_spec) %>% 
  update(
    mtry = mtry(c(1, 30)),
    trees = trees(c(1, 3000))
  )

# build tuning grid
set.seed(984375)
bt_grid3 <- grid_latin_hypercube(bt_param3, size = 50)

# fit workflows/models ----
# set seed
set.seed(98435)
bt_tuned3 <- bt_wflow3 %>% 
  tune_grid(
    birth_fold, 
    grid = bt_grid3, 
    control = control_resamples(save_workflow = TRUE)
  )


# get metrics
bt3_metrics <- bt_tuned3 %>% 
  collect_metrics() %>% 
  filter(.metric == "rmse") %>% 
  slice_min(mean)

# write out results (fitted/trained workflows) ----
save(bt_tuned3, file = here("results/bt_tuned3.rda"))
save(bt3_metrics, file = here("results/bt3_metrics.rda"))

