# fit linear regression

# load packages ----
library(tidyverse)
library(tidymodels)
library(here)

# prefer tidymodels
tidymodels_prefer()

# load training data & controls
load(here("data/data_split/birth_fold.rda"))

# load pre-processing/feature engineering/recipe
load(here("recipes/birth_rec_null.rda"))

# model specifications ----
lm_spec <-
  linear_reg() %>%
  set_engine("lm") %>%
  set_mode("regression")

# define workflows ----
lm_wflow <- 
  workflow() %>% 
  add_model(lm_spec) %>% 
  add_recipe(birth_rec_null)

# fit to resampled data ----
lm_fit <- lm_wflow %>% 
  fit_resamples(birth_fold)

# metrics ----
lm_fit %>% 
  collect_metrics()

# save fit ----
save(lm_fit, file = here("results/lm_fit.rda"))
