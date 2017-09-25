setwd('E:/Google Drive/Project AE_SNR EEG ERP/Data/ERP')
library(plotly)
print('Select ERP scalp file')
ERP_raw_data <- read.table(file.choose(), header=TRUE)

channels <- c('Cz','C1','C2','CP1','CP2','FC1','FC2','FCz')
x_val <- seq(-500,996,by=4)
y_val <- colMeans(ERP_raw_data[channels,])
Cz <- colMeans(ERP_raw_data['Cz',])
plot_data <- rbind(x_val,y_val,Cz)
plot_data <- data.frame(t(plot_data))

ggplot(plot_data)+geom_line(aes(x=x_val,y=y_val))+xlab('time (msec)')+ylab('voltage')+ggtitle('ERP-central region')+ylim(-10,5)+geom_vline(xintercept=0, colour='red')+scale_x_continuous(breaks=seq(-500,1000,100))+geom_hline(yintercept = 0, colour='red')
       
ggplot(plot_data)+geom_line(aes(x=x_val,y=Cz))+xlab('time (msec)')+ylab('voltage')+ggtitle('ERP-Cz')+ylim(-10,5)+geom_vline(xintercept=0, colour='red')+scale_x_continuous(breaks=seq(-500,1000,100))+geom_hline(yintercept = 0, colour='red')
