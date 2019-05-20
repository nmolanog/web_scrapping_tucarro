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
load("search_20_05_2019.RData")
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

vers_rm_list<-list(res_f1$Versión %>%str_subset(fixed("Furgón", ignore_case=TRUE)),
                   res_f1$Versión %>%str_subset(fixed("Furgon", ignore_case=TRUE)),
                   res_f1$Versión %>%str_subset(fixed("ESTACAS", ignore_case=TRUE)),
                   res_f1$Versión %>%str_subset(fixed("4x2", ignore_case=TRUE))
)

descr_rm_list<-list(res_f1$descr %>%str_subset(fixed("Furgón", ignore_case=TRUE)),
                    res_f1$descr %>%str_subset(fixed("Furgon", ignore_case=TRUE)),
                    res_f1$descr %>%str_subset(fixed("ESTACAS", ignore_case=TRUE)),
                    res_f1$descr %>%str_subset(fixed("4x2", ignore_case=TRUE))
)

http_rm_list<-list(res_f1$http %>%str_subset(fixed("Furgon", ignore_case=TRUE)),
                   res_f1$http %>%str_subset(fixed("ESTACAS", ignore_case=TRUE)),
                   res_f1$http %>%str_subset(fixed("4x2", ignore_case=TRUE))
                   )



vers_rm_list%>%reduce(union)->rm_vers
descr_rm_list%>%reduce(union)->rm_descr
http_rm_list%>%reduce(union)->rm_http


res_f1%>%
  filter(placa_par)%>%
  filter(location %in% loc_bog_cun)%>%
  filter(!Placa %in% discard_list$placa)%>%
  filter(!Versión %in% rm_vers)%>%
  filter(!descr %in% rm_descr)%>%
  filter(!http %in% rm_http)%>%
  filter(!str_detect(phone,discard_list$phones%>%paste(collapse="|")))%>%
  {.[order(.$Kilómetros,.$Año,.$precio,decreasing = T),]}->res_f1_1

res_f1_1%>%{.[order(.$Año,.$Kilómetros,.$precio, decreasing = T),]}%>%View()

###https://articulo.tucarro.com.co/MCO-509047450-chevrolet-luv-d-max-4x4-full-equipo-_JM
###available, disponible para peritaje
