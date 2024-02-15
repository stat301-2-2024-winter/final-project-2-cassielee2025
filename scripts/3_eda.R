# EDA

# load packages
library(tidyverse)
library(here)

# load EDA data
load(here("data/data_split/birth_eda.rda"))

# skim data
birth_eda %>% 
  skimr::skim_without_charts()

# factor variables ----

# function for plotting factor variables
plot_factor <- function(var){
  
  # create boxplot between factor variable and birthweight
  birth_eda %>% 
    ggplot(aes({{  var  }}, dbwt)) +
    geom_boxplot() +
    theme_classic()
}

# check that the function works
plot_factor(attend)
plot_factor(bfacil)

# get list of factor variables
factor_vars <- birth_eda %>% 
  select_if(is.factor) %>% 
  colnames()

factor_vars %>% 
  map(plot_factor)

# plot for all factor variables
for(i in factor_vars){

  # make and save plot
  plot_factor(!! sym(i))
  
  # create file name
  file_name <- paste0("factor_", i, ".png")
  
  # save file
  ggsave(
    file_name, 
    plot = last_plot(), 
    path = here("eda_output/")
  )
}

var_name <- as.name("attend") 
plot_factor(var_name) # why doesn't this work
plot_factor(attend)

