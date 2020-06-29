#Author: Amanda Triplett
#Purpose: Assign ss, sy and vka values to specific indicators and make an output excel table

## Load librairies 
library(raster)
library(rgdal)
library(fields)
library(narray)
library(openxlsx)
library(tidyverse)

setwd("~/Documents/Heihe_Basin_Project/Heihe_R/data_output") #Make sure data dropped in data output
load("indicator_file_output.RData") #Load workspace with all indicator file creation data

#Make indicator value table
indicator_table = tibble(allk_vals)
indicator_table = indicator_table %>%
     mutate(indicator = 1:97) %>%
     select(2,1) %>%
     rename(k_values = allk_vals)

#Make map of HF SS values
hf_ss_map=array(0,dim = c(ny,nx,1))
a = hf_ss
for(j in 1:ny){
     hf_ss_map[j,,1] = getValues(a,j,1)
}

#Finding which SS values map to what integers
ss_unique1 = 0
ss_unique2 = 0
c = hf_ss_map[,,1]
c[is.na(c)] = 0
for (i in 1:length(allss_vals)){ #here 1-2 
     ss_unique = 0
     for (j in 1:5){
          a = which(c == allss_vals[i]) #creates a matrix of which ss values = specific val (1-2)
          b = pf_kint_map[,,j] #grabs the indicator map
          ind_temp = b[a] #selects cells of the indicator map which map the specific ss value
          ss_unique = append(ss_unique,sort(unique(ind_temp))) #appends to a list so we get all indicators with that ss
     }
     if (i == 1){
          ss_unique1 = sort(unique(as.vector(ss_unique))) #completed list of all indicators getting the 1st ss val
     }
     else{
          ss_unique2 = sort(unique(as.vector(ss_unique)))#completed list of all indicators getting the 1st ss val
     }
}
#update indicator table
indicator_table2 = indicator_table %>%
     mutate("SS_1e-05" = rep(1,97)) %>%
     mutate("SS_1e-4" = rep(0,97)) %>%
     mutate(SY_vals = rep(0,97))
indicator_table2[c(37,49),3] = 0
indicator_table2[ss_unique2,4] = 1

#Make map of HF SY values
hf_sy_map=array(0,dim = c(ny,nx,1))
a = hf_sy
for(j in 1:ny){
     hf_sy_map[j,,1] = getValues(a,j,1)
}

#Finding which SY values map to what indicators
c = hf_sy_map[,,1]
c[is.na(c)] = 0
b = pf_kint_map[,,1]
for (i in 1:length(allsy_vals)){ #here 1-17
     sy_unique = 0
     a = which(c == allsy_vals[i]) #creates a matrix of which ss values = specific val (1-2)
     ind_temp = b[a] #selects cells of the indicator map which map the specific ss value
     sy_unique = append(sy_unique,sort(unique(ind_temp))) #appends to a list so we get all indicators with that ss
     sy_unique_list = append(sy_unique_list,sy_unique)
     for (j in 2:length(sy_unique)){
          if (indicator_table2[sy_unique[j],5] == 0){
               indicator_table2[sy_unique[j],5] = allsy_vals[i]
          }
          else{
               temp_text = as.character(indicator_table2[sy_unique[j],5])
               temp_text2 = as.character(round((allsy_vals[i]),2))
               temp_text3 = paste(temp_text,temp_text2)
               indicator_table2[sy_unique[j],5] = temp_text3
          }
     }
}
#Update indicator table
indicator_table2 = indicator_table2 %>%
     mutate(vka_value = rep(0,97))

#Make map of HF VKA values
hf_vka_map=array(0,dim = c(ny,nx,5))
for (i in 1:5){
     a = hf_vka_list[[i]]
     for(j in 1:ny){
          hf_vka_map[j,,i] = getValues(a,j,1)
     }
}
hf_vka_map[is.na(hf_vka_map)] = 0
vka_unique_list = 0
#Finding which VKA values map to what indicators
for (i in 1:length(allvka_vals)){ #here 1-60
     vka_unique = 0
     for (j in 1:5){
          c = hf_vka_map[,,j]
          b = pf_kint_map[,,j]
          a = which(c == allvka_vals[i]) #creates a matrix of which ss values = specific val (1-2)
          ind_temp = b[a] #selects cells of the indicator map which map the specific ss value
          vka_unique = append(vka_unique,sort(unique(ind_temp))) #appends to a list so we get all indicators with that ss
          vka_unique_list = append(vka_unique_list,vka_unique)
     }
     for (k in 2:length(vka_unique)){
          if (indicator_table2[vka_unique[k],6] == 0){
               indicator_table2[vka_unique[k],6] = allvka_vals[i]
          }
          else{
               temp_text = as.character(indicator_table2[vka_unique[k],6])
               temp_text2 = as.character(round((allvka_vals[i]),2))
               temp_text3 = paste(temp_text,temp_text2)
               indicator_table2[vka_unique[k],6] = temp_text3
          }
     }
}
save.image(file = "indicator_table.RData")
write.xlsx(indicator_table2,file = "indicator_table.xlsx",sheetName = "indicator_table")
