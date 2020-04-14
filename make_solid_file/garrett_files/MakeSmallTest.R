#starting from the test domain used in the priority flow repo 
#  (1) Using proirity flow to process the DEM and ensure drainage and get flow directions
#  (2) define a smaller subbasin for testing - write out the DEM, Mask and Direction files for this domain
#  (3) Define all the patches and write out the files needed to create a solid file

rm(list=ls())
#setwd("/Users/laura/Documents/CONUS_2.0/Test_Domains/PiorityFlow_TestDomain/Slope_Processing") #workign directory
setwd("~/Dropbox/CONUS_Share/Topography_Testing/SmallTestDomain/Slope_Processing")
#priorityflow_dir=("/Users/laura/Documents/Git_Repos/PriorityFlow") #path to your priority flow repo 

##########################################
#Source Libraries and functions
##uncomment the devtools library and the install command if you need to install PriorityFlow
#library(devtools)
#install_github("lecondon/PriorityFlow", subdir="Rpkg")
library("fields")
library(PriorityFlow)
library("raster")
library("sp")
library("rgdal")

##########################################
# Inputs
# The DEM and mask should be formated as a matrices with the same
# dimensions as the domain (i.e. ncol=nx, nrow=ny)
# The mask should consist of 0's and 1's with 1's for any grid cell on the river network
dem=matrix(scan("dem_test.txt"), ncol=215, byrow=T)
rivermask=matrix(scan("river_mask_test.txt"), ncol=215, byrow=T) #mask of river cells

ny=nrow(dem)
nx=ncol(dem)

#transforming the inputs so it is indexed as [x,y] for functions
demT=t(dem[ny:1,])
rivermaskT=t(rivermask[ny:1,])

#check that you aren't upside down and backwards somehow...
#if you've formatted your input correctly this should look
#like your domain without any additional transforming
image.plot(demT)
image.plot(rivermaskT[])

##########################################
# Process the DEM:
#1. Initialize the queue withriver cells that fall on the border
#2. Traverse the stream network filling sinks and stair stepping around D8 neigbhors
#3. Look for orphan branches and continue processing until they are all connected
#4. Use the processed river cells as the intialize a new queue
#5. process hillslopes from there

ep=0.0 #The epsilon value applied to flat cells
#1.initialize the queue with river cells that fall on the border
init=InitQueue(demT,  initmask=rivermaskT) #rectangular boundary

#2.take a first pass at traversing the streams
trav1=StreamTraverse(demT, mask=rivermaskT, init$queue, init$marked, basins=init$basins, printstep=F, epsilon=ep)
print(paste("First Pass:", round(sum(trav1$marked * rivermaskT)/sum(rivermaskT)*100,1), " % cells processed"))

image(trav1$basins, zlim=c(0.5, max(trav1$basins)))
image.plot(trav1$marked) #The portion of the river mask traversed so far


#3. look for 'orphaned' branches and continue traversing until they are all connected
# orphaned branches are portions of the river network that are connected diagonally (i.e. without any d4 neighbors)
norphan=1
lap=1
while(norphan>0){
	#look for orphan branches
	orphan=FindOrphan(trav1$dem, rivermaskT, trav1$marked)
	norphan=orphan$norphan
	print(paste("lap", lap, norphan, "orphans found"))

	#go around again if orphans are found
	if(norphan>0){
		trav2 = StreamTraverse(trav1$dem, mask=rivermaskT, queue=orphan$queue, marked=trav1$marked, step=trav1$step, direction=trav1$direction, basins=trav1$basins, printstep=F, epsilon=ep)
		trav1=trav2
		lap=lap+1
	} else {
		print("Done!  No orphan branches found")
	}
} #end while
print(paste("Final pass:", round(sum(trav1$marked * rivermaskT)/sum(rivermaskT)*100,1), " % cells processed"))

image(trav1$mask)
image(trav1$basins, zlim=c(0.5, max(trav1$basins)))
image(trav1$marked)

#4.initialize the queue with every cell on the processed river boundary
#to do this use the marked rivers from the last step plus the edge cells
#as the boundary and the mask
inittemp=InitQueue(demT) # Rectangular domain just using this to get a marked matrix of the edge cells
RivBorder=inittemp$marked+trav1$marked #initializing with rectangular boundary
RivBorder[RivBorder>1]=1
image(RivBorder)
init=InitQueue(trav1$dem,  border=RivBorder)

#5.process all the cells off the river usins the river as the boundary
travHS=D4TraverseB(trav1$dem, init$queue, init$marked, direction=trav1$direction, basins=trav1$basins, step=trav1$step, epsilon=ep)

#6. Calculate drainage areas
area=drainageArea(travHS$direction,  printflag=F)

image(travHS$marked) #this shoudl be the entire domain now
image(travHS$step)
image(travHS$basins,zlim=c(0.5, max(travHS$basins)), col=grey.colors(10))
maskcol=colorRampPalette(c('white', 'red'))
image(trav1$marked,zlim=c(0.5,1), col=maskcol(2), add=T)

