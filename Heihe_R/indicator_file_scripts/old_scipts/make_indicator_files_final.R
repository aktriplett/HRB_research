#Author: Amanda Triplett
#Purpose: Import raster attribute data for the subsurface of the HRB. Variables include K,SS,SY,VKA. 
#Map these values to a variable dz list of equal thickness to create an indicator file. 

#Import Librairies 
library(raster)
library(rgdal)
library(fields)
library(narray)
library(openxlsx)
library(rasterVis)
library(tidyverse)
setwd("~/Documents/Heihe_Basin_Project/Heiflow_data/home/eseftp/Heihe_River_Basin/GIS/Model") #for desktop
#setwd("~/Documents/amanda_research/home/eseftp/Heihe_River_Basin/GIS/Model") # for laptop
#load("indicator_file_output.RData") 
## Importing Data

#Import geo layers to find depth
hf_geo1 = raster(x = "Hydrogeology /geologic layering/layer1 bottom.tif")
hf_geo2= raster(x = "Hydrogeology /geologic layering/layer2 bottom.tif")
hf_geo3 = raster(x = "Hydrogeology /geologic layering/layer3 bottom.tif")
hf_geo4 = raster(x = "Hydrogeology /geologic layering/layer4 bottom.tif")
hf_geo5 = raster(x = "Hydrogeology /geologic layering/layer5 bottom.tif")
hf_dem = raster(x = "Hydrogeology /geologic layering/Top Elevation.tif")
hf_geo_list = c(hf_dem,hf_geo1,hf_geo2,hf_geo3,hf_geo4,hf_geo5) #allow cycling for multilayer arrays 

#Import K rasters
hf_k1 = raster(x = "Hydrogeology /hydraulic conductivity/HK/HK layer1.tif")
hf_k2= raster(x = "Hydrogeology /hydraulic conductivity/HK/HK layer2.tif")
hf_k3 = raster(x = "Hydrogeology /hydraulic conductivity/HK/HK layer3.tif")
hf_k4 = raster(x = "Hydrogeology /hydraulic conductivity/HK/HK layer4.tif")
hf_k5 = raster(x = "Hydrogeology /hydraulic conductivity/HK/HK layer5.tif")
hf_k_list = c(hf_k1, hf_k2, hf_k3, hf_k4, hf_k5)

#Import SS rasters (each one is the same, but grabbing all allows processing in the same way as others)
hf_ss1 = raster(x = "Hydrogeology /hydraulic conductivity/SS/SS layer1.tif")
hf_ss2 = raster(x = "Hydrogeology /hydraulic conductivity/SS/SS layer2.tif")
hf_ss3 = raster(x = "Hydrogeology /hydraulic conductivity/SS/SS layer3.tif")
hf_ss4 = raster(x = "Hydrogeology /hydraulic conductivity/SS/SS layer4.tif")
hf_ss5 = raster(x = "Hydrogeology /hydraulic conductivity/SS/SS layer5.tif")

#Import SY raster (there is only one for the first geolayer)
hf_sy = raster(x = "Hydrogeology /hydraulic conductivity/SY/SY layer1.tif")

#Import VKA
hf_vka1 = raster(x = "Hydrogeology /hydraulic conductivity/VKA ratio/VKA layer1.tif")
hf_vka2 = raster(x = "Hydrogeology /hydraulic conductivity/VKA ratio/VKA layer2.tif")
hf_vka3 = raster(x = "Hydrogeology /hydraulic conductivity/VKA ratio/VKA layer3.tif")
hf_vka4 = raster(x = "Hydrogeology /hydraulic conductivity/VKA ratio/VKA layer4.tif")
hf_vka5 = raster(x = "Hydrogeology /hydraulic conductivity/VKA ratio/VKA layer5.tif")
hf_vka_list = c(hf_vka1, hf_vka2, hf_vka3, hf_vka4, hf_vka5)




