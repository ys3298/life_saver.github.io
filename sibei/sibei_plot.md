---
title: "plot from sibei"
author: "Sibei Liu"
date: "2019/11/19"
output: html_document
---



```r
library(tidyverse)
library(ezknitr)
ezknit(file = "sibei/sibei_plot.Rmd", out_dir = "sibei")
```

```
## ezknit output in
## C:\Users\Sibei\Documents\myprojectinDataScience\final\life_saver.github.io\sibei
```

```r
global=read_csv("./data/master.csv")
```

```
## Parsed with column specification:
## cols(
##   country = col_character(),
##   year = col_double(),
##   sex = col_character(),
##   age = col_character(),
##   suicides_no = col_double(),
##   population = col_double(),
##   `suicides/100k pop` = col_double(),
##   `country-year` = col_character(),
##   `HDI for year` = col_double(),
##   `gdp_for_year ($)` = col_number(),
##   `gdp_per_capita ($)` = col_double(),
##   generation = col_character()
## )
```

