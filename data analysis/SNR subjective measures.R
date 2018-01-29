## EXPLORE SNR subjective measures

redcap_data <- read.csv('C:/Users/cwbishop/Documents/SNR-ERP/data analysis/HASNR_DATA_2018-01-08_1630.csv')

# Look at IOI #7
redcap_data['ioiha_response_007']
table(redcap_data['ioiha_response_007'])
barplot(table(ioi_data['ioiha_response_007']))

# ALDQ
aldq_table <- table(redcap_data['aldq_demand'])
plot(table(redcap_data['aldq_demand']))
plot(redcap_data['aldq_demand'])

# APHAB


# Combine subjective measures
plot((redcap_data[,'ioiha_response_007']),redcap_data[,'aldq_demand'])

'aphab_unaided_001','aphab_aided_001','aphab_unaided_005','aphab_aided_005','aphab_unaided_006','aphab_aided_006','aphab_unaided_007','aphab_aided_007','aphab_unaided_011','aphab_aided_011','aphab_unaided_016','aphab_aided_016','aphab_unaided_019','aphab_aided_019','aphab_unaided_024','aphab_aided_024'
