#Author: Amanda Triplett
#Purpose: Create a 3D array which has all of the K values in a 548 x 404 x 15 grid so 
#that it can be converted to ascii format (.sa) in the make_sa_k_field_ssn_ind.R script 
#and then converted to a pfb so it can be read in to the HRB TCL as a K field.
#Note: K values are NOT replaced with indicator integers because it will be read in 
#as a K field, not an indicator file, so the output is the original K values
#from the HeiFlow data assigned to the 15 layer PF model

#Import Librairies 
library(raster)
library(rgdal)
library(fields)
library(narray)
library(openxlsx)
library(rasterVis)
library(tidyverse)
setwd("~/Documents/Heihe_Basin_Project/Heiflow_data/home/eseftp/Heihe_River_Basin/GIS/Model") #for desktop
#setwd("~/Documents/amanda_research/home/eseftp/Heihe_River_Basin/GIS/Model") # for laptop

## Importing Data

#Import geo layers to find depth
hf_geo1 = raster(x = "Hydrogeology /geologic layering/layer1 bottom.tif")
hf_geo2= raster(x = "Hydrogeology /geologic layering/layer2 bottom.tif")
hf_geo3 = raster(x = "Hydrogeology /geologic layering/layer3 bottom.tif")
hf_geo4 = raster(x = "Hydrogeology /geologic layering/layer4 bottom.tif")
hf_geo5 = raster(x = "Hydrogeology /geologic layering/layer5 bottom.tif")
hf_dem = raster(x = "Hydrogeology /geologic layering/Top Elevation.tif")
hf_geo_list = c(hf_dem,hf_geo1,hf_geo2,hf_geo3,hf_geo4,hf_geo5) #allow cycling for multilayer arrays 

#Import K rasters (original units m/day, concert to m/h by dividing by 24)
hf_k1 = round((raster(x = "Hydrogeology /hydraulic conductivity/HK/HK layer1.tif"))/24,digits =3)
hf_k2= round((raster(x = "Hydrogeology /hydraulic conductivity/HK/HK layer2.tif"))/24,digits =3)
hf_k3 = round((raster(x = "Hydrogeology /hydraulic conductivity/HK/HK layer3.tif"))/24,digits =3)
hf_k4 = round((raster(x = "Hydrogeology /hydraulic conductivity/HK/HK layer4.tif"))/24,digits =3)
hf_k5 = round((raster(x = "Hydrogeology /hydraulic conductivity/HK/HK layer5.tif"))/24,digits =3)
hf_k_list = c(hf_k1, hf_k2, hf_k3, hf_k4, hf_k5)


## Set up 
#Get unique K values
hf_kval1 = sort(unique(hf_k1)) #get a list of unique k-values per layer
hf_kval2 = sort(unique(hf_k2)) 
hf_kval3 = sort(unique(hf_k3)) 
hf_kval4 = sort(unique(hf_k4)) 
hf_kval5 = sort(unique(hf_k5)) 
#unique K across all layers
allk_vals = sort(unique(c(hf_kval1,hf_kval2,hf_kval3,hf_kval4,hf_kval5)))

#Setting up Domain
vardz_list = c(.1,.3,.6,1,rep(10,2),rep(30,5),rep(100,3),600) #delineation in z direction

#old delineations
#vardz_list = c(.1,.3,.6,1,2,seq(5,20*5,5),seq(105,50*10,50),rep(20,20),rep(100,7))

ny = 548 #num rows
nx = 404 #num cols
nz = length(vardz_list) #num layers in z-dir

#Create depth list
pf_depth_list = rep(0,nz) #create empty depth list to cell center
pf_depth_list2 = rep(0,nz) #create empty depth list to bottom depth

for (i in 1:nz){ #Cycles through all layers in vardz_list
     if(i == 1){ #for the first value in vardz_list, no extra addition needed
          pf_depth_list[i] = vardz_list[i]/2 #divides first value in vardz_list by 2 to get cell center depth
          pf_depth_list2[i] = vardz_list[i]
     }
     else{ #cumulatively adds the previous depth values
          pf_depth_list[i] = sum(vardz_list[1:(i-1)])+vardz_list[i]/2 #list which is depth to cell center
          pf_depth_list2[i] = sum(vardz_list[1:(i-1)])+vardz_list[i] #creates a list with bottom depths
     }
}

