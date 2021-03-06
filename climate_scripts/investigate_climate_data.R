library(rgdal)
library(raster)

## Testing climate data - correct resolution, incorrect units (must convert)
setwd("~/Documents/Heihe_Basin_Project/Heiflow_data/climate_data") 
precip1 = raster(x = "Precip/HEIFLOW_V1_Precip_2000-01-01.tif")
plot(precip1)

ap1 = raster(x = "AP/ap_2000-01-01.tif")
plot(ap1)

RH1 = raster(x = "RH/rh_2000-01-01.tif")
plot(RH1)

tavg1 = raster(x = "tavf/tavf_2000-01-01.tif")
plot(tavg1)

tmin1 = raster(x = "tminf/tminf_2000-01-01.tif")
plot(tmin1)

tmax1 = raster(x = "tmaxf/tmaxf_2000-01-01.tif")
plot(tmax1)

wu1 = raster(x = "wu/wu_2000-01-01.tif")
plot(wu1)
wu2 = as.matrix(wu1)
#Soil map 
setwd("~/Documents/Heihe_Basin_Project/Heiflow_data/home/eseftp/Heihe_River_Basin/GIS/General")
soil_map = raster(x = "Soil/soil_map.tif")
plot(soil_map)

wu = raster(x = "windu/windu_2000-01-01.tif")
quartz()
levelplot(wu)

wv = raster(x = "windv/windv_2000-01-01.tif")
quartz()
levelplot(wv)

net_rad = raster(x = "netrad/netrad_2000-01-01.tif")
quartz()
levelplot(net_rad)

setwd("~/Documents/Heihe_Basin_Project/Heiflow_data/home/eseftp/Heihe_River_Basin/GIS/General/Irrigation/pumping") 

diversion = raster(x = "diversion_2000-01-01.tif")
quartz()
plot(diversion)

setwd("~/Documents/Heihe_Basin_Project/Heiflow_data/home/eseftp/Heihe_River_Basin/GIS/General/Irrigation/Irrigation") 
irri = raster(x = "WRA.shp")
quartz()
levelplot(irri)