## Set up 
#Get unique K values
hf_kval1 = sort(unique(hf_k1)) #get a list of unique k-values per layer
hf_kval2 = sort(unique(hf_k2)) 
hf_kval3 = sort(unique(hf_k3)) 
hf_kval4 = sort(unique(hf_k4)) 
hf_kval5 = sort(unique(hf_k5)) 
#unique K across all layers
allk_vals = sort(unique(c(hf_kval1,hf_kval2,hf_kval3,hf_kval4,hf_kval5)))

#Get unique SS values
hf_ssval1 = sort(unique(hf_ss1)) #get a list of unique SS values per layer
hf_ssval2 = sort(unique(hf_ss2)) 
hf_ssval3 = sort(unique(hf_ss3)) 
hf_ssval4 = sort(unique(hf_ss4)) 
hf_ssval5 = sort(unique(hf_ss5)) 
#unique SS across all layers
allss_vals = sort(unique(c(hf_ssval1,hf_ssval2,hf_ssval3,hf_ssval4,hf_ssval5)))

#Get unique SY values
allsy_vals = sort(unique(hf_sy))

#Get unique VKA vals
hf_vkaval1 = sort(unique(hf_vka1)) #get a list of unique VKA-values per layer
hf_vkaval2 = sort(unique(hf_vka2)) 
hf_vkaval3 = sort(unique(hf_vka3)) 
hf_vkaval4 = sort(unique(hf_vka4)) 
hf_vkaval5 = sort(unique(hf_vka5)) 
#unique VKA across all layers
allvka_vals = sort(unique(c(hf_vkaval1,hf_vkaval2,hf_vkaval3,hf_vkaval4,hf_vkaval5)))





#Setting up Domain
vardz_list = c(.1,.3,.6,1,rep(10,2),rep(30,5),rep(100,3),600) #delineation in z direction

#old delineations
#vardz_list = c(.1,.3,.6,1,2,seq(5,20*5,5),seq(105,50*10,50),rep(20,20),rep(100,7))

ny = 548 #num rows
nx = 404 #num cols
nz = length(vardz_list) #num layers in z-dir

#Create depth list
pf_depth_list = rep(0,nz) #create empty depth list to cell center
pf_depth_list2 = rep(0,nz) #create empty depth list to bottom depth

for (i in 1:nz){ #Cycles through all layers in vardz_list
     if(i == 1){ #for the first value in vardz_list, no extra addition needed
          pf_depth_list[i] = vardz_list[i]/2 #divides first value in vardz_list by 2 to get cell center depth
          pf_depth_list2[i] = vardz_list[i]
     }
     else{ #cumulatively adds the previous depth values
          pf_depth_list[i] = sum(vardz_list[1:(i-1)])+vardz_list[i]/2 #list which is depth to cell center
          pf_depth_list2[i] = sum(vardz_list[1:(i-1)])+vardz_list[i] #creates a list with bottom depths
     }
}

#Create empty arrays
hf_k_map=array(0,dim = c(ny,nx,5)) #holds heiflow k values
pf_kint_map = array(0,dim = c(ny,nx,5)) #Create an empty array to hold K values per geolayer

hf_depth_map = array(0,dim = c(ny,nx,5)) #Depth map of zeros to hold hf bottom depth 
pf_ind_map=array(0,dim = c(ny,nx,nz)) #empty indicator map with correct x,y,z dim


#Fill depth map
for (i in 1:5){
     a = hf_geo_list[[1]]-hf_geo_list[[i+1]] #subtracts lower layers from top elevation to get depth below surface
     for(j in 1:ny){
          hf_depth_map[j,,i] = getValues(a,j,1)
     }
}
#Replace NA with zeros 
hf_depth_map[is.na(hf_depth_map)] = 0


#Make map of HF K values
for (i in 1:5){
     b = hf_k_list[[i]]
     for(j in 1:ny){
          hf_k_map[j,,i] = getValues(b,j,1)
     }
}
#Replace NA with zeros 
hf_k_map[is.na(hf_k_map)] = 0


