
library(tidyverse)
library(httr)
library(rvest)
url = "https://en.wikipedia.org/wiki/List_of_U.S._states_by_GDP_per_capita"
gdp_xml = read_html(url)

table_gdp_2017 = 
  (gdp_xml %>% html_nodes(css = "table")) %>% 
  .[[1]] %>%
  html_table() %>% data.frame() %>% 
  janitor::clean_names() %>% 
  filter(state!=c("District of Columbia","United States")) %>% 
  select(state,x2017) %>% 
  rename("2017"="x2017")

write_csv(table_gdp_2017,"./data/gdp_per_2017.csv")
