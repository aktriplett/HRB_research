library(raster)
library(rgdal)
library(tidyverse)

## Not run:
## Thin plate spline interpolation with x and y only
# some example data
r <- raster(system.file("external/test.grd", package="raster"))
ra <- aggregate(r, 10) #Aggregate creates a new raster layer / brick with lower resolution (larger cells)
xy <- data.frame(xyFromCell(ra, 1:ncell(ra)))
v <- getValues(ra)
#### Thin plate spline model
library(fields)
tps <- Tps(xy, v)
p <- raster(r)
# use model to predict values at all locations
p <- interpolate(p, tps)
p <- mask(p, r)

## another variable; let's call it elevation
elevation <- (init(r, 'x') * init(r, 'y')) / 100000000 #init initializes a raster object
names(elevation) <- 'elev'
elevation <- mask(elevation, r)
z <- extract(elevation, xy)
# add as another independent variable
xyz <- cbind(xy, z)
tps2 <- Tps(xyz, v)
p2 <- interpolate(elevation, tps2, xyOnly=FALSE)
# as a linear coveriate
tps3 <- Tps(xy, v, Z=z)
# Z is a separate argument in Krig.predict, so we need a new function
# Internally (in interpolate) a matrix is formed of x, y, and elev (Z)
pfun <- function(model, x, ...) {
     predict(model, x[,1:2], Z=x[,3], ...)
}
p3 <- interpolate(elevation, tps3, xyOnly=FALSE, fun=pfun)