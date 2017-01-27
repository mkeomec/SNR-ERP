alphapower <- read.csv(file= "C:/Users/cwbishop/Documents/SNR-ERP/data analysis/alphapower_23-Jan-2017.csv",head=TRUE,sep=",")
 
O1_open <- alphapower$O1_AOC_open[-1]
SNR80 <- alphapower$SNR.80..OLD.[-1]
PTA <- alphapower$PTA[-1]
data <- data.frame(O1_open,SNR80,PTA)

alpha.mod= lm (SNR80~O1_open)
summary(alpha.mod)

alpha.mod1= lm (alphapower$SNR.80..OLD.~alphapower$PTA)
summary(alpha.mod1)

alpha.mod2= lm (alphapower$SNR.80..OLD.~alphapower$PTA+alphapower$O1_AOC_open+alphapower$Age)
summary(alpha.mod2)





ggplot(data, aes(x=O1_open,y=SNR80))+ geom_point(size=5, color="red") +geom_smooth(method="lm", size = 2, se=FALSE)

ggplot(data, aes(x=PTA,y=SNR80))+ geom_point(size=5, color="red") +geom_smooth(method="lm", size = 2, se=FALSE)
