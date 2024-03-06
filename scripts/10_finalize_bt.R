# fit boosted tree using rec 2

# load packages
library(tidyverse)
library(tidymodels)
library(here)
library(doMC)
library(xgboost)

# prefer tidymodels
tidymodels_prefer()

# load training data & controls
load(here("data/data_split/birth_train.rda"))

# load tuning fit
load(here("results/bt_tuned4.rda"))

# parallel processing ----
num_cores <- parallel::detectCores(logical = TRUE)
registerDoMC(cores = num_cores / 2)

# finalize workflow ----
final_wflow <- bt_tuned4 %>%  
  extract_workflow(bt_tuned4) %>% 
  finalize_workflow(select_best(bt_tuned4, metric = "rmse"))

# train final model ----
# set seed
set.seed(9893437)
final_fit <- fit(final_wflow, birth_train)

# save final model
save(final_fit, file = here("results/final_fit.rda"))