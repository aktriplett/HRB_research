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

#create porosity rasters
hf_porosity1 = hf_sy #because we only have one layer with SY values we assign the same all the way down

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

#Assign to final pf raster for layers 1 - 5
pf_porosity = r3

#Change wd and write raster to outputs 
setwd('/Users/amanda_triplett/Documents/Heihe_Basin_Project/Heihe_R/data_output/indicator_output')
saveRDS(pf_porosity, file = 'pf_porosity.Rda')
writeRaster(pf_porosity, 'pf_porosity.tif', format='GTiff', overwrite=T)


