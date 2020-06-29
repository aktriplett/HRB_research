#Author: Amanda Triplett
#Purpose: Import raster attribute data for the subsurface of the HRB. Variables include K,SS,SY,VKA. 
#Map these values to a variable dz list of equal thickness to create an indicator file. 

#Import Librairies 
library(raster)
library(rgdal)
library(fields)
library(narray)

##importing Data
#Import geo layers with elevation data
#Import geo_layers to find depth
hf_geo1 = raster(x = "Hydrogeology /geologic layering/layer1 bottom.tif")
hf_geo2= raster(x = "Hydrogeology /geologic layering/layer2 bottom.tif")
hf_geo3 = raster(x = "Hydrogeology /geologic layering/layer3 bottom.tif")
hf_geo4 = raster(x = "Hydrogeology /geologic layering/layer4 bottom.tif")
hf_geo5 = raster(x = "Hydrogeology /geologic layering/layer5 bottom.tif")
hf_dem = raster(x = "Hydrogeology /geologic layering/Top Elevation.tif")
hf_geo_list = c(hf_dem,hf_geo1,hf_geo2,hf_geo3,hf_geo4,hf_geo5)
#Import K rasters
hf_k1 = raster(x = "Hydrogeology /hydraulic conductivity/HK/HK layer1.tif")#Make sure data path points to file in WD
hf_k2= raster(x = "Hydrogeology /hydraulic conductivity/HK/HK layer2.tif")
hf_k3 = raster(x = "Hydrogeology /hydraulic conductivity/HK/HK layer3.tif")
hf_k4 = raster(x = "Hydrogeology /hydraulic conductivity/HK/HK layer4.tif")
hf_k5 = raster(x = "Hydrogeology /hydraulic conductivity/HK/HK layer5.tif")
hf_k_list = c(hf_k1, hf_k2, hf_k3, hf_k4, hf_k5)

#Import SS raster (only one because same all the way down)
hf_ss = raster(x = "Hydrogeology /hydraulic conductivity/SS/SS layer1.tif")
#Import SY raster (only for first geolayer)
hf_sy = raster(x = "Hydrogeology /hydraulic conductivity/SY/SY layer1.tif")
#Import VKA
#hf_vka = raster(x = "Hydrogeology /hydraulic conductivity/VKA ratio/VKA layer5.tif")


##Set up 
#Get unique K values
hf_kval1 = sort(unique(hf_k1)) #get a list of unique k-values per layer
hf_kval2 = sort(unique(hf_k2)) 
hf_kval3 = sort(unique(hf_k3)) 
hf_kval4 = sort(unique(hf_k4)) 
hf_kval5 = sort(unique(hf_k5)) 
#unique K across all layers
allk_vals = sort(unique(c(hf_kval1,hf_kval2,hf_kval3,hf_kval4,hf_kval5)))
#Get unique SS values
allss_vals = sort(unique(hf_ss))
#ss_unique = as.list(ss_unique)
#Get unique SY values
allsy_vals = sort(unique(hf_sy))


#Setting up Domain
vardz_list = c(.1,.3,.6,1,2,rep(5,20),rep(10,10),rep(50,8),rep(20,20),rep(100,7)) #delineation in z direction
#vardz_list = c(.1,.3,.6,1,2,seq(5,20*5,5),seq(105,50*10,50),rep(20,20),rep(100,7))
ny = 548 #num rows
nx = 404 #num cols
nz = length(vardz_list) #num layers
#Create depth list
pf_depth_list = rep(0,nz) #create empty depth list
for (i in 1:nz){
     if(i == 1){
          pf_depth_list[i] = vardz_list[i]/2
     }
     else{
          pf_depth_list[i] = sum(vardz_list[1:(i-1)])+vardz_list[i]/2 #list which is depth to cell center
     }
}
#Create empty arrays
hf_k_map=array(0,dim = c(ny,nx,5))
pf_kint_map = array(0,dim = c(ny,nx,5)) #Create an empty array to hold K values per geolayer

hf_depth_map = array(0,dim = c(ny,nx,5)) #Depth map of zeros to hold hf bottom depth 
pf_ind_map=array(0,dim = c(ny,nx,nz)) #empty indicator map with correct x,y,z dim

#Fill depth map
for (i in 1:5){
     a = hf_geo_list[[1]]-hf_geo_list[[i+1]]
     hf_depth_map[,,i] = a[,,1]
}
#Replace NA with zeros 
hf_depth_map[is.na(hf_depth_map)] = 0
test1 = hf_depth_map[,,1]
#Fill k val map
for (i in 1:5){
     b= hf_k_list[[i]]
     hf_k_map[,,i] = b[,,1]
}
#Replace NA with zeros 
hf_k_map[is.na(hf_k_map)] = 0
#plot(b)
plot(hf_k_map[,,5])
test2 = hf_k_map[,,1]

