# target variable analysis

# load packages
library(tidyverse)
library(here)
library(patchwork)

# load data
load(here("data/birth_data.rda"))

# split data into eda data and modeling data
birth_eda <- birth_data %>% 
  slice(1:15000)

birth_model_data <- birth_data %>% 
  slice(15001:30000)

# target variable analysis 

p1 <- birth_eda %>% 
  ggplot(aes(dbwt)) +
  geom_density() +
  theme_minimal() +
  theme(
    axis.text.y = element_blank(),
    axis.title.y = element_blank(),
    axis.ticks.y = element_blank()
  ) +
  labs(x = "Birth weight (grams)")

p2 <- birth_eda %>% 
  ggplot(aes(dbwt)) +
  geom_boxplot() +
  theme_void() 

plot <- p2/p1 +
  plot_layout(heights = unit(c(1,5), c("cm", "null")))

save(plot, file = here("memos/memo1_outputs/target_variable.rda"))

# save data splits
save(birth_eda, file = here("data/data_split/birth_eda.rda"))
save(birth_model_data, file = here("data/data_split/birth_model_data.rda"))

