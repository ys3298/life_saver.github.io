
library(tidyverse)
library(readxl)

# read and clean alcohol
alcohol = read_excel("./data/alcohol2017.xlsx", sheet = 2, skip = 3) %>% 
  janitor::clean_names() %>% 
  remove_missing() %>% 
  mutate(state = alcohol_consumption_per_capita_from_all_beverages_in_the_u_s_in_2017_by_state_in_gallons_of_ethanol, 
         alcohol_consumption_per_capita_gallons = x2) %>% 
  select(state, alcohol_consumption_per_capita_gallons)

# read and clean marijuana
marijuana = read_excel("./data/marijuana2017.xlsx", sheet = 2, skip = 3) %>% 
  janitor::clean_names() %>% 
  remove_missing() %>% 
  mutate(state = percentage_of_u_s_adults_that_have_used_cannabis_within_the_past_year_from_2016_to_2017_by_state, 
         marijuana_percentage = x2*0.01) %>% 
  select(state, marijuana_percentage)

left_join(alcohol, marijuana)
