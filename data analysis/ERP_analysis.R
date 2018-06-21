library(plotly)
library(dplyr)


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
grand_avg_std <- data.frame(matrix(0,1,376))

# Create empty df to fill with loop of N1 metrics
N1_peak <- data.frame(matrix(0,1,4))
names(N1_peak) <- c('sub_id','SNR','N1_Amp','N1_latency')

# Create time vector relative to stimulus. -565 to 935 msec
time_list <- seq(-500-68,1000-68,4)

for (i in 1:length(stim_list)){
    #i=1
    filelist_stim <- filelist[grepl(stim_list[i],filelist)]
    print(stim_list[i])
    # Begin loop to load files and extract Cz channel into new dataframe
    data_stim <- data.frame(matrix(0,1,376))
    
    #plot(1, type="n", xlab="time (msec)", ylab="voltage (mV)", xlim=c(0,376), ylim=c(-8,8),xaxt='n')
    
    for (h in 1:length(filelist_stim)){
        current_data <- read.table(filelist_stim[h])
        print(filelist_stim[h])
        current_data <- data.frame(c(as.numeric(substr(filelist_stim[h],1,4)),current_data[65,]))
        data_stim[h,] <- current_data
        #  Take the mininum of N1 values to calculate N1 amplitude and the time for N1 latency. 
        N1_peak[nrow(N1_peak)+1,] <- c(as.numeric(substr(filelist_stim[h],1,4)),stim_list[i],min(current_data[166:190]),time_list[which.min(current_data[166:190])+166])
        
        #plot(c(2:376),current_data[2:376], main=c(as.numeric(substr(filelist_stim[h],1,4)),stim_list[i]),xaxt='n')
        #axis(side=1, at=c(seq(1,376,25)), labels=seq(-565,935,100))
        
        #lines(2:376,current_data[1,2:376],col=colors[1], lwd=1)
   
        
        #readline("Press <return to continue") 
    }
    
    grand_avg[i,] <- c(as.numeric(substr(stim_list[i],5,7)),colMeans((data_stim)[,-1]))

}
N1_peak <- N1_peak[-1,]

## Grand average of ERP N1 metrics across SNR stimulus conditions
# subset by condition. 


#grand_avg_N1_amp <- select(N1_peak$SNR,N1_peak$SNR=='stim101')
grand_avg_N1_peak <- N1_peak%>% group_by(SNR)%>% summarise(sd_N1_amp=sd(as.numeric(N1_Amp)),avg_N1_amp=mean(as.numeric(N1_Amp)),avg_N1_latency=mean(as.numeric(N1_latency)),sd_N1_latency=sd(as.numeric(N1_latency)))

grand_avg_N1_peak$amp_sterr <- grand_avg_N1_peak$sd_N1_amp/6
grand_avg_N1_peak$lat_sterr <- grand_avg_N1_peak$sd_N1_latency/6

#Plot average N1 amp and latency across SNR conditions
SNR_conditions <- seq(-10,15,5)
plot(SNR_conditions,-grand_avg_N1_peak$avg_N1_amp,xlim=c(-12,17),ylim=c(0,4),xaxt='n',main='ERP Grand Average N1 Amplitude')
lines(SNR_conditions[-1],-grand_avg_N1_peak$avg_N1_amp[-1])
arrows(SNR_conditions,-grand_avg_N1_peak$avg_N1_amp-grand_avg_N1_peak$amp_sterr, SNR_conditions,-grand_avg_N1_peak$avg_N1_amp+grand_avg_N1_peak$amp_sterr, length=0.05, angle=90, code=3)
axis(side=1, at=seq(-10,15,5),labels=c('clean','-5','0','5','10','15'))


plot(SNR_conditions,grand_avg_N1_peak$avg_N1_latency,xlim=c(-12,17),ylim=c(130,180),xaxt='n',main='ERP Grand Average N1 Latency')
lines(SNR_conditions[-1],grand_avg_N1_peak$avg_N1_latency[-1])
arrows(SNR_conditions,grand_avg_N1_peak$avg_N1_latency-grand_avg_N1_peak$lat_sterr, SNR_conditions,grand_avg_N1_peak$avg_N1_latency+grand_avg_N1_peak$lat_sterr, length=0.05, angle=90, code=3)
axis(side=1, at=seq(-10,15,5),labels=c('clean','-5','0','5','10','15'))

# Modeling
mod.1 <- lm(N1_peak$N1_Amp~N1_peak$SNR)
summary(mod.1)

mod.2 <- lm(N1_peak$N1_latency~N1_peak$SNR)
summary(mod.2)



## Grand Average plotting
# Color gradient for plotting
colfunc <- colorRampPalette(c("red", "blue"))
colors <- colfunc(6)

# Overlapping plot
plot(1, type="n", xlab="time (msec)", ylab="voltage (mV)", xlim=c(125,376), ylim=c(-3,2),xaxt='n')
axis(side=1, at=c(seq(1,376,25)), labels=seq(-568,932,100))
lines(2:376,grand_avg[1,2:376],col=colors[1], lwd=2)
lines(2:376,grand_avg[2,2:376],col=colors[2], lwd=2)
lines(2:376,grand_avg[3,2:376],col=colors[3], lwd=2)
lines(2:376,grand_avg[4,2:376],col=colors[4], lwd=2)
lines(2:376,grand_avg[5,2:376],col=colors[5], lwd=2)
lines(2:376,grand_avg[6,2:376],col=colors[6], lwd=2)
legend(300,2,legend=c('clean','15','10','5','0','-5'),col=colors, lty=1, cex=1)