#Replace K values with unique integers
hf_kint_temp = matrix(0,548,404)
for (i in 1:5){
     c = hf_k_map[,,i]
     for (n in 1:length(allk_vals)){
          temp = which(as.matrix(c)== allk_vals[n]) 
          hf_kint_temp[temp] = n
     }
     pf_kint_map[,,i] = hf_kint_temp
}


## Assign indicator integer to depth map
for (j in 1:ny){ #loops through all rows
     for (i in 1:nx){ #loops through all cols
          depth_temp = hf_depth_map[j,i,] #"cookie cutter" of i/j cell with a bottom depth value for each layer
          ind_temp = pf_kint_map[j,i,] #"cookie cutter" of cell attributes (Ex. K) of each layer
          for (k in 1:nz){ #Loops depth for each of our domain layers
               dt = pf_depth_list[k] #distance we're going down in our domain
               if (dt <= depth_temp[5]){
                    
                    ltemp = min(which(depth_temp >= dt))#figures out which layer we're in by finding where current k is less than or equal to the layer depth
                    indicator = ind_temp[ltemp] #for specific xyz value, the cell is assigned corresponding attributes from our indicator array
                    pf_ind_map[j,i,k] = indicator
               }
               else{
                    if(depth_temp[5] == 0){
                         pf_ind_map[j,i,k] = 0
                    }
                    else{
                         pf_ind_map[j,i,k] = -1
                    }
               }
          }
     }
}
test4 = pf_ind_map[,,1]

setwd("~/Documents/Heihe_Basin_Project/Heihe_R/data_output") #for desktop
#setwd("~/Documents/amanda_research/data_output") #for laptop
save.image(file = "indicator_file_output.RData")

## Making Indicator Files for SS
#Make indicator value table
indicator_table = tibble(allk_vals)
indicator_table = indicator_table %>%
     mutate(indicator = 1:97) %>%
     select(2,1) %>%
     rename(k_values = allk_vals)

#Make map of HF SS values
pf_ssind_map=array(0,dim = c(ny,nx,nz))
pf_ssint_map = array(0,dim = c(ny,nx,5)) 
hf_ss_map=array(0,dim = c(ny,nx,5))
a = hf_ss1
for(j in 1:ny){
     hf_ss_map[j,,1] = getValues(a,j,1)
}

for(z in 2:5){
     hf_ss_map[,,z] = hf_ss_map[,,1]
}
hf_ss_map[is.na(hf_ss_map)] = 0

#Finding which SS values map to what integers
hf_ss_temp = matrix(0,548,404)
value = 100
for (n in 1:length(allss_vals)){
     for (i in 1:5){
          c = hf_ss_map[,,i]
          temp = which(as.matrix(c)== allss_vals[n]) 
          hf_ss_temp[temp] = value
          pf_ssint_map[,,i] = hf_ss_temp
     }
     value = value + 1
}
##matching depth to SS ind map
for (j in 1:ny){ #loops through all rows
     for (i in 1:nx){ #loops through all cols
          depth_temp = hf_depth_map[j,i,] #"cookie cutter" of i/j cell with a bottom depth value for each layer
          ind_temp = pf_ssint_map[j,i,] #"cookie cutter" of cell attributes (Ex. K) of each layer
          for (k in 1:length(vardz_list)){ #Loops depth for each of our domain layers
               dt = pf_depth_list[k] #distance we're going down in our domain
               if (dt <= depth_temp[5]){
                    ltemp = min(which(depth_temp >= dt))#figures out which layer we're in by finding where current k is less than or equal to the layer depth
                    indicator = ind_temp[ltemp] #for specific xyz value, the cell is assigned corresponding attributes from our indicator array
                    pf_ssind_map[j,i,k] = indicator
               }
               else{
                    if(depth_temp[5] == 0){
                         pf_ssind_map[j,i,k] = 0
                    }
                    else{
                         pf_ssind_map[j,i,k] = -1
                    }
               }
          }
     }
}

