library(rgdal)
library(raster)

setwd("~/Documents/Heihe_Basin_Project/Heiflow_data/home/eseftp/Heihe_River_Basin/GIS/Model/River/river_Data_new")
river_mask = readOGR(dsn = "SFR.shp")
setwd("~/Documents/Heihe_Basin_Project/Heiflow_data/home/eseftp/Heihe_River_Basin/GIS/Model/Grid")
model_grid = readOGR(dsn = "Model_Grid.shp")
setwd("~/Documents/Heihe_Basin_Project/Heihe_R/data_output")

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
