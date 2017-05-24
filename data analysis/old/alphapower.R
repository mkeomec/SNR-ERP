
library(ggplot2)

#alphapower <- read.csv(file= "C:/Users/cwbishop/Documents/SNR-ERP/data analysis/alphapower_Master.csv",head=TRUE,sep=",")

alphapower <- read.csv(file= "C:/Users/Michael/Documents/GitHub/SNR-ERP/data analysis/alphapower_Master.csv",head=TRUE,sep=",")

alphapower <- alphapower[-1,] #removes 1015 subejct info 

#data <- data.frame(Avg_open,Avg_closed,open_closed.ratio,SNR80,PTA, data=alphapower)

Avg_open <- alphapower$Avg_open
Avg_closed <- alphapower$Avg_closed
open_closed.ratio <- alphapower$Open_closed.ratio
SNR80 <- alphapower$SNR_80_OLD
SNR50 <- alphapower$SNR.50..new.
PTA <- alphapower$PTA
Age <- alphapower$Age

cor1 <- cor.test(alphapower$Avg_open,alphapower$SNR.50..new., method="spearman")
cor2 <- cor.test(alphapower$Avg_closed,alphapower$SNR.50..new., method="spearman")
cor3 <- cor.test(alphapower$Open_closed.ratio,alphapower$SNR.50..new., method="spearman")

cor4 <- cor.test(alphapower$Avg_open,alphapower$SNR.80..new., method="spearman")
cor5 <- cor.test(alphapower$Avg_closed,alphapower$SNR.80..new., method="spearman")
cor6 <- cor.test(alphapower$Open_closed.ratio,alphapower$SNR.80..new., method="spearman")

cor7 <- cor.test(alphapower$PTA,alphapower$SNR.50..new., method='spearman')
cor8 <- cor.test(alphapower$Age,alphapower$SNR.50..new., method='spearman')


alpha.mod= lm (SNR80~Avg_open)
summary(alpha.mod)

alpha.mod1= lm (SNR80~PTA)
summary(alpha.mod1)

alpha.mod2= lm (SNR80~PTA+Avg_open+Age)
summary(alpha.mod2)

alpha.mod3= lm (SNR_50_OLD~Avg_open, data=alphapower)
summary(alpha.mod3)

alpha.mod4= lm (SNR_80_OLD~open_closed.ratio, data=alphapower)
summary(alpha.mod4)

alpha.mod5= lm(SNR50~PTA)
summary(alpha.mod5)

alpha.mod6= lm(SNR50~Age)
summary(alpha.mod6)

ggplot(alphapower, aes(x=Avg_open,y=SNR.50..new.)) +
    geom_point(size=2, color="black") +
    geom_smooth(method="lm", size = 1, se=FALSE) +
    annotate("text",label="p == 0.02",parse=TRUE,x=0.35,y=13) +
    annotate("text",label="r^2 == 0.38",parse=TRUE,x=0.35,y=12) +
    labs(x="Alpha Power (power*Hz)",y="SNR-50 (dB)") +
    theme(panel.grid.major = element_blank()
          , panel.grid.minor = element_blank()
          , panel.background = element_blank()
          , axis.line = element_line(colour = "black"))

ggplot(alphapower,aes(x=PTA,y=SNR.50..new.)) +
    geom_point(size=2, color="black") +
    geom_smooth(method="lm", size = 1, se=FALSE) +
    annotate("text",label="p == 0.09",parse=TRUE,x=40.2,y=13) +
    annotate("text",label="r^2 == 0.20",parse=TRUE,x=40.2,y=12) +
    labs(x="Pure Tone Average",y="SNR-50 (dB)") +
    theme(panel.grid.major = element_blank()
        , panel.grid.minor = element_blank()
        , panel.background = element_blank()
        , axis.line = element_line(colour = "black"))
  
