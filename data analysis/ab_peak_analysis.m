% ab_peak_analysis.m
%
% Quick analysis to look at group data and pick peaks for individual subjects.
% For now, peaks for all components are picked based on Channel Cz...
% K. Backer, Sept 2015


% Set Path to EEGLAB:
% Change this to where your EEGLAB directory is located.
addpath(genpath('C:\Users\kcbacker\Documents\MATLAB\eeglab_current\eeglab13_4_4b\'));

conds = {'SL' 'SPL'}; 
groups = {'NH' 'HLU' 'HLA'}; % don't change this order...
subjects = {[393 395] [396 397 399 402] [398 401]}; % Add in the additional subjects you've tested.
comps = {'P1' 'N1' 'P2'}; 

% Setup main directory to load in Group data from:
in_dir = '\blah\blah\blah\Groups\'; % all group .mat files should be here.

% First, calculate Grand Average:
% Load in the group average ERPs:
load([in_dir,'Group_HLA_SPL.mat']); % 'hla_spl_erps', 'msecs'
load([in_dir,'Group_HLA_SL.mat']); % 'hla_sl_erps'
load([in_dir,'Group_HLU_SPL.mat']);% 'hlu_spl_erps'
load([in_dir,'Group_HLU_SL.mat']); % 'hlu_sl_erps'
load([in_dir,'Group_NH_SPL.mat']); % 'nh_spl_erps'
load([in_dir,'Group_NH_SL.mat']); % 'nh_sl_erps'

% Now, average across the groups, at least for now separately for the SPL and SL
% conditions...
grand_avg_spl = (hla_spl_erps + hlu_spl_erps + nh_spl_erps)/3;
grand_avg_sl = (hla_sl_erps + hlu_sl_erps + nh_sl_erps)/3;

% Now, plot the grand averages for the SPL and SL Conditions and then
% select the grand peaks for the P1, N1, and P2:
% msecs variable should be loaded with the Group ERP .mat files.
ch_to_plot = 65; % Channel 65 should correspond to Cz.
figure,plot(msecs, grand_avg_spl(ch_to_plot,:));
[x, y] = ginput(numel(comps)); % Select the peak P1, N1, and P2 in that order.
% x = the Latencies clicked
% y = the Amplitudes at those Latency.
close;
% Because the GUI click may not land on an actual sample in the data... find
% the closest sample:
lats = [];
amps = [];
for idx = 1:length(x)
    % find the closest latency available to the point selected.
    [tempmin, latidx] = min(abs(msecs-x(idx)));
    lat = msecs(latidx);
    
    % now find the amplitude at that latency.
    amp = grand_avg_spl(ch_to_plot,latidx);
    
    lats(idx) = lat;
    amps(idx) = amp;
end % for idx
% Write out these Latency and Amplitude values to a text file:
fid = fopen([in_dir,'GrandMeanValues_SPL.txt'],'wt');
for x = 1:length(lats)
    fprintf(fid,'%g\t %g\n',lats(x), amps(x));
end % for x
fclose(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PUT IN THE FILENAME BELOW
% Plot Group Topography FOR THE SPL CONDITION:
% First need to load in an EEGLAB file to get the channel coordinates:
[si] = ab_subject_info(1, 1);
EEG = pop_loadset('filename','BLAHBLAH.set','filepath',si.out_path); % need channel locations to plot topographies.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Look in the msecs variable to add any times at which you want to see the topogrpahy.
times_to_plot = [lats];
idx = [];
for x = 1:length(times_to_plot)
    idx(x) = find(msecs == times_to_plot(x));
end

for x = 1:length(times_to_plot)
    figure
    subplot(1,3,1)
    topoplot(nh_spl_erps(:,times_to_plot(x)),EEG.chanlocs,'maplimits',[-3 3],'style','map');
    title(sprintf('NH SPL, Time: %s msec',num2str(times_to_plot(x))))
    
    subplot(1,3,2)
    topoplot(hlu_spl_erps(:,times_to_plot(x)),EEG.chanlocs,'maplimits',[-3 3],'style','map');
    title(sprintf('HLU SPL, Time: %s msec',num2str(times_to_plot(x))))
    
    subplot(1,3,3)
    topoplot(hla_spl_erps(:,times_to_plot(x)),EEG.chanlocs,'maplimits',[-3 3],'style','map');
    title(sprintf('HLA SPL, Time: %s msec',num2str(times_to_plot(x))))
end % for x


% PLOT GRAND AVERAGES AND TOPOGRAPHY FOR THE SL CONDITIONS:
ch_to_plot = 65; % Channel 65 should correspond to Cz.
figure,plot(msecs, grand_avg_sl(ch_to_plot,:));
[x, y] = ginput(numel(comps)); % Select the peak P1, N1, and P2 in that order.
% x = the Latencies clicked
% y = the Amplitudes at those Latency.
close;
% Because the GUI click may not land on an actual sample in the data... find
% the closest sample:
lats = [];
amps = [];
for idx = 1:length(x)
    % find the closest latency available to the point selected.
    [tempmin, latidx] = min(abs(msecs-x(idx)));
    lat = msecs(latidx);
    
    % now find the amplitude at that latency.
    amp = grand_avg_sl(ch_to_plot,latidx);
    
    lats(idx) = lat;
    amps(idx) = amp;
end % for idx
% Write out these Latency and Amplitude values to a text file:
fid = fopen([in_dir,'GrandMeanValues_SL.txt'],'wt');
for x = 1:length(lats)
    fprintf(fid,'%g\t %g\n',lats(x), amps(x));
end % for x
fclose(fid);

% Look in the msecs variable to add any times at which you want to see the topogrpahy.
times_to_plot = [lats]; % ms
idx = [];
for x = 1:length(times_to_plot)
    idx(x) = find(msecs == times_to_plot(x));
end

for x = 1:length(times_to_plot)
    figure
    subplot(1,3,1)
    topoplot(nh_sl_erps(:,times_to_plot(x)),EEG.chanlocs,'maplimits',[-3 3],'style','map');
    title(sprintf('NH SL, Time: %s msec',num2str(times_to_plot(x))))
    
    subplot(1,3,2)
    topoplot(hlu_sl_erps(:,times_to_plot(x)),EEG.chanlocs,'maplimits',[-3 3],'style','map');
    title(sprintf('HLU SL, Time: %s msec',num2str(times_to_plot(x))))
    
    subplot(1,3,3)
    topoplot(hla_sl_erps(:,times_to_plot(x)),EEG.chanlocs,'maplimits',[-3 3],'style','map');
    title(sprintf('HLA SL, Time: %s msec',num2str(times_to_plot(x))))
end % for x

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOW, LOOP THROUGH EACH SUBJECT AND GROUP, PLOT THE INDIVIDUAL DATA
% AND SELECT THE PEAKS.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ch_to_plot = 65; % All based on Channel 65, which should correspond to Cz.
window_length = 20; % ms, Will plot +/- 20 ms on each side of the peak latency.
window_samples = round(window_length/(1000/EEG.srate));
fid = fopen([in_dir,'ALL_Latencies.txt'],'wt');
fid2 = fopen([in_dir,'ALL_Amplitudes.txt'],'wt');
for c = 1:numel(conds) % loop through each condition.
    % Load in the text file with the Grand Average Peak Latencies for
    % this condition:
    fid = fopen([in_dir,'GrandMeanValues_',conds{c},'.txt']);
    temp = textscan(fid,'%n %n');
    fclose(fid);
    peaklats = temp{1};
    for g = 1:numel(groups) % loop through each group    
        % C:\\BLAH\BLAH\BLAH\GROUPS\NH\SL OR SPL\
        group_dir = [in_dir,groups{g},filesep,conds{c},filesep];
        for s = 1:length(subjects{g}) % loop through each subject
            % load in the Subject Data for this condition.
            load([group_dir,conds{c},num2str(subjects{g}(s)),'_.mat']);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % NOT SURE WHAT THE VARIABLE HOLDING EACH SUBJECT'S ERPS IS
            % CALLED... IT WILL APPEAR IN THE WORKSPACE WHEN YOU LOAD A
            % SUBJECT'S ERPS... MIGHT BE SOMETHING LIKE 'filt_erps'... for
            % now, calling it "variable_name"... you need to change this
            % below once you know what the variable is actually called.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Loop through each component (P1, N1, P2), plotting the window
            % specified above, surrounding the peak:            
            lats = [];
            amps = [];
            for co = 1:numel(comps)
                % Get the data (latency) index corresponding to the peak
                % latency in the grand grand average ERP:
                [tempmin, latidx] = min(abs(msecs-peaklats(co)));
                figure,plot(msecs(latidx-window_samples:latidx+window_samples),VARIABLE_NAME(ch_to_plot,[latidx-window_samples:latidx+window_samples])');
                title(sprintf('Select the Peak for %s',comps{co}))
                [x, y] = ginput(1);
                close;
                % Now, because where you click may not correspond to an
                % actual sample in the data... find the closest sample and
                % it's amplitude:
                
                % find the closest latency available to the point selected.
                [tempmin, latidx] = min(abs(msecs-x));
                lat = msecs(latidx);
                
                % now find the amplitude at that latency.
                amp = VARIABLE_NAME(ch_to_plot,latidx);    
                
                lats(co) = lat;
                amps(co) = amp;
            end % for co
            % Now, Print out these Latency and Amplitude values to the text file:
            % Condition     Group        P1     N1    P2
            if numel(comps) == 3
                fprintf(fid,'%s\t %s\t %g\t %g\t %g\n', conds{c},groups{g},lats(1),lats(2),lats(3));
                fprintf(fid2,'%s\t %s\t %g\t %g\t %g\n', conds{c},groups{g},amps(1),amps(2),amps(3));
            elseif numel(comps) == 2
                fprintf(fid,'%s\t %s\t %g\t %g\t %g\n', conds{c},groups{g},lats(1),lats(2));
                fprintf(fid2,'%s\t %s\t %g\t %g\t %g\n', conds{c},groups{g},amps(1),amps(2));
            elseif numel(comps) == 1
                fprintf(fid,'%s\t %s\t %g\t %g\t %g\n', conds{c},groups{g},lats(1));
                fprintf(fid2,'%s\t %s\t %g\t %g\t %g\n', conds{c},groups{g},amps(1));
            end
        end % for s        
    end % for g
end % for c
fclose(fid);
fclose(fid2);