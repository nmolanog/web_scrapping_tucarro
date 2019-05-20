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

#url <-"https://vehiculos.tucarro.com.co/desde-2009/luv-d-max_PriceRange_0-50000000"
url <-"https://vehiculos.tucarro.com.co/desde-2009/luv-d-max"
webpage <- read_html(url)

html_nodes(webpage,"li.andes-pagination__button")%>%html_nodes("a")%>% html_attr("href")->pag_buttons

pag_buttons%>%str_detect("Desde_-49|#")%>%{pag_buttons[!.]}%>%unique->target_search_res
target_search_res<-c(url,target_search_res)

list_res<-list()
for(j in seq_along(target_search_res)){
  url <-target_search_res[j]
  webpage <- read_html(url)
  html_nodes(webpage,"ol")[2]%>%html_nodes("li")%>%html_nodes("a")%>%html_attr("href")%>%unique->z0
  list_res[[j]]<-list()
  for(i in seq_along(z0)){
    webpage <- read_html(z0[i])
    temp_descr<-html_nodes(webpage,"div.item-description__text")%>%html_text()%>%str_remove_all("\n|\t")
    if(length(temp_descr)==0){temp_descr<-NA}
    list_res[[j]][[i]]<-data.frame(specs=html_nodes(webpage,"li.specs-item")%>%html_nodes("strong")%>%html_text() , 
                              value=html_nodes(webpage,"li.specs-item")%>%html_nodes("span")%>%html_text())
    list_res[[j]][[i]]<-bind_rows(list_res[[j]][[i]],data.frame(specs=c("phone","precio","http","location","descr"),
                                                      value=c(html_nodes(webpage,"span.profile-info-phone-value")%>%str_extract_all("[0-9]+")%>%{map(.,~paste0(.,collapse=""))}%>%unlist%>%paste0(collapse=";"),
                                                              html_nodes(webpage,"span.price-tag-fraction")%>%str_extract_all("[0-9]+")%>%unlist%>%paste(collapse=""),
                                                              z0[i],
                                                              html_nodes(webpage,"div.location-info")%>%{.[2]}%>%html_text()%>%str_remove_all("\n|\t"),
                                                              temp_descr)))
    list_res[[j]][[i]][,1]%>%str_replace_all(" |-",".")->list_res[[j]][[i]][,1]
  }
}
list_res_0<-list_res
list_res_0%>%map(length)%>%unlist%>%sum->nfindings

list_res_0%>%reduce(c)->list_res
list_res%>%map(~.[,1])%>%reduce(union)->atributes_vec

res<-data.frame(matrix(NA,nfindings,length(atributes_vec),dimnames=list(c(), c(atributes_vec))))

for(i in seq_along(list_res)){
  res[i,list_res[[i]][,1]]<-list_res[[i]][,2]
}
save(res,file=paste0("search_20_05_2019",".RData"))

wb <- openxlsx::createWorkbook()
openxlsx::addWorksheet(wb, sheetName = 1)
openxlsx::writeData(wb,x=res , sheet = 1)
openxlsx::freezePane(wb, sheet = 1, firstActiveRow = 2, firstActiveCol = 2)
openxlsx::saveWorkbook(wb,"luv_from_search.xlsx",TRUE)
