#Author: Amanda Triplett
#Purpose: This code reads in specific storage (ss) and porosity tiffs formatted
#for the Heihe River Basin (HRB). It then creates indicators (1-6) that match the two 
#different ss values (1e-5 and 1e-4) to the three different porosity (n) values (.1, .2, .3)
#which were simplified down from 37 unique values in the original data in melt_assign_SY.R

#Import Librairies 
library(raster)
library(rgdal)
library(fields)
library(rasterVis)
library(tidyverse)

#This code allowed me to read in the make_indicator_files_final.R state and save a specific 
#object separately so as not to load the entire state, but it is obsolete now, kept for 
#reference 
#load('indicator_file_output.Rdata')
#saveRDS(hf_depth_map, file = 'hf_depth_map.Rda')

#rotate 90 degrees clockwise
rotate_90_cw <- function(x) t(apply(x, 2, rev))

#Import SS file
setwd('/Users/amanda_triplett/Documents/Heihe_Basin_Project/Heihe_R/data_input_output/indicator_output') #for desktop
pf_ss = readRDS(file = 'hf_ss_map.Rda') #dim = 548 x 404 x 1
#load the porosity map
pf_porosity = readRDS(file ='pf_n_map.Rda')#from the script simplifying the SY
#Load the depth map
hf_depth_map = readRDS(file = 'hf_depth_map.Rda')#from kfield script

#Set up some constants 
vardz_list = c(.1,.3,.6,1,rep(10,2),rep(30,5),rep(100,3),600) #delineation in z direction
ny = 548 #num rows
nx = 404 #num cols
nz = length(vardz_list) #num layers in z-dir
allss_vals = c(1e-5, 1e-4) #1e-5, 1e-4
allporosity_vals = c(.1, .2, .3)

#This is a useful bit of code to know, but ended up being unnecessary, the arrays 
                #just looked rotated when plotted, but when read into excel, they were the
                #correct orientation

#Rotate ss and porosity 90 degrees clockwise and check graphically
#pf_ss = rotate_90_cw(pf_ss)
#pf_porosity = rotate_90_cw(pf_porosity)

#rotating the depth map, 5 layer array so a little more labor intensive
#rotate_hf_depth_map = array(0,dim = c(nx,ny,5))
#for (i in 1:5){
#        temp_array = hf_depth_map[,,i]
#        temp_array = rotate_90_cw(temp_array)
#        rotate_hf_depth_map[,,i] = temp_array
#}
#quartz()
#levelplot(rotate_hf_depth_map)
#Everything has the correct orientation now


##Create depth list to get cumulative list going down the domain according to delineations
     #specified by vardz_list
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

pf_ssn_map = array(0,dim = c(ny,nx,1)) #creates an empty one layer array to hold
                                        #combo ss / n indicator
#Check the ss / n values of each cell and assign indicator 1-6
for (j in 1:ny){ #loops through all rows
     for (i in 1:nx){ #loops through all cols
          ssval = pf_ss[j,i,1] #gets ss value at current cell 
          ssval = round(ssval, digits = 5)
          #print(ssval)
          nval = pf_porosity[j,i,1] #gets porosity value at current cell
          #print(nval)
          if (ssval == allss_vals[1]){ #checks if ss is value 1 (1e-5)
               if(nval == allporosity_vals[1]){ #checks if porosity is value 1 (.1)
                    #print('1 assigned')
                    pf_ssn_map[j,i,1] = 1 #gives indicator of 1 for (1,1) pair
               }
               else if(nval == allporosity_vals[2]){
                    #print('2 assigned')
                    pf_ssn_map[j,i,1] = 2
               }
               else{
                    #print('3 assigned')
                    pf_ssn_map[j,i,1] = 3
               }
          }
          
          else if (ssval == allss_vals[2]){ #checks if ss is value 2 (1e-4)
               
               if(nval == allporosity_vals[1]){
                    #print('4 assigned')
                    pf_ssn_map[j,i,1] = 4
               }
               else if(nval == allporosity_vals[2]){
                    #print('5 assigned')
                    pf_ssn_map[j,i,1] = 5
               }
               else{
                    #print('6 assigned')
                    pf_ssn_map[j,i,1] = 6
               }
          }
          
          else{
               pf_ssn_map[j,i,1] = 0 #assigns 0, because if porosity is 0 we are outside domain
          }
     }
}

##Plot ss / n indicator map 
#rev_ssn_map = apply(pf_ssn_map,2,rev)
#transpose_ssn_map = t(rev_ssn_map)
#quartz()
#image.plot(transpose_ssn_map[,])
#title('SS / n indicators for HRB (1-6)')
#quartz()
#image.plot(hf_depth_map[,,1])
#image.plot(pf_ssn_map_5L[,,5])

