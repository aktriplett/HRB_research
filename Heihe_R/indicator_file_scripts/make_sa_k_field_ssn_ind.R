#Author: Amanda Triplett
#Purpose: This code grabs the ending 3D arrays from make_indicator_files_final.R and
#create_ind_ss_n_final.R and converts them to ascii format (.sa) and readable (.txt)
#These resulting files can then use the tcl create_pfbs_k_field and create_pfbs_ssn_inds
#respectively to convert the .sa to ParFlow readable PFB

#Note: See the above R scripts for the actual process of turning the raw data into 
#K field or indicator


setwd('/Users/amanda_triplett/Documents/Heihe_Basin_Project/Heihe_R/data_output/indicator_output') #for desktop

#Making the specific storage / porosity indicator into a .sa file 
#load the indicator Rda 3D array
pf_ind_map = readRDS(file = 'pf_ind_file.Rda')
#load library
library(SDMTools)
#set up constants 
ny = 548 #num rows
nx = 404 #num cols
nz = 15 #num layers

#create one column that goes down a row (j), then column(i), then layer(k)
pf_ssn_ind = 0
counter = 0

for (k in 1:nz){
     for (i in 1:nx){
          for (j in 1:ny){
               #print(pf_ind_map[i,j,k])
               pf_ssn_ind[counter]= pf_ind_map[j,i,k]
               counter = counter + 1
          }
     }
}

#write the .txt and .sa file, .sa file will be converted to PFB
write.table(pf_ssn_ind, "pf_ssn_ind.txt", col.names = FALSE, row.names = FALSE, quote = FALSE)   
write.table( t(c(ny,nx,nz)), "pf_ssn_ind.sa", append=F, row.names=F, col.names=F)#creates header
write.table(pf_ssn_ind, "pf_ssn_ind.sa", append=T, row.names=F, col.names=F) #appends the column of indicators



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