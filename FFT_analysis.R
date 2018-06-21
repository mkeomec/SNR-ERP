##Analyzes EEG data that has been preprocessed in Matlab using Fieldtrip: ICA, epoching.

#Directory Setup
setwd('E:/Google Drive/Project AE_SNR EEG ERP/Data/FFT/PSD')

#Load libraries
library(dplyr)
library(ggplot2)
library(ggthemes)
library(corrplot)
library(corrgram)
library(usdm)
library(car)
library(R.matlab)


##Load in data

#Select eyes open or closed condition
#eye_condition <- menu(c("Eyes Open", "Eyes Closed"), title="Condition: Eyes open or eyes closed?")

#import SNR thresholds derived from batch_HINT in Matlab and slope_estimate.R
print('Select SNR text file')
SNR <- read.table(file.choose(), header=TRUE)

#Import HASNR data
print('Select HASNR file')
data <- read.csv(file.choose(), header=TRUE)


#Filter by subjects who partipated
# Subject 1063 has abnormally high alpha power. Exclude
# Subject 1015 was much younger. 1106 is missing SNR data
# 

subject_info <- SNR$sub_id
#subject_info <- SNR$sub_id[!(SNR$sub_id==1063|SNR$sub_id==1015|SNR$sub_id==1106)]


##Filter by audiobility (25-40 db HL SPL)
data <- data[data$subject_id %in% subject_info,]
#correct data entry error
index.error <- is.na(data$left_air_conduction_500)
data$left_air_conduction_500[index.error] <- data$left_air_conduction_750[index.error]
data$left_air_conduction_1000[index.error] <- data$left_air_conduction_1500[index.error]


data$aud <- rowMeans(data[c('right_air_conduction_500','right_air_conduction_1000','right_air_conduction_2000','left_air_conduction_500','left_air_conduction_1000','left_air_conduction_2000')],na.rm=TRUE)

### SET AUDIOBILITY THRESHOLD
#data <- subset(data,aud>25&aud<40)

# update subject_info

subject_info <- data$subject_id

# Update SNR_thres

SNR_thres <- SNR[SNR$sub_id %in% subject_info,]

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
        
        temp_occ <- colMeans(temp_data[c(9,10,31),3:2003])
        #temp_occ <- colMeans(temp_data[c(7,8,9,10,15,16,17,25,26,31,32,33,34,48,49,50,51,53),3:2003])
        
        
        temp_occ$subject_id <-as.numeric(substring(filelist[i],1,4))
        temp_occ <- temp_occ[c(2002,1:2001)]
        occ_data <- rbind(occ_data,temp_occ)
    }
    
    

    ##Average occipital channels 7,8,9,10,15,16,17,25,26,31,32,33,34,48,49,50,51,53
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


#Combine alpha data frames

alpha_data <- cbind(alpha_dataec,alpha_dataeo$alpha_power,alpha_peakec$alpha_peak,alpha_peakeo$alpha_peak)
colnames(alpha_data)[5] <- 'alpha_powereo'
colnames(alpha_data)[2] <- 'alpha_powerec'
colnames(alpha_data)[6] <- 'alpha_peakec'
colnames(alpha_data)[7] <- 'alpha_peakeo'

# Rearrange columns
alpha_data <- alpha_data[,c(1,3:4,2,5:7)]

#Calculate alpha ratio. Ratio=alphapower eo / alphapower ec
alpha_data$ratio <- alpha_data$alpha_powereo/alpha_data$alpha_powerec

# Data variables
# Average ANL sessions
data$ANL <-  rowMeans(data.frame(data$anl_mcl_sess01,data$anl_mcl_sess02,data$anl_mcl_sess03),na.rm=TRUE)
data$aphab_aided <- rowMeans(data.frame(data$aphab_aided_ec,data$aphab_aided_bn,data$aphab_aided_rv))
data$aphab_unaided <- rowMeans(data.frame(data$aphab_unaided_ec,data$aphab_unaided_bn,data$aphab_unaided_rv))
data$alpha_power_peak_ratio <- alpha_power_peakeo/alpha_power_peakec

#Create new dataframes for merging
colnames(data)[1] <- 'subid'
all_data <- merge(alpha_data,data,by='subid')


# Import alpha power during ERP

alpha_ERP <- read.csv(file.choose(), check.names=FALSE,header=TRUE)
alpha_ERP <- alpha_ERP[-c(1,2)]
alpha_ERP <- t(alpha_ERP)
colnames(alpha_ERP) <- c(1:64)

alpha_ERP_occ <- data.frame(rownames(alpha_ERP),rowMeans(alpha_ERP[,c(9,10,31)]))
#alpha_ERP_occ <- data.frame(rownames(alpha_ERP),rowMeans(alpha_ERP[,c(7,8,9,10,15,16,17,25,26,31,32,33,34,48,49,50,51,53)]))

names(alpha_ERP_occ) <- c('subid','alpha_peak_ERP_occ')
all_data <- merge(all_data,alpha_ERP_occ,by='subid')
all_data$alpha_diff <- all_data$alpha_peakeo-all_data$alpha_peak_ERP_occ


plot(all_data$alpha_peak_ERP_occ,all_data$alpha_peakec)

# Add Aphab benefit. Unaided global minus aided global

all_data$aphab_benefit <- all_data$aphab_unaided_global-all_data$aphab_aided_global


#Predictors for modeling 

#predictor_labels <-  c('subid','alpha_powerec','alpha_powereo','ratio','snr80_psycho','snr50_psycho','doso_global+dosoa_sc','dosoa_le','dosoa_pl','dosoa_qu','dosoa_co','dosoa_us','hhie_unaided_total','hhie_aided_total', 'ssq12_score','aphab_unaided_global','aphab_aided_global','sadl_pe','sadl_sc','sadl_nf','sadl_pi','sadl_gl','aldq_demand','lseq_aided_cl','lseq_aided_se','lseq_aided_dq','lseq_aided_dl','lseq_unaided_dl','lseq_unaided_cl','lseq_unaided_se','lseq_unaided_dq','uwcpib_unaided_total','ANL','mlst_pct_av_aid_ists_65_8','mlst_pct_a_aid_ists_65_8','mlst_pct_a_uaid_ists_65_8','mlst_pct_av_uaid_ists_65_8','mlst_pct_a_aid_ists_75_0','mlst_pct_av_aid_ists_75_0','mlst_pct_a_uaid_ists_75_0','mlst_pct_av_uaid_ists_75_0','mlst_le_a_aid_ists_65_8','mlst_le_a_aid_ists_75_0','mlst_le_av_aid_ists_65_8','mlst_le_av_aid_ists_75_0','mlst_le_a_uaid_ists_65_8','mlst_le_a_uaid_ists_75_0','mlst_le_av_uaid_ists_65_8','mlst_le_av_uaid_ists_75_0','hint_srt_spshn_perceptual','aphab_aided','aphab_unaided','alpha_peak_ERP_occ')

