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
ICArun = input('Run ICA? 0=no, 1=yes:  ')
Freq_plot = input('Plot all frequency analysis plots? 0=no, 1=yes:  ')
% Find all .cnt files in subfolders with 'KDT' in the filename
[status,filelist]=system('dir /S/B *KDT_*.cnt');
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
%     cfg = [];
%     cfg.dataset = dataname{1};
%     cfg.channel = 'EEG';
%     cfg.viewmode = 'vertical';
%     cfg.blocksize = 1;                             % Length of data to display, in seconds
%     cfg.preproc.demean = 'yes';                    % Demean the data before display
%     cfg.ylim = [-46 46];
%      
%     ft_databrowser(cfg);
%      
%     set(gcf, 'Position',[1 1 1200 800])
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
if ICArun==1
    cfg = [];
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
    saveas(ICAfigure,strcat(subjectid,'_',date,'_','ICA'))
end
    
     
 cfg = [];
    
        if ICArun==1
            pause
            x = inputdlg('Enter space-separated numbers. ICA components:')
            cfg.component = str2num(x{:});
            data_iccleaned = ft_rejectcomponent(cfg, ic_data);
            save(strcat(subjectid,'_',date,'_','ICAclean.mat'),'data_iccleaned')
            ICAcomponents(i,:)=[subjectid,x]
        else
            load('ICA.mat')
%             x=cell2num(ICAcomponents(find(ismember(ICAcomponents,num2str(subjectid))),2))
            load(strcat(subjectid,'ICAclean.mat'))
            % This section needs further development. Want to call ICA from a previous file        
            % x=ICA.mat
        end
  
%     cfg = [];
%     cfg.channel = 'EEG';
%     cfg.viewmode = 'vertical';
%     cfg.blocksize = 1;                             % Length of data to display, in seconds
%     cfg.preproc.demean = 'yes';                    % Demean the data before display
%     cfg.ylim = [-46 46];
%      
%     ft_databrowser(cfg,data_iccleaned);
%      
%     set(gcf, 'Position',[1 1 1200 800])  
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

save(strcat(subjectid,'_',date,'_','trl.mat'),'trl')

    %% Frequency analysis over time
if Freq_plot==1
    cfg              = [];
    cfg.trials       = 'all'
    cfg.output       = 'pow'; 
    cfg.channel      = 'all';
    cfg.method       = 'mtmconvol';
    cfg.taper        = 'hanning';
    cfg.toi          = [0 : 1 : 120];
    
    cfg.foi          = 0:.5:20;
    cfg.t_ftimwin    = ones(size(cfg.foi)) * 0.5;
    TFRhann_open = ft_freqanalysis(cfg, data_iccleaned_open);
    TFRhann_closed = ft_freqanalysis(cfg, data_iccleaned_closed);
  

%     % Plot Occipital channels.
%  Eyes Closed
    cfg = [];
    cfg.baselinetype = 'absolute';  
    cfg.zlim         = [0 25];	        
    cfg.channel      = {'O1','O2','OZ','POZ','PO4','PO3'};

    figure;
    ft_singleplotTFR(cfg, TFRhann_closed);
    colormap jet
    Occipital_closed=gcf
    saveas(Occipital_closed,strcat(subjectid,'_',date,'_','Occ_closed'))

%     Eyes Open

    figure;
    ft_singleplotTFR(cfg, TFRhann_open);
    colormap jet
    Occipital_open=gcf
    saveas(Occipital_open,strcat(subjectid,'_',date,'_','Occ_open'))
    
%   All channels, eyes open
    cfg.channel      = 'all'
    figure;
    ft_singleplotTFR(cfg, TFRhann_open);
    colormap jet
    global_open=gcf
    saveas(global_open,strcat(subjectid,'_',date,'_','global_open'))

%   All channels, eyes closed    
    figure;
    ft_singleplotTFR(cfg, TFRhann_closed);
    colormap jet
    global_closed=gcf
    saveas(global_closed,strcat(subjectid,'_',date,'_','global_closed'))
    
