# fit k nearest neighbor

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
load(here("recipes/birth_rec1a.rda"))

# parallel processing ----
num_cores <- parallel::detectCores(logical = TRUE)
registerDoMC(cores = num_cores / 2)

# model specifications ----
knn_model <-
  nearest_neighbor(neighbors = tune()) %>%
  set_engine("kknn") %>%
  set_mode("regression")

# define workflows ----
knn_wflow <- 
  workflow() %>% 
  add_model(knn_model) %>% 
  add_recipe(birth_rec1a)

# hyperparameter tuning values ----

# check ranges for hyperparameters
hardhat::extract_parameter_set_dials(knn_model)

# change hyperparameter ranges
knn_param <- extract_parameter_set_dials(knn_model) %>% 
  update(neighbors = neighbors(c(1, 50)))

# build tuning grid
knn_grid <- grid_regular(knn_param, levels = 25)

# fit workflows/models ----
# set seed
set.seed(902348)
knn_tuned <- knn_wflow %>% 
  tune_grid(
    birth_fold, 
    grid = knn_grid, 
    control = control_resamples(save_workflow = TRUE)
  )

# write out results (fitted/trained workflows) ----
save(knn_tuned, file = here("results/knn_tuned.rda"))