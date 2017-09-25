function preprocess

% Function to preprocess EEG Neuroscan data for spectral analysis

% Project AB Study Pre-processing settings
% Jobs in order of pre-processing steps:
% im = import data, resample
% m = merge datasets, remove EOG
% e = epoch 
% ar = auto-reject bad trials
% i = ica first time
% v = visually inspect components epoch by epoch, reject noisy trials
% i = ica second time, then reject actual components
% in = interpolate bad channels over specified time ranges
% r = re-reference--Done after ICA because Cz is not independent of the
% other channels because it is the average reference.
% b = baseline
% a = artifact rejection (using threshold)
% s = sort trials based on condition and/or responses
% This ends the general pre-processing.

%%  Load data into EEGLAB
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG = pop_loadcnt('E:\Google Drive\Project AE_SNR EEG ERP\Data\1016\1016_AAT_09_30_2016.cnt' , 'dataformat', 'auto', 'memmapfile', '');
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'gui','off'); 
EEG = eeg_checkset( EEG );

%% Resample to 250 hz
EEG = pop_resample( EEG, 250);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 
pop_saveh( ALLCOM, 'eeglabhist.m', 'C:\Users\cwbishop\Documents\MATLAB\');
EEG = eeg_checkset( EEG );

%% Load channel locations/turn off channel FCZ (ground)/set reference to Cz
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 
EEG=pop_chanedit(EEG, 'load',{'C:\\Users\\cwbishop\\Documents\\SNR-ERP\\data analysis\\Neuroscan65.elp' 'filetype' 'autodetect'},'changefield',{64 'datachan' 0});
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );
EEG = pop_reref( EEG, 64);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'gui','off'); 
eeglab redraw;

%% Run ICA
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'gui','off'); 
pop_saveh( ALLCOM, 'eeglabhist.m', 'C:\Users\cwbishop\Documents\SNR-ERP\data analysis\');
EEG = eeg_checkset( EEG );
EEG = pop_runica(EEG, 'extended',1,'interupt','on');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );
pop_topoplot(EEG,0, [1:63] ,'CNT file resampled',[8 8] ,0,'electrodes','on');
eeglab redraw;

%% Define epochs according to trigger codes
EEG = pop_epoch( EEG, {  '20'  }, [0  120], 'newname', 'CNT file resampled epochs', 'epochinfo', 'yes');
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'gui','off'); 
EEG = eeg_checkset( EEG );
eeglab redraw;

