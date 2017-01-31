y <- read.csv(file="C:/Users/cwbishop/Documents/SNR-ERP/data analysis/alphapower_23-Jan-2017.csv")

x <- read.csv(file="E:/Google Drive/Project AE_SNR EEG ERP/Documentation/SNR Subject Key.csv")

sub_id <- y[[1]]

x["subject_id"=sub_id]
x[x$Subject_ID %in% sub_id,]

