#y <- read.csv(file="C:/Users/cwbishop/Documents/SNR-ERP/data analysis/alphapower_23-Jan-2017.csv")

y <- read.csv(file="C:/Users/Michael/Documents/GitHub/SNR-ERP/data analysis/alphapower_23-Jan-2017.csv")

#x <- read.csv(file="E:/Google Drive/Project AE_SNR EEG ERP/Documentation/SNR Subject Key.csv")

x <- read.csv(file="C:/Users/Michael/Google Drive/Project AE_SNR EEG ERP/Documentation/SNR Subject Key.csv")

sub_id <- y[[1]]


sub_id_PTA <- x[x$Subject_ID %in% sub_id,]

x$Subject_ID %in% sub_id

for(i in 1:length(sub_id)){
  if (sub_id[i] %in% x$Subject_ID) {
    y$PTA_Code[y$subject_id==sub_id[i]]<- x[x$Subject_ID == sub_id[i],"PTA"]} 
  }


library(xlsx)
write.xlsx(sub_id_PTA,file = "C:/Users/Michael/Documents/AuD/Year 1/BnBLab/AAS Conference 2017/R/pta_values.xlsx")

