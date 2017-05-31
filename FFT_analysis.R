##Analyzes EEG data that has been preprocessed in Matlab using Fieldtrip: ICA, epoching.

setwd('E:/Google Drive/Project AE_SNR EEG ERP/Data/FFT/PSD')

##Load in data

#Select eyes open or closed condition
#eye_condition <- menu(c("Eyes Open", "Eyes Closed"), title="Condition: Eyes open or eyes closed?")
eye_condition <- as.numeric(readline(prompt="Condition: 'eo'=1 or 'ec'=2 ?: ")); print(eye_condition)


switch(eye_condition,
filelist <- Sys.glob("*eo*")     
,filelist <- Sys.glob("*ec*"))

#Create empty dataframe to fill
data <- data.frame(Date=as.Date(character()),
                 File=character(), 
                 User=numeric(), 
                 stringsAsFactors=FALSE)
occ_data <- data.frame(Date=as.Date(character()),
                   File=character(), 
                   User=numeric(), 
                   stringsAsFactors=FALSE)


#load and add subject id
for (i in 1:length(filelist)){
     temp_data <- read.csv(filelist[i])
     temp_data$subject_id <- substring(filelist[i],1,4)
     temp_data <- temp_data[c(2003,1:2002)]
     
     data <- rbind(data,temp_data)
     
     temp_occ <- colMeans(temp_data[c(31,10,9,18,34,33),3:2003])
     temp_occ$subject_id <-as.numeric(substring(filelist[i],1,4))
     temp_occ <- temp_occ[c(2002,1:2001)]
     occ_data <- rbind(occ_data,temp_occ)
}

##Average occipital channels 31,10,9,18,34,33

plot(c(1:120),occ_data[2,2:121])
plot(c(1:300),occ_data[5,2:301])
##calculate alpha power
#Alpha power between 7.5 and 12.5 hz. Sampling frequency of FFT data is 4hz
#Alpha band
alpha_band <- seq(30,50, by=1)

alpha_power <- rowMeans(occ_data[,alpha_band], na.rm=TRUE)
alpha_power <- data.frame(alpha_power)
alpha_power$subid <- occ_data$subject_id
alpha_power <- alpha_power[c(2,1)]
#import SNR thresholds derived from batch_HINT in Matlab and slope_estimate.R
SNR <- read.table(file.choose(), header=TRUE)

# Merge SNR threshold and alpha power datasets


#cor.test(alphapower,SNR,method='pearson')

