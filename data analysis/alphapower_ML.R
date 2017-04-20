# Alpha power analysis code. Input from Fieldtrip

library(ggplot2)
library(car)
alphapower <- read.csv(file= "C:/Users/cwbishop/Documents/SNR-ERP/data analysis/alphapower_12-Apr-2017.csv",head=TRUE,sep=",")
SNR <- read.csv(file= "E:/Google Drive/Project AE_SNR EEG ERP/Data/SNR2017-04-12.csv",head=TRUE,sep=",")

#alphapower <- read.csv(file= "E:/Google Drive/Project AE_SNR EEG ERP/Data/SNR2017-04-12.csv",head=TRUE,sep=",")

# Import and filter subject's ages
age_data <- read.csv(file.choose(), header=TRUE)
rownames(age_data) <- age_data$subject_id
subids <- as.character(SNR$sub_id)

#Import audiogram information
audio <- read.csv(file.choose(), header=TRUE)
rownames(audio) <- audio$subject_id
raudio <- rowMeans(audio[subids,c(3,5,7)])
laudio <- rowMeans(audio[subids,c(13,15,17)])

#Combine data into single dataframe
data <- cbind(SNR,age_data[subids,],raudio,laudio)
rownames(data) <- data$sub_id

data <- data[c(-1,-3,-16,-20,-21,-22,-23,-24,-25),] #removes 1015, 1093, and 1096 subject info 
alphapower <- alphapower[c(-1,-3,-16,-20,-21,-22,-23,-24,-25),]
#data <- data.frame(Avg_open,Avg_closed,open_closed.ratio,SNR80,PTA, data=alphapower)
# Set variables
SNR50 <- data[,10]
SNR80 <- data[,11]
Avg_open <- rowMeans(alphapower[,2:7])
Avg_closed <- rowMeans(alphapower[,8:13])
Open_closed.ratio <- Avg_open/Avg_closed


cor.test(Avg_open,SNR50, method="spearman")
cor.test(Avg_open,SNR80, method="spearman")
cor.test(Avg_closed,SNR50, method="spearman")
cor.test(Avg_open,SNR50, method="pearson")
cor.test(Avg_closed,SNR50, method="pearson")
cor.test(Open_closed.ratio,SNR50, method="spearman")
cor.test(alphapower$PTA,alphapower$Age, method="spearman")
cor.test(alphapower$Age,alphapower$SNR.50..new., method="spearman")
cor.test(alphapower$PTA,alphapower$SNR.50..new., method="spearman")
cor.test(alphapower$Open_closed.ratio,alphapower$SNR.50..new., method="spearman")
cor.test(alphapower$PTA,alphapower$Avg_open, method="pearson")
cor.test(alphapower$PTA,alphapower$Avg_closed, method="pearson")
cor.test(alphapower$Age,alphapower$Avg_open, method="pearson")
cor.test(alphapower$Age,alphapower$Avg_closed, method="pearson")
cor.test(alphapower$Age,alphapower$PTA, method="pearson")

cor.test(alphapower$Avg_open,alphapower$SNR.50..new., method="spearman")
cor.test(alphapower$Avg_closed,alphapower$SNR.50..new., method="spearman")
cor.test(alphapower$Open_closed.ratio,alphapower$SNR.50..new., method="spearman")

alpha.mod= lm (SNR80~Avg_open)
summary(alpha.mod)

alpha.mod1= lm (SNR80~PTA)
summary(alpha.mod1)

alpha.mod2= lm (SNR80~PTA+Avg_open+Age)
summary(alpha.mod2)

alpha.mod3= lm (SNR_50_OLD~Avg_open, data=alphapower)
summary(alpha.mod3)

alpha.mod4= lm (snr80_staircase  ~Avg_closed, data=alphapower)
summary(alpha.mod4)

alpha.mod5= lm (SNR80~Avg_closed)
summary(alpha.mod5)

alpha.mod6= lm (SNR.50..new.~open_closed.ratio, data=alphapower)
summary(alpha.mod6)

alpha.mod7= lm (SNR.50..new.~Avg_open, data=alphapower)
summary(alpha.mod7)

alpha.mod8= lm (SNR.50..new.~Avg_open+Avg_closed+PTA+Age+Open_closed.ratio, data=alphapower)
summary(alpha.mod6)

alpha.mod9= lm (SNR.50..new.~Avg_open+Avg_closed+PTA+Age, data=alphapower)
summary(alpha.mod9)

alpha.mod9= lm (SNR.80..new.~Avg_open+Avg_closed, data=alphapower)
summary(alpha.mod9)
vif(alpha.mod9)



cor.test(alphapower$Open_closed.ratio,alphapower$Avg_closed, method="pearson")


ggplot(alphapower, aes(x=Avg_open,y=SNR50))+
  geom_point(size=2, color="black") +
  geom_smooth(method="lm", size = 1, se=FALSE)+
  theme(panel.grid.major = element_blank()
        , panel.grid.minor = element_blank()
        , panel.background = element_blank()
        , axis.line = element_line(colour = "black"))
  

ggplot(alphapower, aes(x=Avg_closed,y=SNR50))+ 
  geom_point(size=2, color="black") +
  geom_smooth(method="lm", size = 1, se=FALSE)+
  theme(panel.grid.major = element_blank()
        , panel.grid.minor = element_blank()
        , panel.background = element_blank()
        , axis.line = element_line(colour = "black"))

ggplot(alphapower, aes(x=Avg_open,y=SNR80))+
  geom_point(size=2, color="black")+
  geom_smooth(method="lm", size = 1, se=FALSE)+
  theme(panel.grid.major = element_blank()
        , panel.grid.minor = element_blank()
        , panel.background = element_blank()
        , axis.line = element_line(colour = "black"))

ggplot(alphapower, aes(x=Avg_closed,y=SNR_50_OLD))+
  geom_point(size=2, color="black")+
  geom_smooth(method="lm", size = 1, se=FALSE)+
  theme(panel.grid.major = element_blank()
        , panel.grid.minor = element_blank()
        , panel.background = element_blank()
        , axis.line = element_line(colour = "black"))

ggplot(alphapower, aes(x=open_closed.ratio,y=SNR_80_OLD))+
  geom_point(size=2, color="black")+
  geom_smooth(method="lm", size = 1, se=FALSE)+
  theme(panel.grid.major = element_blank()
        , panel.grid.minor = element_blank()
        , panel.background = element_blank()
        , axis.line = element_line(colour = "black"))

ggplot(alphapower, aes(x=Avg_open,y=Avg_closed))+
  geom_point(size=2, color="black")+
  geom_smooth(method="lm", size = 1, se=FALSE)+
  theme(panel.grid.major = element_blank()
        , panel.grid.minor = element_blank()
        , panel.background = element_blank()
        , axis.line = element_line(colour = "black"))

ggplot(alphapower, aes(x=Age,y=PTA))+
  geom_point(size=2, color="black")+
  geom_smooth(method="lm", size = 1, se=FALSE)+
  theme(panel.grid.major = element_blank()
        , panel.grid.minor = element_blank()
        , panel.background = element_blank()
        , axis.line = element_line(colour = "black"))

ggplot(alphapower, aes(x=open_closed.ratio,y=Avg_closed))+
    geom_point(size=2, color="black")+
    geom_smooth(method="lm", size = 1, se=FALSE)+
    theme(panel.grid.major = element_blank()
          , panel.grid.minor = element_blank()
          , panel.background = element_blank()
          , axis.line = element_line(colour = "black"))


alpha_sorted=alphapower[order(alphapower$Avg_open),]
alpha_sorted[c("Row","Avg_open")]

