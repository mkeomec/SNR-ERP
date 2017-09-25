function EEG_SNR_preprocess

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
% EEG = pop_loadcnt('E:\Google Drive\Project AE_SNR EEG ERP\Data\1016\1016_AAT_09_30_2016.cnt' , 'dataformat', 'auto', 'memmapfile', '');
[filename,path]=uigetfile
EEG = pop_loadcnt(strcat(path,filename),'keystroke','on','dataformat','int32');
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'gui','off'); 
EEG = eeg_checkset( EEG );

%% Resample to 250 hz
EEG = pop_resample( EEG, 250);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 
% pop_saveh( ALLCOM, 'eeglabhist.m', 'C:\Users\cwbishop\Documents\MATLAB\');
% EEG = eeg_checkset( EEG );

%% Load channel locations/turn off channel FCZ (ground)/set reference to Cz
% EEG.chanlocs = readlocs('Neuroscan65.elp','elecind',[1:64]);
% % EEG=pop_chanedit(EEG, 'lookup','E:\\Google Drive\\Project AE_SNR EEG ERP\\Data analysis\\Neuroscan65.elp','load',{'E:\\Google Drive\\Project AE_SNR EEG ERP\\Data analysis\\Neuroscan65.elp' 'filetype' 'besa'},'changefield',{64 'datachan' 0});
% [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
% EEG = eeg_checkset( EEG );
% EEG = pop_reref( EEG, 64);
% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'gui','off'); 
% EEG = eeg_checkset( EEG );
% EEG.nbchan = EEG.nbchan +1;
% EEG.chanlocs(end+1).labels = 'Cz';
% EEG.chanlocs(end).ref = '';

EEG=pop_chanedit(EEG, 'lookup','E:\\Google Drive\\Project AE_SNR EEG ERP\\Data analysis\\Neuroscan65.elp','load',{'E:\\Google Drive\\Project AE_SNR EEG ERP\\Data analysis\\Neuroscan65.elp' 'filetype' 'autodetect'},'changefield',{65 'datachan' 0});
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );
EEG = pop_reref( EEG, [],'refloc',struct('type',{'REF'},'labels',{'Cz'},'sph_theta',{-90},'sph_phi',{90},'theta',{90},'radius',{0},'sph_radius',{1},'X',{3.7494e-33},'Y',{-6.1232e-17},'Z',{1},'ref',{''},'urchan',{65},'datachan',{0}));
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'gui','off'); 
% EEG.chanlocs = readlocs('Neuroscan65.elp','elecind',[1:64]);
% % EEG=pop_chanedit(EEG, 'load',{'C:\\Users\\cwbishop\\Documents\\SNR-ERP\\data analysis\\Neuroscan65.elp' 'filetype' 'autodetect'},'changefield',{64 'datachan' 0});
% % [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
% EEG = eeg_checkset( EEG );
% EEG = pop_reref( EEG, 64);
% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'gui','off'); 
% eeglab redraw;

%% Epoch data
EEG = eeg_checkset( EEG );
EEG = pop_epoch( EEG, {  '101'  }, [-0.5           1], 'newname', 'CNT file resampled epochs', 'epochinfo', 'yes');
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'gui','off'); 
EEG = eeg_checkset( EEG );
% Baseline Data
EEG = pop_rmbase( EEG, [-300    0])

%% Auto Reject data
% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4,'gui','off'); 
% EEG = eeg_checkset( EEG );
% [EEG,rmepochs] = pop_autorej(EEG,'threshold',1000,'startprob',5,'maxrej',5,'eegplot','off','nogui','on');


%% Run ICA
% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4,'gui','off'); 
% pop_saveh( ALLCOM, 'eeglabhist.m', 'C:\Users\cwbishop\Documents\SNR-ERP\data analysis\');
% EEG = eeg_checkset( EEG );

EEG = eeg_checkset( EEG );
EEG = pop_runica(EEG, 'extended',1,'interupt','on');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
pop_selectcomps(EEG, [1:65] );
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );

% eeglab redraw;
% EEG = eeg_checkset( EEG );
% pop_selectcomps(EEG, [1:65] );
% [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
% EEG = eeg_checkset( EEG );



% pop_topoplot(EEG,0, [1:65] ,'CNT file resampled',[8 8] ,0,'electrodes','on');
% EEG = eeg_checkset( EEG );

% [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
% EEG = eeg_checkset( EEG );
% figure; pop_plottopo(EEG, [1:65] , 'CNT file resampled epochs pruned with ICA', 0, 'ydir',-1);
% eeglab redraw;


% EEG = pop_subcomp(EEG,find(EEG.reject.gcompreject));

% Baseline Data
% si.baseline.timerange = [-300 0]; % For ERPs.
% [EEG] = pop_rmbase(EEG, si.baseline.timerange);

                   
                   
                    



%% Reconstructs Cz and adds it as the last channel.
% Since the data has been epoched, need to make it
% continuous.
 % Re-reference Data
                    
%                     EEG.data = reshape(EEG.data, EEG.nbchan, EEG.pnts*EEG.trials);
%                     
% %                     [q] = comreff(EEG.data');
%                    [q]= pop_reref(EEG.data,[])
%                     EEG.nbchan = EEG.nbchan +1;
%                     EEG.chanlocs(end+1).labels = 'Cz';
%                     EEG.chanlocs(end).ref = '';
% % % % % % % % %                     EEG.data = 
%                     
%                     % Reshape data back into epochs:
%                     EEG.data = reshape(EEG.data, EEG.nbchan, EEG.pnts, EEG.trials);
%                     
%                     % Re-load elp file, this time including Cz:
%                     if si.remove_eog == 0
%                         EEG.chanlocs = readlocs('Neuroscan65.elp');
%                     else
%                         EEG.chanlocs = readlocs('Neuroscan65_NO_EOG.elp');
%                     end
%                     % Save Re-referenced Dataset:
%                     root_fn = [root_fn,'_',lower(si.jobs{j})];
%                     pop_saveset(EEG,'filename',[root_fn,'.set'],'filepath',si.out_path);