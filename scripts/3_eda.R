# EDA

# load packages
library(tidyverse)
library(here)
library(corrplot)

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
  
  # create file name
  file_name <- rlang::englue("factor_{{  var  }}.png")
  
  # save file
  ggsave(
    file_name, 
    plot = last_plot(), 
    path = here("memos/memo2_outputs/eda_outputs")
  )
}

# get list of factor variables
factor_vars <- birth_eda %>% 
  select(where(is.factor), where(is.logical)) %>% 
  colnames()

# plot for all factor variables
for(i in factor_vars){
  
  # make and save plot
  plot_factor(!! sym(i))

}

# numeric variables ----

# function for plotting numeric variables
plot_numeric <- function(var){
  
  # create scatterplot between numeric variable and birthweight
  birth_eda %>% 
    ggplot(aes({{  var  }}, dbwt)) +
    geom_point(alpha = 0.1) +
    geom_smooth(method = "lm", se = FALSE) + 
    theme_classic()
  
  # create file name
  file_name <- rlang::englue("numeric_{{  var  }}.png")
  
  # save file
  ggsave(
    file_name, 
    plot = last_plot(), 
    path = here("memos/memo2_outputs/eda_outputs")
  )
}

# get list of numeric variables
numeric_vars <- birth_eda %>% 
  select(where(is.numeric), -dbwt) %>% 
  colnames()

# plot for all numeric variables
for(i in numeric_vars){
  
  # make and save plot
  plot_numeric(!! sym(i))
  
}

# make a correlation matrix ----

png(filename = here("memos/memo2_outputs/eda_outputs/corrplot.png"), unit = "in", width = 5, height = 4, res = 300)

birth_eda %>% 
  na.omit() %>% 
  select(where(is.numeric)) %>% 
  cor() %>% 
  corrplot()

dev.off()


