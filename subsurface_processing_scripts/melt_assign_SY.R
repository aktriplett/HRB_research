#Import Librairies 
library(raster)
library(rgdal)
library(fields)
library(rasterVis)
library(tidyverse)

##Import Data
setwd("~/Documents/Heihe_Basin_Project/Heiflow_data/home/eseftp/Heihe_River_Basin/GIS/Model")

#Import SY raster (there is only one for the first geolayer)
hf_sy = raster(x = "Hydrogeology /hydraulic conductivity/SY/SY layer1.tif")

#Import K rasters
hf_k1 = raster(x = "Hydrogeology /hydraulic conductivity/HK/HK layer1.tif")
hf_k2= raster(x = "Hydrogeology /hydraulic conductivity/HK/HK layer2.tif")
hf_k3 = raster(x = "Hydrogeology /hydraulic conductivity/HK/HK layer3.tif")
hf_k4 = raster(x = "Hydrogeology /hydraulic conductivity/HK/HK layer4.tif")
hf_k5 = raster(x = "Hydrogeology /hydraulic conductivity/HK/HK layer5.tif")
hf_k_list = c(hf_k1, hf_k2, hf_k3, hf_k4, hf_k5)

#create porosity rasters
hf_porosity1 = hf_sy
hf_porosity2 = hf_k2
hf_porosity3 = hf_k3
hf_porosity4 = hf_k4
hf_porosity5 = hf_k5

#melt SY in layer 1 values to .1, .2, .3, min .05, max .35
r = raster::reclassify(hf_porosity1, cbind(.05, .13, .1)) #any SY between range .05 and .13 will be .1
r2 = raster::reclassify(r, cbind(.15, .22, .2)) #any SY between .15 and .22 will be .2 (no .23, .24)
r3 = raster::reclassify(r2, cbind(.24, .35, .3)) #any SY between .24 and .35 will be .3 (there is no .24, this just allows .25 to be sorted as .3)
all_r_vals = sort(unique(r))
all_r2_vals = sort(unique(r2))
all_r3_vals = sort(unique(r3))
r_matrix = as.matrix(r)
r2_matrix = as.matrix(r2)
r3_matrix = as.matrix(r3)
#plot(r3)
#Assign to final pf raster for layer 1
pf_porosity1 = r3

#Assign SY values to layers 2-5
plot(r3)

