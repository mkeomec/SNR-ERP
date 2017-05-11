% clean up, call defaults
clear
ft_defaults
% specify what to load
% dir = 'D:\Data\Ktremblay\subs\';
% dir = 'E:\Google Drive\Project AE_SNR EEG ERP\Data\1033\'
% dat = '1033_KDT_1-10-2017.cnt';

subid = inputdlg('Enter space-separated numbers. Subject IDs:')
subid=strsplit(subid{1},' ')
[status,filelist]=system('dir /S/B *KDT_*.cnt');
list = textscan(filelist, '%s', 'Delimiter', '\n');
filelist=list{1,1}

% Start of analysis loop for each subject
for i=1:length(subid)
    subjectid=(subid{i})
    cell_list=regexp(filelist,subjectid);
    cellindex=find(not(cellfun('isempty',cell_list)));
    dataname=filelist(cellindex)

    %% load data into one file, filter it on the way
    cfg = [];
    cfg.dataset = dataname{1};
    cfg.continuous  = 'yes';
    cfg.bpfilter = 'yes';
    cfg.bpfreq = [.5 100]; 
    continuous_dat = ft_preprocessing(cfg);

    % extract trialinfo to split up into eyes open / eyes closed later
    cfg=[];
    cfg.dataset=dataname{1};
    cfg.trialdef.eventvalue = [20 22];
    cfg.trialdef.eventtype  = 'trigger';
    cfg.trialdef.prestim    = 0;
    cfg.trialdef.poststim   = 120;
    for_triggers=ft_definetrial(cfg); 

    

%% split it up into 1s snippets to allow for a more informed ICA
cfg = [];
cfg.length               = 1;   % specify length of trials in seconds here
split_dat               = ft_redefinetrial(cfg, continuous_dat);
%% do the ICA
cfg=[];
cfg.channel='all';
ICA_filt=ft_componentanalysis(cfg,split_dat);

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

%% now split into eyes open / eyes closed data
% start end end samples of trials are listed in for_triggers.trl


cfg = [];
trlo =for_triggers.trl();
trlo(:,3) = [];
trlo((trlo(:,3)==22),:) = [];
cfg.trl = trlo;
trial_dat_o = ft_redefinetrial(cfg, ICA_clean);
trial_dat_o.info = trlo(:,3);

cfg = [];
trlc =for_triggers.trl();
trlc(:,3) = [];
trlc((trlo(:,3)==20),:) = [];
cfg.trl = trlc;
trial_dat_c = ft_redefinetrial(cfg, ICA_clean);
trial_dat_c.info = trlc(:,3);


%% append data for eyes open and eyes closed, get PSD
eo_dat = cat(2,trial_dat_o.trial{:});
ec_dat =cat(2,trial_dat_c.trial{:});


% 2000 samples are 2 seconds
winlength = 1000;
% overlap by 1 second
noverlap = 500;
nfft = 4000;
fs = 1000;
for e = 1:64
                [wo, f] = pwelch(eo_dat(e,:),winlength, noverlap, nfft, fs);
                PSD_eo(e,:) = wo;
                 [wc, f] = pwelch(ec_dat(e,:),winlength, noverlap, nfft, fs);
                PSD_ec(e,:) = wc;
end

% Global average PSD
PSD_eo_mean=mean(PSD_eo(:,1:120))
PSD_ec_mean=mean(PSD_ec(:,1:120))
%%
figure
rectangle('Position', [8,-1.5,4,4], 'Curvature', [0, 0], 'FaceColor', [.9 .9 .9]) % highlight alpha range
hold on
plot(f(2:120), log10(PSD_eo_mean(2:120)), 'color', [0 0 1]); % Eyes open in blue
hold on
plot(f(2:120), log10(PSD_ec_mean(2:120)), 'color', [1 0 0]); % Eyes closed in red
set(gcf, 'color', 'white')
xlabel('Frequency [Hz]')
ylabel('Log10(Power)')
legend('Eyes open', 'Eyes closed')

channel_id=load('quickcap64.mat')
channel_id=channel_id.lay.label(1:64,:)
PSD_ec_table=table(PSD_ec,'RowNames',channel_id)
writetable(PSD_ec_table,strcat(subjectid,'PSD_ec_',date,'.csv'),'WriteRowNames',true)
PSD_eo_table=table(PSD_eo,'RowNames',channel_id)
writetable(PSD_eo_table,strcat(subjectid,'PSD__eo_',date,'.csv'),'WriteRowNames',true)
end

