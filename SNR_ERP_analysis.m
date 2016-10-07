% important EEG functions:
% Simple pipeline.  No ICA.

% Set path to EEGLAB:
addpath(genpath('C:\Users\kcbacker\Documents\MATLAB\eeglab_current\eeglab13_4_4b\'));

% Trigger Codes
tcs = [101:106];
for c = 1:length(tcs)
    tc_labels{c} = num2str(tcs(c));
end

% Import Data
EEG = pop_loadcnt([si.data_path,si.fns{f}],'keystroke','on',...
    'dataformat','int32');

% Downsample data to 250 Hz because keep getting out of memory error:
EEG = pop_resample(EEG,250);


% Save each imported dataset:
pop_saveset(EEG,'filename',[dataset_fn,'.set'],'filepath',si.out_path);


% Merge Datasets, if you have more than 1 dataset per subject.
tmp = {};
for f = 1:length(si.fns)
    tmp{f} = pop_loadset('filename',[root_fn,num2str(f),'.set'],'filepath',si.out_path);
end
tmp = cell2mat(tmp);
EEG = pop_mergeset(tmp,[1:length(tmp)]);
clear tmp


% Epoch Data (Input EEG, trigger code(s), and time limits here, e.g., [-1 1.004]):
[EEG] = pop_epoch(EEG,tc_labels,si.epoch.timelim); 

% Baseline Data (Baseline to something like: [-300 0])
[EEG] = pop_rmbase(EEG, si.baseline.timerange);

% Re-reference Data
% I use a custom function for this, but you should see if the EEGLAB one
% works... Don't quote me on this command, since I don't typically  use it.
% the empty brackets mean "take the average reference".
% By setting 'keepref' to 'on', it should add a 65th channel, which is Cz.
% If you have problems, I might be able to help...
[EEG] = pop_reref(EEG,[], 'keepref','on');

% Load elp (channel config) file, this time including Cz:
EEG.chanlocs = readlocs('Neuroscan65.elp');

% Interpolate Bad Channels, only if absolutely necessary.
%EEG = eeg_interp(EEG, badchans);

% Reject trials with artifacts (the easy way)
[EEG] = pop_eegthresh(EEG, 1,[1:65], -100,+100,...
    si.thold1.starttime,si.thold1.endtime,0,1);

% Sort Data based on Specified Events (the 6 conditions)
for c = 1:tcs
    % Select events:
    [EEGout] = pop_selectevent(EEG,'type',tc_labels{c});
    
    % Save EEG dataset with only the selected events:
    pop_saveset(EEGout,'filename',[root_fn,'_',tc_names{c},'.set'],...
        'filepath',si.out_path);
end % for c


% For ERP Analysis:
% Loop through each subject, load in their data.
[EEG] = pop_loadset('filename',fn.set,'filepath',path_to_data);
data = EEG.data;
erps = zeros(size(data,1),size(data,2));
for ch = 1:size(data,1) % Loop through each channel
    temp = squeeze(data(ch,:,:));
    erps(ch,:) = mean(temp,2);
end % ch

% Zero-pad and Filter the ERPs 

% Save the erps as a mat file

% Load in all the subjects and Average across the group:

% Plot them.
% Topographies
% For topos, load in EEGLAB data file for channel info.
topoplot(mean_data,EEG.chanlocs,'maplimits',[-3 3],'style','map','electrodes','on');