#predictors <- all_data[predictor_labels]
#cor.test(x = all_data$snr80_psycho,y = all_data$alpha_peak_ERP_occ)

## Data visualization

#corrplot(predictors,method='color')
#corrgram(predictors,order=FALSE, lower.panel=panel.shade,
 #        upper.panel=panel.cor, text.panel=panel.txt)

# Restrict variables 
## Look at survey global scores
#predictor2_labels <-  c('alpha_powerec','alpha_powereo','alpha_peakec','alpha_peakeo','ratio','snr80_psycho','snr50_psycho','age','aud','hhie_aided_total', 'sadl_sc','sadl_gl','uwcpib_unaided_total','ANL','mlst_pct_av_aid_ists_65_8','mlst_pct_a_aid_ists_65_8','mlst_pct_a_uaid_ists_65_8','mlst_pct_av_uaid_ists_65_8','mlst_pct_a_aid_ists_75_0','mlst_pct_av_aid_ists_75_0','mlst_pct_a_uaid_ists_75_0','mlst_pct_av_uaid_ists_75_0','mlst_le_a_aid_ists_65_8','mlst_le_a_aid_ists_75_0','mlst_le_av_aid_ists_65_8','mlst_le_av_aid_ists_75_0','mlst_le_a_uaid_ists_65_8','mlst_le_a_uaid_ists_75_0','mlst_le_av_uaid_ists_65_8','mlst_le_av_uaid_ists_75_0','hint_srt_spshn_perceptual','alpha_peak_ERP_occ')

#predictors2 <- all_data[predictor2_labels]
#corrgram(predictors2,order=FALSE, lower.panel=panel.shade,
         #upper.panel=panel.pie, text.panel=panel.txt)

#cor.test(x = all_data$hint_srt_spshn_perceptual,y = all_data$alpha_peak_ERP_occ)
#cor.test(x = all_data$sadl_sc,y = all_data$alpha_peak_ERP_occ)
#cor.test(x = all_data$sadl_gl,y = all_data$alpha_peak_ERP_occ)

#predictor3_labels <-  c('aphab_aided','aphab_unaided','aldq_demand','alpha_powerec','alpha_powereo','alpha_peakec','alpha_peakeo','ratio','snr80_psycho','snr50_psycho','age','aud','hhie_aided_total', 'sadl_sc','sadl_gl','uwcpib_unaided_total','ANL','hint_srt_spshn_perceptual','mlst_pct_av_aid_ists_65_8','mlst_pct_a_aid_ists_65_8','mlst_pct_a_uaid_ists_65_8','mlst_pct_av_uaid_ists_65_8','mlst_pct_a_aid_ists_75_0','mlst_pct_av_aid_ists_75_0','mlst_pct_a_uaid_ists_75_0','mlst_pct_av_uaid_ists_75_0','mlst_le_a_aid_ists_65_8','mlst_le_a_aid_ists_75_0','mlst_le_av_aid_ists_65_8','mlst_le_av_aid_ists_75_0','mlst_le_a_uaid_ists_65_8','mlst_le_a_uaid_ists_75_0','mlst_le_av_uaid_ists_65_8','mlst_le_av_uaid_ists_75_0')

#predictors3 <- all_data[predictor3_labels]
#corrgram(predictors3,order=FALSE, lower.panel=panel.shade,
 #        upper.panel=panel.pie, text.panel=panel.txt)

## Look at individual Aphab questions related to SNR
# Group Aphab values by pragmatic subscale r=reversed

# aphab1 = Ease of Communication (4,10,12,14,15,23)
# aphab2 = Background noise (1r,6,7,16r,19r,24)
# aphab3 = Reverberation (2,5,9r,11r,18,21r)
# aphab4= Aversiveness (3,8,13,17,20,22)
# 






# 1) When I am in a crowded grocery store, talking with the cashier, I can follow the conversation. 
# 5) I have trouble understanding the dialogue in a movie or at the theater. 
# 6) When I am listening to the news on the car radio, and family members are talking, I have trouble hearing the news.
# 7)When I'm at the dinner table with several people, and am trying to have a conversation with one person, understanding speech is difficult. 
# 11) When I am in a theater watching a movie or play, and the people around me are whispering and rustling paper wrappers, I can still make out the dialogue.
# 16) I can understand conversations even when several people are talking. 
# 19)  I can communicate with others when we are in a crowd.
# 24) I have trouble understanding others when an air conditioner or fan is on



#aphab_labels <- c('alpha_powerec','alpha_powereo','alpha_peakec','alpha_peakeo','ratio','snr80_psycho','snr50_psycho','aphab_unaided_001','aphab_aided_001','aphab_unaided_005','aphab_aided_005','aphab_unaided_006','aphab_aided_006','aphab_unaided_007','aphab_aided_007','aphab_unaided_011','aphab_aided_011','aphab_unaided_016','aphab_aided_016','aphab_unaided_019','aphab_aided_019','aphab_unaided_024','aphab_aided_024')

#aphab <- all_data[aphab_labels]
#corrgram(aphab[,c('alpha_powerec','alpha_powereo','alpha_peakec','alpha_peakeo','ratio','snr80_psycho','snr50_psycho','aphab_unaided_001','aphab_aided_001','aphab_unaided_005','aphab_aided_005','aphab_unaided_006','aphab_aided_006','aphab_unaided_007','aphab_aided_007','aphab_unaided_011','aphab_aided_011','aphab_unaided_016','aphab_aided_016','aphab_unaided_019','aphab_aided_019','aphab_unaided_024','aphab_aided_024')],order=FALSE, lower.panel=panel.pts,
#         upper.panel=panel.pie, text.panel=panel.txt)


## Look at individual HHIE questions related to SNR
#6) Does a hearing problem cause you difficulty when attending a party?
# 21) Does a hearing problem cause you difficulty when in a restaurant with relatives or friends?