#Fill Kval map 
for (i in 1:5){
     b = hf_k_map[,,i]
     #print(range(hf_k_map[,,i]))
     #hf_kint_temp = array(0, dim = c(ny,nx,1))
     for (n in 1:length(allk_vals)){
          temp = which(as.matrix(a) == allk_vals[n]) 
          #temp = which(as.matrix(layer_three_K) == allK_vals[n]) 
          hf_kint_temp[temp] = n
     }
     #test1 = as.data.frame(hf_kint_temp)
     #print(range(hf_kint_temp))
     pf_kint_map[,,i] = hf_kint_temp[,,1]
     #print(range(pf_kint_map))
}
test = as.data.frame(pf_kint_map[,,1])
##Assign indicator integer to depth map
for (j in 1:ny){ #loops through all rows
     for (i in 1:nx){ #loops through all cols
          depth_temp = hf_depth_map[j,i,] #"cookie cutter" of i/j cell with a bottom depth value for each layer
          ind_temp = pf_kint_map[j,i,] #"cookie cutter" of cell attributes (Ex. K) of each layer
          for (k in 1:nz){ #Loops depth for each of our domain layers
               dt = pf_depth_list[k] #distance we're going down in our domain
               if (dt <= depth_temp[5]){
                    
                    ltemp = min(which(depth_temp >= dt))#figures out which layer we're in by finding where current k is less than or equal to the layer depth
                    indicator = ind_temp[ltemp] #for specific xyz value, the cell is assigned corresponding attributes from our indicator array
                    pf_ind_map[j,i,k] = indicator
               }
               else{
                    if(depth_temp[5] == 0){
                         pf_ind_map[j,i,k] = 0
                    }
                    else{
                    pf_ind_map[j,i,k] = -99
                    }
               }
          }
     }
}
plot(pf_ind_map[,,1])
##Plotting
quartz()
par(mfrow=c(2,3))
for(k in 1:5){
     image.plot(t(hf_depth_map[548:1,,k]))
}

quartz()
par(mfrow=c(3,3))
for(k in c(1,5,10,20,30,40,50,60,70)){
     image.plot(t(pf_ind_map[548:1,,k]))
}

ss_unique1 = 0
ss_unique2 = 0
#Finding which SS and SY values map to what integers
for (i in 1:length(allss_vals)){
     ss_unique = 0
     for (j in 1:5){
          a = which(as.array(hf_ss == (allss_vals[i])))
          ind_temp = hf_kvals_map[,,j]
          ind_temp = ind_temp[a]
          ss_unique = append(ss_unique,sort(unique(ind_temp)))  
     }
     if (i == 1){
          ss_unique1 = sort(unique(as.vector(ss_unique)))
     }
     else{
          ss_unique2 = sort(unique(as.vector(ss_unique)))
     }
}
##Tests
if (any(hf_kvals_map == 1)){
     print(1)
}

#for (i in 1:5){
     #k_array = as.array(hf_k_list[[i]])
     #print(range(k_array))
     for (j in 1:length(allk_vals)){
          temp = which(as.matrix(hf_kvals_map) == allk_vals[j]) 
          hf_kvals_map[temp] = j
          print(range(hf_kvals_map))
     }
     #k_array[is.na(k_array)] = 0
     #hf_kvals_map[,,i] = k_array
#}
for (g in 1:5){ #loops through all layers
     for (i in 1:ny){ #loops through all rows
          for (j in 1:nx){ #loops through all cols
               #l_temp = hf_depth_map[i,j,] #"cookie cutter" of i/j cell with a bottom depth value for each layer
               k_temp = hf_kvals_map[i,j,] #"cookie cutter" of cell attributes (Ex. K) of each layer
               for (k in 1:length(allk_vals)){ #Loops depth for each of our domain layers
                    dk = allk_vals[k] #distance we're going down in our domain
                    if (dt <= depth_temp[5]){
                    
                         ltemp = min(which(depth_temp >= dt))#figures out which layer we're in by finding where current k is less than or equal to the layer depth
                         indicator = ind_temp[ltemp] #for specific xyz value, the cell is assigned corresponding attributes from our indicator array
                         pf_ind_map[i,j,k] = indicator
                    }
                    else{
                         if(depth_temp[5] == 0){
                              pf_ind_map[i,j,k] = 0
                         }
                         else{
                              pf_ind_map[i,j,k] = -99
                         }
                    }
               }
          }
     }
}

#Fill k val map
for (i in 1:5){
     c = hf_k_list[[i]]
     for (j in 1:ny){
          hf_k_map[j,,i] = getValues(c,j,1)
     }
}
