## Function to convert Matlab processed data to averaged Alpha power over trials

library(ggplot2)
library(car)
library(R.matlab)

setwd('E:/Google Drive/Project AE_SNR EEG ERP/Data/FFT/PSD_ERP')
filelist <- Sys.glob("*a_ERP_PSD*")
subjects <- c('1015','1018','1019','1020','1021','1026','1027','1030','1033','1045','1046','1055','1061','1063','1064','1068','1069','1070','1071','1075','1076','1080','1081','1084','1089','1091','1093','1094','1095','1096','1097','1098','1099','1101','1102','1103','1105','1106')
analyzed_subjects <- c('1015','1018','1021','1026','1027','1030','1033','1045','1046','1055','1061','1064','1063','1068','1069','1070','1071','1075','1076','1080','1081','1089','1091','1093','1094','1095','1096','1097','1098','1099','1101','1102','1103','1105')
subjects_to_analyze <- subjects[!subjects %in% analyzed_subjects]


for (h in 1:length(subjects_to_analyze)){
    ##Import data from PSD Matlab format. 
    current_subject <- subjects_to_analyze[h]
    subject_file <- filelist[substring(filelist,1,4) %in% current_subject]
    
    ## Raw EEG data was processed. Data format: 64 channel x 250 trials x 2000 sample PSD window (power     band. 0.4hz bins)
    
    PSD_data <- readMat(subject_file, header=TRUE)
    PSD_data <- PSD_data[[1]]
    # Average Channels and sample PSD window by trials

    temp_PSD_data <- NULL
    temp_PSD_data1 <- NULL
    mean_PSD_data <- NULL
    for (k in 1:2000){
        for (j in 1:64){
            for (i in 1:250){
                temp_PSD_data[i]<- PSD_data[[i]][[1]][j,k]
            
            }
            temp_PSD_data1[j] <- mean(temp_PSD_data)
        }
        mean_PSD_data <-cbind(mean_PSD_data,temp_PSD_data1 )
    }

    #Save PSD data
    
    write.csv(mean_PSD_data, file = paste(current_subject,'_Alpha_avg_trials_',Sys.Date(),'.csv',sep=""))
}






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
    
    
    
    
    # 
    # ##calculate alpha power
    # #Alpha power between 7.5 and 12.5 hz. Sampling frequency of FFT data is 4hz
    # #Alpha band
    # alpha_band <- seq(30,50, by=1)
    # 
    # alpha_power <- rowMeans(occ_data[,alpha_band], na.rm=TRUE)
    # alpha_power <- data.frame(alpha_power)
    # alpha_power$subid <- occ_data$subject_id
    # alpha_power <- alpha_power[c(2,1)]
    # 
    # #Calculate peak alpha power within Alpha band
    # alpha_peak <- apply(occ_data[,alpha_band],1,max)
    # alpha_peak <- data.frame(alpha_peak)
    # alpha_peak$subid <- occ_data$subject_id
    # 
    # 
    # 
    # # Merge SNR threshold and alpha power datasets
    # #Remove subjects without alphapower or SNR values
    # 
    # 
    # #combine datasets
    # alpha_data <- cbind(alpha_power,SNR_thres[,9:10])
    # 
    # assign(paste('alpha_data',eyes, sep=""),alpha_data)
    # assign(paste('alpha_peak',eyes, sep=""),alpha_peak)
    # 
    # #Identify peak frequency and calculate power within -2 hz:2 hz
    # alpha_power_peak <- 1
    # for (i in 1:length(alpha_peak[,1])){
    #     
    #     alpha_power_peak[i] <- rowMeans(occ_data[i,(which.max(occ_data[i,alpha_band])+30-8):(which.max(occ_data[i,alpha_band])+30+8)])
    # }
    # assign(paste('alpha_power_peak',eyes, sep=""),alpha_power_peak)