#staggered plot

plot(1, type="n", xlab="time (msec)", ylab="voltage (mV)", xlim=c(125,376), ylim=c(-11,2),xaxt='n')
axis(side=1, at=c(seq(1,376,25)), labels=seq(-568,932,100))
lines(2:376,grand_avg[1,2:376],col=colors[1], lwd=2)
lines(2:376,grand_avg[2,2:376]-2,col=colors[2], lwd=2)
lines(2:376,grand_avg[3,2:376]-4,col=colors[3], lwd=2)
lines(2:376,grand_avg[4,2:376]-6,col=colors[4], lwd=2)
lines(2:376,grand_avg[5,2:376]-8,col=colors[5], lwd=2)
lines(2:376,grand_avg[6,2:376]-10,col=colors[6], lwd=2)
legend(300,2,legend=c('clean','15','10','5','0','-5'),col=colors, lty=1, cex=1)
# Plot N1 Peak amplitude 

#import SNR thresholds derived from batch_HINT in Matlab and slope_estimate.R
print('Select SNR text file')
SNR <- read.table('E:/Google Drive/Project AE_SNR EEG ERP/Data/FFT/PSD/SNR2018-01-16.txt', header=TRUE)

#Import HASNR data
print('Select HASNR file')
data <- read.csv('E:/Google Drive/Project AE_SNR EEG ERP/Data/FFT/PSD/HASNR_DATA_2018-01-29_1718.csv', header=TRUE)
data$aud <- rowMeans(data[c('right_air_conduction_500','right_air_conduction_1000','right_air_conduction_2000','left_air_conduction_500','left_air_conduction_1000','left_air_conduction_2000')],na.rm=TRUE)
#merge SNR and N1_peak

SNR_N1 <- merge(N1_peak,SNR, by='sub_id')

# import alpha during ERP values 

print('Select Alpha avg file')
alpha_ERP <- read.csv('E:/Google Drive/Project AE_SNR EEG ERP/Data/FFT/PSD_ERP/Alpha_avg_trials/All_subjects_Alpha_peak_ERP2018-02-14.csv', check.names=FALSE,header=TRUE)
alpha_ERP <- alpha_ERP[-c(1,2)]
alpha_ERP <- t(alpha_ERP)
colnames(alpha_ERP) <- c(1:64)

alpha_ERP_occ <- data.frame(rownames(alpha_ERP),rowMeans(alpha_ERP[,c(9,10,31)]))

names(alpha_ERP_occ) <- c('sub_id','alpha_peak_ERP_occ')
colnames(data)[1] <- 'sub_id'

data$sub_id <- as.character(data$sub_id)
alpha_ERP_occ$sub_id <- as.character(alpha_ERP_occ$sub_id)

all_data_EEG <- merge(SNR_N1,alpha_ERP_occ,by='sub_id')
all_data_EEG <- merge(all_data_EEG,data,by='sub_id')

#Test association between SNR and ERP metrics
cor.test(as.numeric(SNR_N1$N1_Amp),SNR_N1$snr50_psycho)
plot(as.numeric(SNR_N1$N1_Amp),SNR_N1$snr50_psycho)

cor.test(as.numeric(SNR_N1$N1_Amp),SNR_N1$snr80_psycho)
plot(as.numeric(SNR_N1$N1_Amp),SNR_N1$snr80_psycho)

#Model Testing
mod2 <- lm(as.numeric(SNR_N1$N1_Amp)~SNR_N1$snr80_psycho)
summary(mod2)

mod3 <- lm(SNR_N1$snr80_psycho~as.numeric(SNR_N1$N1_Amp)+as.numeric(SNR_N1$N1_latency)+all_data_EEG$alpha_peak_ERP_occ)
summary(mod3)
data_stim101 <- all_data_EEG[all_data_EEG$SNR=='stim101',]


## Model to test how N1 amp and latency and alpha peak ERP impact snr 80 from clean bas

mod4 <- lm(data_stim101$snr80_psycho~as.numeric(data_stim101$N1_Amp)+as.numeric(data_stim101$N1_latency)+data_stim101$alpha_peak_ERP_occ)
summary(mod4)

##
mod5 <- lm(snr50_psycho~as.numeric(N1_Amp)+as.numeric(N1_latency)+aud+alpha_peak_ERP_occ+age,data=data_stim101)
summary(mod5)
##

mod6 <- lm(all_data_EEG$snr80_psycho~as.numeric(all_data_EEG$N1_amp))

mod7 <- lm(data_stim101$aphab_aided_global~as.numeric(data_stim101$N1_Amp)+data_stim101$alpha_peak_ERP_occ+data_stim101$snr50_psycho+as.numeric(data_stim101$N1_latency))
summary(mod7)

##
mod7 <- lm(aphab_aided_global~as.numeric(N1_Amp)+as.numeric(N1_latency)+aud+alpha_peak_ERP_occ+snr50_psycho+age,data=data_stim101)
summary(mod7)
##
