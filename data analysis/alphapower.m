function alphapower

<<<<<<< HEAD
% Create layout in Fieldtrip





% Preprocessing: Reference channel set to Cz. 

cfg = [];
cfg.dataset     = '1063_KDT_10_27_2016.cnt';
cfg.reref       = 'yes';
=======
% Define Trial 

cfg = [];
cfg.dataset = 'C:\Users\Michael\Google Drive\Project AE_SNR EEG ERP\Data\1016\1016_KDT_09_30_2016.cnt';
cfg.trialfun = 'ft_trialfun_general'; % this is the default
cfg.trialdef.eventtype  = 'trigger'; %speify event type
%cfg.trialdef.evetvalue  = '22'; %specify trigger value; this doesn't seem
%to be needed or i'm using it incorrectly: result is the same whether it is
%used or not
%cfg.trl = cfg.trialdef.triallength;
data_eeg = ft_definetrial(cfg);


%% Artifact Rejection (Auto)

% muscle
cfg = [];
cfg.dataset     = 'C:\Users\Michael\Google Drive\Project AE_SNR EEG ERP\Data\1016\1016_KDT_09_30_2016.cnt';
cfg.continuous = 'yes';
cfg.trl = 'data_eeg.trl';
% channel selection, cutoff and padding
% the current values are based off the Fieldtrip tutorials
cfg.artfctdef.zvalue.channel = 'all';
cfg.artfctdef.zvalue.cutoff = 4;
cfg.artfctdef.zvalue.trlpadding  = 0;
cfg.artfctdef.zvalue.fltpadding  = 0;
cfg.artfctdef.zvalue.artpadding  = 0.1;
%parameters
% the current values are based off the Fieldtrip tutorials
cfg.artifctdef.zvalue.bpfilter = 'yes';
cfg.artfctdef.zvalue.bpfreq = [110 140];
cfg.artfctdef.zvalue.bpfiltord   = 9;
cfg.artfctdef.zvalue.bpfilttype  = 'but';
cfg.artfctdef.zvalue.hilbert     = 'yes';
cfg.artfctdef.zvalue.boxcar      = 0.2;
%gui
%cfg.artfctdef.zvalue.interactive = 'yes'; %activates gui to manualy
%accept/reject and/or change threshold; doesn't work currently :(

data_eeg = ft_artifact_zvalue(cfg);


%% Preprocessing: Reference channel set to Cz. 
cfg = [];
cfg.dataset = 'C:\Users\Michael\Google Drive\Project AE_SNR EEG ERP\Data\1016\1016_KDT_09_30_2016.cnt';
cfg.continuous  = 'yes';
>>>>>>> origin/master
cfg.channel     = 'all';
%cfg.trl = 'data_eeg.trl'
cfg.bpfilter = 'yes';
cfg.bpfreq = [.5 50];  
cfg.reref       = 'yes';
cfg.refmethod     = 'avg'
cfg.implicitref = 'Cz';            % the implicit (non-recorded) reference channel is added to the data representation
cfg.refchannel     = {'Cz', '65'}; % the average of these channels is used as the new reference, note that channel '53' corresponds to the right mastoid (M2)
data_eeg        = ft_preprocessing(cfg);

  
%% Frequency analysis

cfg              = [];
cfg.output       = 'pow'; 
cfg.channel      = 'all';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.toi          = [0 : 5 : 1000];
cfg.foi          = 0:1:25;
cfg.t_ftimwin    = ones(size(cfg.foi)) * 0.5;
TFRhann = ft_freqanalysis(cfg, data_eeg);


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
cfg.xlim         = [287 412];   
cfg.zlim         = [0 25];	
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