# fit elastic net regression

# random processes present throughout script

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
load(here("recipes/birth_rec2a.rda"))

# parallel processing ----
num_cores <- parallel::detectCores(logical = TRUE)
registerDoMC(cores = num_cores / 2)

# model specifications ----
en_spec <- 
  linear_reg(
    penalty = tune(), 
    mixture = tune()
  ) %>%
  set_engine("glmnet") %>%
  set_mode("regression")

# define workflows ----
en_wflow2 <-
  workflow() %>%
  add_model(en_spec) %>% 
  add_recipe(birth_rec2a)

# hyperparameter tuning values ----

# check ranges for hyperparameters
hardhat::extract_parameter_set_dials(en_spec)

# set hyperparameter ranges
en_param2 <- extract_parameter_set_dials(en_spec) %>% 
  update(
    penalty = penalty(c(-10, 0)),
    mixture = mixture(c(0,1))
  )

# build tuning grid
set.seed(87634)
en_grid2 <- grid_latin_hypercube(en_param2, size = 500)

# fit workflows/models ----
# set seed
set.seed(9765)
en_tuned2 <- en_wflow2 %>% 
  tune_grid(
    birth_fold, 
    grid = en_grid2, 
    control = control_resamples(save_workflow = TRUE)
  )

# write out results (fitted/trained workflows) ----
save(en_tuned2, file = here("results/en_tuned2.rda"))