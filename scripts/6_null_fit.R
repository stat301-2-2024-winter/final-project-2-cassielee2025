# fit null model

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
load(here("recipes/birth_rec1a.rda"))

# parallel processing ----
num_cores <- parallel::detectCores(logical = TRUE)
registerDoMC(cores = num_cores - 1)

# model specifications ----
null_spec <-
  null_model() %>% 
  set_engine("parsnip") %>% 
  set_mode("regression")

# define workflows ----
null_wflow <- 
  workflow() %>% 
  add_model(null_spec) %>% 
  add_recipe(birth_rec1a)

# fit to resampled data ----
null_fit <- null_wflow %>% 
  fit_resamples(birth_fold)

# metrics ----
null_fit %>% 
  collect_metrics()

# save fit ----
save(null_fit, file = here("results/null_fit.rda"))
  