## Look at SSQ values
# 2) You are listening to someone talking to you, whle at the samte time trying to follow the news on TV. Can you follow what both people are saying?
# 3) You are in conversation with one person in a room where there are many other people talking. Can you follow what the person you are talking to is saying?
# 4) You are in a group of about five people in a busy restaurant. You can see everyone elese in the group. Can you follow the conversation?
# 5) 

# Group SSQ values by pragmatic subscale
# SSQ1= Speech in noise (1,3,4) 
# SSQ2= Multiple speech streams (2,5)
# SSQ3= Localization (6)
# SSQ4= Distant and movement (7,8)
# SSQ5= Segregation (9)
# SSQ6= Identification and sound (10)
# SSQ7= Quality & naturalness (11)
# SSQ8= Listening effort (12)
# SSQ9= Speech in noise (1,3,4) Multiple speech streams (2,5)
# SSQ10= Localization (6) Distant and movement (7,8)

# add SSQ subscale variables
all_data$SSQ1 <- rowMeans(all_data[,c('ssq12_response_001','ssq12_response_002','ssq12_response_003','ssq12_response_004','ssq12_response_005')])
all_data$SSQ2 <- rowMeans(all_data[,c('ssq12_response_006','ssq12_response_007','ssq12_response_008')])
all_data$SSQ3 <- rowMeans(all_data[,c('ssq12_response_009','ssq12_response_010','ssq12_response_011','ssq12_response_012')])


#ssq12_labels <- c('alpha_powerec','alpha_powereo','alpha_peakec','alpha_peakeo','ratio','snr80_psycho','snr50_psycho','age','aud','ssq12_response_001','ssq12_response_002','ssq12_response_003','ssq12_response_004','ssq12_response_005','ssq12_response_006','ssq12_response_007','ssq12_response_008','ssq12_response_009','ssq12_response_010','ssq12_response_011','ssq12_response_012','ssq12_score','SSQ1','SSQ2','SSQ3')

#ssq12 <- all_data[ssq12_labels]
#corrgram(ssq12,order=FALSE, lower.panel=panel.pts,
#         upper.panel=panel.pie, text.panel=panel.txt)

#ssq.model <- lm(alpha_power_peak_ratio~SSQ1+SSQ2+SSQ3,data=all_data)
#summary(ssq.model)

#ssq.model <- lm(alpha_power_peakec~SSQ1+SSQ2+SSQ3,data=all_data)
#summary(ssq.model)

#ssq.model <- lm(alpha_power_peakeo~SSQ1+SSQ2+SSQ3,data=all_data)
#summary(ssq.model)

#ssq.model <- lm(alpha_power_peak_ratio~SSQ2,data=all_data)
#summary(ssq.model)
#plot(all_data$alpha_power_peak_ratio,all_data$SSQ2)
#cor.test(all_data$alpha_power_peak_ratio,all_data$SSQ2)

#ssq.model <- lm(alpha_power_peak_ratio~SSQ2,data=all_data)
#summary(ssq.model)

#ALDQ model

#mod_aldq <- lm(aldq_demand~alpha_power_peak_ratio+alpha_power_peakec+alpha_power_peakeo+snr80_psycho+snr50_psycho+SSQ1+SSQ2+SSQ3+aphab_unaided_ec+aphab_unaided_bn+aphab_unaided_rv+aphab_unaided_av+aphab_aided_ec+aphab_aided_bn+aphab_aided_rv+aphab_aided_av,data=all_data)
#summary(mod_aldq)

## Look at IOI values
# GOLD STANDARD FOR HEARING AID SUCCESS
# 7) Considering everything, how much has your present hearing aid(s) changed your enjoyment of life?


#ioi_labels <- c('alpha_powerec','alpha_powereo','alpha_peakec','alpha_peakeo','ratio','snr80_psycho','snr50_psycho','age','aud','ioiha_response_001','ioiha_response_002','ioiha_response_003','ioiha_response_004','ioiha_response_005','ioiha_response_006','ioiha_response_007')
#ioi <- all_data[ioi_labels]
#corrgram(ioi,order=FALSE, lower.panel=panel.pts,
 #        upper.panel=panel.cor, text.panel=panel.txt)


#corrgram(predictors2,order=FALSE, lower.panel=panel.pts,
 #        upper.panel=panel.pie, text.panel=panel.txt)
# plot alpha vs age 
# Alpha eyes closed vs age and aud
#corrgram(all_data[,c('alpha_powerec','alpha_peakec','age','aud')],order=FALSE, lower.panel=panel.pts,
#         upper.panel=panel.conf, text.panel=panel.txt)

#corrgram(all_data[,c('alpha_powerec','alpha_peakec','alpha_powereo','alpha_peakeo','aphab_aided','aphab_unaided','aldq_demand','age','ioiha_response_001','ioiha_response_002','ioiha_response_003','ioiha_response_004','ioiha_response_005','ioiha_response_006','ioiha_response_007')],order=FALSE, lower.panel=panel.pts,
#         upper.panel=panel.conf, text.panel=panel.txt)

# Alpha eyes open vs age and aud
#corrgram(all_data[,c('alpha_powereo','alpha_peakeo','age','aud')],order=FALSE, lower.panel=panel.pts,
   #      upper.panel=panel.conf, text.panel=panel.txt)

# Alpha vs SNR 

#corrgram(all_data[,c('alpha_powereo','alpha_peakeo','age','aud','snr80_psycho','snr50_psycho')],order=FALSE, lower.panel=panel.pts,
 #        upper.panel=panel.conf, text.panel=panel.txt)

#corrgram(all_data[,c('alpha_powerec','alpha_peakec','age','aud','snr80_psycho','snr50_psycho')],order=FALSE, lower.panel=panel.pts,
  #       upper.panel=panel.conf, text.panel=panel.txt)




#Model
#alpha_model_eo <- lm(alpha_powereo~ioiha_response_001+ioiha_response_002+ioiha_response_003+ioiha_response_004+ioiha_response_005+ioiha_response_006+ioiha_response_007,data=all_data)
#summary(alpha_model_eo)

#alpha_model_eo <- lm(alpha_powereo~ioiha_response_002+ioiha_response_007,data=all_data)
#summary(alpha_model_eo)

