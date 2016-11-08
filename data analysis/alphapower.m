function alphapower

% Create layout in Fieldtrip

%% Visualize EEG data in data browser
cfg = [];
cfg.dataset = '1016_KDT_09_30_2016.cnt';
cfg.channel = 'EEG';
cfg.viewmode = 'vertical';
cfg.blocksize = 1;                             % Length of data to display, in seconds
cfg.preproc.demean = 'yes';                    % Demean the data before display
cfg.ylim = [-46 46];
 
ft_databrowser(cfg);
 
set(gcf, 'Position',[1 1 1200 800])
print -dpng natmeg_databrowser2.png


%% Preprocessing: Reference channel set to Cz. 
% 
% cfg = [];
% cfg.dataset     = '1016_KDT_09_30_2016.cnt';
% cfg.reref       = 'yes';

% %% Define trial
% 
cfg = [];
cfg.dataset = '1016_AAT_09_30_2016.cnt';
cfg.trialfun = 'ft_trialfun_general'; % this is the default
cfg.trialdef.eventtype  = 'trigger'; %specify event type
cfg.trialdef.eventvalue  = 22; %specify trigger value;
cfg.trialdef.poststim=120
cfg.trialdef.prestim=0
%cfg.trl = cfg.trialdef.triallength;
cfg = ft_definetrial(cfg);
cfg.continuous  = 'yes';
cfg.channel     = 'all';
cfg.bpfilter = 'yes';
cfg.bpfreq = [.5 50];  
data_eeg        = ft_preprocessing(cfg);
trl=cfg.trl

cfg.trl=trl
cfg.dataset = '1016_AAT_09_30_2016.cnt';
trialdata = ft_preprocessing(cfg);	% call preprocessing, putting the output in ‘trialdata’

%% Downsample to 250
trialdata_orig = trialdata; %save the original data for later use
cfg            = [];
cfg.resamplefs = 250;
cfg.detrend    = 'no';
trialdata           = ft_resampledata(cfg, trialdata);
%% ICA

cfg = [];
cfg.channel = 'EEG';
ic_data = ft_componentanalysis (cfg,trialdata);
cfg = [];
cfg.viewmode = 'component';
cfg.continuous = 'yes';
cfg.layout = 'quickcap64.mat';
cfg.blocksize = 1;
cfg.channels = [1:10];
ft_databrowser(cfg,ic_data);

cfg = [];
cfg.component = [3 8 9 19 32];
data_iccleaned = ft_rejectcomponent(cfg, ic_data);

% %% Artifact Detection (Auto)
% 
% % muscle
% cfg = [];
% cfg.dataset     = data_eeg;
% cfg.continuous = 'yes';
% cfg.trl = trl;
% % channel selection, cutoff and padding
% % the current values are based off the Fieldtrip tutorials
% cfg.artfctdef.zvalue.channel = 'all';
% cfg.artfctdef.zvalue.cutoff = 8;
% cfg.artfctdef.zvalue.trlpadding  = 0;
% cfg.artfctdef.zvalue.fltpadding  = 0;
% cfg.artfctdef.zvalue.artpadding  = 0.1;
% cfg.artfctdef.zvalue.artfctpeak  = 'no'
% cfg.artfctdef.zvalue.interactive = 'no'
% 
% 
% %parameters
% % the current values are based off the Fieldtrip tutorials
% cfg.artifctdef.zvalue.bpfilter = 'yes';
% cfg.artfctdef.zvalue.bpfreq = [110 140];
% cfg.artfctdef.zvalue.bpfiltord   = 9;
% cfg.artfctdef.zvalue.bpfilttype  = 'but';
% 
% [cfg, artifact_muscle] = ft_artifact_zvalue(cfg,data_eeg);
% 
% 
% % EOG Artifact rejection
% 
% cfg = [];
% cfg.dataset     = data_eeg;
% cfg.continuous = 'yes';
% cfg.trl = trl;
% cfg.artfctdef.zvalue.channel = 'all';
% cfg.artfctdef.zvalue.cutoff = 8;
% cfg.artfctdef.zvalue.trlpadding  = 0;
% cfg.artfctdef.zvalue.fltpadding  = 0;
% cfg.artfctdef.zvalue.artpadding  = 0.1;
% cfg.artfctdef.zvalue.artfctpeak  = 'no'
% cfg.artfctdef.zvalue.interactive = 'no'
% 
% %parameters
% % the current values are based off the Fieldtrip tutorials
% cfg.artifctdef.zvalue.bpfilter = 'yes';
% cfg.artfctdef.zvalue.bpfreq = [1 15];
% cfg.artfctdef.zvalue.bpfiltord   = 4;
% cfg.artfctdef.zvalue.bpfilttype  = 'but';
% 
% [cfg, artifact_EOG] = ft_artifact_zvalue(cfg,data_eeg);


