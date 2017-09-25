##Analyzes EEG data that has been preprocessed in Matlab using Fieldtrip: ICA, epoching.

setwd('E:/Google Drive/Project AE_SNR EEG ERP/Data/FFT/PSD')
library(dplyr)
library(ggplot2)
library(ggthemes)
library(corrplot)
library(corrgram)
##Load in data

#Select eyes open or closed condition
#eye_condition <- menu(c("Eyes Open", "Eyes Closed"), title="Condition: Eyes open or eyes closed?")

#import SNR thresholds derived from batch_HINT in Matlab and slope_estimate.R
print('Select SNR text file')
SNR <- read.table(file.choose(), header=TRUE)
SNR_thres <- SNR[c(1,9,10)]

#Import Audiobility
#print('Select Audiograms')
#audio <- read.csv(file.choose(), header=TRUE)

#Import age
#print('Select HASNR file')
#age <- read.csv(file.choose(), header=TRUE)

#Import HASNR data
print('Select HASNR file')
data <- read.csv(file.choose(), header=TRUE)


#Filter by subjects who partipated
# Subject 1063 has abnormally high alpha power. Exclude
# 
subject_info <- SNR$sub_id[!(SNR$sub_id==1063|SNR$sub_id==1015)]
data <- data[data$subject_id %in% subject_info,]
data$left_air_conduction_500[19] <- data$left_air_conduction_750[19]
data$left_air_conduction_1000[19] <- data$left_air_conduction_1500[19]


##Filter by audiobility (25-40 db HL SPL)

#data <- data[rowMeans(data[c('right_air_conduction_500','right_air_conduction_1000','right_air_conduction_2000','left_air_conduction_500','left_air_conduction_1000','left_air_conduction_2000')])<41&rowMeans(data[c('right_air_conduction_500','right_air_conduction_1000','right_air_conduction_2000','left_air_conduction_500','left_air_conduction_1000','left_air_conduction_2000')])>24,]

data$aud <- rowMeans(data[c('right_air_conduction_500','right_air_conduction_1000','right_air_conduction_2000','left_air_conduction_500','left_air_conduction_1000','left_air_conduction_2000')],na.rm=TRUE)

#Filter by age >50
#age <- age[age$Subject.ID %in% audio$subject_id,]
#age <- age[age$What.is.the.subject.s.age.>50,]
#data <- data[data$age>49,]

##Filter SNR thres by age
#SNR_thres <- SNR_thres[SNR_thres$sub_id %in% data$subject_id,]

#Filter SNR within data dataframe
SNR_thres <- SNR_thres[SNR_thres$sub_id %in% data$subject_id,]

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
    alpha_data <- cbind(alpha_power,SNR_thres)

    assign(paste('alpha_data',eyes, sep=""),alpha_data)
    assign(paste('alpha_peak',eyes, sep=""),alpha_peak)
    
    #Identify peak frequency and calculate power within -2 hz:2 hz
    alpha_power_peak <- 1
    for (i in 1:length(alpha_peak[,1])){
    
    alpha_power_peak[i] <- rowMeans(occ_data[i,(which.max(occ_data[i,alpha_band])+30-8):(which.max(occ_data[i,alpha_band])+30+8)])
    }
    assign(paste('alpha_power_peak',eyes, sep=""),alpha_power_peak)
}




alpha_data <- cbind(alpha_dataec,alpha_dataeo$alpha_power,alpha_peakec$alpha_peak,alpha_peakeo$alpha_peak)
colnames(alpha_data)[6] <- 'alpha_powereo'
colnames(alpha_data)[2] <- 'alpha_powerec'
colnames(alpha_data)[7] <- 'alpha_peakec'
colnames(alpha_data)[8] <- 'alpha_peakeo'

alpha_data <- alpha_data[,c(1:2,6,3:5)]
alpha_data$ratio <- alpha_data$alpha_powereo/alpha_data$alpha_powerec

