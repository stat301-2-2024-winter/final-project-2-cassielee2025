# analyze models

# load libraries
library(tidyverse)
library(tidymodels)
library(here)


# load fits
load(here("results/bt_tuned.rda"))
load(here("results/bt_tuned2.rda"))
load(here("results/bt_tuned3.rda"))
load(here("results/bt_tuned4.rda"))

# combine workflows ----
bt_fits <- as_workflow_set(
  bt = bt_tuned,
  bt2 = bt_tuned2,
  bt3 = bt_tuned3,
  bt4 = bt_tuned4
)

bt_metrics <- bt_fits %>% 
  collect_metrics() %>% 
  filter(.metric == "rmse") %>% 
  slice_min(mean, by = wflow_id)

# save metrics
save(bt_metrics, file = here("results/bt_metrics.rda"))

################################################################################
# autoplot tuning graphs ####
################################################################################
bt_metrics %>% 
  arrange(mean) %>% 
  mutate(rank = 1:4) %>% 
  ggplot(aes(rank, mean)) +
  geom_point(aes(color = wflow_id)) +
  geom_errorbar(aes(color = wflow_id, ymin = mean - std_err, ymax = mean + std_err), width = 0.1) +
  labs(
    x = "Workflow Rank",
    y = "RMSE"
  ) +
  guides(color = guide_legend(title = "Model")) 

ggsave(plot = last_plot(), filename = "workflow_rank_bt_only.png", path = here("results/"))