#alpha_model_ec <- lm(alpha_powerec~ioiha_response_001+ioiha_response_002+ioiha_response_005+ioiha_response_006+ioiha_response_007,data=all_data)
#summary(alpha_model_ec)

#alpha_model_ratio <- lm(alpha_power_peak_ratio ~ioiha_response_001+ioiha_response_002+ioiha_response_003+ioiha_response_004+ioiha_response_005+ioiha_response_006+ioiha_response_007,data=all_data)
#summary(alpha_model_ratio)

#alpha_model_ratio <- lm(alpha_power_peakeo ~ioiha_response_001+ioiha_response_002+ioiha_response_003+ioiha_response_004+ioiha_response_005+ioiha_response_006+ioiha_response_007,data=all_data)
#summary(alpha_model_ratio)

#alpha_peakeo_model <- lm(alpha_power_peakeo ~ioiha_response_001+ioiha_response_002+ioiha_response_003+ioiha_response_004+ioiha_response_005,data=all_data)
#summary(alpha_peakeo_model)

#alpha_peakec_model <- lm(alpha_power_peakec ~ioiha_response_001+ioiha_response_002+ioiha_response_003+ioiha_response_004+ioiha_response_005+ioiha_response_007,data=all_data)
#summary(alpha_peakec_model)

#alpha_peakec_model <- lm(alpha_power_peakec ~ioiha_response_001+ioiha_response_003+ioiha_response_005+ioiha_response_007+ssq12_response_008,data=all_data)
#summary(alpha_peakec_model)




## APHAB MODELING

#alpha_model.2 <- lm(alpha_powereo~aphab_unaided_001+aphab_unaided_002+aphab_unaided_003+aphab_unaided_004+aphab_unaided_005+aphab_unaided_006+aphab_unaided_007+aphab_unaided_008+aphab_unaided_009+aphab_unaided_010+aphab_unaided_011+aphab_unaided_012+aphab_unaided_013+aphab_unaided_014+aphab_unaided_015+aphab_unaided_016+aphab_unaided_017+aphab_unaided_018+aphab_unaided_019+aphab_unaided_024,data=all_data)
#summary(alpha_model.2)

#subscales
#alpha_model.2 <- lm(alpha_power_peakec~aphab_unaided_ec+aphab_unaided_bn+aphab_unaided_rv+aphab_unaided_av,data=all_data)
#summary(alpha_model.2)

#alpha_model.2 <- lm(alpha_power_peakec~aphab_unaided_bn+aphab_unaided_av,data=all_data)
#summary(alpha_model.2)

#alpha_model.2 <- lm(alpha_power_peakeo~aphab_unaided_ec+aphab_unaided_bn+aphab_unaided_rv+aphab_unaided_av,data=all_data)
#summary(alpha_model.2)

#alpha_model.2 <- lm(alpha_power_peakeo~aphab_unaided_bn+aphab_unaided_av,data=all_data)
#summary(alpha_model.2)

#alpha_model.2 <- lm(alpha_power_peakeo~aphab_unaided_ec+aphab_unaided_bn+aphab_unaided_rv+aphab_unaided_av+aphab_aided_ec+aphab_aided_bn+aphab_aided_rv+aphab_aided_av,data=all_data)
#summary(alpha_model.2)

#alpha_model.2 <- lm(alpha_power_peakec~aphab_unaided_ec+aphab_unaided_bn+aphab_unaided_rv+aphab_unaided_av+aphab_aided_ec+aphab_aided_bn+aphab_aided_rv+aphab_aided_av,data=all_data)
#summary(alpha_model.2)

#alpha_model.2 <- lm(alpha_power_peak_ratio~aphab_unaided_ec+aphab_unaided_bn+aphab_unaided_rv+aphab_unaided_av+aphab_aided_ec+aphab_aided_bn+aphab_aided_rv+aphab_aided_av,data=all_data)
#summary(alpha_model.2)


#alpha_model.2 <- lm(alpha_power_peak_ratio~aphab_unaided_002+aphab_unaided_003+aphab_unaided_004+aphab_unaided_005+aphab_unaided_006+aphab_unaided_007 +aphab_unaided_008+aphab_unaided_009+aphab_unaided_010+aphab_unaided_011+aphab_unaided_012+aphab_unaided_013+aphab_unaided_014+aphab_unaided_015+aphab_unaided_016+aphab_unaided_017+aphab_unaided_018+aphab_unaided_019+aphab_unaided_020+aphab_unaided_021+aphab_unaided_022+aphab_unaided_023+aphab_unaided_024,data=all_data)
#summary(alpha_model.2)

#alpha_model.2 <- lm(alpha_powereo~aphab_unaided_006+aphab_unaided_007+aphab_unaided_019,data=aphab)
#summary(alpha_model.2)

#alpha_model.2 <- lm(alpha_power_peakec~aphab_aided_006+aphab_aided_016,data=aphab)
#summary(alpha_model.2)

#alpha_model.2 <- lm(alpha_power_peakeo~aphab_aided_006+aphab_aided_016,data=aphab)
#summary(alpha_model.2)
#vif(alpha_model.2)

#alpha_model.2 <- lm(alpha_power_peak_ratio~aphab_aided_001+aphab_aided_005+aphab_aided_006+aphab_aided_007+aphab_aided_011+aphab_aided_016+aphab_aided_019+aphab_aided_024,data=aphab)
#summary(alpha_model.2)

#alpha_model.2 <- lm(alpha_powereo~aphab_aided_006+aphab_aided_016,data=aphab)
#summary(alpha_model.2)

#alpha_model.2 <- lm(alpha_powereo~aphab_aided_006+aphab_aided_016,data=aphab)
#summary(alpha_model.2)

#alpha_model.2 <- lm(alpha_powerec~aphab_aided_006+aphab_aided_016,data=aphab)
#summary(alpha_model.2)

#alpha_model.2 <- lm(alpha_powereo~aphab_unaided_006+aphab_unaided_016,data=aphab)
#summary(alpha_model.2)

#alpha_model.2 <- lm(alpha_powerec~aphab_unaided_006+aphab_unaided_016,data=aphab)
#summary(alpha_model.2)

#SSQ Modeling


#alpha_model.3 <- lm(alpha_power_peak_ratio~ssq12_response_001+ssq12_response_002+ssq12_response_003+ssq12_response_004+ssq12_response_005+ssq12_response_006+ssq12_response_007+ssq12_response_008+ssq12_response_009+ssq12_response_010+ssq12_response_011+ssq12_response_012+ssq12_score,data=all_data)
#summary(alpha_model.3)

