##script to assign land cover values 
library(rgdal)
library(raster)

#make rasters
setwd("~/Documents/Heihe_Basin_Project/QGIS_projects") 
#landuse2000 = raster(x = "landuse2000_full.tif")
#landuse2007 = raster(x = "LU2007_full.tif")
landuse2011 = raster(x = "landuse2011_EPSG32647_HKextent.tif")
landuse2011_matrix = as.matrix(landuse2011)
landuse2011_matrix[is.na(landuse2011_matrix)] = 0

#Change to IGBP values with indexing - raster
landuse2011[landuse2011 == 21] = 5
landuse2011[landuse2011 == 22] = 7
landuse2011[landuse2011 == 23] = 5
landuse2011[landuse2011 == 24] = 4
landuse2011[landuse2011 == 31] = 10
landuse2011[landuse2011 == 32] = 10
landuse2011[landuse2011 == 33] = 10
landuse2011[landuse2011 == 41] = 17
landuse2011[landuse2011 == 42] = 17
landuse2011[landuse2011 == 43] = 17
landuse2011[landuse2011 == 44] = 15
landuse2011[landuse2011 == 45] = 16
landuse2011[landuse2011 == 46] = 11
landuse2011[landuse2011 == 51] = 13
landuse2011[landuse2011 == 52] = 13
landuse2011[landuse2011 == 53] = 13
landuse2011[landuse2011 == 61] = 16
landuse2011[landuse2011 == 62] = 16
landuse2011[landuse2011 == 63] = 16
landuse2011[landuse2011 == 64] = 11
landuse2011[landuse2011 == 65] = 18
landuse2011[landuse2011 == 66] = 18
landuse2011[landuse2011 == 67] = 16
landuse2011[landuse2011 == 121] = 12
landuse2011[landuse2011 == 122] = 12
landuse2011[landuse2011 == 123] = 12

plot(landuse2011)


#Change to IGBP values with indexing - matrix for visual check
landuse2011_matrix[landuse2011_matrix == 21] = 5
landuse2011_matrix[landuse2011_matrix == 22] = 7
landuse2011_matrix[landuse2011_matrix == 23] = 5
landuse2011_matrix[landuse2011_matrix == 24] = 4
landuse2011_matrix[landuse2011_matrix == 31] = 10
landuse2011_matrix[landuse2011_matrix == 32] = 10
landuse2011_matrix[landuse2011_matrix == 33] = 10
landuse2011_matrix[landuse2011_matrix == 41] = 17
landuse2011_matrix[landuse2011_matrix == 42] = 17
landuse2011_matrix[landuse2011_matrix == 43] = 17
landuse2011_matrix[landuse2011_matrix == 44] = 15
landuse2011_matrix[landuse2011_matrix == 45] = 16
landuse2011_matrix[landuse2011_matrix == 46] = 11
landuse2011_matrix[landuse2011_matrix == 51] = 13
landuse2011_matrix[landuse2011_matrix == 52] = 13
landuse2011_matrix[landuse2011_matrix == 53] = 13
landuse2011_matrix[landuse2011_matrix == 61] = 16
landuse2011_matrix[landuse2011_matrix == 62] = 16
landuse2011_matrix[landuse2011_matrix == 63] = 16
landuse2011_matrix[landuse2011_matrix == 64] = 11
landuse2011_matrix[landuse2011_matrix == 65] = 18
landuse2011_matrix[landuse2011_matrix == 66] = 18
landuse2011_matrix[landuse2011_matrix == 67] = 16
landuse2011_matrix[landuse2011_matrix == 121] = 12
landuse2011_matrix[landuse2011_matrix == 122] = 12
landuse2011_matrix[landuse2011_matrix == 123] = 12

plot(landuse2011_matrix)



