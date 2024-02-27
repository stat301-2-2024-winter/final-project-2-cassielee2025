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
# basic recipes using variables as is (leaving illb_r and ilp_r with 888 for first birth/pregnancy) ----
################################################################################
# recipe for linear, elastic net, and neural network models
birth_rec1a <- birth_train %>% 
  recipe(dbwt ~ .) %>% 
  step_mutate(
    # change NA in interval (numeric) variables to 0 if plural delivery
    across(c(illb_r, ilp_r), \(x) if_else(is.na(x), 0, x)),
    
    # and change NA in precare to 10 (essentially negative amounts of prenatal care) if no precare
    precare = if_else(is.na(precare), 10, precare),
    
    # change logical data type to character
    across(c(plural_del, any_precare, first_birth, first_preg), as.character)
  ) %>% 
  
  #change string to factor
  step_string2factor(plural_del, any_precare, first_birth, first_preg) %>% 
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
  step_mutate(
    # change NA in interval (numeric) variables to 0 if plural delivery
    across(c(illb_r, ilp_r), \(x) if_else(is.na(x), 0, x)),
    
    # and change NA in precare to 10 (essentially negative amounts of prenatal care) if no precare
    precare = if_else(is.na(precare), 10, precare),
    
    # change logical data type to character
    across(c(plural_del, any_precare, first_birth, first_preg), as.character)
  ) %>% 
  #change string to factor
  step_string2factor(plural_del, any_precare, first_birth, first_preg) %>% 
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
save(birth_rec1b, file = here("recipes/birth_rec1b.rda"))

################################################################################
# recipe adding prenatal in first trimester care as a binary variable, interaction terms ----
################################################################################
# recipe for linear, elastic net, and neural network models
birth_rec2a <- birth_train %>% 
  recipe(dbwt ~ .) %>% 
  step_mutate(
    
    # change NA in interval (numeric) variables to 0 if plural delivery
    across(c(illb_r, ilp_r), \(x) if_else(is.na(x), 0, x)),
    
    # was there prenatal care beginning in the first trimester?
    first_tri_precare = case_when(
      is.na(precare) ~ FALSE,
      precare <= 3 ~ TRUE,
      precare > 3 ~ FALSE
    ),
    
    # is the mother a teenager or over 35
    age_risk = case_when(
      mager <= 18 ~ TRUE, 
      mager >= 35 ~ TRUE,
      mager > 18 & mager < 35 ~ FALSE
    ),
    
    # change logical data type to character
    across(c(first_tri_precare, plural_del, any_precare, first_birth, first_preg, age_risk), as.character)
  ) %>% 
  step_rm(precare) %>% 
  step_string2factor(first_tri_precare, plural_del, any_precare, first_birth, first_preg, age_risk) %>% 
  step_unknown(all_nominal_predictors()) %>% 
  step_dummy(all_nominal_predictors()) %>% 
  step_zv(all_predictors()) %>% 
  step_lincomb(all_predictors()) %>% 
  step_sqrt(all_numeric_predictors()) %>% 
  step_interact(
    # interaction between starting prenatal care early and number of prenatal visits
    ~ starts_with("first_tri_precare"):previs,
  ) %>% 
  step_interact(
    # interaction between weight gain and pre-pregnancy weight
    ~ p_wgt_r:wtgain
  ) %>%
  step_interact(
    # interaction between plural delivery and weight gain
    ~ starts_with("plural_del"):wtgain
  ) %>%
  step_interact(
    # interaction between cigarettes and weight gain
    ~ cig_0:wtgain
  ) %>%
  step_interact(
    # interaction between risks and number of prenatal visits
    ~ starts_with("no_risks"):previs
  ) %>%
  step_scale(all_numeric_predictors()) %>% 
  step_center(all_numeric_predictors())

birth_rec2a %>% 
  prep() %>% 
  bake(new_data = NULL)

# recipe for tree based models
birth_rec2b <- birth_train %>% 
  recipe(dbwt ~ .) %>% 
  step_sqrt(cig_0, p_wgt_r, wtgain) %>% 
  step_mutate(
    
    # change NA in interval (numeric) variables to 0 if plural delivery
    across(c(illb_r, ilp_r), \(x) if_else(is.na(x), 0, x)),
    
    # was there prenatal care beginning in the first trimester?
    first_tri_precare = case_when(
      is.na(precare) ~ FALSE,
      precare <= 3 ~ TRUE,
      precare > 3 ~ FALSE
    ),
    
    # change logical data type to character
    across(c(first_tri_precare, plural_del, any_precare, first_birth, first_preg), as.character)
  ) %>% 
  step_rm(precare) %>% 
  step_string2factor(first_tri_precare, plural_del, any_precare, first_birth, first_preg) %>% 
  step_unknown(all_nominal_predictors()) %>% 
  step_dummy(all_nominal_predictors(), one_hot = TRUE) %>% 
  step_zv(all_predictors()) %>% 
  step_lincomb(all_predictors()) %>% 
  step_interact(
    # interaction between starting prenatal care early and number of prenatal visits
    ~ starts_with("first_tri_precare"):previs,
  ) %>% 
  step_interact(
    # interaction between weight gain and pre-pregnancy weight
    ~ p_wgt_r:wtgain
  ) %>%
  step_interact(
    # interaction between plural delivery and weight gain
    ~ starts_with("plural_del"):wtgain
  ) %>%
  step_interact(
    # interaction between cigarettes and weight gain
    ~ cig_0:wtgain
  ) %>%
  step_interact(
    # interaction between risks and number of prenatal visits
    ~ starts_with("no_risks"):previs
  )

birth_rec2b %>% 
  prep() %>% 
  bake(new_data = NULL)

# save recipes 
save(birth_rec2a, file = here("recipes/birth_rec2a.rda"))
save(birth_rec2b, file = here("recipes/birth_rec2b.rda"))