# Data variables
# Average ANL sessions
data$ANL <-  rowMeans(data.frame(data$anl_mcl_sess01,data$anl_mcl_sess02,data$anl_mcl_sess03),na.rm=TRUE)
data$aphab_aided <- rowMeans(data.frame(data$aphab_aided_ec,data$aphab_aided_bn,data$aphab_aided_rv))
data$aphab_unaided <- rowMeans(data.frame(data$aphab_unaided_ec,data$aphab_unaided_bn,data$aphab_unaided_rv))
alpha_power_peak_ratio <- alpha_power_peakeo/alpha_power_peakec

#Create new dataframes for merging
colnames(data)[1] <- 'subid'
all_data <- merge(alpha_data,data,by='subid')

#Predictors for modeling 

predictor_labels <-  c('subid','alpha_powerec','alpha_powereo','snr80_psycho','snr50_psycho','doso_global', 'dosoa_sc','dosoa_le','dosoa_pl','dosoa_qu','dosoa_co','dosoa_us','hhie_unaided_total','hhie_aided_total', 'ssq12_score','aphab_unaided_global','aphab_aided_global','sadl_pe','sadl_sc','sadl_nf','sadl_pi','sadl_gl','aldq_demand','lseq_aided_cl','lseq_aided_se','lseq_aided_dq','lseq_aided_dl','lseq_unaided_dl','lseq_unaided_cl','lseq_unaided_se','lseq_unaided_dq','uwcpib_unaided_total','ANL','mlst_pct_av_aid_ists_65_8','mlst_pct_a_aid_ists_65_8','mlst_pct_a_uaid_ists_65_8','mlst_pct_av_uaid_ists_65_8','mlst_pct_a_aid_ists_75_0','mlst_pct_av_aid_ists_75_0','mlst_pct_a_uaid_ists_75_0','mlst_pct_av_uaid_ists_75_0','mlst_le_a_aid_ists_65_8','mlst_le_a_aid_ists_75_0','mlst_le_av_aid_ists_65_8','mlst_le_av_aid_ists_75_0','mlst_le_a_uaid_ists_65_8','mlst_le_a_uaid_ists_75_0','mlst_le_av_uaid_ists_65_8','mlst_le_av_uaid_ists_75_0','hint_srt_spshn_perceptual','aphab_aided','aphab_unaided')

predictors <-all_data[predictor_labels]

# Data visualization

corrplot(predictors,method='color')
corrgram(predictors,order=FALSE, lower.panel=panel.shade,
         upper.panel=panel.pie, text.panel=panel.txt)

#Model
alpha_model <- lm(alpha_powereo~.,data=predictors)
summary(alpha_model)









cor.test(alpha_data[,"alpha_powereo"],alpha_data[,'snr50_psycho'],method='pearson')
cor.test(alpha_data[,"alpha_powereo"],alpha_data[,'snr80_psycho'],method='pearson')
cor.test(alpha_data[,"alpha_powerec"],alpha_data[,'snr50_psycho'],method='pearson')
cor.test(alpha_data[,"alpha_powerec"],alpha_data[,'snr80_psycho'],method='pearson')
cor.test(alpha_power_peakeo,alpha_data$snr50_psycho)
cor.test(alpha_power_peakeo,alpha_data$snr80_psycho)
cor.test(alpha_power_peakeo,data$hint_srt_ists_snr80)
cor.test(alpha_power_peakeo,data$doso_global)
cor.test(alpha_power_peakec,data$doso_global)
cor.test(alpha_power_peakeo,data$aphab_unaided_global)

cor.test(alpha_power_peakeo,data$sadl_pe)
cor.test(alpha_power_peakec,data$sadl_pe)
cor.test(alpha_power_peakeo,data$sadl_gl)
cor.test(alpha_power_peakeo,data$sadl_sc)
cor.test(alpha_power_peakeo,data$aldq_demand,method='spearman')
cor.test(alpha_power_peakeo,data$anl_anl_sess01)
cor.test(alpha_power_peakec,data$anl_anl_sess01)
cor.test(alpha_power_peakeo,data$mlst_pct_av_aid_ists_75_0)
cor.test(alpha_power_peakeo,data$dosoa_le)
cor.test(alpha_power_peakec,data$dosoa_le)

