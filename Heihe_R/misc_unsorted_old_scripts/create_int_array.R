library(raster)
library(rgdal)
library(abind)
library(tidyverse)
#Import K rasters
layer_one_K = raster(x = "/Users/amanda_triplett/Documents/Heihe_Basin_Project/Heiflow_data/home/eseftp/Heihe_River_Basin/GIS/Model/Hydrogeology /hydraulic conductivity/HK/HK layer1.tif")
layer_two_K= raster(x = "/Users/amanda_triplett/Documents/Heihe_Basin_Project/Heiflow_data/home/eseftp/Heihe_River_Basin/GIS/Model/Hydrogeology /hydraulic conductivity/HK/HK layer2.tif")
layer_three_K = raster(x = "/Users/amanda_triplett/Documents/Heihe_Basin_Project/Heiflow_data/home/eseftp/Heihe_River_Basin/GIS/Model/Hydrogeology /hydraulic conductivity/HK/HK layer3.tif")
layer_four_K = raster(x = "/Users/amanda_triplett/Documents/Heihe_Basin_Project/Heiflow_data/home/eseftp/Heihe_River_Basin/GIS/Model/Hydrogeology /hydraulic conductivity/HK/HK layer4.tif")
layer_five_K = raster(x = "/Users/amanda_triplett/Documents/Heihe_Basin_Project/Heiflow_data/home/eseftp/Heihe_River_Basin/GIS/Model/Hydrogeology /hydraulic conductivity/HK/HK layer5.tif")
#Import SS raster (only one because same all the way down)
all_SS = raster(x = "//Users/amanda_triplett/Documents/Heihe_Basin_Project/Heiflow_data/home/eseftp/Heihe_River_Basin/GIS/Model/Hydrogeology /hydraulic conductivity/SS/SS layer1.tif")
#Import SY raster (only for first geolayer)
layer_one_SY = raster(x = "//Users/amanda_triplett/Documents/Heihe_Basin_Project/Heiflow_data/home/eseftp/Heihe_River_Basin/GIS/Model/Hydrogeology /hydraulic conductivity/SY/SY layer1.tif")
#layer_one_VKA = raster(x = "//Users/amanda_triplett/Documents/Heihe_Basin_Project/Heiflow_data/home/eseftp/Heihe_River_Basin/GIS/Model/Hydrogeology /hydraulic conductivity/VKA ratio/VKA layer5.tif")
##Plot test
#plot(layer_one_VKA)

#Get unique values
Kval1 = sort(unique(layer_one_K)) #get a list of unique k-values
Kval2 = sort(unique(layer_two_K)) 
Kval3 = sort(unique(layer_three_K)) 
Kval4 = sort(unique(layer_four_K)) 
Kval5 = sort(unique(layer_five_K)) 

allK_vals = sort(unique(c(Kval1,Kval2,Kval3,Kval4,Kval5)))
SS_vals = sort(unique(all_SS))
SY_vals = sort(unique(layer_one_SY))
SY_ints = c(98:115)

Kint1 = matrix(0,548,404) #create a matrix that's same dim as domain
Kint2 = matrix(0,548,404)
Kint3 = matrix(0,548,404)
Kint4 = matrix(0,548,404)
Kint5 = matrix(0,548,404)
SYind = matrix(0,548,404)
SY_empty = matrix(0,548,404)
SSind = matrix(0,548,404)

##Creating indicator map for SY
for (n in 1:length(SY_vals)){ 
        temp = which(as.matrix(layer_one_SY) == SY_vals[n]) 
        SYind[temp] = SY_ints[n] 
}
##Creating indicator map for SS
for (n in 1:length(SS_vals)){ 
        temp = which(as.matrix(all_SS) == SS_vals[n]) 
        SSind[temp] = n 
}
##Creating indicator map for K
for (n in 1:length(allK_vals)){ #loops 97 times through all unique k-values
     temp = which(as.matrix(layer_one_K) == allK_vals[n]) ##which cells of layer 1 = current k value, gives boolean true
     Kint1[temp] = n ##current temp (all cells that = current n) added to int matrix
}

for (n in 1:length(allK_vals)){ 
     temp = which(as.matrix(layer_two_K) == allK_vals[n]) 
     Kint2[temp] = n 
}

for (n in 1:length(allK_vals)){ 
     temp = which(as.matrix(layer_three_K) == allK_vals[n]) 
     Kint3[temp] = n 
}

for (n in 1:length(allK_vals)){ 
     temp = which(as.matrix(layer_four_K) == allK_vals[n]) 
     Kint4[temp] = n 
}

for (n in 1:length(allK_vals)){ 
     temp = which(as.matrix(layer_five_K) == allK_vals[n]) 
     Kint5[temp] = n
}
intermediate_list = list(Kint1, Kint2, Kint3, Kint4, Kint5) #creates a list of matrices
all_k_layers = abind(intermediate_list, along = 3) #creates a 3D array (5 stacked K matrices)
intermediate_list = list(SSind,SSind,SSind,SSind,SSind)
all_SS_layers = abind(intermediate_list, along = 3)
intermediate_list = list(SYind, SY_empty, SY_empty, SY_empty,SY_empty)
all_SY_layers = abind(intermediate_list, along = 3)

##Check

for (i in 1:5){
        wb = loadWorkbook(file = "test_indicator_map.xlsx")
        writeData(wb, sheet = i, all_k_layers[,,i])
        saveWorkbook(wb, "test_indicator_map.xlsx", overwrite = TRUE)
}

summary = matrix(0,33,10)
int1 %>% group_by 
for (n in 1:length(all_vals)){
        temp = layer_one_K - int1[int1==n]
        print(range(temp))
}
