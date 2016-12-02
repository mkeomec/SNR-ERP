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
% cfg = [];
% cfg.dataset = '1016_KDT_09_30_2016.cnt';
% cfg.trialfun = 'ft_trialfun_general'; % this is the default
% cfg.trialdef.eventtype  = 'trigger'; %specify event type
% cfg.trialdef.eventvalue  = 22; %specify trigger value;
% cfg.trialdef.poststim=120
% cfg.trialdef.prestim=0
% %cfg.trl = cfg.trialdef.triallength;
% cfg = ft_definetrial(cfg);
% trl=cfg.trl
% 
% cfg.trl = trl; 			% saved somewhere previously
% trialdata = ft_preprocessing(cfg);	% call preprocessing, putting the output in ‘trialdata’
% 
% 
% %% Preprocessing: Reference channel set to Cz. 
% cfg = [];
% cfg.dataset = '1016_KDT_09_30_2016.cnt';
% cfg.continuous  = 'yes';
% cfg.channel     = 'all';
% %cfg.trl = 'data_eeg.trl'
% cfg.bpfilter = 'yes';
% cfg.bpfreq = [.5 50];  
% cfg.reref       = 'yes';
% cfg.refmethod     = 'avg'
% cfg.implicitref = 'Cz';            % the implicit (non-recorded) reference channel is added to the data representation
% cfg.refchannel     = {'Cz', '65'}; % the average of these channels is used as the new reference, note that channel '53' corresponds to the right mastoid (M2)
% data_eeg        = ft_preprocessing(cfg);

%% Define Trial
cfg = [];
cfg.dataset = '1016_KDT_09_30_2016.cnt';
cfg.trialfun = 'ft_trialfun_general'; % this is the default
cfg.trialdef.eventtype  = 'trigger'; %specify event type
cfg.trialdef.eventvalue  = 22; %specify trigger value;
cfg.trialdef.poststim=120
cfg.trialdef.prestim=0
%cfg.trl = cfg.trialdef.triallength;
cfg = ft_definetrial(cfg);

trl=cfg.trl

trialdata = ft_preprocessing(cfg)

% Preprocessing: Reference channel set to Cz. 

cfg = [];
cfg.dataset = '1016_KDT_09_30_2016.cnt';
cfg.channel     = 'all';
%cfg.trl = 'data_eeg.trl'
cfg.bpfilter = 'yes';
cfg.bpfreq = [.5 50];  
cfg.reref       = 'yes';
cfg.refmethod     = 'avg'
cfg.implicitref = 'Cz';            % the implicit (non-recorded) reference channel is added to the data representation
cfg.refchannel     = {'Cz', '65'}; % the average of these channels is used as the new reference, note that channel '53' corresponds to the right mastoid (M2)
data_eeg        = ft_preprocessing(cfg);


%% Downsample to 250
data_orig = data_eeg; %save the original data for later use
cfg            = [];
cfg.resamplefs = 250;
cfg.detrend    = 'no';
data_eeg           = ft_resampledata(cfg, data_eeg);
%% ICA

cfg = [];
cfg.method  = 'runica'
ic_data = ft_componentanalysis (cfg,data_eeg);

cfg.viewmode = 'component';
cfg.continuous = 'yes';
cfg.layout = 'quickcap64.mat';
cfg.blocksize = 1;
cfg.channels = [1:10];
ft_databrowser(cfg,ic_data);


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

cfg=[]; 
cfg.artfctdef.reject = 'partial'; % this rejects complete trials, use 'partial' if you want to do partial artifact rejection
cfg.artfctdef.eog.artifact = artifact_EOG; % 
% cfg.artfctdef.jump.artifact = artifact_jump;
cfg.artfctdef.muscle.artifact = artifact_muscle;
data_no_artifacts = ft_rejectartifact(cfg,data_eeg);

%% Merge "trials" together: DOES NOT WORK
% data.merge = ft_appenddata(cfg, data_no_artifacts)

%% Define Trial 

cfg = [];
cfg.dataset = data_no_artifacts;
cfg.trialfun = 'ft_trialfun_general'; % this is the default
cfg.trialdef.eventtype  = 'trigger'; %specify event type
cfg.trialdef.eventvalue  = 22; %specify trigger value;
cfg.trialdef.poststim=120
cfg.trialdef.prestim=0
%cfg.trl = cfg.trialdef.triallength;
cfg = ft_definetrial(cfg);
trl=cfg.trl

cfg.trl = trl; 			% saved somewhere previously
trialdata = ft_preprocessing(cfg);	% call preprocessing, putting the output in ‘trialdata’


  
%% Frequency analysis

cfg              = [];
cfg.trials       = 1:369
cfg.output       = 'pow'; 
cfg.channel      = 'all';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.toi          = [0 : 5 : 120];
cfg.foi          = 0:1:20;
cfg.t_ftimwin    = ones(size(cfg.foi)) * 0.5;
TFRhann = ft_freqanalysis(cfg, data_no_artifacts);


% Plot single channel
cfg = [];
% cfg.baseline     = [-0.5 -0.1];
cfg.baselinetype = 'absolute';  
% cfg.maskstyle    = 'saturation';	
cfg.zlim         = [0 25];	        
cfg.channel      = 'OZ';
 
figure;
ft_singleplotTFR(cfg, TFRhann);

% 
cfg = [];
% cfg.baseline     = [-0.5 -0.1]; 
% cfg.baselinetype = 'absolute'; 
cfg.xlim         = [1 360];   
cfg.zlim         = [0 10];	
cfg.ylim         = [7.5 12.5];
cfg.marker       = 'on';
cfg.showlabels   = 'yes';	
cfg.layout       = 'quickcap64.mat';
figure 
% ft_multiplotTFR(cfg, TFRhann);
ft_topoplotTFR(cfg, TFRhann);




% Topo plot of Alpha power
% 
% cfg = [];
% cfg.baseline     = [-0.5 -0.1];	
% cfg.baselinetype = 'absolute';
% cfg.xlim         = [88 208];   
% cfg.zlim         = [-1.5e-27 1.5e-27];
% cfg.ylim         = [7 12.5];
% cfg.marker       = 'on';
% % cfg.layout       = 'Neuroscan65.elp';
% figure 
% ft_topoplotTFR(cfg, TFRhann);