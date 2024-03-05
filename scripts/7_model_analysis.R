# analyze models

# load libraries
library(tidyverse)
library(tidymodels)
library(here)

# load fits
load(here("results/bt_tuned.rda"))
load(here("results/en_tuned.rda"))
load(here("results/lm_fit.rda"))
load(here("results/knn_tuned.rda"))
load(here("results/nnet_tuned.rda"))
load(here("results/null_fit.rda"))
load(here("results/rf_tuned.rda"))

load(here("results/bt_tuned2.rda"))
load(here("results/en_tuned2.rda"))
load(here("results/knn_tuned2.rda"))
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
  
  .id = "model"
) %>% 
  select(model, .metric, mean, n, std_err)

# combine workflows ----
all_fits <- as_workflow_set(
  bt = bt_tuned,
  bt2 = bt_tuned2,
  en = en_tuned,
  en2 = en_tuned2,
  knn = knn_tuned,
  knn2 = knn_tuned2,
  nnet = nnet_tuned,
  nnet2 = nnet_tuned2,
  rf = rf_tuned,
  rf2 = rf_tuned2
)

# best tuning parameters
all_tuning_parameters <- bind_rows(
  "bt" = bt_tuned %>% select_best(metric = "rmse"),
  "bt2" = bt_tuned2 %>% select_best(metric = "rmse"),
  "en" = en_tuned %>% select_best(metric = "rmse"),
  "en2" = en_tuned2 %>% select_best(metric = "rmse"),
  "knn" = knn_tuned %>% select_best(metric = "rmse"),
  "knn2" = knn_tuned2 %>% select_best(metric = "rmse"),
  "nnet" = nnet_tuned %>% select_best(metric = "rmse"),
  "nnet2" = nnet_tuned2 %>% select_best(metric = "rmse"),
  "rf" = rf_tuned %>% select_best(metric = "rmse"),
  "rf2" = rf_tuned2 %>% select_best(metric = "rmse"),
  .id = "model"
) %>% 
  select(-.config)

# save parameters
save(all_tuning_parameters, file = here("results/all_tuning_parameters.rda"))

# best metrics

all_metrics <- all_fits %>% 
  collect_metrics() %>% 
  filter(.metric == "rmse") %>% 
  slice_min(mean, by = wflow_id)

# save metrics
save(null_lm_metrics, file = here("results/null_lm_metrics.rda"))
save(all_metrics, file = here("results/all_metrics.rda"))

################################################################################
# autoplot tuning graphs ####
################################################################################
bt_tuned %>% 
  autoplot(metric = "rmse")

ggsave(plot = last_plot(), filename = "bt_tuned_autoplot.png", path = here("results/"))

bt_tuned2 %>% 
  autoplot(metric = "rmse")

ggsave(plot = last_plot(), filename = "bt_tuned2_autoplot.png", path = here("results/"))

en_tuned %>% 
  autoplot(metric = "rmse")

ggsave(plot = last_plot(), filename = "en_tuned_autoplot.png", path = here("results/"))

en_tuned2 %>% 
  autoplot(metric = "rmse")

ggsave(plot = last_plot(), filename = "en_tuned2_autoplot.png", path = here("results/"))

knn_tuned %>% 
  autoplot(metric = "rmse")

ggsave(plot = last_plot(), filename = "knn_tuned_autoplot.png", path = here("results/"))

knn_tuned2 %>% 
  autoplot(metric = "rmse")

ggsave(plot = last_plot(), filename = "knn_tuned2_autoplot.png", path = here("results/"))

nnet_tuned %>% 
  autoplot(metric = "rmse")

ggsave(plot = last_plot(), filename = "nnet_tuned_autoplot.png", path = here("results/"))

nnet_tuned2 %>% 
  autoplot(metric = "rmse")

ggsave(plot = last_plot(), filename = "nnet_tuned2_autoplot.png", path = here("results/"))

rf_tuned %>% 
  autoplot(metric = "rmse")

ggsave(plot = last_plot(), filename = "rf_tuned_autoplot.png", path = here("results/"))

rf_tuned2 %>% 
  autoplot(metric = "rmse")

ggsave(plot = last_plot(), filename = "rf_tuned2_autoplot.png", path = here("results/"))

# plot the best of each model

all_metrics %>% 
  arrange(mean) %>% 
  mutate(rank = 1:10) %>% 
  ggplot(aes(rank, mean)) +
  geom_point(aes(color = wflow_id)) +
  geom_errorbar(aes(color = wflow_id, ymin = mean - std_err, ymax = mean + std_err), width = 0.1) +
  labs(
    x = "Workflow Rank",
    y = "RMSE"
  ) +
  guides(color = guide_legend(title = "Model")) +
  geom_hline(yintercept = 526.3188) +
  geom_hline(yintercept = 524.7359, linetype = "dotted") + 
  geom_hline(yintercept = 527.9017, linetype = "dotted") +
  scale_x_continuous(breaks = seq(0, 10, 2)) +
  annotate("text", label = "Ordinary Linear Regression", x = 8.25, y = 527)

ggsave(plot = last_plot(), filename = "workflow_rank_plot.png", path = here("results/"))