% Topo, eyes closed
    cfg = [];
    cfg.xlim         = [1 360];   
    cfg.zlim         = [0 20];	
    cfg.ylim         = [7.5 12.5];
    cfg.marker       = 'on';
    cfg.showlabels   = 'yes';	
    cfg.layout       = 'neuroscan.mat';
    
    figure 
    ft_topoplotTFR(cfg, TFRhann_closed);
    colormap jet
    topo_closed=gcf
    saveas(topo_closed,strcat(subjectid,'_',date,'_','topo_closed'))
    figure 
    ft_topoplotTFR(cfg, TFRhann_open);
    colormap jet
    topo_open=gcf
    saveas(topo_open,strcat(subjectid,'_',date,'_','topo_open'))
end
    %% Frequency Analysis per trial
      cfg = [];
      cfg.foi          = [0:.1:20]; 
      cfg.toi          = [0 : 1 : 120];
%       cfg.tapsmofrq    = 1
      cfg.taper        = 'hanning';
      cfg.channel      = 'all';
      cfg.trials       = 'all'
      cfg.method       = 'mtmfft';
      cfg.output       = 'pow';
      cfg.t_ftimwin    = ones(size(cfg.foi)) * 0.5;
      cfg.pad          = 'nextpow2'
      
      FFT_open    = ft_freqanalysis(cfg, data_iccleaned_open);
      FFT_closed    = ft_freqanalysis(cfg, data_iccleaned_closed);

    %% Calculate area under the curve Alpha power from FFT

    FFT_open.powspctrm
    FFT_closed.powspctrm
    
%   Channel Layout
%   quickcap64: POZ=48, PO3= 55, PO4=57, O1=61, OZ=62, O2=63 
%   Neuroscan65.elp: POZ=18, PO3=34 , PO4=33, O1=10, OZ=31, O2=9 
    OZ_AOC_open(i)=trapz(FFT_open.powspctrm(31,17:26))
    O1_AOC_open(i)=trapz(FFT_open.powspctrm(10,17:26))
    O2_AOC_open(i)=trapz(FFT_open.powspctrm(9,17:26))
    POZ_AOC_open(i)=trapz(FFT_open.powspctrm(18,17:26))
    PO3_AOC_open(i)=trapz(FFT_open.powspctrm(34,17:26))
    PO4_AOC_open(i)=trapz(FFT_open.powspctrm(33,17:26))
    
    OZ_AOC_closed(i)=trapz(FFT_closed.powspctrm(31,17:26))
    O1_AOC_closed(i)=trapz(FFT_closed.powspctrm(10,17:26))
    O2_AOC_closed(i)=trapz(FFT_closed.powspctrm(9,17:26))
    POZ_AOC_closed(i)=trapz(FFT_closed.powspctrm(18,17:26))
    PO3_AOC_closed(i)=trapz(FFT_closed.powspctrm(34,17:26))
    PO4_AOC_closed(i)=trapz(FFT_closed.powspctrm(33,17:26))
    
    plot(mean(FFT_open.powspctrm([31,10,9,18,34,33],:)))
    FFT_open_fig=gcf
    saveas(FFT_open_fig,strcat(subjectid,'_',date,'_','FFT_open'))
    
    figure
    plot(mean(FFT_closed.powspctrm([31,10,9,18,34,33],:)))
    FFT_closed_fig=gcf
    saveas(FFT_closed_fig,strcat(subjectid,'_',date,'_','FFT_closed'))
    close all
end
if ICArun==1
    save(strcat('ICA_',date,'.mat'),'ICAcomponents')
end
OZ_AOC_open=OZ_AOC_open'
O1_AOC_open=O1_AOC_open'
O2_AOC_open=O2_AOC_open'
POZ_AOC_open=POZ_AOC_open'
PO3_AOC_open=PO3_AOC_open'
PO4_AOC_open=PO4_AOC_open'

OZ_AOC_closed=OZ_AOC_closed'
O1_AOC_closed=O1_AOC_closed'
O2_AOC_closed=O2_AOC_closed'
POZ_AOC_closed=POZ_AOC_closed'
PO3_AOC_closed=PO3_AOC_closed'
PO4_AOC_closed=PO4_AOC_closed'
T=table(O1_AOC_open,O2_AOC_open,OZ_AOC_open,POZ_AOC_open,PO3_AOC_open,PO4_AOC_open,O1_AOC_closed,O2_AOC_closed,OZ_AOC_closed,POZ_AOC_closed, PO3_AOC_closed, PO4_AOC_closed,'RowNames',subid)
writetable(T,strcat('alphapower_',date,'.csv'),'WriteRowNames',true)
