# fit neural network model

# load packages ----
library(tidyverse)
library(tidymodels)
library(here)
library(doMC)

# prefer tidymodels
tidymodels_prefer()

# load training data & controls
load(here("data/data_split/birth_fold.rda"))

# load pre-processing/feature engineering/recipe
load(here("recipes/birth_rec2a.rda"))

# parallel processing ----
num_cores <- parallel::detectCores(logical = TRUE)
registerDoMC(cores = num_cores / 2)

# model specifications ----
nnet_spec <- 
  mlp(
    hidden_units = tune(), 
    penalty = tune(), 
    epochs = tune()
  ) %>% 
  set_engine("nnet", MaxNWts = 2600) %>% 
  set_mode("regression")

# hyperparameter tuning values ----

# check ranges for hyperparameters
hardhat::extract_parameter_set_dials(nnet_spec)

# set hyperparameter ranges
nnet_param2 <- extract_parameter_set_dials(nnet_spec)

# build tuning grid
set.seed(231324)
nnet_grid2 <- grid_latin_hypercube(nnet_param2, size = 100)

# define workflows ----
nnet_wflow2 <-
  workflow() %>% 
  add_model(nnet_spec) %>% 
  add_recipe(birth_rec2a)

# fit to resampled data ----
set.seed(98375)
nnet_tuned2 <- 
  nnet_wflow2 %>% 
  tune_grid(
    birth_fold,
    grid = nnet_grid2,
    control = control_resamples(save_workflow = TRUE)
  )

# write out results (fitted/trained workflows) ----
save(nnet_tuned2, file = here("results/nnet_tuned2.rda"))
