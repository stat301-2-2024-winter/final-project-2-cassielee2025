# create recipes

# load packages ----
library(tidyverse)
library(tidymodels)
library(here)

# prefer tidymodels
tidymodels_prefer()

# load training set
load(here("data/data_split/birth_train.rda"))

################################################################################
# basic recipes using variables as is ----
################################################################################
# recipe for linear and elastic net
birth_rec1a <- birth_train %>% 
  recipe(dbwt ~ .) %>% 
  # change NA in interval (numeric) variables to 0 if plural delivery
  # and change NA in precare to 10 (essentially negative amounts of prenatal care) if no precare
  step_mutate(across(c(illb_r, ilop_r, ilp_r), \(x) if_else(is.na(x), 0, x)),
              precare = if_else(is.na(precare), 10, precare)) %>% 
  step_mutate(across(c(plural_del, any_precare), as.character)) %>% 
  step_string2factor(plural_del, any_precare) %>% 
  step_unknown(all_nominal_predictors()) %>% 
  step_dummy(all_nominal_predictors()) %>% 
  step_zv(all_predictors()) %>% 
  step_lincomb(all_predictors()) %>% 
  step_scale(all_numeric_predictors()) %>% 
  step_center(all_numeric_predictors())

birth_rec1a %>% 
  prep() %>% 
  bake(new_data = NULL) %>% 
  slice(1:5)

# recipe for tree based models
birth_rec1b <- birth_train %>% 
  recipe(dbwt ~ .) %>% 
  # change NA in interval (numeric) variables to 0 if plural delivery
  # and change NA in precare to 10 (essentially negative amounts of prenatal care) if no precare
  step_mutate(across(c(illb_r, ilop_r, ilp_r), \(x) if_else(is.na(x), 0, x)),
              precare = if_else(is.na(precare), 10, precare)) %>% 
  step_mutate(across(c(plural_del, any_precare), as.character)) %>% 
  step_string2factor(plural_del, any_precare) %>% 
  step_unknown(all_nominal_predictors()) %>% 
  step_dummy(all_nominal_predictors(), one_hot = TRUE) %>% 
  step_zv(all_predictors()) %>% 
  step_lincomb(all_predictors())


birth_rec1b %>% 
  prep() %>% 
  bake(new_data = NULL) %>% 
  slice(1:5)

# save recipes 
save(birth_rec1a, file = here("recipes/birth_rec1a.rda"))
save(birth_rec1b, file = here("recipes/birth_recb.rda"))

################################################################################
# recipe using binary variables ----
################################################################################