#Create empty arrays
hf_k_map=array(0,dim = c(ny,nx,5)) #holds heiflow k values

hf_depth_map = array(0,dim = c(ny,nx,5)) #Depth map of zeros to hold hf bottom depth 
pf_kfield_map=array(0,dim = c(ny,nx,nz)) #empty kfield map with correct x,y,z dim

#Fill depth map
for (i in 1:5){
     a = hf_geo_list[[1]]-hf_geo_list[[i+1]] #subtracts lower layers from top elevation to get depth below surface
     for(j in 1:ny){
          hf_depth_map[j,,i] = getValues(a,j,1)
     }
}
#Replace NA with zeros 
hf_depth_map[is.na(hf_depth_map)] = 0

#Make map of HF K values
for (i in 1:5){
     b = hf_k_list[[i]]
     for(j in 1:ny){
          hf_k_map[j,,i] = getValues(b,j,1)
     }
}
#Replace NA with zeros 
hf_k_map[is.na(hf_k_map)] = 0

## Assign indicator integer to depth map
for (j in 1:ny){ #loops through all rows
     for (i in 1:nx){ #loops through all cols
          depth_temp = hf_depth_map[j,i,] #"cookie cutter" of i/j cell with a bottom depth value for each layer
          ind_temp = hf_k_map[j,i,] #"cookie cutter" of cell attributes (Ex. K) of each layer
          for (k in 1:nz){ #Loops depth for each of our domain layers
               dt = pf_depth_list[k] #distance we're going down in our domain
               if (dt <= depth_temp[5]){
                    
                    ltemp = min(which(depth_temp >= dt))#figures out which layer we're in by finding where current k is less than or equal to the layer depth
                    indicator = ind_temp[ltemp] #for specific xyz value, the cell is assigned corresponding attributes from our indicator array
                    pf_kfield_map[j,i,k] = indicator
               }
               else{
                    if(depth_temp[5] == 0){
                         pf_kfield_map[j,i,k] = 0
                    }
                    else{
                         pf_kfield_map[j,i,k] = 0.001
                    }
               }
          }
     }
}
#Save the indicator file output / rotation test 
setwd('/Users/amanda_triplett/Documents/Heihe_Basin_Project/Heihe_R/data_input_output/indicator_output') #for desktop
saveRDS(pf_kfield_map, file = 'pf_kfield_0617.Rda')
pf_kfield_map = readRDS(file = 'pf_kfield_0617.Rda')
ny = 548 #num rows
nx = 404 #num cols
nz = 15 #num layers
#Begin code to actually rotate all the layers
rotated_kfield_map=array(0,dim = c(nx,ny,nz))
for (m in nz:1){ #nz:1 because in parflow (0,0,0) is lower left corner of bottom layer (nx,ny,nz) upper right corner of top
        temp = t(pf_kfield_map[ny:1,,m])
        rotated_kfield_map[,,(nz-m)+1] = temp #(nz-m)+1 because we need to assign the LAST layer to the FIRST slot
}
#you should be able to do an image.plot that looks unrotated if it is in the proper parflow form because it thinks it is (x,y)

#plot test
#quartz()
#image.plot(rotated_kfield_map[,,15])

library(PriorityFlow)
writepfb(rotated_kfield_map, 'pf_kfield_0617.pfb',1000,1000,600)

#Rotates everything correctly but weirdly the pfb has layer 15 on the top and on the bottom...
#writepfb(pf_ind_map, 'pf_indicators.pfb',1000,1000,100)
#saveRDS(pf_ind_map, file = 'pf_ind_file.Rda')

#Save the  K field file output 
#setwd('/Users/amanda_triplett/Documents/Heihe_Basin_Project/Heihe_R/data_output/indicator_output') #for desktop
#saveRDS(pf_kfield_map, file = 'pf_kfield_map.Rda')

