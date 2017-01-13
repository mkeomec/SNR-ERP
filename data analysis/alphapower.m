function alphapower

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
    

    % Visualize EEG data in data browser
    cfg = [];
    cfg.dataset = dataname{1};
    cfg.channel = 'EEG';
    cfg.viewmode = 'vertical';
    cfg.blocksize = 1;                             % Length of data to display, in seconds
    cfg.preproc.demean = 'yes';                    % Demean the data before display
    cfg.ylim = [-46 46];
     
    ft_databrowser(cfg);
     
    set(gcf, 'Position',[1 1 1200 800])
%     print -dpng natmeg_databrowser2.png



   %% ICA Analysis over entire recording. 1)Trials established, 2)Downsample, 3) ICA, 4) Trials averaged
%    Define trial
    % 
    cfg = [];
    cfg.dataset = dataname{1};
    cfg.trialfun = 'ft_trialfun_general'; % this is the default
    cfg.trialdef.eventtype  = 'trigger'; %specify event type
    cfg.trialdef.eventvalue  = 22; %specify trigger value;
    cfg.trialdef.poststim=120
    cfg.trialdef.prestim=0
    cfg = ft_definetrial(cfg);
    data_eeg  = ft_preprocessing(cfg);
    trl.closed=cfg.trl

    cfg = [];
    cfg.dataset = dataname{1};
    cfg.trialfun = 'ft_trialfun_general'; % this is the default
    cfg.trialdef.eventtype  = 'trigger'; %specify event type
    cfg.trialdef.eventvalue  = 20; %specify trigger value;
    cfg.trialdef.poststim=120
    cfg.trialdef.prestim=0
    cfg = ft_definetrial(cfg);
    data_eeg  = ft_preprocessing(cfg);
    trl.open=cfg.trl
    
    cfg=[];
    cfg.dataset = dataname{1};
    cfg.continuous  = 'yes';
    cfg.channel     = 'all';
    cfg.bpfilter = 'yes';
    cfg.bpfreq = [.5 50];  
    trialdata = ft_preprocessing(cfg);	% call preprocessing, putting the output in ‘trialdata’
   
    %% Downsample to 250
    trialdata_orig = trialdata; %save the original data for later use
    cfg            = [];
    cfg.resamplefs = 250;
    cfg.detrend    = 'no';
    trialdata           = ft_resampledata(cfg, trialdata);
    
    %% ICA

    cfg = [];
%     cfg.channel = {'EEG'};
    cfg.method='runica';
    ic_data = ft_componentanalysis (cfg,trialdata);
    cfg = [];
    cfg.viewmode = 'component';
    cfg.continuous = 'yes';
    cfg.layout = 'quickcap64.mat';
    cfg.blocksize = 1;
    cfg.channels = [1:10];
    ft_databrowser(cfg,ic_data);
    colormap jet
    ICAfigure=gcf
    saveas(ICAfigure,strcat(subjectid,'ICA'))
 pause
    
 
 
 
 cfg = [];
    x = inputdlg('Enter space-separated numbers. ICA components:')
        if isempty(x{1,1})==0
            cfg.component = str2num(x{:});
        else
            load(ICA.mat)
            % This section needs further development. Want to call ICA from a previous file        
            % x=ICA.mat
        end
 
        
 data_iccleaned = ft_rejectcomponent(cfg, ic_data);
 save(strcat(subjectid,'ICAclean.mat'),'data_iccleaned')

   
    cfg = [];
    cfg.channel = 'EEG';
    cfg.viewmode = 'vertical';
    cfg.blocksize = 1;                             % Length of data to display, in seconds
    cfg.preproc.demean = 'yes';                    % Demean the data before display
    cfg.ylim = [-46 46];
     
    ft_databrowser(cfg,data_iccleaned);
     
    set(gcf, 'Position',[1 1 1200 800])  
%  Split ICA cleaned data into trials based on TRL defined above.


trl.open(:,1:2)=trl.open(:,1:2)/4
trl.open(:,1:2)=round(trl.open(:,1:2))
trl.closed(:,1:2)=trl.closed(:,1:2)/4
trl.closed(:,1:2)=round(trl.closed(:,1:2))
cfg = [];
cfg.trl=trl.open
data_iccleaned_open = ft_redefinetrial(cfg,data_iccleaned);  
cfg = [];
cfg.trl=trl.closed
data_iccleaned_closed = ft_redefinetrial(cfg,data_iccleaned);  

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

      FFT_open    = ft_freqanalysis(cfg, data_iccleaned_open);
      FFT_closed    = ft_freqanalysis(cfg, data_iccleaned_closed);

    %% Calculate area under the curve Alpha power from FFT

    FFT_open.powspctrm
    FFT_closed.powspctrm
    Oz_AOC_open(i)=trapz(FFT_open.powspctrm(31,15:25))
    O1_AOC_open(i)=trapz(FFT_open.powspctrm(10,15:25))
    O2_AOC_open(i)=trapz(FFT_open.powspctrm(9,15:25))
    Oz_AOC_closed(i)=trapz(FFT_closed.powspctrm(31,15:25))
    O1_AOC_closed(i)=trapz(FFT_closed.powspctrm(10,15:25))
    O2_AOC_closed(i)=trapz(FFT_closed.powspctrm(9,15:25))
    
    ICA(i,:)=[subjectid,x]
    plot(FFT_open.powspctrm')
end
save ICA.mat ICA
T=table(O1_AOC,O2_AOC,Oz_AOC,'RowNames',subid)
writetable(T,strcat(subjectid,'alphapower'))
