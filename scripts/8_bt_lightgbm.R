# fit boosted tree

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
bt_spec2 <- 
  boost_tree(
    mtry = tune(), 
    min_n = tune(),
    learn_rate = tune(),
    trees = tune()
  ) %>%
  set_engine("lightgbm") %>%
  set_mode("regression")

# define workflows ----
bt_wflow2 <-
  workflow() %>%
  add_model(bt_spec2) %>% 
  add_recipe(birth_rec1b)

# hyperparameter tuning values ----

# check ranges for hyperparameters
hardhat::extract_parameter_set_dials(bt_spec2)

# change hyperparameter ranges
bt_param2 <- extract_parameter_set_dials(bt_spec2) %>% 
  update(
    mtry = mtry(c(1, 30)),
    min_n = min_n(c(2, 50)),
    learn_rate = learn_rate(range = c(-5, -0.2)),
    trees = trees(c(1, 3000))
  )

# build tuning grid
set.seed(984375)
bt_grid2 <- grid_random(bt_param2, size = 50)

# fit workflows/models ----
# set seed
set.seed(98435)
bt_tuned2 <- bt_wflow2 %>% 
  tune_grid(
    birth_fold, 
    grid = bt_grid2, 
    control = control_resamples(save_workflow = TRUE)
  )

# write out results (fitted/trained workflows) ----
save(bt_tuned2, file = here("results/bt_tuned2.rda"))
