library(raster)
library(rgdal)
library(abind)
library(openxlsx)

ny = 548 #num rows
nx = 404 #num cols

#Import geo_layers to find depth
layer_one = raster(x = "/Users/amanda_triplett/Documents/Heihe_Basin_Project/Heiflow_data/home/eseftp/Heihe_River_Basin/GIS/Model/Hydrogeology /geologic layering/layer1 bottom.tif")
layer_two= raster(x = "/Users/amanda_triplett/Documents/Heihe_Basin_Project/Heiflow_data/home/eseftp/Heihe_River_Basin/GIS/Model/Hydrogeology /geologic layering/layer2 bottom.tif")
layer_three = raster(x = "/Users/amanda_triplett/Documents/Heihe_Basin_Project/Heiflow_data/home/eseftp/Heihe_River_Basin/GIS/Model/Hydrogeology /geologic layering/layer3 bottom.tif")
layer_four = raster(x = "/Users/amanda_triplett/Documents/Heihe_Basin_Project/Heiflow_data/home/eseftp/Heihe_River_Basin/GIS/Model/Hydrogeology /geologic layering/layer4 bottom.tif")
layer_five = raster(x = "/Users/amanda_triplett/Documents/Heihe_Basin_Project/Heiflow_data/home/eseftp/Heihe_River_Basin/GIS/Model/Hydrogeology /geologic layering/layer5 bottom.tif")
layer_surface = raster(x = "/Users/amanda_triplett/Documents/Heihe_Basin_Project/Heiflow_data/home/eseftp/Heihe_River_Basin/GIS/Model/Hydrogeology /geologic layering/Top Elevation.tif")

##Subtract to get depth below surface for each layer

a = layer_surface - layer_one
b = layer_surface - layer_two
c = layer_surface - layer_three
d = layer_surface - layer_four
e = layer_surface - layer_five
#Set up matrices of zeros for the depth map
one_depth = matrix(0,ny,nx)
two_depth = matrix(0,ny,nx)
three_depth = matrix(0,ny,nx)
four_depth = matrix(0,ny,nx)
five_depth = matrix(0,ny,nx)

#Fill the matrices with elevation values
for (i in 1:ny){
     one_depth[i,] = getValues(a,i,1)
     two_depth[i,] = getValues(b,i,1)
     three_depth[i,] = getValues(c,i,1)
     four_depth[i,] = getValues(d,i,1)
     five_depth[i,] = getValues(e,i,1)
}

#one_depth[is.na(one_depth)] = 0

#Make the geolayer depth map
intermediate_list = list(one_depth, two_depth,three_depth,four_depth,five_depth) #creates a list of matrices
depth_map = abind(intermediate_list, along = 3)


vardz_list = c(.1,.3,.6,1,rep(20,105)) #cut offs for layers in z
nz = length(vardz_list) #number of layers in z
depth = c(.05, .25,.7,1.5,seq(12,2102,20))#depth to cell center



ind_map=array(99,dim = c(ny,nx,nz)) #map of attributes and depths

for (i in 1:ny){ #loops through all rows
     for (j in 1:nx){ #loops through all cols
          depth_temp = depth_map[i,j,] #"cookie cutter" of i/j cell with a bottom depth value for each layer
          ind_temp1 = all_k_layers[i,j,] #"cookie cutter" of cell attributes (Ex. K) of each layer
          ind_temp2 = all_SS_layers[i,j,]
          ind_temp3 = all_SY_layers[i,j,]
          for (k in 1:nz){ #Loops through center cell depth for each of our domain layers nz = 34
               dt = depth[k] #distance we're going down in our domain
               ltemp = min(which(depth_temp >= dt))#figures out which layer we're in by finding where current k is less than or equal to the layer depth
               indicator1 = ind_temp1[ltemp] #for specific xyz value, the cell is assigned corresponding attributes from our indicator array
               indicator2 = ind_temp2[ltemp]
               indicator3 = ind_temp3[ltemp]
               #still need to add SY for layer one...
               ind_map[i,j,k] = paste0(indicator2,indicator3,indicator1)
          }
     }
}

#depth_map = array(0,nx,ny,5) #Creates a stack of 5 arrays with certain x,y dim of all zeroes
#depth_map[,,1] = layer1_depth #sets depth map in array 1 as the layer 1 bottom depths (need to convert these layers from elevation to depth below surface)
for (i in 1:50){
     wb = loadWorkbook(file = "indicator_map.xlsx")
     writeData(wb, sheet = paste0("layer_",i), ind_map[,,i])
     saveWorkbook(wb, "indicator_map.xlsx", overwrite = TRUE)
}