% 
% cfg            = [];
%    cfg.trl        = 'data_eeg.trl'
%    cfg.datafile   = '1016_KDT_09_30_2016.cnt';
%    cfg.headerfile = '1016_KDT_09_30_2016.cnt';
%    cfg.continuous = 'yes'; 
%  
%    % channel selection, cutoff and padding
%    cfg.artfctdef.zvalue.channel     = 'EEG';
%    cfg.artfctdef.zvalue.cutoff      = 4;
%    cfg.artfctdef.zvalue.trlpadding  = 0;
%    cfg.artfctdef.zvalue.artpadding  = 0.1;
%    cfg.artfctdef.zvalue.fltpadding  = 0;
%  
%    % algorithmic parameters
%    cfg.artfctdef.zvalue.bpfilter   = 'yes';
%    cfg.artfctdef.zvalue.bpfilttype = 'but';
%    cfg.artfctdef.zvalue.bpfreq     = [1 15];
%    cfg.artfctdef.zvalue.bpfiltord  = 4;
%    cfg.artfctdef.zvalue.hilbert    = 'yes';
%  
%    % feedback
%    cfg.artfctdef.zvalue.interactive = 'yes';
%  
%    [cfg, artifact_EOG] = ft_artifact_zvalue(cfg);

%% Artifact Rejection

% cfg=[]; 
% cfg.artfctdef.reject = 'partial'; % this rejects complete trials, use 'partial' if you want to do partial artifact rejection
% cfg.artfctdef.eog.artifact = artifact_EOG; % 
% % cfg.artfctdef.jump.artifact = artifact_jump;
% cfg.artfctdef.muscle.artifact = artifact_muscle;
% data_no_artifacts = ft_rejectartifact(cfg,data_eeg);




  
%% Frequency analysis over time

cfg              = [];
cfg.trials       = 'all'
cfg.output       = 'pow'; 
cfg.channel      = 'all';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.toi          = [0 : 1 : 120];
cfg.foi          = 0:.5:20;
cfg.t_ftimwin    = ones(size(cfg.foi)) * 0.5;
TFRhann = ft_freqanalysis(cfg, data_iccleaned);

% Plot single channel
cfg = [];
% cfg.baseline     = [-0.5 -0.1];
cfg.baselinetype = 'absolute';  
% cfg.maskstyle    = 'saturation';	
cfg.zlim         = [0 25];	        
cfg.channel      = 'OZ';
 
figure;
ft_singleplotTFR(cfg, TFRhann);
 
cfg = [];
% cfg.baseline     = [-0.5 -0.1]; 
% cfg.baselinetype = 'absolute'; 
cfg.xlim         = [1 360];   
cfg.zlim         = [0 20];	
cfg.ylim         = [7.5 12.5];
cfg.marker       = 'on';
cfg.showlabels   = 'yes';	
cfg.layout       = 'quickcap64.mat';
figure 
% ft_multiplotTFR(cfg, TFRhann);
ft_topoplotTFR(cfg, TFRhann);

%% Frequency Analysis per trial
  cfg = [];
  cfg.foi          = [1:30]; 
  cfg.tapsmofrq    = 1
  cfg.taper        = 'hanning';
  cfg.channel      = 'all';
  cfg.trials       = 'all'
  cfg.method       = 'mtmfft';
  cfg.output       = 'pow';
   
  FFT    = ft_freqanalysis(cfg, data_iccleaned);
  
  
%%   
  
  
  
  
  