ggplot(alphapower,aes(x=Age,y=SNR.50..new.))+
    geom_point(size=2, color="black") +
    geom_smooth(method="lm", size = 1, se=FALSE) +
    annotate("text",label="p == 0.21",parse=TRUE,x=80,y=13) +
    annotate("text",label="r^2 == 0.15",parse=TRUE,x=80,y=12) +
    labs(x="Age (years)",y="SNR-50 (dB)") +
    theme(panel.grid.major = element_blank()
        , panel.grid.minor = element_blank()
        , panel.background = element_blank()
        , axis.line = element_line(colour = "black"))

ggplot(alphapower, aes(x=Avg_closed,y=SNR.50..new.)) +
  geom_point(size=2, color="black") +
  geom_smooth(method="lm", size = 1, se=FALSE) +
  annotate("text",label="p == 0.25",parse=TRUE,x=0.7,y=13) +
  annotate("text",label="r^2 == 0.1",parse=TRUE,x=0.7,y=12) +
  labs(x="Alpha Power (power*Hz)",y="SNR-50 (dB)") +
  theme(panel.grid.major = element_blank()
        , panel.grid.minor = element_blank()
        , panel.background = element_blank()
        , axis.line = element_line(colour = "black"))

ggplot(alphapower, aes(x=Avg_open,y=SNR_80_OLD)) +
  geom_point(size=2, color="black") +
  geom_smooth(method="lm", size = 1, se=FALSE) +
  theme(panel.grid.major = element_blank()
        , panel.grid.minor = element_blank()
        , panel.background = element_blank()
        , axis.line = element_line(colour = "black"))
  

ggplot(alphapower, aes(x=Avg_closed,y=SNR_80_OLD)) + 
  geom_point(size=2, color="black") +
  geom_smooth(method="lm", size = 1, se=FALSE) +
  theme(panel.grid.major = element_blank()
        , panel.grid.minor = element_blank()
        , panel.background = element_blank()
        , axis.line = element_line(colour = "black"))

ggplot(alphapower, aes(x=Avg_open,y=SNR_50_OLD)) +
  geom_point(size=2, color="black") +
  geom_smooth(method="lm", size = 1, se=FALSE) +
  theme(panel.grid.major = element_blank()
        , panel.grid.minor = element_blank()
        , panel.background = element_blank()
        , axis.line = element_line(colour = "black"))

ggplot(alphapower, aes(x=Avg_closed,y=SNR_50_OLD)) +
  geom_point(size=2, color="black") +
  geom_smooth(method="lm", size = 1, se=FALSE) +
  theme(panel.grid.major = element_blank()
        , panel.grid.minor = element_blank()
        , panel.background = element_blank()
        , axis.line = element_line(colour = "black"))

ggplot(alphapower, aes(x=open_closed.ratio,y=SNR_80_OLD)) +
  geom_point(size=2, color="black") +
  geom_smooth(method="lm", size = 1, se=FALSE) +
  theme(panel.grid.major = element_blank()
        , panel.grid.minor = element_blank()
        , panel.background = element_blank()
        , axis.line = element_line(colour = "black"))

ggplot(alphapower, aes(x=Avg_open,y=Avg_closed)) +
  geom_point(size=2, color="black") +
  geom_smooth(method="lm", size = 1, se=FALSE) +
  theme(panel.grid.major = element_blank()
        , panel.grid.minor = element_blank()
        , panel.background = element_blank()
        , axis.line = element_line(colour = "black"))

ggplot(alphapower, aes(x=PTA,y=SNR_80_OLD)) +
  geom_point(size=2, color="black") +
  geom_smooth(method="lm", size = 1, se=FALSE) +
  theme(panel.grid.major = element_blank()
        , panel.grid.minor = element_blank()
        , panel.background = element_blank()
        , axis.line = element_line(colour = "black"))

ggplot(alphapower, aes(x=PTA,y=SNR_50_OLD)) +
  geom_point(size=2, color="black") +
  geom_smooth(method="lm", size = 1, se=FALSE) +
  theme(panel.grid.major = element_blank()
        , panel.grid.minor = element_blank()
        , panel.background = element_blank()
        , axis.line = element_line(colour = "black"))


alpha_sorted=alphapower[order(alphapower$Avg_open),]
alpha_sorted[c("Row","Avg_open")]

