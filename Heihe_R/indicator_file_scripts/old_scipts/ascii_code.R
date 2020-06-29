library(SDMTools)
setwd("~/Documents/Heihe_Basin_Project/Heihe_R/data_output") 
nx = 548 
ny = 404 
nz = 15

ascii_k_ind = 0
counter = 0

for (k in 1:nz){
     for (j in 1:ny){
          for (i in 1:nx){
               #print(pf_ind_map[i,j,k])
               ascii_k_ind[counter]= pf_ind_map[i,j,k]
               counter = counter + 1
          }
     }
}


write.table(ascii_k_ind, "ascii_k_ind.txt", col.names = FALSE, row.names = FALSE, quote = FALSE)   
#write_file(ascii_k_ind, "ascii_k_ind.sa")


