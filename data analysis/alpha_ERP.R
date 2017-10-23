library(ggplot2)
library(car)
library(R.matlab)
PSD_data <- readMat(file.choose(), header=TRUE)
f=seq(from=0,to=500,by=.25)

#plot individual channels
# POZ
plot(f[2:120], log10(PSD_data[48,2:120]))
#Po3
plot(f[2:120], log10(PSD_data[31,2:120]))

#plot global means of all channels

plot(f[2:120],log10(colMeans(PSD_data[,2:120])))

#plot occipital channels

plot(f[2:120],log10(colMeans(PSD_data[c(31,10,9,18,34,33),2:120])))

log10(colMeans(PSD_data[c(31:51)]))
log_PSD <- log10(colMeans(PSD_data[c(31,10,9,18,34,33),2:120]))

#calculate alpha peak
max(log_PSD[c(31:51)])-min(log_PSD[c(31:51)])
