
library(ggplot2)
library(car)
alphapower <- read.csv(file= "C:/Users/cwbishop/Documents/SNR-ERP/data analysis/alphapower_Master.csv",head=TRUE,sep=",")

#alphapower <- read.csv(file= "C:/Users/Michael/Documents/GitHub/SNR-ERP/data analysis/alphapower_Master.csv",head=TRUE,sep=",")

alphapower <- alphapower[-1,] #removes 1015 subejct info 

#data <- data.frame(Avg_open,Avg_closed,open_closed.ratio,SNR80,PTA, data=alphapower)

Avg_open <- alphapower$Avg_open
Avg_closed <- alphapower$Avg_closed
open_closed.ratio <- alphapower$Open_closed.ratio
SNR80 <- alphapower$SNR.80..new. 
PTA <- alphapower$PTA
Age <- alphapower$Age

cor.test(alphapower$Avg_open,alphapower$SNR.50..new., method="spearman")
cor.test(alphapower$Avg_closed,alphapower$SNR.50..new., method="spearman")
cor.test(alphapower$Avg_open,alphapower$SNR.50..new., method="pearson")
cor.test(alphapower$Avg_closed,alphapower$SNR.50..new., method="pearson")
cor.test(alphapower$Open_closed.ratio,alphapower$SNR.50..new., method="spearman")
cor.test(alphapower$PTA,alphapower$Age, method="spearman")
cor.test(alphapower$Age,alphapower$SNR.50..new., method="spearman")
cor.test(alphapower$PTA,alphapower$SNR.50..new., method="spearman")
cor.test(alphapower$Open_closed.ratio,alphapower$SNR.50..new., method="spearman")


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


ggplot(alphapower, aes(x=Avg_open,y=SNR.50..new.))+
  geom_point(size=2, color="black") +
  geom_smooth(method="lm", size = 1, se=FALSE)+
  theme(panel.grid.major = element_blank()
        , panel.grid.minor = element_blank()
        , panel.background = element_blank()
        , axis.line = element_line(colour = "black"))
  

ggplot(alphapower, aes(x=Avg_closed,y=SNR.80..new.))+ 
  geom_point(size=2, color="black") +
  geom_smooth(method="lm", size = 1, se=FALSE)+
  theme(panel.grid.major = element_blank()
        , panel.grid.minor = element_blank()
        , panel.background = element_blank()
        , axis.line = element_line(colour = "black"))

ggplot(alphapower, aes(x=Avg_open,y=SNR_50_OLD))+
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

