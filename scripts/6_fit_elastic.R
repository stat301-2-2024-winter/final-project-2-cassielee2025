# fit elastic net regression

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
load(here("recipes/birth_rec1.rda"))

# parallel processing ----
num_cores <- parallel::detectCores(logical = TRUE)
registerDoMC(cores = num_cores - 1)

# model specifications ----
elastic_rec <- 
  linear_reg(
    penalty = tune(), 
    mixture = tune()
  ) %>%
  set_engine("glm") %>%
  set_mode("regression")