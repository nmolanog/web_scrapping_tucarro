#######################
###load data
#######################
rm(list=ls())
options(max.print=999999)
options(stringsAsFactors = FALSE)
library(tidyverse)
library(xml2)
library(rvest)
library(stringr)
list.files()%>%str_subset(".RData")
load("search_30_03_2019.RData")
summary(res)