#alpha_model.3 <- lm(alpha_power_peak_ratio~ssq12_response_001+ssq12_response_002+ssq12_response_003+ssq12_response_008+ssq12_response_009+ssq12_response_011,data=all_data)
#summary(alpha_model.3)

#alpha_model.3 <- lm(alpha_power_peak_ratio~ssq12_response_002+ssq12_response_003+ssq12_response_008,data=all_data)
#summary(alpha_model.3)


#alpha_model.4 <- lm(alpha_power_peakeo~ssq12_response_001+ssq12_response_002+ssq12_response_003+ssq12_response_004+ssq12_response_005+ssq12_response_008+ssq12_response_009+ssq12_response_010+ssq12_response_011+ssq12_response_012+ssq12_score,data=all_data)
#summary(alpha_model.4)

#alpha_model.5 <- lm(alpha_power_peakec~ssq12_response_001+ssq12_response_002+ssq12_response_003+ssq12_response_004+ssq12_response_005+ssq12_response_006+ssq12_response_007+ssq12_response_008+ssq12_response_009+ssq12_response_010+ssq12_response_011+ssq12_response_012+ssq12_score,data=all_data)
#summary(alpha_model.5)

#alpha_model.6 <- lm(alpha_powerec~ssq12_response_001+ssq12_response_002+ssq12_response_003+ssq12_response_004+ssq12_response_005+ssq12_response_006+ssq12_response_007+ssq12_response_008+ssq12_response_009+ssq12_response_010+ssq12_response_011+ssq12_response_012+ssq12_score,data=all_data)
#summary(alpha_model.6)

#alpha_model.7 <- lm(alpha_powereo~ssq12_response_001+ssq12_response_002+ssq12_response_003+ssq12_response_004+ssq12_response_005+ssq12_response_006+ssq12_response_007+ssq12_response_008+ssq12_response_009+ssq12_response_010+ssq12_response_011+ssq12_response_012+ssq12_score,data=all_data)
#summary(alpha_model.7)

###Beginning model

#alpha_model.8 <- lm(alpha_peak_ERP_occ~alpha_power_peak_ratio+alpha_peakeo+alpha_peakec+snr80_psycho+snr50_psycho+aud+SSQ1+SSQ2+SSQ3+aphab_unaided_ec+aphab_unaided_bn+aphab_unaided_rv+aphab_unaided_av+aphab_aided_ec+aphab_aided_bn+aphab_aided_rv+aphab_aided_av+hint_srt_spshn_perceptual,data=all_data)
#summary(alpha_model.8)


##### Current most interesting model
#alpha_model.8 <- lm(alpha_peak_ERP_occ~snr80_psycho+snr50_psycho+aud+aphab_unaided_bn+aphab_unaided_rv+aphab_unaided_av+aphab_aided_ec+hint_srt_spshn_perceptual,data=all_data)
#summary(alpha_model.8)

#alpha_model.8 <- lm(alpha_peak_ERP_occ~snr80_psycho+snr50_psycho+aud+SSQ1+SSQ2+SSQ3+aphab_unaided_ec+aphab_unaided_bn+aphab_unaided_rv+aphab_unaided_av+aphab_aided_ec+aphab_aided_bn+aphab_aided_rv+aphab_aided_av+hint_srt_spshn_perceptual,data=all_data)
#summary(alpha_model.8)

#alpha_model.8 <- lm(alpha_peak_ERP_occ~alpha_power_peak_ratio+alpha_peakec+alpha_peakeo+snr80_psycho+snr50_psycho+aud+SSQ1+SSQ2+SSQ3+aphab_unaided_ec+aphab_unaided_bn+aphab_unaided_rv+aphab_unaided_av+aphab_aided_ec+aphab_aided_bn+aphab_aided_rv+aphab_aided_av+hint_srt_spshn_perceptual,data=all_data)
#summary(alpha_model.8)

#alpha_model.8 <- lm(alpha_power_peak_ratio~alpha_peak_ERP_occ+snr80_psycho+snr50_psycho+aud+SSQ1+SSQ2+SSQ3+aphab_unaided_ec+aphab_unaided_bn+aphab_unaided_rv+aphab_unaided_av+aphab_aided_ec+aphab_aided_bn+aphab_aided_rv+aphab_aided_av+hint_srt_spshn_perceptual,data=all_data)
#summary(alpha_model.8)

#plot(all_data$alpha_peak_ERP_occ,all_data$hint_srt_spshn_perceptual)




#cor.test(alpha_data[,"alpha_powereo"],alpha_data[,'snr50_psycho'],method='pearson')
#cor.test(alpha_data[,"alpha_powereo"],alpha_data[,'snr80_psycho'],method='pearson')
#cor.test(alpha_data[,"alpha_powerec"],alpha_data[,'snr50_psycho'],method='pearson')
#cor.test(alpha_data[,"alpha_powerec"],alpha_data[,'snr80_psycho'],method='pearson')
#cor.test(alpha_power_peakeo,alpha_data$snr50_psycho)
#cor.test(alpha_power_peakeo,alpha_data$snr80_psycho)
#cor.test(alpha_power_peakeo,data$hint_srt_ists_snr80)
#cor.test(alpha_power_peakeo,data$doso_global)
#cor.test(alpha_power_peakec,data$doso_global)
#cor.test(alpha_power_peakeo,data$aphab_unaided_global)

#cor.test(alpha_power_peakeo,data$sadl_pe)
#cor.test(alpha_power_peakec,data$sadl_pe)
#cor.test(alpha_power_peakeo,data$sadl_gl)
#cor.test(alpha_power_peakeo,data$sadl_sc)
#cor.test(alpha_power_peakeo,data$aldq_demand,method='spearman')
#cor.test(alpha_power_peakeo,data$anl_anl_sess01)
#cor.test(alpha_power_peakec,data$anl_anl_sess01)
#cor.test(alpha_power_peakeo,data$mlst_pct_av_aid_ists_75_0)
#cor.test(alpha_power_peakeo,data$dosoa_le)
#cor.test(alpha_power_peakec,data$dosoa_le)

