library(rgdal)
library(raster)

## Data Imports
#setwd("~/Documents/Heihe_Basin_Project/Heiflow_data/home/eseftp/Heihe_River_Basin/GIS/Model/River/river_Data_new")#desktop
setwd("~/Documents/amanda_research/home/eseftp/Heihe_River_Basin/GIS/Model/Boundary Condition/Surface water")#laptop
river_mask = readOGR(dsn = "Reaches.shp")
terminal_lakes = readOGR(dsn = "terminal_lakes_clipped.shp")
#plot(river_mask)
#plot(terminal_lakes)

#setwd("~/Documents/Heihe_Basin_Project/Heiflow_data/home/eseftp/Heihe_River_Basin/GIS/Model/Grid")#desktop
setwd("~/Documents/amanda_research/home/eseftp/Heihe_River_Basin/GIS/Model/Grid")#laptop
model_grid = readOGR(dsn = "Model_Grid.shp")

setwd("~/Documents/amanda_research/home/eseftp/Heihe_River_Basin/GIS/Model") # for laptop
hf_geo1 = raster(x = "Hydrogeology /geologic layering/layer1 bottom.tif")


##Rasterize the shape files, assign 0 for "off" and 1 for "on"
river_mask_rast = rasterize(river_mask, hf_geo1, field=1, background=0)
model_grid_rast = rasterize(model_grid, hf_geo1, field=1, background=0)
terminal_lakes_rast = rasterize(terminal_lakes, hf_geo1, field=1, background=0)

##Merge river and lake mask
#river_lake_mask = merge(terminal_lakes_rast,river_mask_rast,tolerance = 1)
#river_lake_mask<- merge(terminal_lakes_rast, river_mask_rast, by.x = "values", by.y = "values")
#river_lake_mask <- mask(merge(river_mask_rast, terminal_lakes_rast))


##Plot check
plot(river_mask_rast, main = "River Mask", axes = F, box = F)
plot(model_grid_rast, main = "Domain Mask", axes = F, box = F)
plot(terminal_lakes_rast, main = "Terminal Lakes Mask", axes = F, box = F)
zoom(terminal_lakes_rast)
plot(river_lake_mask, main = "River Mask with Lakes", axes = F, box = F)

##Write Rasters 
setwd("~/Documents/amanda_research/data_output/topo_processing_output") # for laptop
writeRaster(river_mask_rast, 'river_mask.tif', format='GTiff', overwrite=T)
writeRaster(model_grid_rast, 'domain_mask.tif', format='GTiff', overwrite=T)
writeRaster(terminal_lakes_rast, 'terminal_lakes_mask.tif', format='GTiff', overwrite=T)












##Old methods
r <- rasterize(river_mask, hf_geo1)
river_mask_rast = r
river_mask_rast[!is.na(r)] = 1
river_mask_rast[is.na(r)] = 0
writeRaster(river_mask_rast, 'river_mask.tif', format='GTiff', overwrite=T)
plot(river_mask_rast, main = "River Mask", axes = F, box = F)

r <- rasterize(model_grid, hf_geo1)
model_grid_rast = r
model_grid_rast[!is.na(r)] = 1
model_grid_rast[is.na(r)] = 0
writeRaster(model_grid_rast, 'domain_mask.tif', format='GTiff', overwrite=T)
plot(model_grid_rast, main = "Domain Mask", axes = F, box = F)

r <- rasterize(terminal_lakes, hf_geo1)
terminal_lakes_rast = r
terminal_lakes_rast[!is.na(r)] = 1
terminal_lakes_rast[is.na(r)] = 0
writeRaster(terminal_lakes_rast, 'terminal_lakes_mask.tif', format='GTiff', overwrite=T)
plot(terminal_lakes_rast, main = "Terminal Lakes Mask", axes = F, box = F)


terminal_lakes_rast = rasterize(terminal_lakes, hf_geo1, field=1, background=0)
plot(r)






river_mask_test2 = shp2raster(river_mask, hf_geo1, "river vals", 1)
shp2raster <- function(shp, mask.raster, label, value, transform = FALSE, proj.from = NA,
                       proj.to = NA, map = TRUE) {
  require(raster, rgdal)
  
  # use transform==TRUE if the polygon is not in the same coordinate system as
  # the output raster, setting proj.from & proj.to to the appropriate
  # projections
  if (transform == TRUE) {
    proj4string(shp) <- proj.from
    shp <- spTransform(shp, proj.to)
  }
  
  # convert the shapefile to a raster based on a standardised background
  # raster
  r <- rasterize(shp, mask.raster)
  # set the cells associated with the shapfile to the specified value
  r[!is.na(r)] <- value
  # merge the new raster with the mask raster and export to the working
  # directory as a tif file
  r <- mask(merge(r, mask.raster), mask.raster, filename = label, format = "GTiff",
            overwrite = T)
  
  # plot map of new raster
  if (map == TRUE) {
    plot(r, main = label, axes = F, box = F)
  }
  
  names(r) <- label
  return(r)
}
