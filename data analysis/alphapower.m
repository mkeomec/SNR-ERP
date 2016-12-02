function alphapower()

    %  TO-DO
    % -Create layout in Fieldtrip
    % -Create wrapper to batch process all subjects
    % -Save input for ICA

%% Description: 
% EEG-SNR project: Analysis code to assess the alpha power during the KDT
% and AAT. Currently the code analyzes the closed eyes condition during the
% AAT.
% NOTE: Matlab working directory must be in data folder that is above subjects folders

%% Enter subject ID for subjects to be analyzed. Opens dialog box to enter
% Subject id's
subid = inputdlg('Enter space-separated numbers. Subject IDs:')
subid=strsplit(subid{1},' ')

% Find all .cnt files in subfolders with 'KDT' in the filename
[status,filelist]=system('dir /S/B *KDT*.cnt');
list = textscan(filelist, '%s', 'Delimiter', '\n');
filelist=list{1,1}

% Create data table to store results


% Start of analysis loop for each subject
for i=1:length(subid)
    subjectid=(subid{i})
    cell_list=regexp(filelist,subjectid);
    cellindex=find(not(cellfun('isempty',cell_list)));
    dataname=filelist(cellindex)
    


    %% Visualize EEG data in data browser
    % cfg = [];
    % cfg.dataset = '1061_KDT_10_24_2016.cnt';
    % cfg.channel = 'EEG';
    % cfg.viewmode = 'vertical';
    % cfg.blocksize = 1;                             % Length of data to display, in seconds
    % cfg.preproc.demean = 'yes';                    % Demean the data before display
    % cfg.ylim = [-46 46];
    %  
    % ft_databrowser(cfg);
    %  
    % set(gcf, 'Position',[1 1 1200 800])
    % print -dpng natmeg_databrowser2.png

    %% Define trial
    % 
    cfg = [];
    cfg.dataset = dataname{1};
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
    cfg.dataset = dataname{1};
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

    x = inputdlg('Enter space-separated numbers. ICA components:')
        if isempty(x{1,1})==0
            cfg.component = str2num(x{:});
        else
            load(ICA.mat)
            % This section needs further development. Want to call ICA from a previous file        
            % x=ICA.mat
        end
        


    % cfg.component = [3 8 9 19 32];
    % cfg.component = [12];
    %  cfg.component = [2];
    % cfg.component = [34];
    % cfg.component = [22];
    % cfg.component = [6 14];
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
    cfg.channel      = 'O1';

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


    %% Calculate area under the curve Alpha power from FFT

    FFT.powspctrm
    Oz_AOC(i)=trapz(FFT.powspctrm(31,15:25))
    O1_AOC(i)=trapz(FFT.powspctrm(10,15:25))
    O2_AOC(i)=trapz(FFT.powspctrm(9,15:25))
    plot(FFT.powspctrm')

    
end

T=table(O1_AOC,O2_AOC,Oz_AOC,'RowNames',subid)
