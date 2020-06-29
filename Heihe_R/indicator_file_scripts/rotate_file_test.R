#Author: Amanda Triplett
#Purpose: This code grabs the ending 3D arrays from make_indicator_files_final.R and
#create_ind_ss_n_final.R and converts them to ascii format (.sa) and readable (.txt)
#These resulting files can then use the tcl create_pfbs_k_field and create_pfbs_ssn_inds
#respectively to convert the .sa to ParFlow readable PFB

#Note: See the above R scripts for the actual process of turning the raw data into 
#K field or indicator

#rotate 90 degrees clockwise
rotate_90_cw <- function(x) t(apply(x, 2, rev))

setwd('/Users/amanda_triplett/Documents/Heihe_Basin_Project/Heihe_R/data_input_output/indicator_output') #for desktop

#Making the specific storage / porosity indicator into a .sa file 
#load the indicator Rda 3D array
pf_ind_map = readRDS(file = 'pf_ind_file.Rda')
test = pf_ind_map[,,1]
test2 = rotate_90_cw(test)
levelplot(test)
levelplot(test2)
#load library
library(SDMTools)
#set up constants 
ny = 548 #num rows
nx = 404 #num cols
nz = 15 #num layers

#test one of the layers
#pf_ind_map_layer1 = pf_ind_map[,,1]
#rotate_90_cw(pf_ind_map_layer1)
#levelplot(pf_ind_map_layer1)
#create one column that goes down a row (j), then column(i), then layer(k)
pf_ssn_ind = rep(0, nx*ny*nz)


for (m in 1:3320880){
}
jj = 1

for (k in 1:nz){
     for (j in 1:ny){
          for (i in 1:nx){
               #print(pf_ind_map[i,j,k])
               pf_ssn_ind[jj]= pf_ind_map[j,i,k]
               jj=jj+1
          }
     }
}



#write the .txt and .sa file, .sa file will be converted to PFB
write.table(pf_ssn_ind, "pf_ssn_ind_test.txt", col.names = FALSE, row.names = FALSE, quote = FALSE)   
write.table( t(c(ny,nx,nz)), "pf_ssn_ind_test.sa", append=F, row.names=F, col.names=F)#creates header
write.table(pf_ssn_ind, "pf_ssn_ind_test.sa", append=T, row.names=F, col.names=F) #appends the column of indicators



#Make the .sa / .txt file for the K field 

#load the K field Rda 3D array
pf_kfield_map = readRDS(file = 'pf_kfield_map.Rda')
#create one column that goes down a row (j), then column(i), then layer(k)
pf_k_field = 0
counter = 0

for (k in 1:nz){
     for (i in 1:nx){
          for (j in 1:ny){
               #print(pf_ind_map[i,j,k])
               pf_k_field[counter]= pf_kfield_map[j,i,k]
               counter = counter + 1
          }
     }
}

write.table(pf_k_field, "pf_k_field.txt", col.names = FALSE, row.names = FALSE, quote = FALSE)   
write.table( t(c(ny,nx,nz)), "pf_k_field.sa", append=F, row.names=F, col.names=F)#creates header
write.table(pf_k_field, "pf_k_field.sa", append=T, row.names=F, col.names=F) #appends the column of indicators