#testing subbasin logic
direction=travHS$direction
direction[,1]=1
direction[,ny]=3
direction[1,]=2
direction[nx,]=4
subbasin=CalcSubbasins(direction,  area, riv_th=60, merge_th=10)
image.plot(subbasin$segments)
image.plot(subbasin$subbasins)

##########################################
#Define a smaller sub domain by finding the upstream area of a point
### some plotting to pick a point
image.plot(rivermaskT[])
image.plot(rivermaskT[60:120,35:80])
#image(rivermaskT)
#xpoint=86
#ypoint=67
xpoint=100
ypoint=46
window=10
#points(xpoint/nx, ypoint/ny, pch='*', col='white')
image.plot(rivermaskT[(xpoint-window):(xpoint+window),(ypoint-window):(ypoint+window)])
points(0.5, 0.5, pch='*', col='white')
rivermaskT[xpoint,ypoint]

### definte the watershed for the xy point you select
direction=travHS$direction
clip=DelinWatershed(c(xpoint, ypoint), direction, d4=c(1,2,3,4), printflag=F)
dim(clip$watershed)
sum(clip$watershed)^0.5
image.plot(clip$watershed)
clip$xrange
clip$yrange

#Clipe the files that will be needed for the next round
DEMrawclip=demT[clip$xrange[1]:clip$xrange[2], clip$yrange[1]:clip$yrange[2]]
DEMclip=travHS$dem[clip$xrange[1]:clip$xrange[2], clip$yrange[1]:clip$yrange[2]]
Directionclip=direction[clip$xrange[1]:clip$xrange[2], clip$yrange[1]:clip$yrange[2]]
Riverclip=rivermaskT[clip$xrange[1]:clip$xrange[2], clip$yrange[1]:clip$yrange[2]]
Maskclip=clip$watershed[clip$xrange[1]:clip$xrange[2], clip$yrange[1]:clip$yrange[2]]
Areaclip=area[clip$xrange[1]:clip$xrange[2], clip$yrange[1]:clip$yrange[2]]
image.plot(DEMclip)
image.plot(Maskclip)
image.plot(Areaclip)
image.plot(Riverclip)
dim(DEMclip)

#write out all of the files you will need for the next round of processing
runname="SmallTest"
nyclip=clip$yrange[2]-clip$yrange[1]+1
nxclip=clip$xrange[2]-clip$xrange[1]+1
write.table( t(DEMclip[,nyclip:1]) ,paste(runname, ".procDEM.out.txt", sep=""), row.names=F, col.names=F)
write.table( t(DEMrawclip[,nyclip:1]) ,paste(runname, ".rawDEM.out.txt", sep=""), row.names=F, col.names=F)
write.table( t(Directionclip[,nyclip:1]) ,paste(runname, ".Mask.out.txt", sep=""), row.names=F, col.names=F)
write.table( t(Maskclip[,nyclip:1]) ,paste(runname, ".Direction.out.txt", sep=""), row.names=F, col.names=F)

##########################################
# Write out all the borders for the solid file

# Find all the border cells 
# Note this is all done with the un-transposed matrices
mask_mat=t(Maskclip[,nyclip:1])
ny=nrow(mask_mat)
nx=ncol(mask_mat)

###Back
#Back borders occur where mask[y+1]-mask[y] is negative (i.e. the cell above is a zero and the cell is inside the mask, i.e. a 1)
back_mat=matrix(0, ncol=nx, nrow=ny)
back_mat[2:ny, ]=mask_mat[1:(ny-1), ] - mask_mat[2:ny, ]
back_mat[1,]=-1*mask_mat[1,] #the upper boundary of the top row
back_mat[back_mat>0]=0
back_mat=-1*back_mat
image.plot(t(back_mat[ny:1,]))

#Front
#Front borders occure where mask[y-1]-mask[y] is negative (i.e. the cell above is a zero and the cell is inside the mask, i.e. a 1)
front_mat=matrix(0, ncol=nx, nrow=ny)
front_mat[1:(ny-1), ]=mask_mat[2:ny, ] - mask_mat[1:(ny-1), ]
front_mat[ny,]=-1*mask_mat[ny,] #the lower boundary of the bottom row
front_mat[front_mat>0]=0
front_mat=-1*front_mat 
image.plot(t(front_mat[ny:1,]))

#Left
#Left borders occure where mask[x-1]-mask[x] is negative 
left_mat=matrix(0, ncol=nx, nrow=ny)
left_mat[,2:nx]=mask_mat[,1:(nx-1)] - mask_mat[,2:nx]
left_mat[,1]=-1*mask_mat[,1] #the left boundary of the first column
left_mat[left_mat>0]=0
left_mat=-1*left_mat 
image.plot(t(left_mat[ny:1,]))

#Right
#Right borders occure where mask[x+1]-mask[x] is negative 
right_mat=matrix(0, ncol=nx, nrow=ny)
right_mat[,1:(nx-1)]=mask_mat[,2:nx] - mask_mat[,1:(nx-1)]
right_mat[,nx]=-1*mask_mat[,nx] #the right boundary of the last column
right_mat[right_mat>0]=0
right_mat=-1*right_mat 
image.plot(t(right_mat[ny:1,]))