#creating 5 layer ss / n ind map 
pf_ssn_map_5L = array(0,dim = c(ny,nx,5))
pf_ssn_map_5L[,,1] = pf_ssn_map
pf_ssn_map_5L[,,2] = pf_ssn_map
pf_ssn_map_5L[,,3] = pf_ssn_map
pf_ssn_map_5L[,,4] = pf_ssn_map
pf_ssn_map_5L[,,5] = pf_ssn_map

## Assign indicator integer to depth map
pf_ind_map=array(0,dim = c(ny,nx,nz)) #empty indicator map with correct x,y,z dim

for (j in 1:ny){ #loops through all rows
     for (i in 1:nx){ #loops through all cols
          depth_temp = hf_depth_map[j,i,] #"cookie cutter" of i/j cell with a bottom depth value for each layer
          ind_temp = pf_ssn_map_5L[j,i,] #"cookie cutter" of cell attributes (Ex. K) of each layer
          for (k in 1:nz){ #Loops depth for each of our domain layers
               dt = pf_depth_list[k] #distance we're going down in our domain
               if (dt <= depth_temp[5]){
                    ltemp = min(which(depth_temp >= dt))#figures out which layer we're in by finding where current k is less than or equal to the layer depth
                    indicator = ind_temp[ltemp] #for specific xyz value, the cell is assigned corresponding attributes from our indicator array
                    pf_ind_map[j,i,k] = indicator
               }
               else{ #outside domain in x/y
                    if(depth_temp[5] == 0){
                         pf_ind_map[j,i,k] = 0 
                    }
                    else{ #outside domain in z, assign 7 which will have certain impermeable bedrock properties
                         pf_ind_map[j,i,k] = 7
                    }
               }
          }
     }
}


#Test the indicator file
#quartz()
#image.plot(pf_ind_map[,,12])
#test_mat = as.data.frame(pf_ind_map[,,12])
#library(xlsx)
#write.xlsx(test_mat, 'test_mat.xlsx') #the indicator looks like it is written correction in excel
                #so a problem with the creation of the ascii? 

#Rotate the indicator file
setwd('/Users/amanda_triplett/Documents/Heihe_Basin_Project/Heihe_R/data_input_output/indicator_output') #for desktop
pf_ind_map = readRDS(file = 'pf_ind_file.Rda')
#test ss / n assignment
#quartz()
#image.plot(pf_ind_map[,,10])
### These are intermediate steps, directions and information about rotating input for parflow
#if it looks like how you want to see in excel, or as a picture, test3 is the step you need
        #to take to get proper output (x,y) ordering
ny = 548 #num rows
nx = 404 #num cols
nz = 15 #num layers
test = t(pf_ind_map[,,1])#swaps x/y
test2 = pf_ind_map[ny:1,,1] #flip on y-axis (actually flips x, because it thinks it's x,y)
test3 = t(pf_ind_map[ny:1,,1]) #flips y to be in right order, and makes it x,y instead of y,x
test4 = test[,ny:1] #same result as test3, ny:1 in second spot because we already flipped axes
test3d = t(pf_ind_map[ny:1,,])
#Defunct rotation function
#rotate_90_cw <- function(x) t(apply(x, 2, rev))

#Begin code to actually rotate all the layers
rotated_pf_ind_map=array(0,dim = c(nx,ny,nz))
for (m in nz:1){ #nz:1 because in parflow (0,0,0) is lower left corner of bottom layer (nx,ny,nz) upper right corner of top
        temp = t(pf_ind_map[ny:1,,m])
        rotated_pf_ind_map[,,(nz-m)+1] = temp #(nz-m)+1 because we need to assign the LAST layer to the FIRST slot
}
#you should be able to do an image.plot that looks unrotated if it is in the proper parflow form because it thinks it is (x,y)
#plot test
quartz()
image.plot(rotated_pf_ind_map[,,10])
#write the pfb
library(PriorityFlow)
writepfb(rotated_pf_ind_map, 'pf_ssn_ind_final_600.pfb',1000,1000,600)

#Plotting 
zero <-"#B3B3B3" # (gray color, same as your figure example)
outside_dom = "#000000"
reds <- rev(brewer.pal('YlOrRd', n = 4))
blues <- brewer.pal('Blues', n =3)

myTheme <- rasterTheme(region = c(outside_dom,zero, blues, reds))
quartz()
levelplot(pf_ind_map, xlab=NULL, ylab=NULL,layout=c(4,4),
          par.settings = myTheme,
          names.attr=1:15, 
          at = c(-1,0,1,2,3,4,5,6,7),
          scales=list(draw=FALSE),
          main = "SS / n Indicators per PF layer")