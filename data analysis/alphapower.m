function alphapower

% Create layout in Fieldtrip





% Preprocessing: Reference channel set to Cz. 

cfg = [];
cfg.dataset     = '1063_KDT_10_27_2016.cnt';
cfg.reref       = 'yes';
cfg.channel     = 'all';
cfg.implicitref = 'Cz';            % the implicit (non-recorded) reference channel is added to the data representation
cfg.refchannel     = {'Cz', '65'}; % the average of these channels is used as the new reference, note that channel '53' corresponds to the right mastoid (M2)
data_eeg        = ft_preprocessing(cfg);

% Frequency analysis

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