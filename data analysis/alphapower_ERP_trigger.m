% clean up, call defaults
clear
ft_defaults
cd 'e:\Google Drive\Project AE_SNR EEG ERP\Data'
%% Subject selection
% All the subjects with EEG collected
stim=[108 109 110 111 112]
Current_sub = [1015 1018 1019 1020 1021 1026 1027 1030 1033 1045 1046 1055 1061 1063 1064 1068 1069 1070 1071 1075 1076 1080 1081 1084 1089 1091 1093 1094 1095 1096 1097 1098 1099 1101 1102 1103 1105 1106]

% Subjects to exclude from analysis
analyzed_sub=[1015]

% Create list of subjects to analyze
subid=Current_sub(~ismember(Current_sub,analyzed_sub))
subid=num2cell(subid)

% Create file listing. Working directory must be in data folder above
% subjects folder
[status,filelist]=system('dir /S/B *ERP_*.cnt');
list = textscan(filelist, '%s', 'Delimiter', '\n');
filelist=list{1,1}

% Start of analysis loop for each subject
for i=1:length(subid)
    clearvars -except 'subid' 'filelist' 'list' 'i'
    % Identify Subject file
    subjectid=(subid{i})
    subjectid=num2str(subjectid)
    cell_list=regexp(filelist,subjectid);
    cellindex=find(not(cellfun('isempty',cell_list)));
    dataname=filelist(cellindex)
    [h,~]=size(dataname)
    
        
    %% load data into one file, filter it on the way
    % Trigger code 101 is clean ba's. Define trials  
    tic
    cfg = [];
    
    % This 'if' statement accounts for multiple cnt EEG files for a single
    % recording period. During data collection, there were incidents where
    % Neuroscan crashed, or the recording was stopped half way through
    % collection and restarted as a new file. Append the multiple cnt files
    % into one before further processing
    if h>1
       
       cfg1=[];
       cfg.dataset=dataname(1,1);
       data1=ft_preprocessing(cfg);
       
       cfg2=[];
       cfg.dataset=dataname(2,1);
       data2=ft_preprocessing(cfg);
       
       
       % Combine data from multiple testing sessions
       tic
       
       for j=1:length(data2.time{1})
           time_data(1,j)=data1.time{1}(1,length(data1.time{1}))+data2.time{1}(1,j);
       end
       combined_data=data1
       combined_data.time{1,1}=cat(2,data1.time{1},time_data)
       combined_data.trial{1,1}=cat(2,data1.trial{1},data2.trial{1})
       %Update remaining values that are sample number dependent
       combined_data.sampleinfo(1,2)=length(combined_data.trial{1,1})
       combined_data.hdr.nSamples=length(combined_data.trial{1,1})
       combined_data.cfg.trl(1,2)=length(combined_data.trial{1,1})
         
       toc
       
       
       cfg=[];
%        cfg.dataset = dataname{1};       
       cfg.bpfilter = 'yes';
       cfg.bpfreq = [.5 100]; 
       cfg.trialdef.eventtype  = 'trigger';
       cfg.trialdef.prestim    = 0;
       cfg.trialdef.poststim   = 1.2;
       cfg.trialdef.eventvalue = 108;
%        Error using ft_definetrial. Too many input arguments
       cfg=ft_definetrial(cfg,combined_data);
       
        
    else
        cfg.dataset = dataname{1};    
        cfg.bpfilter = 'yes';
        cfg.bpfreq = [.5 100]; 
        cfg.trialdef.eventtype  = 'trigger';
        cfg.trialdef.prestim    = 0;
        cfg.trialdef.poststim   = 1.2;
        cfg.trialdef.eventvalue = 108;
        [cfg]=ft_definetrial(cfg); 
  end  
   toc
    
    % Preprocessing. Rereference to average
    
    cfg.reref= 'yes';
    cfg.refchannel='all';
    cfg.continuous  = 'yes';
    triggered_dat = ft_preprocessing(cfg);
    
    toc

    save(strcat(subjectid,'_',date,'_','triggered.mat'), 'triggered_dat', '-v7.3');

%% Play 'victory' music
    load handel.mat;
    soundsc(y, Fs);
    toc
end

% %% do the ICA
% cfg=[];
% cfg.channel='all';
% ICA_filt=ft_componentanalysis(cfg,triggered_dat);
% 
% %% Do fft on components
% 
% ICA_filt_fft = ft_ica_powerspec(ICA_filt);
% 
% % ICA_filt_fft.unmixing is the matrix of weights that I talked about, thats
% % always wort saving. But since harddrives are cheap, why not save it all.
% %%
% cfg=[];
% cfg.viewmode='component';
% cfg.layout = 'quickcap64.mat';
% %ft_databrowser(cfg, ICA_filt)
% ft_componentbrowser_afft(cfg,ICA_filt_fft);
% clear bad components
% %clc
% 
% bad_components=input('Components to reject (ie: [1,2,3]): ');
% 
% 
% % reject bad components
% cfg=[];
% cfg.component = bad_components;
% ICA_clean=ft_rejectcomponent(cfg, ICA_filt_fft);
% 
% % save the ICA result and the cleaned data, use save version 7.3 to make
% % sure nothing is compressed and data is lost
% 
% save(strcat(subjectid,'_',date,'_','ICAdat.mat'), 'ICA_filt_fft', '-v7.3');
% save(strcat(subjectid,'_',date,'_','ICA_clean.mat'), 'ICA_clean', '-v7.3');
% 
% %% Calculate PSD
% % 2000 samples are 2 seconds
% winlength = 1000;
% % overlap by 1 second
% noverlap = 500;
% nfft = 4000;
% fs = 1000;
% for t=1:length(ICA_clean.trial)
%     for e = 1:64
%                 [w, f] = pwelch(ICA_clean.trial{t}(e,:),winlength, noverlap, nfft, fs);
%                 PSD{t}(e,:) = w;
%     end
% end
% 
% % Save as v6 because R can not load 7.3. 
% save(strcat(subjectid,'_',date,'_','PSD.mat'), 'PSD', '-v6');
% toc
% end

