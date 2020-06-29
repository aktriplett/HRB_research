library(raster)
library(rgdal)
layer_one = raster(x = "/Users/amanda_triplett/Documents/Heihe_Basin_Project/Heiflow_data/home/eseftp/Heihe_River_Basin/GIS/Model/Hydrogeology /geologic layering/layer1 bottom.tif")
layer_two= raster(x = "/Users/amanda_triplett/Documents/Heihe_Basin_Project/Heiflow_data/home/eseftp/Heihe_River_Basin/GIS/Model/Hydrogeology /geologic layering/layer2 bottom.tif")
layer_three = raster(x = "/Users/amanda_triplett/Documents/Heihe_Basin_Project/Heiflow_data/home/eseftp/Heihe_River_Basin/GIS/Model/Hydrogeology /geologic layering/layer3 bottom.tif")
layer_four = raster(x = "/Users/amanda_triplett/Documents/Heihe_Basin_Project/Heiflow_data/home/eseftp/Heihe_River_Basin/GIS/Model/Hydrogeology /geologic layering/layer4 bottom.tif")
layer_five = raster(x = "/Users/amanda_triplett/Documents/Heihe_Basin_Project/Heiflow_data/home/eseftp/Heihe_River_Basin/GIS/Model/Hydrogeology /geologic layering/layer5 bottom.tif")
layer_surface = raster(x = "/Users/amanda_triplett/Documents/Heihe_Basin_Project/Heiflow_data/home/eseftp/Heihe_River_Basin/GIS/Model/Hydrogeology /geologic layering/Top Elevation.tif")

plot(layer_surface, 
     main = "DEM - HRB")

plot(layer_one, 
     main = "Layer One- HRB")

plot(layer_two, 
     main = "Layer Two- HRB")

plot(layer_three, 
     main = "Layer Three- HRB")

plot(layer_four, 
     main = "Layer Four- HRB")

plot(layer_five, 
     main = "Layer Five- HRB")

#crs(layer_surface) #proj=utm +zone=47 +ellps=WGS84 +units=m +no_defs 
#UTM - Universal transverse mercator

#xres(layer_surface)
#1000m x 1000m aka 1km x 1km
#yres(layer_surface)
#1000m x 1000m aka 1km x 1km

#hist(layer_surface,
     #main = "Distribution of surface elevation values",
     #xlab = "Elevation (meters)", ylab = "Frequency",
     #col = "springgreen")

#compareRaster(layer_surface, layer_five,
              #extent = TRUE)
#All rasters have same extent

#compareRaster(layer_surface, layer_five,
              #res = TRUE)
#All rasters have same resolution

#nlayers(layer_surface)
#One band 

##Subtracting and finding the thickness of layers 
#surface-layer_One
one_thick = layer_surface-layer_one
plot(one_thick, 
     main = "Diff between Layer One and Surface")
#layer_one-layer_two
two_thick = layer_one-layer_two
plot(two_thick, 
     main = "Layer two thick")

#layer_two-layer_three
three_thick = layer_two-layer_three
plot(three_thick, 
     main = "Layer three thick")

#layer_three-layer_four
four_thick = layer_three-layer_four
plot(four_thick, 
     main = "Layer four thick")

#layer_four-layer_five
five_thick = layer_four-layer_five
plot(five_thick, 
     main = "Layer five thick")

total_thick = layer_surface - layer_five
cuts=c(0,100,200,300,400,500,600,700,800,900,1000,1100,1200,1300,1400,1500,1600,1700,1800,1900,2000,2100)
plot(total_thick,breaks = cuts, col = rainbow(21),
     main = "Total Thickness")

