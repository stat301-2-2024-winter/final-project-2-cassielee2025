# create recipes

# load packages ----
library(tidyverse)
library(tidymodels)
library(here)

# prefer tidymodels
tidymodels_prefer()

# load training set
load(here("data/data_split/birth_train.rda"))

# recipe for linear and elastic net
birth_rec1 <- birth_train %>% 
  recipe(dbwt ~ .) %>% 
  step_unknown(all_nominal_predictors()) %>% 
  step_dummy(all_nominal_predictors()) %>% 
  step_nzv(all_predictors()) %>% 
  step_scale(all_numeric_predictors()) %>% 
  step_center(all_numeric_predictors()) 

birth_rec1 %>% 
  prep() %>% 
  bake(new_data = NULL) %>% 
  slice(1:5)

# recipe for tree based models
birth_rec2 <- birth_train %>% 
  recipe(dbwt ~ .) %>% 
  step_unknown(all_nominal_predictors()) %>% 
  step_dummy(all_nominal_predictors(), one_hot = TRUE) %>% 
  step_nzv(all_predictors())

birth_rec2 %>% 
  prep() %>% 
  bake(new_data = NULL) %>% 
  slice(1:5)

# save recipes 
save(birth_rec1, file = here("recipes/birth_rec1.rda"))
save(birth_rec2, file = here("recipes/birth_rec2.rda"))
