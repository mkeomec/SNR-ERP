% Artifact rejection testing for muscle/EOG using the Fieldtrip tutorials
% All of the values are based off the fieldtrip examples, and randomly
% commented out lines of code were removed to get the function to
% work...not exactly sure why it works/doesn't work when those parameters
% are or are not in use. 


%% Define Trial 
cfg = [];
cfg.dataset = 'C:\Users\Michael\Google Drive\Project AE_SNR EEG ERP\Data\1016\1016_KDT_09_30_2016.cnt';
cfg.trialfun = 'ft_trialfun_general'; % this is the default
cfg.trialdef.eventtype  = 'trigger';
cfg = ft_definetrial(cfg);
trl = cfg.trl
%% Artifact Rejection (Auto)

% muscle
cfg = [];
cfg.trl = trl;
cfg.dataset     = 'C:\Users\Michael\Google Drive\Project AE_SNR EEG ERP\Data\1016\1016_KDT_09_30_2016.cnt';
cfg.continuous = 'yes';

% channel selection, cutoff and padding
cfg.artfctdef.zvalue.channel = 'all';
cfg.artfctdef.zvalue.cutoff = 4;
cfg.artfctdef.zvalue.trlpadding  = 0;
cfg.artfctdef.zvalue.fltpadding  = 0;
cfg.artfctdef.zvalue.artpadding  = 0.1;

%parameters
cfg.artifctdef.zvalue.bpfilter = 'yes';
cfg.artfctdef.zvalue.bpfreq = [110 140];
cfg.artfctdef.zvalue.bpfiltord   = 9;
%cfg.artfctdef.zvalue.bpfilttype  = 'but';
%cfg.artfctdef.zvalue.hilbert     = 'yes';
%cfg.artfctdef.zvalue.boxcar      = 0.2;

%gui
% cfg.artfctdef.zvalue.interactive = 'yes'; %activates gui to manualy accept/reject and/or change threshold; 
% doesn't work currently

[cfg, artifact_muscle] = ft_artifact_zvalue(cfg);
 %% EOG
   cfg            = [];
   cfg.trl        = trl;
   cfg.dataset     = 'C:\Users\Michael\Google Drive\Project AE_SNR EEG ERP\Data\1016\1016_KDT_09_30_2016.cnt';
   cfg.continuous = 'yes'; 
 
   % channel selection, cutoff and padding
   cfg.artfctdef.zvalue.channel     = 'all';
   cfg.artfctdef.zvalue.cutoff      = 4;
   cfg.artfctdef.zvalue.trlpadding  = 0;
   cfg.artfctdef.zvalue.artpadding  = 0.1;
   cfg.artfctdef.zvalue.fltpadding  = 0;
 
   % algorithmic parameters
  % cfg.artfctdef.zvalue.bpfilter   = 'yes';
   %cfg.artfctdef.zvalue.bpfilttype = 'but';
  % cfg.artfctdef.zvalue.bpfreq     = [ 15];
  % cfg.artfctdef.zvalue.bpfiltord  = 4;
   %cfg.artfctdef.zvalue.hilbert    = 'yes';
 
   % feedback
%    cfg.artfctdef.zvalue.interactive = 'yes'; % doesn't work currently
 
   [cfg, artifact_EOG] = ft_artifact_zvalue(cfg);