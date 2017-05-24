##Analyzes EEG data that has been preprocessed in Matlab using Fieldtrip: ICA, epoching.

setwd('E:/Google Drive/Project AE_SNR EEG ERP/Data/FFT/PSD')

##Load in data

#Select eyes open or closed condition
eye_condition <-  menu(c("Open", "Closed"), title="Condition to analyze: Eyes open or eyes closed?")

switch(eye_condition,
filelist <- Sys.glob("*eo*")     
,filelist <- Sys.glob("*ec*"))

#Create empty dataframe to fill
data <- data.frame(Date=as.Date(character()),
                 File=character(), 
                 User=numeric(), 
                 stringsAsFactors=FALSE)

#load and add subject id
for (i in 1:length(filelist)){
     temp_data <- read.csv(filelist[i])
     temp_data$subject_id <- substring(filelist[i],1,4)
     temp_data <- temp_data[c(2003,1:2002)]
     
     data <- rbind(data,temp_data)
}

##Average occipital channels

##calculate alpha power