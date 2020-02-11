#Import Librairies 
library(raster)
library(rgdal)
library(fields)
library(rasterVis)
library(tidyverse)

##Load porosity map
setwd("~/Documents/Heihe_Basin_Project/Heihe_R/data_output/indicator_output") #for desktop
hf_porosity_map = load(file = "hf_porosity_map.Rdata")
hf_ss_map = load(file = "hf_ss_map.Rdata")

setwd("~/Documents/Heihe_Basin_Project/Heiflow_data/home/eseftp/Heihe_River_Basin/GIS/Model")
#Import SS rasters (each one is the same, but grabbing all allows processing in the same way as others)
hf_ss1 = raster(x = "Hydrogeology /hydraulic conductivity/SS/SS layer1.tif")

#Make map of HF SS values
ny = 548 #num rows
nx = 404 #num cols
nz = 5 #num layers

hf_ss_map=array(0,dim = c(ny,nx,5))
a = hf_ss1
for(j in 1:ny){
     hf_ss_map[j,,1] = getValues(a,j,1)
}

for(z in 2:5){
     hf_ss_map[,,z] = hf_ss_map[,,1]
}
hf_ss_map[is.na(hf_ss_map)] = 0

zero <-"#B3B3B3" # (gray color, same as your figure example)
lowest = "#000000"
reds <- rev(brewer.pal('YlOrRd', n = 1))
blues <- brewer.pal('Blues', n = 1)

myTheme <- rasterTheme(region = c(zero,lowest, blues, reds))
my.at = c(-1e-05,0,1e-05, 1e-04)
quartz()
levelplot(hf_ss_map, xlab=NULL, ylab=NULL,layout=c(2,3),
          par.settings = myTheme, scales=list(draw=FALSE),
          at = my.at,
          main = "SS Value per HF Layer")

setwd("~/Documents/Heihe_Basin_Project/Heihe_R/data_output/indicator_output") #for desktop
save(hf_porosity_map, file = "hf_ss_map.Rdata")
