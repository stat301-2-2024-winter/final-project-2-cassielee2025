# Final model performance

# load packages ----
library(tidyverse)
library(tidymodels)
library(here)

# handle common conflicts
tidymodels_prefer()

# load testing data
load(here("data/data_split/birth_test.rda"))

# load fit
load(here("results/final_fit.rda"))

# set metrics
bt_metrics <- metric_set(rmse, rsq, mae, ccc, rpd)

# predictions with testing set
birth_prediction <- birth_test %>% 
  select(dbwt) %>% 
  bind_cols(predict(final_fit, birth_test))

# get metrics
test_metrics <- bt_metrics(birth_prediction, truth = dbwt, estimate = .pred)
save(test_metrics, file = here("results/test_metrics.rda"))

# visualize results
ggplot(birth_prediction, aes(x = dbwt, y = .pred)) + 
  geom_abline(lty = 2) + 
  geom_point(alpha = 0.3) + 
  labs(y = "Predicted Birth Weight", x = "Actual Birth Weight") +
  coord_obs_pred()

ggsave(plot = last_plot(), filename = "predictions_plot.png", path = here("results/"))

# winkler interval ----
birth_prediction %>% 
  winkler(dbwt, .pred)



