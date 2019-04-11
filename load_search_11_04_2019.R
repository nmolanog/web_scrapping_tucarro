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
load("search_11_04_2019.RData")
load("discard_list.RData")
summary(res)

res$Placa%>%str_sub(start=-1)%>%as.numeric()%>%{.%%2}%>%{!.}->res$placa_par
res[,c("Placa","placa_par")]

res%>%select(setdiff(colnames(res),c("http","descr","phone")))%>% map(unique)
res%>%filter(!Tipo.de.combustible %in% c("Gasolina", "Gasolina y gas"))%>%
  filter(!Versión %in% (res$Versión%>%str_subset("4x2")))->res_f1

res_f1%>%select(setdiff(colnames(res),c("http","descr","phone")))%>% map(unique)
res_f1$location%>%str_subset(fixed("bog", ignore_case=TRUE))%>%unique()->loc_bog
res_f1$location%>%str_subset(fixed("cund", ignore_case=TRUE))%>%unique()->loc_cun

loc_bog_cun<-union(loc_bog,loc_cun)

res_f1%>%filter(precio <60000000)%>%
  filter(placa_par)%>%
  filter(location %in% loc_bog_cun)%>%
  filter(!Placa %in% discard_list$placa)%>%
  filter(!str_detect(phone,discard_list$phones%>%paste(collapse="|")))%>%
  {.[order(.$Kilómetros,.$Año,.$precio,decreasing = T),]}->res_f1_1

res_f1$available<-NA
res_f1$dir_meeting<-NA
res_f1$contact_name<-NA

###https://articulo.tucarro.com.co/MCO-506821341-chevrolet-luv-d-max-_JM
###cita peritaje semana santa

###https://articulo.tucarro.com.co/MCO-505967035-chevrolet-luv-d-max-_JM
###peritaje en automax

###https://articulo.tucarro.com.co/MCO-509340837-chevrolet-luv-d-max-doble-cabina-4x4-mt-3000-_JM
###https://articulo.tucarro.com.co/MCO-507892330-chevrolet-luv-d-max-_JM
##no contestan. volver a llamar

