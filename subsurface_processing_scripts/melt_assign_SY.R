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
#quartz()
#plot(pf_porosity1)

#Assign porosity values to layers 2-5
#Make map of HF SS values
ny = 548 #num rows
nx = 404 #num cols
nz = 5 #num layers
pf_porosity_ind_map=array(0,dim = c(ny,nx,nz))
pf_porosity_int_map = array(0,dim = c(ny,nx,5)) 
hf_porosity_map=array(0,dim = c(ny,nx,5))
a = pf_porosity1
for(j in 1:ny){
     hf_porosity_map[j,,1] = getValues(a,j,1) #applies all correct porosity values to top layer
}

for(z in 2:5){
     hf_porosity_map[,,z] = hf_porosity_map[,,1] #applies same porosity values to layers 2-5
}
hf_porosity_map[is.na(hf_porosity_map)] = 0 #final result is a map with all five layers having the simplified porosity values .1, .2 and .3 applied to the same locations

zero <-"#B3B3B3" # (gray color, same as your figure example)
lowest = "#000000"
reds <- rev(brewer.pal('YlOrRd', n = 1))
blues <- brewer.pal('Blues', n = 1)

myTheme <- rasterTheme(region = c(zero,lowest, blues, reds))
my.at = c(-.1,0,.1,.2,.3)
quartz()
levelplot(hf_porosity_map, xlab=NULL, ylab=NULL,layout=c(2,3),
          par.settings = myTheme, scales=list(draw=FALSE),
          at = my.at,
          main = "Porosity Value per HF Layer")


