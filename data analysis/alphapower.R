alphapower <- read.csv(file= "C:/Users/cwbishop/Documents/SNR-ERP/data analysis/alphapower_Master.csv",head=TRUE,sep=",")

alphapower <- alphapower[-1,] 

#data <- data.frame(Avg_open,Avg_closed,open_closed.ratio,SNR80,PTA, data=alphapower)

Avg_open <- alphapower$Avg_open
Avg_closed <- alphapower$Avg_closed
open_closed.ratio <- alphapower$Open_closed.ratio
SNR80 <- alphapower$SNR_80_OLD
PTA <- alphapower$PTA
Age <- alphapower$Age

alpha.mod= lm (SNR80~Avg_open)
summary(alpha.mod)

alpha.mod1= lm (SNR80~PTA)
summary(alpha.mod1)

alpha.mod2= lm (SNR80~PTA+Avg_open+Age)
summary(alpha.mod2)





ggplot(alphapower, aes(x=Avg_open,y=SNR_80_OLD))+ geom_point(size=5, color="red") +geom_smooth(method="lm", size = 2, se=FALSE)

ggplot(alphapower, aes(x=PTA,y=SNR_80_OLD))+ geom_point(size=5, color="red") +geom_smooth(method="lm", size = 2, se=FALSE)

alpha_sorted=alphapower[order(alphapower$Avg_open),]
alpha_sorted[c("Row","Avg_open")]
