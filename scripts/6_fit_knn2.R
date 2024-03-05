# fit k nearest neighbor using second recipe

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
knn_model <-
  nearest_neighbor(neighbors = tune()) %>%
  set_engine("kknn") %>%
  set_mode("regression")

# define workflows ----
knn_wflow2 <- 
  workflow() %>% 
  add_model(knn_model) %>% 
  add_recipe(birth_rec2a)

# hyperparameter tuning values ----

# check ranges for hyperparameters
hardhat::extract_parameter_set_dials(knn_model)

# change hyperparameter ranges
knn_param2 <- extract_parameter_set_dials(knn_model) %>% 
  update(neighbors = neighbors(c(1, 500)))

# build tuning grid
knn_grid2 <- grid_regular(knn_param2, levels = 250)

# fit workflows/models ----
# set seed
set.seed(237894)
knn_tuned2 <- knn_wflow2 %>% 
  tune_grid(
    birth_fold, 
    grid = knn_grid2, 
    control = control_resamples(save_workflow = TRUE)
  )

# write out results (fitted/trained workflows) ----
save(knn_tuned2, file = here("results/knn_tuned2.rda"))