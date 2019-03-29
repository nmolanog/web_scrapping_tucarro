#######################
###load data
#######################
rm(list=ls())
options(max.print=999999)
library(tidyverse)
library(xml2)
library(rvest)
library(stringr)

url <-"https://articulo.tucarro.com.co/MCO-504847705-mazda-bt-50-_JM"
webpage <- read_html(url)
html_nodes(webpage,"h2#class")

title_html <- html_nodes(webpage,"h2#class")
title <- html_text(title_html)
head(title)
html_nodes(webpage,"h2")
html_nodes(webpage,"strong")
html_nodes(webpage,"li")
html_nodes(webpage,"li.specs-item")
html_nodes(webpage,"ul")
html_nodes(webpage,"ul.attribute-list")

##phones
html_nodes(webpage,"span.profile-info-phone-value")%>%str_extract_all("[0-9]+")%>%{map(.,~paste0(.,collapse=""))}%>%unlist%>%paste0(collapse=";")

html_nodes(webpage,"li.specs-item")%>%html_nodes("strong")%>%html_text() 
html_nodes(webpage,"li.specs-item")%>%html_nodes("span")%>%html_text()

data.frame(specs=html_nodes(webpage,"li.specs-item")%>%html_nodes("strong")%>%html_text() , 
           value=html_nodes(webpage,"li.specs-item")%>%html_nodes("span")%>%html_text())

html_nodes(webpage,"ul.attribute-list")%>%html_nodes("li")%>%
  html_text()%>%str_replace_all("\\n","")%>%str_replace_all("\\t","")


#######################
###get https from search
#######################
rm(list=ls())
options(max.print=999999)
library(tidyverse)
library(xml2)
library(rvest)
library(stringr)

url <-"https://carros.tucarro.com.co/desde-2009/"
webpage <- read_html(url)
html_nodes(webpage,"a")%>% html_attr("href")%>%str_subset("articulo")
html_nodes(webpage,"a")%>% html_attr("href")%>%str_subset("articulo")%>%unique
html_nodes(webpage,"ol")[2]%>%html_nodes("li")%>%html_nodes("a")%>%html_attr("href")%>%unique->a
###how to get appropiate ol?
html_nodes(webpage,"ol")%>% html_attr("id")


###pagination buttons
html_nodes(webpage,"li.andes-pagination__button")%>%html_nodes("a")%>% html_attr("href")
z0<-a
list_res<-list()
for(i in seq_along(z0)){
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