#plot(alpha_data$alpha_powerec,alpha_data$snr80_psycho)
#plot(alpha_data$alpha_powereo,alpha_data$snr80_psycho)
#plot(alpha_data$alpha_powereo,alpha_data$snr50_psycho)
#plot(alpha_data$alpha_powerec,alpha_data$snr50_psycho)
#plot(alpha_data$ratio,alpha_data$snr80_psycho)
#plot(alpha_data$ratio,alpha_data$snr50_psycho)

#Alpha_power_peak plots
# Create list of variables to plot
#plot_x <- data.frame(alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec, alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec, alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec, alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec, alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec, alpha_power_peakec,alpha_power_peakec, alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakec,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peakeo,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio,alpha_power_peak_ratio)

#plot_y <- data.frame(alpha_data$snr80_psycho,alpha_data$snr50_psycho,data$doso_global, data$dosoa_sc,data$dosoa_le,data$dosoa_pl,data$dosoa_qu,data$dosoa_co,data$dosoa_us,data$hhie_unaided_total,data$hhie_aided_total, data$ssq12_score,data$aphab_unaided_global,data$aphab_aided_global,data$sadl_pe,data$sadl_sc,data$sadl_nf,data$sadl_pi,data$sadl_gl,data$aldq_demand,data$lseq_aided_cl,data$lseq_aided_se,data$lseq_aided_dq,data$lseq_aided_dl,data$lseq_unaided_dl,data$lseq_unaided_cl,data$lseq_unaided_se,data$lseq_unaided_dq,data$uwcpib_unaided_total,data$ANL,data$mlst_pct_av_aid_ists_65_8,data$mlst_pct_a_aid_ists_65_8,data$mlst_pct_a_uaid_ists_65_8,data$mlst_pct_av_uaid_ists_65_8,data$mlst_pct_a_aid_ists_75_0,data$mlst_pct_av_aid_ists_75_0,data$mlst_pct_a_uaid_ists_75_0,data$mlst_pct_av_uaid_ists_75_0,data$mlst_le_a_aid_ists_65_8,data$mlst_le_a_aid_ists_75_0,data$mlst_le_av_aid_ists_65_8,data$mlst_le_av_aid_ists_75_0,data$mlst_le_a_uaid_ists_65_8,data$mlst_le_a_uaid_ists_75_0,data$mlst_le_av_uaid_ists_65_8,data$mlst_le_av_uaid_ists_75_0,data$hint_srt_spshn_perceptual,data$aphab_aided,data$aphab_unaided,alpha_data$snr80_psycho,alpha_data$snr50_psycho,data$doso_global, data$dosoa_sc,data$dosoa_le,data$dosoa_pl,data$dosoa_qu,data$dosoa_co,data$dosoa_us,data$hhie_unaided_total,data$hhie_aided_total, data$ssq12_score,data$aphab_unaided_global,data$aphab_aided_global,data$sadl_pe,data$sadl_sc,data$sadl_nf,data$sadl_pi,data$sadl_gl,data$aldq_demand,data$lseq_aided_cl,data$lseq_aided_se,data$lseq_aided_dq,data$lseq_aided_dl,data$lseq_unaided_dl,data$lseq_unaided_cl,data$lseq_unaided_se,data$lseq_unaided_dq,data$uwcpib_unaided_total,data$ANL,data$mlst_pct_av_aid_ists_65_8,data$mlst_pct_a_aid_ists_65_8,data$mlst_pct_a_uaid_ists_65_8,data$mlst_pct_av_uaid_ists_65_8,data$mlst_pct_a_aid_ists_75_0,data$mlst_pct_av_aid_ists_75_0,data$mlst_pct_a_uaid_ists_75_0,data$mlst_pct_av_uaid_ists_75_0,data$mlst_le_a_aid_ists_65_8,data$mlst_le_a_aid_ists_75_0,data$mlst_le_av_aid_ists_65_8,data$mlst_le_av_aid_ists_75_0,data$mlst_le_a_uaid_ists_65_8,data$mlst_le_a_uaid_ists_75_0,data$mlst_le_av_uaid_ists_65_8,data$mlst_le_av_uaid_ists_75_0,data$hint_srt_spshn_perceptual,data$aphab_aided,data$aphab_unaided,alpha_data$snr80_psycho,alpha_data$snr50_psycho,data$doso_global, data$dosoa_sc,data$dosoa_le,data$dosoa_pl,data$dosoa_qu,data$dosoa_co,data$dosoa_us,data$hhie_unaided_total,data$hhie_aided_total, data$ssq12_score,data$aphab_unaided_global,data$aphab_aided_global,data$sadl_pe,data$sadl_sc,data$sadl_nf,data$sadl_pi,data$sadl_gl,data$aldq_demand,data$lseq_aided_cl,data$lseq_aided_se,data$lseq_aided_dq,data$lseq_aided_dl,data$lseq_unaided_dl,data$lseq_unaided_cl,data$lseq_unaided_se,data$lseq_unaided_dq,data$uwcpib_unaided_total,data$ANL,data$mlst_pct_av_aid_ists_65_8,data$mlst_pct_a_aid_ists_65_8,data$mlst_pct_a_uaid_ists_65_8,data$mlst_pct_av_uaid_ists_65_8,data$mlst_pct_a_aid_ists_75_0,data$mlst_pct_av_aid_ists_75_0,data$mlst_pct_a_uaid_ists_75_0,data$mlst_pct_av_uaid_ists_75_0,data$mlst_le_a_aid_ists_65_8,data$mlst_le_a_aid_ists_75_0,data$mlst_le_av_aid_ists_65_8,data$mlst_le_av_aid_ists_75_0,data$mlst_le_a_uaid_ists_65_8,data$mlst_le_a_uaid_ists_75_0,data$mlst_le_av_uaid_ists_65_8,data$mlst_le_av_uaid_ists_75_0,data$hint_srt_spshn_perceptual,data$aphab_aided,data$aphab_unaided)

#plot_variables <- list(plot_x,plot_y)

# Function to plot variables
#plot_f <- function(x,y){
  #  plot(x,y, col=rainbow(26), pch=18, xlab=colnames(plot_variables[[1]])[i],ylab=colnames(plot_variables[[2]])[i])
  #  text(x,y+.02*max(y,na.rm=TRUE),labels=alpha_data$subid,cex=0.5)
  #  text(.9*max(x,na.rm=TRUE),.9*max(y,na.rm=TRUE),paste('R2=',round(cor.test(x,y)[[4]],digits=8)))
  #  text(.9*max(x,na.rm=TRUE),.8*max(y,na.rm=TRUE),paste('p=',round(cor.test(x,y)[[3]], digits=8)))   
    
