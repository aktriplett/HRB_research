#plotting masks
quartz()
#par(mfrow=c(2,2))
#image.plot(demT, main="Elevation")
#image.plot(maskT, main="Watershed Mask")
image.plot(channelT, main="River Network")
#image.plot(lakesT, main="Terminal Lakes")

#plotting DEM smoothing
quartz()
par(mfrow=c(1,3))
image.plot(demTunsmth)
image.plot(demT)
image.plot(demTunsmth-demT)

#plotting the init object
quartz()
image.plot(init$marked[175:375,450:500]+lakemaskT[175:375,450:500])
image.plot(init$marked[,100:200]+lakemaskT[, 100:200])

#plotting traversing the stream network
quartz()
image.plot(RivBorder[175:375,450:500])


temprast=maskR    #maskR is the tif file for mask, which provides a template.
values(temprast)=t(area[, ny:1])      #make sure data in the right direction
temprast=setMinMax(temprast)
writeRaster(temprast, 'area.tif', format='GTiff', overwrite=T)