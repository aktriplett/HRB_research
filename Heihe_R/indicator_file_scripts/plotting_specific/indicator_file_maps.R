## Importing data, setting up constants
library(raster)
library(rgdal)
library(sp)
library(ggspatial)
library(rasterVis)
library(tidyverse)

load("indicator_file_output.RData") 


## Plots of hydrogeologic attributes per HeiFlow Layers 
#hf_k_map, 5 layers, contains actual K values
hf_k_map_scratch = rotate(hf_k_map)

zero <-"#B3B3B3" # (gray color, same as your figure example)
outside_dom = "#000000"
reds <- rev(brewer.pal('YlOrRd', n = 9))
blues <- brewer.pal('Blues', n = 9)

myTheme <- rasterTheme(region = c(zero, blues, reds))
my.at = c(-1,0,.2,.5,2,4,6,8,10,12,15,18,20,22,25,30,35,40,50,60,80,135)
quartz()
levelplot(hf_k_map, xlab=NULL, ylab=NULL,layout=c(2,3),
          names.attr=1:15,  
          par.settings = myTheme, scales=list(draw=FALSE),
          at = my.at,
          main = "K Values per HF GeoLayer")


x1 <- 0:ncol(x)
y1 <- 0:nrow(x)
z <- matrix(1, nrow=length(x1), ncol=length(y1))

col.mat <- t(apply(matrix(rgb(getValues(x)/255), nrow=nrow(x), byrow=TRUE), 2, rev))

# Rotate 45 degrees
persp(x1, y1, z, zlim=c(0,2), theta = 20, phi = 90, 
      col = col.mat, scale=FALSE, border=NA, box=FALSE)
png("SaveThisPlot.png")
persp(x1, y1, z, zlim=c(0,2), theta = 20, phi = 90, 
      col = col.mat, scale=FALSE, border=NA, box=FALSE)

## Plots of hydrogeologic attributes per my selected DZ