## Function to analyze alpha data processed from alpha_ERP_avg_trials.R. Data imported are 64 channels by 2000 sample PSD window (power band. 0.4hz bins)

library(ggplot2)
library(car)
library(R.matlab)

setwd('E:/Google Drive/Project AE_SNR EEG ERP/Data/FFT/PSD_ERP/Alpha_avg_trials')
filelist <- Sys.glob("*Alpha_avg_trials*")
subjects <- c('1018','1019','1020','1021','1026','1027','1030','1033','1045','1046','1055','1061','1063','1068','1069','1070','1071','1075','1076','1089','1093','1094','1095','1096','1097','1098','1099','1101','1102','1103','1106')
analyzed_subjects <- c('1000')
subjects_to_analyze <- subjects[!subjects %in% analyzed_subjects]

#Create empty data frames to populate later
comb_alpha_power <- data.frame(NULL)
comb_alpha_power_peak <- data.frame(NULL)

for (h in 1:length(subjects_to_analyze)){
    ##Import data from PSD Matlab format. 
    current_subject <- subjects_to_analyze[h]
    subject_file <- filelist[substring(filelist,1,4) %in% current_subject]
    
    ## PSD data format: 64 channel x 2000 sample PSD window (power band. 0.4hz bins)
    
    PSD_data <- read.csv(subject_file, header=TRUE)
    
    ##calculate alpha power by averaging power within alphaband
    #Alpha power between 7.5 and 12.5 hz. Sampling frequency of FFT data is 4hz
    #Alpha band
    alpha_band <- seq(30,50, by=1)

    alpha_power <- rowMeans(PSD_data[,alpha_band], na.rm=TRUE)
    alpha_power <- data.frame(alpha_power)
    colnames(alpha_power) <- current_subject
    comb_alpha_power <- c(comb_alpha_power,alpha_power)
    comb_alpha_power <- data.frame(comb_alpha_power)
    
    

    #Calculate peak alpha power within Alpha band
    alpha_peak <- apply(PSD_data[,alpha_band],1,max)
    alpha_peak <- data.frame(alpha_peak)
    



    # Merge SNR threshold and alpha power datasets
    #Remove subjects without alphapower or SNR values


    #combine datasets
 #   alpha_data <- cbind(alpha_power,SNR_thres[,9:10])

    
    #Identify peak frequency and calculate power within -2 hz:2 hz
    alpha_power_peak <- 1
    for (i in 1:length(alpha_peak[,1])){

        alpha_power_peak[i] <- rowMeans(PSD_data[i,(which.max(PSD_data[i,alpha_band])+30-8):(which.max(PSD_data[i,alpha_band])+30+8)])
    }
    alpha_power_peak <- data.frame(alpha_power_peak)
    colnames(alpha_power_peak) <- current_subject
    comb_alpha_power_peak <- c(comb_alpha_power_peak,alpha_power_peak)
    comb_alpha_power_peak <- data.frame(comb_alpha_power_peak)

    #Plot power in the alpha band for occipital channels
    alpha_plot <- colMeans(PSD_data[c(31,10,9,18,34,33),2:120])
    alpha_plot <- data.frame(seq(from=0.25, to =29.75, by=0.25),alpha_plot)
    colnames(alpha_plot)[1]='freq'
ggplot(data=alpha_plot)+geom_point(aes(x=freq,y=alpha_plot))

#Save PSD data
}

# write.csv(mean_PSD_data, file = paste(current_subject,'_Alpha_avg_trials_',Sys.Date(),'.csv',sep=""))




#global average
# plot(colMeans(mean_PSD_data[,1:200]))
# plot(colMeans(mean_PSD_data[c(7,8,10,15,16,17,25,26,31,32,33,34,48,49,50,51,53),1:200]))
# plot(mean_PSD_data[,])

# 
# par(mfrow=c(1,1))
# 
# for(i in 1:4){
# plot(mean_PSD_data[i,1:200])
# }
# 
# 
# 
# 
# f=seq(from=0,to=500,by=.25)
# 
# #plot individual channels
# # POZ
# plot(f[2:120], log10(mean_PSD_data[48,2:120]))
# #Po3
# plot(f[2:120], log10(mean_PSD_data[31,2:120]))
# 
# #plot global means of all channels
# 
# plot(f[2:120],log10(colMeans(mean_PSD_data[,2:120])))
# 
# #plot occipital channels
# 
# plot(f[2:120],log10(colMeans(mean_PSD_data[c(31,10,9,18,34,33),2:120])))
# 
# log10(colMeans(mean_PSD_data[c(31:51)]))
# log_PSD <- log10(colMeans(mean_PSD_data[c(31,10,9,18,34,33),2:120]))
# 
# #calculate alpha peak
# max(log_PSD[c(31:51)])-min(log_PSD[c(31:51)])


    ##Average occipital channels 7,8,10,15,16,17,25,26,31,32,33,34,48,49,50,51,53
    # 7-P4
    # 8-P3
    # 9-O2
    # 10-O1
    # 15-P8
    # 16-P7
    # 17-Pz
    # 25-CB1
    # 26-CB2
    # 31-Oz
    # 32-Iz
    # 33-PO4
    # 34-PO3
    # 48-P1
    # 49-POz
    # 50-P2
    # 51-P6
    # 53-P5
    
    
    