plot(alpha_data$alpha_powerec,alpha_data$snr80_psycho)
plot(alpha_data$alpha_powereo,alpha_data$snr80_psycho)
plot(alpha_data$alpha_powereo,alpha_data$snr50_psycho)
plot(alpha_data$alpha_powerec,alpha_data$snr50_psycho)
plot(alpha_data$ratio,alpha_data$snr80_psycho)
plot(alpha_data$ratio,alpha_data$snr50_psycho)

#Alpha_power_peak plots
# Create list of variables to plot
plot_x <- data.frame(alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec, alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec, alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec, alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec, alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec, alpha_power_peakec,alpha_power_peakec, alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio)

plot_y <- data.frame(alpha_data$snr80_psycho,alpha_data$snr50_psycho,data$doso_global, data$dosoa_sc,data$dosoa_le,data$dosoa_pl,data$dosoa_qu,data$dosoa_co,data$dosoa_us,data$hhie_unaided_total,data$hhie_aided_total, data$ssq12_score,data$aphab_unaided_global,data$aphab_aided_global,data$sadl_pe,data$sadl_sc,data$sadl_nf,data$sadl_pi,data$sadl_gl,data$aldq_demand,data$lseq_aided_cl,data$lseq_aided_se,data$lseq_aided_dq,data$lseq_aided_dl,data$lseq_unaided_dl,data$lseq_unaided_cl,data$lseq_unaided_se,data$lseq_unaided_dq,data$uwcpib_unaided_total,data$ANL,data$mlst_pct_av_aid_ists_65_8,data$mlst_pct_a_aid_ists_65_8,data$mlst_pct_a_uaid_ists_65_8,data$mlst_pct_av_uaid_ists_65_8,data$mlst_pct_a_aid_ists_75_0,data$mlst_pct_av_aid_ists_75_0,data$mlst_pct_a_uaid_ists_75_0,data$mlst_pct_av_uaid_ists_75_0,data$mlst_le_a_aid_ists_65_8,data$mlst_le_a_aid_ists_75_0,data$mlst_le_av_aid_ists_65_8,data$mlst_le_av_aid_ists_75_0,data$mlst_le_a_uaid_ists_65_8,data$mlst_le_a_uaid_ists_75_0,data$mlst_le_av_uaid_ists_65_8,data$mlst_le_av_uaid_ists_75_0,data$hint_srt_spshn_perceptual,data$aphab_aided,data$aphab_unaided,alpha_data$snr80_psycho,alpha_data$snr50_psycho,data$doso_global, data$dosoa_sc,data$dosoa_le,data$dosoa_pl,data$dosoa_qu,data$dosoa_co,data$dosoa_us,data$hhie_unaided_total,data$hhie_aided_total, data$ssq12_score,data$aphab_unaided_global,data$aphab_aided_global,data$sadl_pe,data$sadl_sc,data$sadl_nf,data$sadl_pi,data$sadl_gl,data$aldq_demand,data$lseq_aided_cl,data$lseq_aided_se,data$lseq_aided_dq,data$lseq_aided_dl,data$lseq_unaided_dl,data$lseq_unaided_cl,data$lseq_unaided_se,data$lseq_unaided_dq,data$uwcpib_unaided_total,data$ANL,data$mlst_pct_av_aid_ists_65_8,data$mlst_pct_a_aid_ists_65_8,data$mlst_pct_a_uaid_ists_65_8,data$mlst_pct_av_uaid_ists_65_8,data$mlst_pct_a_aid_ists_75_0,data$mlst_pct_av_aid_ists_75_0,data$mlst_pct_a_uaid_ists_75_0,data$mlst_pct_av_uaid_ists_75_0,data$mlst_le_a_aid_ists_65_8,data$mlst_le_a_aid_ists_75_0,data$mlst_le_av_aid_ists_65_8,data$mlst_le_av_aid_ists_75_0,data$mlst_le_a_uaid_ists_65_8,data$mlst_le_a_uaid_ists_75_0,data$mlst_le_av_uaid_ists_65_8,data$mlst_le_av_uaid_ists_75_0,data$hint_srt_spshn_perceptual,data$aphab_aided,data$aphab_unaided,alpha_data$snr80_psycho,alpha_data$snr50_psycho,data$doso_global, data$dosoa_sc,data$dosoa_le,data$dosoa_pl,data$dosoa_qu,data$dosoa_co,data$dosoa_us,data$hhie_unaided_total,data$hhie_aided_total, data$ssq12_score,data$aphab_unaided_global,data$aphab_aided_global,data$sadl_pe,data$sadl_sc,data$sadl_nf,data$sadl_pi,data$sadl_gl,data$aldq_demand,data$lseq_aided_cl,data$lseq_aided_se,data$lseq_aided_dq,data$lseq_aided_dl,data$lseq_unaided_dl,data$lseq_unaided_cl,data$lseq_unaided_se,data$lseq_unaided_dq,data$uwcpib_unaided_total,data$ANL,data$mlst_pct_av_aid_ists_65_8,data$mlst_pct_a_aid_ists_65_8,data$mlst_pct_a_uaid_ists_65_8,data$mlst_pct_av_uaid_ists_65_8,data$mlst_pct_a_aid_ists_75_0,data$mlst_pct_av_aid_ists_75_0,data$mlst_pct_a_uaid_ists_75_0,data$mlst_pct_av_uaid_ists_75_0,data$mlst_le_a_aid_ists_65_8,data$mlst_le_a_aid_ists_75_0,data$mlst_le_av_aid_ists_65_8,data$mlst_le_av_aid_ists_75_0,data$mlst_le_a_uaid_ists_65_8,data$mlst_le_a_uaid_ists_75_0,data$mlst_le_av_uaid_ists_65_8,data$mlst_le_av_uaid_ists_75_0,data$hint_srt_spshn_perceptual,data$aphab_aided,data$aphab_unaided)