##Creating SY indicator map
pf_syind_map=array(0,dim = c(ny,nx,nz))
pf_syint_map = array(0,dim = c(ny,nx,5)) 
hf_sy_map=array(0,dim = c(ny,nx,5))
a = hf_sy
for(j in 1:ny){
     hf_sy_map[j,,1] = getValues(a,j,1)
}

hf_sy_map[is.na(hf_sy_map)] = 0

#Finding which SY values map to what integers
hf_sy_temp = matrix(0,548,404)
value = 200
for (n in 1:length(allsy_vals)){
     for (i in 1:1){
          c = hf_sy_map[,,i]
          temp = which(as.matrix(c)== allsy_vals[n]) 
          hf_sy_temp[temp] = value
          pf_syint_map[,,i] = hf_sy_temp
     }
     value = value + 1
}
##matching depth to SY ind map
for (j in 1:ny){ #loops through all rows
     for (i in 1:nx){ #loops through all cols
          depth_temp = hf_depth_map[j,i,] #"cookie cutter" of i/j cell with a bottom depth value for each layer
          ind_temp = pf_syint_map[j,i,] #"cookie cutter" of cell attributes (Ex. K) of each layer
          for (k in 1:length(vardz_list)){ #Loops depth for each of our domain layers
               dt = pf_depth_list[k] #distance we're going down in our domain
               if (dt <= depth_temp[5]){
                    ltemp = min(which(depth_temp >= dt))#figures out which layer we're in by finding where current k is less than or equal to the layer depth
                    indicator = ind_temp[ltemp] #for specific xyz value, the cell is assigned corresponding attributes from our indicator array
                    pf_syind_map[j,i,k] = indicator
               }
               else{
                    if(depth_temp[5] == 0){
                         pf_syind_map[j,i,k] = 0
                    }
                    else{
                         pf_syind_map[j,i,k] = -1
                    }
               }
          }
     }
}

##Making VKA ind map 
#Make map of HF VKA values
hf_depth_map[is.na(hf_depth_map)] = 0
pf_vkaind_map=array(0,dim = c(ny,nx,nz))
pf_vkaint_map = array(0,dim = c(ny,nx,5)) 
hf_vka_map=array(0,dim = c(ny,nx,5))

for (z in 1:5){
     a = hf_vka_list[[z]]
     for(j in 1:ny){
          hf_vka_map[j,,z] = getValues(a,j,1)
     }
}

hf_vka_map[is.na(hf_vka_map)] = 0

hf_vka_temp = matrix(0,548,404)
value = 300
for (n in 1:length(allvka_vals)){
     for (i in 1:5){
          c = hf_vka_map[,,i]
          temp = which(as.matrix(c)== allvka_vals[n]) 
          hf_vka_temp[temp] = value
          pf_vkaint_map[,,i] = hf_vka_temp
     }
     value = value + 1
}
##matching depth to VKA ind map
for (j in 1:ny){ #loops through all rows
     for (i in 1:nx){ #loops through all cols
          depth_temp = hf_depth_map[j,i,] #"cookie cutter" of i/j cell with a bottom depth value for each layer
          ind_temp = pf_vkaint_map[j,i,] #"cookie cutter" of cell attributes (Ex. K) of each layer
          for (k in 1:length(vardz_list)){ #Loops depth for each of our domain layers
               dt = pf_depth_list[k] #distance we're going down in our domain
               if (dt <= depth_temp[5]){
                    ltemp = min(which(depth_temp >= dt))#figures out which layer we're in by finding where current k is less than or equal to the layer depth
                    indicator = ind_temp[ltemp] #for specific xyz value, the cell is assigned corresponding attributes from our indicator array
                    pf_vkaind_map[j,i,k] = indicator
               }
               else{
                    if(depth_temp[5] == 0){
                         pf_vkaind_map[j,i,k] = 0
                    }
                    else{
                         pf_vkaind_map[j,i,k] = -1
                    }
               }
          }
     }
}
save.image(file = "indicator_file_output.RData")