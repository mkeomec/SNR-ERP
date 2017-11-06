library(ggplot2)
library(car)
library(R.matlab)

#Import data from PSD Matlab format. Raw EEG data was processed 
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


for (j in 1:2){
    eye_condition <- j
    
    
    switch(eye_condition,
           filelist <- Sys.glob("*eo*")
           ,filelist <- Sys.glob("*ec*"))
    
    #filter filelist to age and audiobility thresholds
    
    filelist <- filelist[substring(filelist,1,4) %in% data$subject_id]
    
    
    switch(eye_condition,
           eyes <- "eo"
           ,eyes <- "ec")
    
    
    #Create empty dataframe to fill
    data_fft <- data.frame(Date=as.Date(character()),
                           File=character(), 
                           User=numeric(), 
                           stringsAsFactors=FALSE)
    occ_data <- data.frame(Date=as.Date(character()),
                           File=character(), 
                           User=numeric(), 
                           stringsAsFactors=FALSE)
    alpha_power_peak <- data.frame(Date=as.Date(character()),
                                   File=character(), 
                                   User=numeric(), 
                                   stringsAsFactors=FALSE)
    
    #load and add subject id
    for (i in 1:length(filelist)){
        temp_data <- read.csv(filelist[i])
        temp_data$subject_id <- substring(filelist[i],1,4)
        temp_data <- temp_data[c(2003,1:2002)]
        
        data_fft <- rbind(data_fft,temp_data)
        
        # temp_occ <- colMeans(temp_data[c(31,10,9,18,34,33),3:2003])
        temp_occ <- colMeans(temp_data[c(7,8,10,15,16,17,25,26,31,32,33,34,48,49,50,51,53),3:2003])
        temp_occ$subject_id <-as.numeric(substring(filelist[i],1,4))
        temp_occ <- temp_occ[c(2002,1:2001)]
        occ_data <- rbind(occ_data,temp_occ)
    }
    
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
    
    
    
    
    
    ##calculate alpha power
    #Alpha power between 7.5 and 12.5 hz. Sampling frequency of FFT data is 4hz
    #Alpha band
    alpha_band <- seq(30,50, by=1)
    
    alpha_power <- rowMeans(occ_data[,alpha_band], na.rm=TRUE)
    alpha_power <- data.frame(alpha_power)
    alpha_power$subid <- occ_data$subject_id
    alpha_power <- alpha_power[c(2,1)]
    
    #Calculate peak alpha power within Alpha band
    alpha_peak <- apply(occ_data[,alpha_band],1,max)
    alpha_peak <- data.frame(alpha_peak)
    alpha_peak$subid <- occ_data$subject_id
    
    
    
    # Merge SNR threshold and alpha power datasets
    #Remove subjects without alphapower or SNR values
    
    
    #combine datasets
    alpha_data <- cbind(alpha_power,SNR_thres[,9:10])
    
    assign(paste('alpha_data',eyes, sep=""),alpha_data)
    assign(paste('alpha_peak',eyes, sep=""),alpha_peak)
    
    #Identify peak frequency and calculate power within -2 hz:2 hz
    alpha_power_peak <- 1
    for (i in 1:length(alpha_peak[,1])){
        
        alpha_power_peak[i] <- rowMeans(occ_data[i,(which.max(occ_data[i,alpha_band])+30-8):(which.max(occ_data[i,alpha_band])+30+8)])
    }
    assign(paste('alpha_power_peak',eyes, sep=""),alpha_power_peak)
}