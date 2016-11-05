function preprocess

% Function to preprocess EEG Neuroscan data for spectral analysis

% Load data into EEGLAB
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG = pop_loadcnt('E:\Google Drive\Project AE_SNR EEG ERP\Data\1016\1016_AAT_09_30_2016.cnt' , 'dataformat', 'auto', 'memmapfile', '');
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'gui','off'); 
EEG = eeg_checkset( EEG );

% Resample to 250 hz
EEG = pop_resample( EEG, 250);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 
pop_saveh( ALLCOM, 'eeglabhist.m', 'C:\Users\cwbishop\Documents\MATLAB\');
EEG = eeg_checkset( EEG );

% Define epochs according to trigger codes
EEG = pop_selectevent( EEG, 'type',20,'deleteevents','on');
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'gui','off'); 
EEG = eeg_checkset( EEG );
pop_eegplot( EEG, 1, 1, 1);
EEG = eeg_checkset( EEG );
EEG = pop_rmdat( EEG, {'20'},[0 120] ,0);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'gui','off'); 
eeglab redraw;