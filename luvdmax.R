#######################
###load data
#######################
rm(list=ls())
options(max.print=999999)
rm(list=ls())
options(stringsAsFactors = FALSE)
options(max.print=999999)
library(here)
library(tidyverse)
library(xml2)
library(rvest)
library(stringr)
list.files()%>%str_subset(".txt")
z0<-read.delim("Luv_Dmax_to_R", header = F, sep = "\t", dec = ".")
z0[,1]->z0

list_res<-list()
for(i in seq_along(z0) ){
  webpage <- read_html(z0[i])
  list_res[[i]]<-data.frame(specs=html_nodes(webpage,"li.specs-item")%>%html_nodes("strong")%>%html_text() , 
                            value=html_nodes(webpage,"li.specs-item")%>%html_nodes("span")%>%html_text())
  list_res[[i]]<-bind_rows(list_res[[i]],data.frame(specs=c("phone","precio"),
                                                    value=c(html_nodes(webpage,"span.profile-info-phone-value")%>%str_extract_all("[0-9]+")%>%{map(.,~paste0(.,collapse=""))}%>%unlist%>%paste0(collapse=";"),
                                                            html_nodes(webpage,"span.price-tag-fraction")%>%str_extract_all("[0-9]+")%>%unlist%>%paste(collapse=""))))
  list_res[[i]][,1]%>%str_replace_all(" ",".")->list_res[[i]][,1]
}

list_res%>%map(~.[,1])%>%reduce(union)->atributes_vec

res<-data.frame(matrix(NA,length(z0),length(atributes_vec)+1,dimnames=list(c(), c(atributes_vec,"http"))))

for(i in seq_along(z0)){
  res[i,list_res[[i]][,1]]<-list_res[[i]][,2]
  res[i,"http"]<-z0[i]
}
