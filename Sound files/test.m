
audio=readtable('audiograms.csv')
rows = audio.subject_id==1006

dBHL = audio(rows,:)

dBHL.right_air_conduction_500 
dBHL.right_air_conduction_1000
dBHL.right_air_conduction_2000
dBHL.left_air_conduction_500 
dBHL.left_air_conduction_1000
dBHL.left_air_conduction_2000

PTA_R = (dBHL.right_air_conduction_500 + ...
dBHL.right_air_conduction_1000 ...
+dBHL.right_air_conduction_2000)/3

PTA_L = (dBHL.left_air_conduction_500 + ...
 dBHL.left_air_conduction_1000 ... 
+dBHL.left_air_conduction_2000)/3

PTA_Final = (PTA_R+PTA_L)/2