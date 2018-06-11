setwd('E:/Google Drive/Project AE_SNR EEG ERP/Data/ERP')
library(plotly)



## Read and plot single ERP recording
print('Select ERP scalp file')
ERP_raw_data <- read.table(file.choose(), header=TRUE)

channels <- c('Cz','C1','C2','CP1','CP2','FC1','FC2','FCz')
x_val <- seq(-500,996,by=4)
y_val <- colMeans(ERP_raw_data[channels,])
Cz <- colMeans(ERP_raw_data['Cz',])
plot_data <- rbind(x_val,y_val,Cz)
plot_data <- data.frame(t(plot_data))

#ggplot(plot_data)+geom_line(aes(x=x_val,y=y_val))+xlab('time (msec)')+ylab('voltage')+ggtitle('ERP-central region')+ylim(-10,5)+geom_vline(xintercept=0, colour='red')+scale_x_continuous(breaks=seq(-500,1000,100))+geom_hline(yintercept = 0, colour='red')
       
ggplot(plot_data)+geom_line(aes(x=x_val,y=Cz))+xlab('time (msec)')+ylab('voltage')+ggtitle('ERP-Cz')+ylim(-10,5)+geom_vline(xintercept=0, colour='red')+scale_x_continuous(breaks=seq(-500,1000,100))+geom_hline(yintercept = 0, colour='red')

## Plot grand averages for across all subjects
# Set directory
setwd('E:/Google Drive/Project AE_SNR EEG ERP/Data')

# Search for files with name: "ERP_stim" including subdirectories
filelist <- list.files(pattern = "ERP_stim", recursive = TRUE)
# Remove files from folder "ERP", because that was a test folder
filelist <- filelist[!grepl("ERP/10*",filelist)]
# Remove files from folder "old"
filelist <- filelist[!grepl("old",filelist)]
subjects <- c('1015','1018','1019','1020','1021','1026','1027','1030','1033','1045','1046','1055','1061','1064','1063','1068','1069','1070','1071','1075','1076','1080','1081','1084','1089','1091','1093','1094','1095','1096','1097','1098','1099','1101','1102','1103','1105','1106')

## Loop to load and extract Cz ERP from all subjects, then sort by stim type

# Create stim_list of all SNR conditions
stim_list <- c('stim101','stim108','stim109','stim110','stim111','stim112')

# Create empty df to fill with loop of grand avg 
grand_avg <- data.frame(matrix(0,1,376))

# Create empty df to fill with loop of N1 metrics
N1_peak <- data.frame(matrix(0,1,4))
names(N1_peak) <- c('sub_id','SNR','N1 Amp','N1 latency')

# Create time vector relative to stimulus. -565 to 935 msec
time_list <- seq(-565,935,4)

for (i in 1:length(stim_list)){
        filelist_stim <- filelist[grepl(stim_list[i],filelist)]
    print(stim_list[i])
    # Begin loop to load files and extract Cz channel into new dataframe
    data_stim <- data.frame(matrix(0,1,376))
    for (h in 1:length(filelist_stim)){
        current_data <- read.table(filelist_stim[h])
        print(filelist_stim[h])
        current_data <- data.frame(c(as.numeric(substr(filelist_stim[h],1,4)),current_data[65,]))
        data_stim[h,] <- current_data
        
        N1_peak[nrow(N1_peak)+1,] <- c(as.numeric(substr(filelist_stim[h],1,4)),stim_list[i],min(current_data[166:190]),time_list[which.min(current_data[166:190])+166])
        #N1_peak[h+((i-1)*(length(filelist_stim))),] <- c(as.numeric(substr(filelist_stim[h],1,4)),stim_list[i],min(current_data),time_list[which.min(current_data)])
        plot(c(2:376),current_data[2:376], main=as.numeric(substr(filelist_stim[h],1,4)),xaxt='n')
        axis(side=1, at=c(seq(1,376,25)), labels=seq(-565,935,100))
        #readline("Press <return to continue") 
    }
    
    grand_avg[i,] <- c(as.numeric(substr(stim_list[i],5,7)),colMeans((data_stim)[,-1]))
}
N1_peak <- N1_peak[-1,]

# Color gradient for plotting
colfunc <- colorRampPalette(c("red", "blue"))
colors <- colfunc(6)

plot(1, type="n", xlab="time (msec)", ylab="voltage (mV)", xlim=c(0,376), ylim=c(-3,2),xaxt='n')
axis(side=1, at=c(seq(1,376,25)), labels=seq(-565,935,100))
lines(2:376,grand_avg[1,2:376],col=colors[1], lwd=4)
lines(2:376,grand_avg[2,2:376],col=colors[2], lwd=4)
lines(2:376,grand_avg[3,2:376],col=colors[3], lwd=4)
lines(2:376,grand_avg[4,2:376],col=colors[4], lwd=4)
lines(2:376,grand_avg[5,2:376],col=colors[5], lwd=4)
lines(2:376,grand_avg[6,2:376],,col=colors[6], lwd=4)