plot_variables <- list(plot_x,plot_y)

# Function to plot variables
plot_f <- function(x,y){
    plot(x,y, col=rainbow(26), pch=18, xlab=colnames(plot_variables[[1]])[i],ylab=colnames(plot_variables[[2]])[i])
    text(x,y+.02*max(y,na.rm=TRUE),labels=alpha_data$subid,cex=0.5)
    text(.9*max(x,na.rm=TRUE),.9*max(y,na.rm=TRUE),paste('R2=',round(cor.test(x,y)[[4]],digits=8)))
    text(.9*max(x,na.rm=TRUE),.8*max(y,na.rm=TRUE),paste('p=',round(cor.test(x,y)[[3]], digits=8)))   
    
}

par(mfrow=c(2,2))
for (i in 1:length(plot_variables[[1]])){
    plot_f(plot_variables[[1]][,i],plot_variables[[2]][,i])
    
}

plot(alpha_power_peakec,data$age, col=1:26, pch=18)
plot(alpha_power_peakeo,data$age, col=1:26, pch=18)
cor.test(alpha_power_peakec,data$age)
cor.test(alpha_power_peakeo,data$age)

plot(alpha_power_peakec,data$aud, col=1:26, pch=18)
plot(alpha_power_peakeo,data$aud, col=1:26, pch=18)
cor.test(alpha_power_peakec,data$aud)
cor.test(alpha_power_peakeo,data$aud)
#plot(alpha_power_peakeo,data$hhie_unaided_total, col=1:26, pch=18)
#plot(alpha_power_peakec,data$hhie_aided_total, col=1:26, pch=18)
#plot(alpha_power_peakeo,data$hhie_aided_total, col=1:26, pch=18)
#plot(alpha_power_peakec,data$ssq12_score, col=1:26, pch=18)
#plot(alpha_power_peakeo,data$ssq12_score, col=1:26, pch=18)
#plot(alpha_power_peakeo,data$hint_srt_ists_snr50, col=1:26, pch=18)
#plot(alpha_power_peakeo,data$hint_srt_ists_snr80, col=1:26, pch=18)
#plot(alpha_power_peakeo,data$aphab_unaided_global, col=1:26, pch=18)
#plot(alpha_power_peakec,data$aphab_unaided_global, col=1:26, pch=18)
#plot(alpha_power_peakeo,data$aphab_aided_global, col=1:26, pch=18)
#plot(alpha_power_peakec,data$aphab_aided_global, col=1:26, pch=18)
#plot(alpha_power_peakeo,data$sadl_pe, col=1:26, pch=18)
#plot(alpha_power_peakec,data$sadl_pe, col=1:26, pch=18)
#plot(alpha_power_peakeo,data$sadl_sc, col=1:26, pch=18)
#plot(alpha_power_peakec,data$sadl_sc, col=1:26, pch=18)
#plot(alpha_power_peakeo,data$sadl_nf, col=1:26, pch=18)
#plot(alpha_power_peakec,data$sadl_nf, col=1:26, pch=18)
#plot(alpha_power_peakeo,data$sadl_pi, col=1:26, pch=18)
#plot(alpha_power_peakec,data$sadl_pi, col=1:26, pch=18)
#plot(alpha_power_peakeo,data$sadl_gl, col=1:26, pch=18)
#plot(alpha_power_peakec,data$sadl_gl, col=1:26, pch=18)
#plot(alpha_power_peakec,data$aldq_demand, col=1:26, pch=18)
#plot(alpha_power_peakeo,data$aldq_demand, col=1:26, pch=18)
#plot(alpha_power_peakeo,data$lseq_aided_cl, col=1:26, pch=18)
#plot(alpha_power_peakeo,data$lseq_aided_se, col=1:26, pch=18)
#plot(alpha_power_peakeo,data$lseq_aided_dq, col=1:26, pch=18)
#plot(alpha_power_peakeo,data$lseq_aided_dl, col=1:26, pch=18)
#plot(alpha_power_peakeo,data$lseq_unaided_dl, col=1:26, pch=18)
#plot(alpha_power_peakeo,data$lseq_unaided_cl, col=1:26, pch=18)
#plot(alpha_power_peakeo,data$lseq_unaided_se, col=1:26, pch=18)
#plot(alpha_power_peakeo,data$lseq_unaided_dq, col=1:26, pch=18)
#plot(alpha_power_peakeo,data$uwcpib_unaided_total, col=1:26, pch=18)
#plot(alpha_power_peakec,data$uwcpib_unaided_total, col=1:26, pch=18)
#plot(alpha_power_peakeo,data$anl_anl_sess01, col=1:26, pch=18)
#plot(alpha_power_peakec,data$anl_anl_sess01, col=1:26, pch=18)
#plot(alpha_power_peakeo,data$anl_anl_sess02, col=1:26, pch=18)
#plot(alpha_power_peakec,data$anl_anl_sess02, col=1:26, pch=18)
#plot(alpha_power_peakeo,data$mlst_pct_av_aid_ists_65_8, col=1:26, pch=18)
#plot(alpha_power_peakeo,data$mlst_pct_av_aid_ists_75_0, col=1:26, pch=18)
#
#
#plot(alpha_power_peakec,data$anl_anl_sess02)





#Explore data

#for (i in 1:dim(occ_data)[1]){
#    plot(1:249,occ_data[i,2:250])
#    rect(30, 0, 50, 100, density = NULL, angle = 45)
#    text(50,2,SNR_thres$snr80_psycho[i])
#    text(50,3,SNR_thres$sub_id[i])
#    }

#Modeling
model <- lm(SNR_thres$snr80_psycho~alpha_power_peakeo)
model <- lm(SNR_thres$snr80_psycho~alpha_power_peakeo+alpha_power_peakec)
model <- lm(alpha_power_peakeo~data$hhie_aided_total+data$lseq_unaided_cl+data$doso_global+data$dosoa_pl+data$sadl_pe+data$sadl_gl+data$hint_srt_spshn_perceptual)
model <- lm(alpha_power_peakeo~data$sadl_gl)
summary(model)
