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

discarded_placa<-c("RHU-514","COC-844","QIA010","OBI-928","HKY-612","DDO-390","SXY-546","DIU-204","KBO274","SWT 328","IFW-662","CRD 4X4","HSZ 438")
discarded_phones<-c("16950576","3209514205")
discard_list<-list(placa=discarded_placa,phones=discarded_phones)
save(discard_list,file=paste0("discard_list",".RData"))