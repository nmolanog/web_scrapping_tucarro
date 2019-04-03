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
load("search_03_04_2019.RData")
summary(res)

res$Placa%>%str_sub(start=-1)%>%as.numeric()%>%{.%%2}%>%{!.}->res$placa_par
res[,c("Placa","placa_par")]

res%>%select(setdiff(colnames(res),c("http","descr","phone")))%>% map(unique)
res%>%filter(!Combustible %in% c("Gasolina", "Gasolina y gas"))%>%
  filter(!Versión %in% (res$Versión%>%str_subset("4x2")))%>%
  filter(!Tracción %in% (res$Tracción%>%str_subset("4x2")))%>%
  filter(!Transmisión %in% (res$Transmisión%>%str_subset("Automática")))%>%
  filter(!Tipo %in% (res$Tipo%>%str_subset("Ambulancias")))->res_f1

res_f1%>%select(setdiff(colnames(res),c("http","descr","phone")))%>% map(unique)
res_f1$location%>%str_subset(fixed("bog", ignore_case=TRUE))%>%unique()->loc_bog
res_f1$location%>%str_subset(fixed("cund", ignore_case=TRUE))%>%unique()->loc_cun

loc_bog_cun<-union(loc_bog,loc_cun)

res_f1%>%filter(Único.dueño %in% "Sí")%>%
  filter(precio <60000000)%>%
  filter(placa_par)%>%
  filter(location %in% loc_bog_cun)%>%
  {.[order(.$Recorrido,.$Año,.$precio,decreasing = T),]}->res_f1_1

res_f1$available<-NA
res_f1$dir_meeting<-NA
res_f1$contact_name<-NA

res_f1[res_f1$http %in% "https://articulo.tucarro.com.co/MCO-508168090-chevrolet-luv-d-max-4x4-td-3000cc-mt-aa-_JM",c("available","dir_meeting","contact_name")]<-data.frame(available=T,dir_meeting="cr69d # 2-15 centroamerica",contact_name="Andres Gomez")
res_f1[res_f1$http %in% "https://articulo.tucarro.com.co/MCO-504384355-chevrolet-luv-d-max-_JM",c("available","dir_meeting","contact_name")]<-data.frame(available=T,dir_meeting="cl67d bis # 67-22","maria pinzon")
res_f1[res_f1$http %in% "https://articulo.tucarro.com.co/MCO-503566431-chevrolet-luv-d-max-_JM",c("available")]<-F

