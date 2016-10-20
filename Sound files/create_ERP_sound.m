function create_ERP_sound(subid)

% This function receives audiogram information and outputs appropriate
% sound files for the SNR-ERP study, Project AE. Sound intensity is
% calculated based on 30 db above PTA db HL converted to db SPL

% TO DO: Automatically import audiogram information from spreadsheet so
% "audiogram" input will not be necessary
% 
% Inputs:
%  1. subid = 4-digit Subject ID for SNR and SNR-ERP study. UW site
%             subjects begin with 1. MUST ENTER AS STRING
%  2. transducer = Enter type of tranducer (1= TDH-50, 2= ER4)


% Table of Contents:
% 1. Import sound files
% 2. Calculate PTA
% 3. Add 30 db and convert to SPL
% 4. Create sound stimuli
% 5. Create Sound Stimuli
% 6. Create Noise Stimuli

% 0. Import audiogram


audio=readtable('audiograms.csv');
rows = audio.subject_id==subid;
audiogram=audio(rows,:);
audiogram=[audiogram.right_air_conduction_500 audiogram.right_air_conduction_1000 audiogram.right_air_conduction_2000 audiogram.left_air_conduction_500 audiogram.left_air_conduction_1000 audiogram.left_air_conduction_2000]
transducer=audio.Transducer (rows,:)
transducer=transducer{1}
% 1. Import sound files

noise65db=audioread('Noise65.wav');
stim65db=audioread('stim65.wav');

% 2. Calculate pure tone average (PTA)
%  Average 
PTA=mean(mean(audiogram,2))

% 3. Add 30 db HL and convert to SPL for frequency 1000 Hz
PTA30=PTA+30

switch transducer
    case 'TDH-50'
        SPL30=PTA30+7.5
    
    case 'ER3'
        SPL30=PTA30   
        
    case 'Headphones'
        SPL30=PTA30+7.5
        
end

% 4. Create sound stimuli 
stim=stim65db*(db2amp(SPL30-65));

% 5. Create Noise stimuli
noiseSNR_5=noise65db*(db2amp(SPL30-60));
noiseSNR0=noise65db*(db2amp(SPL30-65));
noiseSNR5=noise65db*(db2amp(SPL30-70));
noiseSNR10=noise65db*(db2amp(SPL30-75));
noiseSNR15=noise65db*(db2amp(SPL30-80));

% 6. Output sound files
subjectid=num2str(subid)
audiowrite(strcat(subjectid,'stim.wav'),stim65db,10000)
audiowrite(strcat(subjectid,'SNRnoise_5.wav'),noiseSNR_5,44100)
audiowrite(strcat(subjectid,'SNRnoise0.wav'),noiseSNR0,44100)
audiowrite(strcat(subjectid,'SNRnoise5.wav'),noiseSNR5,44100)
audiowrite(strcat(subjectid,'SNRnoise10.wav'),noiseSNR10,44100)
audiowrite(strcat(subjectid,'SNRnoise15.wav'),noiseSNR15,44100)