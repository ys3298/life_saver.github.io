library(tidyverse)
library(patchwork)
library(ggplot2)
library(gganimate)
library(babynames)
library(hrbrthemes)
library(gapminder)
library(gifski)

global=read_csv("./data/master.csv")

## Global trend (by year)

data_year=global %>% 
  group_by(year) %>%
  summarize(population = sum(population), 
            suicides = sum(suicides_no), 
            suicides_per100k = (suicides / population) * 100000)

data_year2=arrange(data_year, desc(suicides_per100k))[1,] 
data_year2$suicides_per100k<-round(data_year2$suicides_per100k,2)


e=ggplot(data_year,aes(year,suicides_per100k))+geom_point(col = "brown2", size = 1)+geom_line(col = "brown2", size = 1)+scale_x_continuous(breaks = seq(1986, 2016, 2)) +
  scale_y_continuous(breaks = seq(10, 20))+labs(
                                                x = "Year", 
                                                y = "Suicides per 100k")+theme_set(theme_minimal() + theme(legend.position = "bottom",axis.text.x = element_text(angle = 60, hjust = 1)))+geom_text(data=data_year2,aes(label=suicides_per100k))

ggsave("global_trend.jpg",e,path="./sibei",width =5, height =4)



## Global gender trend(by year) bar chart

data_gender=global %>%
  group_by(sex,year) %>%
  summarize(population = sum(population), 
            suicides = sum(suicides_no), 
            suicides_per100k = (suicides / population) * 100000)

a=ggplot(data_gender,aes(x=year,y=suicides_per100k)) + 
  geom_bar(aes(fill=sex),position="stack",stat="identity")+scale_x_continuous(breaks = seq(1986, 2016, 2))+coord_flip()+
  labs(x = "Year", y = "Suicide rate(per 100k)")+
  scale_color_hue(name = "Sex")+theme_set(theme_minimal() + theme(legend.position = "bottom"))

b=ggplot(data_gender,aes(year, suicides_per100k, col = sex)) + 
  geom_line() + 
  geom_point() + 
  labs(
       x = "Year", 
       y = "Suicide rate(per 100k)")  + 
  theme_set(theme_minimal() + theme(legend.position = "bottom"))+
  scale_x_continuous(breaks = seq(1985, 2015, 5), minor_breaks = F)

c=a+b

ggsave("global_trend_bysex.jpg",c,path="./sibei",width = 10, height = 5)


## Different age group trend(by year) animation separeted line

data_age=global %>% 
  mutate(
    age=fct_relevel(age,"5-14 years","15-24 years","25-34 years","35-54 years","55-74 years","75+ years")
  )%>%
  group_by(year, age) %>%
  summarize(suicide_per100k = (sum(as.numeric(suicides_no)) / sum(as.numeric(population))) * 100000) 


g=ggplot(data_age,aes(year, suicide_per100k , color = age)) + 
  facet_grid(age ~ ., scales = "free_y") + 
  geom_line() + 
  geom_point()+
  labs(title = "Suicide rate change by Age", 
       x = "Year", 
       y = "Suicides per 100k") + 
  theme(legend.position = "none") + 
  scale_x_continuous(breaks = seq(1986, 2016, 6))+ transition_reveal(year)

animate(g, duration = 5, fps = 20, width = 400, height = 400, renderer = gifski_renderer())
anim_save("age_trend_global.gif",path="./sibei")

h=ggplot(data_age,aes(year, suicide_per100k , color = age))+
  geom_line(stat = "identity") +
  theme_set(theme_minimal() + theme(legend.position = "bottom"))+
  labs(title = "Suicide rate change by Age", 
       x = "Year", 
       y = "Suicides per 100k") + scale_x_continuous(breaks = seq(1986, 2016, 6))+ transition_reveal(year)

animate(h, duration = 5, fps = 20, width = 400, height = 400, renderer = gifski_renderer())
anim_save("age_trend_global2.gif",path="./sibei")

