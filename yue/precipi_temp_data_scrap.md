weather\_data\_scraping
================
Yue Lai

## scraping precipitation data from website

``` r
precipi_data = read_html("https://www.netstate.com/states/tables/state_precipitation.htm") %>%
  html_nodes(css = "table") %>%
  .[[1]] %>%
  html_table(fill = TRUE) %>% 
  select(X2, X3) %>% 
  slice(-1:-4) %>% 
  slice(-(n() - 3):-n()) %>% 
  rename(state = X2, precipitation = X3) %>% 
  separate(precipitation, into = c("precipitation_inches", "precipitation_cm"), sep = " inches [(]") %>% 
  select(state, precipitation_inches) %>% 
  mutate(precipitation_inches = as.numeric(precipitation_inches))

write.table(precipi_data, file = "./precipitation_avg.csv", sep = ",", row.names = FALSE)
```

## scraping temperature data from website

``` r
temp_data = read_html("http://www.usa.com/rank/us--average-temperature--metro-area-rank.htm?yr=9000&dis=&wist=&plow=&phigh=") %>%
  html_nodes(css = "table") %>%
  .[[2]] %>%
  html_table() %>% 
  slice(-1) %>% 
  separate(X2, into = c("temperature", "unit"), sep = "°") %>% 
  separate(X3, into = c("area_state", "population"), sep = " / ") %>% 
  separate(area_state, into = c("area", "state_ab"), sep = ", ") %>% 
  select(temperature, state_ab) %>% 
  mutate(temperature = as.numeric(temperature)) %>% 
  group_by(state_ab) %>% 
  summarize(mean_temperature_F = mean(temperature)) %>% 
  filter(nchar(state_ab) == 2)

state_ab_data = read_excel(path = "./state_ab.xlsx")

temperature_data = 
  left_join(state_ab_data, temp_data, by = "state_ab") %>% 
  select(state, mean_temperature_F)

write.table(temperature_data, file = "./temperature_avg.csv", sep = ",", row.names = FALSE)
```