#}

#par(mfrow=c(2,2))
#for (i in 1:length(plot_variables[[1]])){
 #   plot_f(plot_variables[[1]][,i],plot_variables[[2]][,i])
    
#}

#plot(alpha_power_peakec,data$age, col=1:26, pch=18)
#plot(alpha_power_peakeo,data$age, col=1:26, pch=18)
#cor.test(alpha_power_peakec,data$age)
#cor.test(alpha_power_peakeo,data$age)

#plot(alpha_power_peakec,data$aud, col=1:26, pch=18)
#plot(alpha_power_peakeo,data$aud, col=1:26, pch=18)
#cor.test(alpha_power_peakec,data$aud)
#cor.test(alpha_power_peakeo,data$aud)
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
#model <- lm(SNR_thres$snr80_psycho~alpha_power_peakeo)
#model <- lm(SNR_thres$snr80_psycho~alpha_power_peakeo+alpha_power_peakec)
#model <- lm(alpha_power_peakeo~data$hhie_aided_total+data$lseq_unaided_cl+data$doso_global+data$dosoa_pl+data$sadl_pe+data$sadl_gl+data$hint_srt_spshn_perceptual)
#model <- lm(alpha_power_peakeo~data$sadl_gl)

#model <- lm(SNR_thres$snr50_psycho~alpha_power_peakec+alpha_power_peakeo+all_data$ratio+data$hhie_aided_total+data$lseq_unaided_cl+data$doso_global+data$dosoa_pl+data$sadl_pe+data$sadl_gl+data$hint_srt_spshn_perceptual)
#model <- lm(alpha_power_peakeo~SNR_thres$snr50_psycho+SNR_thres$snr80_psycho+data$hhie_aided_total+data$lseq_unaided_cl+data$doso_global+data$dosoa_pl+data$sadl_pe+data$sadl_gl+data$hint_srt_spshn_perceptual+all_data$ssq12_response_003+all_data$ssq12_response_008)

#model <- lm(alpha_power_peakeo~ all_data$ssq12_response_011+all_data$ssq12_response_007+ all_data$ssq12_response_008)
#model <- lm(alpha_power_peakeo~ all_data$ssq12_response_001+all_data$ssq12_response_002+ all_data$ssq12_response_005+all_data$ssq12_response_008)


#cor.test(all_data$ssq12_response_008,all_data$ssq12_response_006)
#summary(model)


# Analysis 3-30-2018

##Resting state Alpha power
#Beginning model
# Alpha peak eyes open 
alpha_model.8 <- lm(alpha_peakeo~snr80_psycho+snr50_psycho+aud+SSQ1+SSQ2+SSQ3+aphab_unaided_ec+aphab_unaided_bn+aphab_unaided_rv+aphab_unaided_av+aphab_aided_ec+aphab_aided_bn+aphab_aided_rv+aphab_aided_av+hint_srt_spshn_perceptual,data=all_data)
summary(alpha_model.8)

cor.test(all_data$alpha_peakeo,all_data$snr80_psycho)
plot(all_data$alpha_peakeo,all_data$snr80_psycho)

# Backward model selection
alpha_model.8 <- lm(alpha_peakeo~snr80_psycho+aud+SSQ1+SSQ2+SSQ3+hint_srt_spshn_perceptual,data=all_data)
summary(alpha_model.8)

# Alpha peak eyes closed
alpha_model.8 <- lm(alpha_peakec~snr80_psycho+aud+SSQ1+SSQ2+SSQ3+aphab_unaided_ec+aphab_unaided_bn+aphab_unaided_rv+aphab_unaided_av+aphab_aided_ec+aphab_aided_bn+aphab_aided_rv+aphab_aided_av+hint_srt_spshn_perceptual,data=all_data)
summary(alpha_model.8)
cor.test(all_data$alpha_peakec,all_data$snr80_psycho)
plot(all_data$alpha_peakec,all_data$snr80_psycho)

# Backward model selection
alpha_model.8 <- lm(alpha_peakec~snr80_psycho+aud+hint_srt_spshn_perceptual,data=all_data)
summary(alpha_model.8)

alpha_model.8 <- lm(alpha_power_peak_ratio~snr80_psycho+aud+SSQ1+SSQ2+SSQ3+aphab_unaided_ec+aphab_unaided_bn+aphab_unaided_rv+aphab_unaided_av+aphab_aided_ec+aphab_aided_bn+aphab_aided_rv+aphab_aided_av+hint_srt_spshn_perceptual,data=all_data)
summary(alpha_model.8)



## Alpha power during ERP
# Behavioral Measures
#Beginning model

alpha_model.8 <- lm(alpha_peak_ERP_occ~alpha_power_peak_ratio+alpha_peakeo+alpha_peakec+snr80_psycho+snr50_psycho+aud+SSQ1+SSQ2+SSQ3+aphab_unaided_ec+aphab_unaided_bn+aphab_unaided_rv+aphab_unaided_av+aphab_aided_ec+aphab_aided_bn+aphab_aided_rv+aphab_aided_av+hint_srt_spshn_perceptual,data=all_data)
summary(alpha_model.8)

# Backward model selection
alpha_model.8 <- lm(alpha_peak_ERP_occ~alpha_peakeo+snr50_psycho+aud+SSQ1+aphab_unaided_ec+aphab_unaided_bn+aphab_unaided_rv+aphab_unaided_av+aphab_aided_ec+aphab_aided_rv+hint_srt_spshn_perceptual,data=all_data)
summary(alpha_model.8)

##### Current most interesting model

alpha_model.8 <- lm(alpha_peak_ERP_occ~alpha_power_peak_ratio+snr50_psycho+aud+aphab_unaided_bn+aphab_unaided_rv+aphab_aided_ec,data=all_data)
summary(alpha_model.8)

plot(all_data$alpha_peak_ERP_occ,all_data$snr50_psycho)
plot(all_data$alpha_peak_ERP_occ,all_data$snr80_psycho)
plot(all_data$alpha_peak_ERP_occ,all_data$aud)
plot(all_data$alpha_peak_ERP_occ,all_data$aphad_aided_ec)

## Alpha power during ERP compared to self-report measures

