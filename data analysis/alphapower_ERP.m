% clean up, call defaults
clear
ft_defaults
cd 'e:\Google Drive\Project AE_SNR EEG ERP\Data'
%% Subject selection
% All the subjects with EEG collected
Current_sub = [1015 1018 1019 1020 1021 1026 1027 1030 1033 1045 1046 1055 1061 1063 1068 1069 1070 1071 1075 1076 1089 1093 1094 1095 1096 1097 1098 1099 1101 1102 1103 1106]

% Subjects to exclude from analysis
analyzed_sub=[1015 1018 1019 1020 1026 1027 1030 1033 1045 1046 1055 1061 1063 1068 1069 1070 1071 1075 1076 1089 1093 1094 1095 1096 1097 1098 1099 1101 1102 1103 1106]

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
    % Identify Subject file
    subjectid=(subid{i})
    subjectid=num2str(subjectid)
    cell_list=regexp(filelist,subjectid);
    cellindex=find(not(cellfun('isempty',cell_list)));
    dataname=filelist(cellindex)

    %% load data into one file, filter it on the way
    % Trigger code 101 is clean ba's. Define trials  
    tic
    cfg = [];
    cfg.dataset = dataname{1};
    cfg.bpfilter = 'yes';
    cfg.bpfreq = [.5 100]; 
    cfg.trialdef.eventtype  = 'trigger';
    cfg.trialdef.prestim    = 0;
    cfg.trialdef.poststim   = 1.2;
    cfg.trialdef.eventvalue = 101;
    [cfg]=ft_definetrial(cfg); 
    
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
soundsc(y, 2*Fs);

%% do the ICA
cfg=[];
cfg.channel='all';
ICA_filt=ft_componentanalysis(cfg,triggered_dat);

%% Do fft on components

ICA_filt_fft = ft_ica_powerspec(ICA_filt);

% ICA_filt_fft.unmixing is the matrix of weights that I talked about, thats
% always wort saving. But since harddrives are cheap, why not save it all.
%%
cfg=[];
cfg.viewmode='component';
cfg.layout = 'quickcap64.mat';
%ft_databrowser(cfg, ICA_filt)
ft_componentbrowser_afft(cfg,ICA_filt_fft);
clear bad components
%clc

bad_components=input('Components to reject (ie: [1,2,3]): ');


% reject bad components
cfg=[];
cfg.component = bad_components;
ICA_clean=ft_rejectcomponent(cfg, ICA_filt_fft);

% save the ICA result and the cleaned data, use save version 7.3 to make
% sure nothing is compressed and data is lost

save(strcat(subjectid,'_',date,'_','ICAdat.mat'), 'ICA_filt_fft', '-v7.3');
save(strcat(subjectid,'_',date,'_','ICA_clean.mat'), 'ICA_clean', '-v7.3');

%% Calculate PSD
% 2000 samples are 2 seconds
winlength = 1000;
% overlap by 1 second
noverlap = 500;
nfft = 4000;
fs = 1000;
for t=1:length(ICA_clean.trial)
    for e = 1:64
                [w, f] = pwelch(ICA_clean.trial{t}(e,:),winlength, noverlap, nfft, fs);
                PSD{t}(e,:) = w;
    end
end

% Save as v6 because R can not load 7.3. 
save(strcat(subjectid,'_',date,'_','PSD.mat'), 'PSD', '-v6');
toc
end

