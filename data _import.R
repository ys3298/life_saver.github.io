library(tidyverse)
library(readxl)
library(rvest)
library(httr)

## suicide_rate_df
suicide_rate_df = 
  read_excel("./data/suicide_age_gender.xlsx") %>% 
  janitor::clean_names() %>%
  filter(year == 2017) %>% 
  filter(is.na(ten_year_age_groups)) %>% 
  drop_na(gender) %>% 
  select(state,gender, deaths, population) %>%
  group_by(state) %>% 
  summarize(
    suicide_rate_per100000 = sum(deaths)*100000/sum(population)
  )


## gender_rate_df
gender_rate_df = 
  read_excel("./data/suicide_age_gender.xlsx") %>% 
  janitor::clean_names() %>%
  filter(year == 2017) %>% 
  filter(is.na(ten_year_age_groups)) %>% 
  drop_na(gender) %>% 
  select(state,gender,population) %>% 
  pivot_wider(
    names_from = "gender",
    values_from = "population"
  ) %>% 
  mutate(
    female_ratio = Female/(Female+Male),
    male_ratio = Male/(Female+Male)
  ) %>% 
  select(state, female_ratio, male_ratio)


## gender_suiciderate_df
gender_suiciderate_df =
  read_excel("./data/suicide_age_gender.xlsx") %>% 
  janitor::clean_names() %>%
  filter(year == 2017) %>% 
  filter(is.na(ten_year_age_groups)) %>% 
  drop_na(gender) %>% 
  select(state,gender,deaths,population) %>% 
  mutate(
    suicide_rate_per100000 = deaths*100000/population
  ) %>% 
  select(state, gender, suicide_rate_per100000) %>% 
  pivot_wider(
    names_from = gender,
    values_from = suicide_rate_per100000
  ) %>% 
  mutate(F_suicide_rate_per100000 = Female, M_suicide_rate_per100000 = Male) %>% 
  select(-Female, -Male)


## age 
age_df =
  read_excel("./data/suicide_age_gender.xlsx") %>% 
  janitor::clean_names() %>%
  filter(year == 2017) %>% 
  drop_na(ten_year_age_groups) %>% 
  select(state,gender,ten_year_age_groups, population) %>% 
  pivot_wider(
    names_from = "gender",
    values_from = "population"
  ) %>% 
  mutate(
    Female = replace(Female, is.na(Female), 0),
    Male = replace(Male, is.na(Male), 0),
    total = Female + Male
  ) %>% 
  select(-Female, -Male) %>%
  pivot_wider(
    names_from = "ten_year_age_groups",
    values_from = "total"
  ) %>%
  rename("Y15_24" = "15-24 years", "Y25_34" = "25-34 years","Y35_44" = "35-44 years","Y45_54" = "45-54 years","Y55_64" = "55-64 years","Y65_74" = "65-74 years","Y5_14" = "5-14 years", "Y75_84" = "75-84 years","Y85_larger" = "85+ years") %>% 
  mutate(
    Y5_14 = replace(Y5_14, is.na(Y5_14), 0),
    Y15_24 = replace(Y15_24, is.na(Y15_24), 0),
    Y25_34 = replace(Y25_34, is.na(Y25_34), 0),
    Y35_44 = replace(Y35_44, is.na(Y35_44), 0),
    Y45_54 = replace(Y45_54, is.na(Y45_54), 0),
    Y55_64 = replace(Y55_64, is.na(Y55_64), 0),
    Y65_74 = replace(Y65_74, is.na(Y65_74), 0),
    Y75_84 = replace(Y75_84, is.na(Y75_84), 0),
    Y85_larger = replace(Y85_larger, is.na(Y85_larger), 0),
    total = Y5_14 + Y15_24 + Y25_34+Y35_44+Y45_54+Y55_64+Y65_74 +Y75_84+Y85_larger,
    R5_14 = Y5_14/total,
    R15_24= Y15_24/total,
    R25_34=Y25_34/total,
    R35_44=Y35_44/total,
    R45_54=Y45_54/total,
    R55_64=Y55_64/total,
    R65_74=Y65_74/total,
    R75_84=Y75_84/total,
    R85_larger = Y85_larger/total
  ) %>% 
  select(state, contains("R"))


## read and clean alcohol
alcohol = read_excel("./data/alcohol2017.xlsx", sheet = 2, skip = 3) %>% 
  janitor::clean_names() %>% 
  remove_missing() %>% 
  mutate(state = alcohol_consumption_per_capita_from_all_beverages_in_the_u_s_in_2017_by_state_in_gallons_of_ethanol, 
         alcohol_consumption_per_capita_gallons = x2) %>% 
  select(state, alcohol_consumption_per_capita_gallons)


## read and clean marijuana
marijuana = read_excel("./data/marijuana2017.xlsx", sheet = 2, skip = 3) %>% 
  janitor::clean_names() %>% 
  remove_missing() %>% 
  mutate(state = percentage_of_u_s_adults_that_have_used_cannabis_within_the_past_year_from_2016_to_2017_by_state, 
         marijuana_percentage = x2*0.01) %>% 
  select(state, marijuana_percentage)

left_join(alcohol, marijuana)


## education
edu = 
  cbind(readxl::read_excel("./xj/Educational Attainment.xlsx",range = "A2:A54"),
        readxl::read_excel("./xj/Educational Attainment.xlsx",range = "N2:S54")) %>% 
  janitor::clean_names() %>% 
  mutate(year = "2017") %>% 
  select(state, year, everything(),-less_than_bachelors,-at_least_bachelors) 


## gun
url = "https://www.thoughtco.com/gun-owners-percentage-of-state-populations-3325153"
gun_xml = read_html(url)
gun_xml %>%
  html_nodes(css = "table")

gun= 
  (gun_xml %>% html_nodes(css = "table")) %>% 
  .[[1]] %>%
  html_table(header = T) %>% 
  slice(-1) %>% 
  as_tibble() %>% 
  janitor::clean_names() %>% 
  mutate(year = "2017") %>% 
  select(state,year,everything(),-rank) %>% 
  select(-year)


## precipitation
precipitation = read_html("https://www.netstate.com/states/tables/state_precipitation.htm") %>%
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


## temperature
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

state_ab_data = read_excel(path = "./data/state_ab.xlsx")

temperature = 
  left_join(state_ab_data, temp_data, by = "state_ab") %>% 
  select(state, mean_temperature_F) %>% 
  mutate(state = str_replace(state, "\\s", ""))

## GDP
gdp = read.csv("./data/gdp_2017.csv") %>% 
  mutate(gdp = X2017) %>% 
  select(-X2017)

## joint
us_2017 = 
  left_join(suicide_rate_df, gender_rate_df) %>% 
  left_join(gender_suiciderate_df) %>% 
  left_join(age_df) %>% 
  left_join(alcohol) %>% 
  left_join(marijuana) %>% 
  left_join(edu) %>% 
  left_join(gdp) %>% 
  left_join(gun) %>% 
  left_join(precipitation) %>% 
  left_join(temperature) %>% 
  select(-year)

write_csv(us_2017,"./data/us_2017.csv")