alpha_model.8 <- lm(alpha_peak_ERP_occ~doso_global+dosoa_sc+dosoa_le+dosoa_pl+dosoa_qu+dosoa_co+dosoa_us+hhie_unaided_total+hhie_aided_total+ssq12_score+aphab_unaided_global+aphab_aided_global+sadl_pe+sadl_sc+sadl_nf+sadl_pi+sadl_gl+aldq_demand+lseq_aided_cl+lseq_aided_se+lseq_aided_dq+lseq_unaided_dl+lseq_unaided_cl+lseq_unaided_se+lseq_unaided_dq+aphab_unaided_ec+aphab_unaided_bn+aphab_unaided_rv+aphab_unaided_av+aphab_aided_ec+aphab_aided_rv,data=all_data)
summary(alpha_model.8)

#Backward Model Selection

alpha_model.8 <- lm(alpha_peak_ERP_occ~doso_global+dosoa_sc+dosoa_le+dosoa_pl+dosoa_qu+dosoa_co+dosoa_us+hhie_unaided_total+hhie_aided_total+ssq12_score+sadl_pe+sadl_sc+sadl_nf+sadl_pi+sadl_gl+aldq_demand+lseq_aided_cl+lseq_aided_se+lseq_aided_dq+lseq_unaided_dl+lseq_unaided_cl+lseq_unaided_se+lseq_unaided_dq+aphab_unaided_global+aphab_aided_global,data=all_data)
summary(alpha_model.8)

# Model testing

alpha_model.1 <- lm(alpha_peak_ERP_occ~doso_global+dosoa_co+ssq12_score+aphab_unaided_global+aphab_aided_global+sadl_pe+sadl_nf+sadl_pi+aldq_demand,data=all_data)
summary(alpha_model.1)

#Current best model
alpha_model.1 <- lm(alpha_peak_ERP_occ~doso_global+dosoa_co+ssq12_score++sadl_pe+sadl_nf+sadl_pi+aldq_demand+aphab_unaided_ec+aphab_unaided_bn+aphab_unaided_rv+aphab_unaided_av+aphab_aided_ec+aphab_aided_rv+aphab_aided_bn+aphab_aided_av,data=all_data)
summary(alpha_model.1)
vif(alpha_model.1)

# Alpha power during ERP compared to behavioral and self-report measures

alpha_model.2 <- lm(alpha_peak_ERP_occ~alpha_peakeo+alpha_peakec+snr80_psycho+snr50_psycho+aud+SSQ1+SSQ2+SSQ3+hint_srt_spshn_perceptual+doso_global+hhie_unaided_total+hhie_aided_total+sadl_gl+aldq_demand+lseq_aided_cl+lseq_aided_se+lseq_aided_dq+lseq_unaided_dl+lseq_unaided_cl+lseq_unaided_se+lseq_unaided_dq+aphab_unaided_global+aphab_aided_global,data=all_data)
summary(alpha_model.2)

# Backward Model Selection

alpha_model.2 <- lm(alpha_peak_ERP_occ~alpha_peakeo+snr80_psycho+aud+SSQ1+SSQ2+SSQ3+hint_srt_spshn_perceptual+doso_global+hhie_aided_total+sadl_gl+aldq_demand+lseq_aided_cl+lseq_aided_se+lseq_aided_dq+lseq_unaided_dl+lseq_unaided_cl+lseq_unaided_se+lseq_unaided_dq+aphab_unaided_global+aphab_aided_global,data=all_data)
summary(alpha_model.2)

# Multicollinearity selection VIF >5

alpha_model.2 <- lm(alpha_peak_ERP_occ~snr80_psycho+doso_global+aldq_demand+aphab_aided_global,data=all_data)
summary(alpha_model.2)
vif(alpha_model.2)

#Forward Selection

alpha_model.2 <- lm(alpha_peak_ERP_occ~snr50_psycho+aud+aphab_aided_global+aldq_demand,data=all_data)
summary(alpha_model.2)

alpha_model.2 <- lm(alpha_peak_ERP_occ~snr50_psycho+aud+aphab_aided_ec+aldq_demand,data=all_data)
summary(alpha_model.2)

##### Current best model #####
alpha_model.2 <- lm(alpha_peak_ERP_occ~snr50_psycho+aud+aphab_aided_global+aldq_demand,data=all_data)
summary(alpha_model.2)



plot(all_data$alpha_peak_ERP_occ,all_data$snr50_psycho)
abline(lm(all_data$snr50_psycho~all_data$alpha_peak_ERP_occ))

plot(all_data$alpha_peak_ERP_occ,all_data$snr80_psycho)
abline(lm(all_data$snr80_psycho~all_data$alpha_peak_ERP_occ))

plot(all_data$alpha_peak_ERP_occ,all_data$aud)
abline(lm(all_data$aud~all_data$alpha_peak_ERP_occ))

plot(all_data$alpha_peak_ERP_occ,all_data$aphad_aided_global)
abline(lm(all_data$aphab_aided_global~all_data$alpha_peak_ERP_occ))


plot(all_data$alpha_peak_ERP_occ,all_data$aldq_demand)
abline(lm(all_data$aldq_demand~all_data$alpha_peak_ERP_occ))

# Occipital 
#Beginning model
alpha_model.8 <- lm(alpha_peak_ERP_occ~snr50_psycho+aud+aphab_unaided_bn+aphab_unaided_rv+aphab_aided_ec,data=all_data)
summary(alpha_model.8)

# Occipital and parietal lobes 
##### Current most interesting model
alpha_model.2 <- lm(alpha_peak_ERP_occ~alpha_power_peak_ratio+aud+aphab_unaided_bn+aphab_unaided_rv+aphab_unaided_av+aphab_aided_ec+hint_srt_spshn_perceptual,data=all_data)
summary(alpha_model.2)

cor.test(all_data$alpha_peak_ERP_occ,all_data$hint_srt_spshn_perceptual)
plot(all_data$alpha_peak_ERP_occ,all_data$hint_srt_spshn_perceptual)

# Alpha power difference between baseline and ERP
alpha_model.1 <- lm(alpha_diff~snr50_psycho+aud+SSQ1+SSQ2+SSQ3+aphab_unaided_ec+aphab_unaided_bn+aphab_unaided_av+aphab_aided_ec+aphab_aided_bn+aphab_aided_av+hint_srt_spshn_perceptual,data=all_data)
summary(alpha_model.1)
