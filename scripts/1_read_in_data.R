# read in data and check quality

# load packages
library(tidyverse)
library(here)

births <- read_csv(here("data/US_births(2018).csv")) %>% 
  janitor::clean_names()


# ok so there are like 3 million observations so ask if i can select some variables and randomly sample like 30 thousand observations