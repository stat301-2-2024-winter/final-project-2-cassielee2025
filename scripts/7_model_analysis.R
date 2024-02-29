# analyze models

# load libraries
library(tidyverse)
library(tidymodels)
library(here)

# load fits
load(here("results/bt_tuned.rda"))
load(here("results/en_tuned.rda"))
load(here("results/lm_fit.rda"))
load(here("results/nnet_tuned.rda"))
load(here("results/null_fit.rda"))
load(here("results/rf_tuned.rda"))

load(here("results/bt_tuned2.rda"))
load(here("results/en_tuned2.rda"))
load(here("results/lm_fit2.rda"))
load(here("results/nnet_tuned2.rda"))
load(here("results/rf_tuned2.rda"))

# null and lm fit metrics ----
null_lm_metrics <- bind_rows(
  
  "null" = null_fit %>% 
    collect_metrics() %>% 
    filter(.metric == "rmse"),
  
  "lm" = lm_fit %>% 
    collect_metrics() %>% 
    filter(.metric == "rmse"),
  
  "lm2" = lm_fit2 %>% 
    collect_metrics() %>% 
    filter(.metric == "rmse"),
  
  .id = "model"
) %>% 
  select(model, .metric, mean, n, std_err)

# combine workflows ----
all_fits <- as_workflow_set(
  bt = bt_tuned,
  en = en_tuned,
  nnet = nnet_tuned,
  rf = rf_tuned,
  bt2 = bt_tuned2,
  en2 = en_tuned2,
  nnet2 = nnet_tuned2,
  rf2 = rf_tuned2
)

all_metrics <- all_fits %>% 
  collect_metrics() %>% 
  filter(.metric == "rmse") %>% 
  slice_min(mean, by = wflow_id)

# save metrics
save(null_lm_metrics, file = here("results/null_lm_metrics.rda"))
save(all_metrics, file = here("results/all_metrics.rda"))