#write out the patches in a PF format
left=right=front=back=rep(0, nx*ny)
jj=1
for(j in ny:1){
  print(j)
  for(i in 1:nx){
    front[jj]=front_mat[j,i]
    back[jj]=back_mat[j,i]
    left[jj]=left_mat[j,i]
    right[jj]=right_mat[j,i]
    jj=jj+1
  }
}

fout="../Solid_file/Left_Border.sa"
write.table( t(c(nx,ny,1)), fout, append=F, row.names=F, col.names=F)
write.table(left, fout, append=T, row.names=F, col.names=F)
fout="../Solid_file/Right_Border.sa"
write.table( t(c(nx,ny,1)), fout, append=F, row.names=F, col.names=F)
write.table(right, fout, append=T, row.names=F, col.names=F)
fout="../Solid_file/Front_Border.sa"
write.table( t(c(nx,ny,1)), fout, append=F, row.names=F, col.names=F)
write.table(front, fout, append=T, row.names=F, col.names=F)
fout="../Solid_file/Back_Border.sa"
write.table( t(c(nx,ny,1)), fout, append=F, row.names=F, col.names=F)
write.table(back, fout, append=T, row.names=F, col.names=F)

#write out the patches in a ASC
#note looping is different from PF start in upper left and loop down
leftA=rightA=frontA=backA=rep(0, nx*ny)
jj=1
for(j in 1:ny){
  print(j)
  for(i in 1:nx){
    frontA[jj]=front_mat[j,i]
    backA[jj]=back_mat[j,i]
    leftA[jj]=left_mat[j,i]
    rightA[jj]=right_mat[j,i]
    jj=jj+1
  }
}

header1=paste("ncols        ", nx, sep="")
header2=paste("nrows        ", ny, sep="")
header3="xllcorner    0.0"
header4="yllcorner    0.0"
header5="cellsize     1000.0"
header6="NODATA_value  0.0"

header=rbind(header1, header2, header3, header4, header5, header6)

fout="../Solid_file/Left_Border.asc"
write.table(header, fout, append=F, row.names=F, col.names=F, quote=F)
write.table(leftA, fout, append=T, row.names=F, col.names=F)
fout="../Solid_file/Right_Border.asc"
write.table(header, fout, append=F, row.names=F, col.names=F, quote=F)
write.table(rightA, fout, append=T, row.names=F, col.names=F)
fout="../Solid_file/Front_Border.asc"
write.table(header, fout, append=F, row.names=F, col.names=F, quote=F)
write.table(frontA, fout, append=T, row.names=F, col.names=F)
fout="../Solid_file/Back_Border.asc"
write.table(header, fout, append=F, row.names=F, col.names=F, quote=F)
write.table(backA, fout, append=T, row.names=F, col.names=F)


# Deal with top and bottom patches
# 3 = regular overland boundary
# 4 = River
# 6 = bottom

#come up with a river mask
rivermask=Areaclip
areath=50 #drainage area threshold for rivers
rivermask[rivermask<areath]=0
rivermask[rivermask>0]=1
rivermask=rivermask*Maskclip
image.plot(rivermask)
rivermask_mat=t(rivermask[,nyclip:1])

#top
top_mat=mask_mat*3
#top_mat[rivermask_mat==1]=4 #to make a top with rivers
image.plot(top_mat)

#bottom
bottom_mat=mask_mat*6

#write out the patches in a PF format
bottom=top=rep(0, nx*ny)
jj=1
for(j in ny:1){
  print(j)
  for(i in 1:nx){
    bottom[jj]=bottom_mat[j,i]
    top[jj]=top_mat[j,i]
    jj=jj+1
  }
}
fout="../Solid_file/Bottom_Border.sa"
write.table( t(c(nx,ny,1)), fout, append=F, row.names=F, col.names=F)
write.table(bottom, fout, append=T, row.names=F, col.names=F)
fout="../Solid_file/TopNoRiver_Border.sa"
write.table( t(c(nx,ny,1)), fout, append=F, row.names=F, col.names=F)
write.table(top, fout, append=T, row.names=F, col.names=F)

#write out the patches in a asc format
bottomA=topA=rep(0, nx*ny)
jj=1
for(j in 1:ny){
  print(j)
  for(i in 1:nx){
    bottomA[jj]=bottom_mat[j,i]
    topA[jj]=top_mat[j,i]
    jj=jj+1
  }
}
fout="../Solid_file/Bottom_Border.asc"
write.table( header, fout, append=F, row.names=F, col.names=F, quote=F)
write.table(bottomA, fout, append=T, row.names=F, col.names=F)
fout="../Solid_file/TopNoRiver_Border.asc"
write.table( header, fout, append=F, row.names=F, col.names=F, quote=F)
write.table(topA, fout, append=T, row.names=F, col.names=F)
