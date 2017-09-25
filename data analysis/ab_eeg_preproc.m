function ab_eeg_preproc(subjects)

% function arcww_eeg_preproc(subjects)
% for Kate's study.
%
% Input subjects as a cell array of strings.
% Imports and pre-processes raw EEG data (individual subjects).
%
% Generic flexible batch code that relies on ab_subject_info.m for
% settings.
%
% Also, removed Filtering section since it won't be needed here.
%
% K. Backer, 2013 February 17

pause on

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set path to EEGLAB:
addpath(genpath('/home/kbacker/data/home/EEGLAB/eeglab11_0_4_4b/'));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Loop through each subject:
for s = 1:length(subjects)
    sub = subjects{s};
    
    % Call subject info to get settings:
    [si] = ab_subject_info(sub);
    
    
    % Loop through each cnt file of EEG data
    for f = 1:numel(si.fns)        
        
        % Filename prefix:
        if isempty(strfind(si.fns{f},'ilter'))
            root_fn = [sub,'_SPL_'];
        else
            root_fn = [sub,'_SL_'];
        end
        
        % Use Switch Case routine to know order of jobs:
        for j = 1:length(si.jobs)
            switch lower(si.jobs{j})
                
                case 'im' % Import Data
                    root_fn = [root_fn,lower(si.jobs{j})];
                    %for f = 1:length(si.fns)
                    if ~exist([si.out_path,root_fn,'.set'],'file')
                        if strcmp(si.fns{f}(end-2:end),'bdf') % Biosemi File
                            EEG = pop_biosig([si.data_path,si.fns{f}],'ref',[1:64]);
                        elseif strcmp(si.fns{f}(end-2:end),'cnt')  % Neuroscan
                            EEG = pop_loadcnt([si.data_path,si.fns{f}],'keystroke','on',...
                                'dataformat','int32');
                            % Downsample data because keep getting out of memory error:
                            EEG = pop_resample(EEG,si.resamp_rate);
                            % Resampling broke here because it was using
                            % EEGLAB's firls function, not MATLAB's firls
                            % function... renamed EEGLABs functions.
                        end % if
                        
                        % Remove EOG channels:
                        if si.remove_eog == 1
                            display('Removing EOG Channels')
                            EEG.nbchan = 60; % Have to trick EEGLAB here.
                            EEG = pop_chanedit(EEG,'delete',[19:22]); % Removes the channel locs fields but not the actual data.
                            EEG.data = [EEG.data(1:18,:); EEG.data(23:64,:)];
                            EEG = eeg_checkset(EEG);
                            
                            EEG.chanlocs = readlocs('Neuroscan65_NO_EOG.elp','elecind',[1:60]);
                        else
                            display('Not removing EOG Channels')
                            % This is a good time to load the electrode positions needed for ICA mapping and Interpolation:
                            EEG.chanlocs = readlocs('Neuroscan65.elp','elecind',[1:64]); % Don't read in Cz now... need to create it.
                        end
                        
                        EEG = eeg_checkset(EEG);
                        
                        % Save each imported dataset:
                        pop_saveset(EEG,'filename',[root_fn,'.set'],'filepath',si.out_path);
                    end % if ~exist
                    %end % for f
                    
                case 'm' % Merge Datasets
                    tmp = {};
                    for f = 1:length(si.fns)
                        tmp{f} = pop_loadset('filename',[root_fn,num2str(f),'.set'],'filepath',si.out_path);
                    end
                    tmp = cell2mat(tmp);
                    
                    EEG = pop_mergeset(tmp,[1:length(tmp)]);
                    clear tmp
                    
                    %                 % Remove EOG channels:
                    %                 if si.remove_eog == 1
                    %                     display('Removing EOG Channels')
                    %                     EEG.nbchan = 60; % Have to trick EEGLAB here.
                    %                     EEG = pop_chanedit(EEG,'delete',[19:22]); % Removes the channel locs fields but not the actual data.
                    %                     EEG.data = [EEG.data(1:18,:); EEG.data(23:64,:)];
                    %                     EEG = eeg_checkset(EEG);
                    %
                    %                     EEG.chanlocs = readlocs('Neuroscan65_NO_EOG.elp','elecind',[1:60]);
                    %                 else
                    %                     display('Not removing EOG Channels')
                    %                     % This is a good time to load the electrode positions needed for ICA mapping and Interpolation:
                    %                     EEG.chanlocs = readlocs('Neuroscan65.elp','elecind',[1:64]); % Don't read in Cz now... need to create it.
                    %                 end
                    
                    EEG = eeg_checkset(EEG);
                    
                    sprintf('Done Merging data files for subject %s.',sub)
                    
                    % Save Merged Dataset:
                    root_fn = [root_fn,'_',lower(si.jobs{j})];
                    pop_saveset(EEG,'filename',[root_fn,'.set'],'filepath',si.out_path);
                    
                    
                case 'e' % Epoch Data
                    %  Now, epoch the data:
                    [EEG] = pop_epoch(EEG,si.epoch.typerange,si.epoch.timelim);
                    sprintf('Done Epoching data of subject %s',sub)
                    
                    % Remove 1st 10 trials from everyone's data:
                    [EEG] = pop_select(EEG,'notrial',[1:10]);
                    display('Removed Trials 1 to 10 from data')
                    
                    % Save Epoched Dataset:
                    root_fn = [root_fn,'_',lower(si.jobs{j})];
                    pop_saveset(EEG,'filename',[root_fn,'.set'],'filepath',si.out_path);
                    
                case 'ar' % Auto-Rejection of Improbable Data before first ICA:
                    [EEG,rmepochs] = pop_autorej(EEG,'threshold',1000,'startprob',5,'maxrej',5,'eegplot','off','nogui','on');
                    sprintf(['Number of epochs marked for deletion for subject',sub,' is ',num2str(length(rmepochs))])
                    %pause
                    % Save the list of rejected trials
                    fid = fopen([si.out_path,sub,'-AR_Marked_Epochs.txt'],'wt');
                    for z = 1:length(rmepochs)
                        fprintf(fid,'%g\n',rmepochs(z));
                    end % for z
                    fclose(fid);
                    
                    % Save Dataset after Auto-Rejection:
                    root_fn = [root_fn,'_',lower(si.jobs{j})];
                    pop_saveset(EEG,'filename',[root_fn,'.set'],'filepath',si.out_path);
                    
                case 'i' % Run ICA
                    if ~exist([si.out_path,sub,'_im_m_e_ar_i.set'],'file')
                        [EEG] = pop_loadset('filename',[sub,'_im_m_e_ar.set'],'filepath',si.out_path);
                        
                        tic
                        EEG = pop_runica(EEG,'icatype','runica','dataset',1,'options',{'extended',1});
                        toc
                        pop_expica(EEG,'weights',fullfile(si.out_path,[sub,'_ica_weights1.txt']));
                        
                        % Save Dataset after ICA:
                        root_fn = [root_fn,'_',lower(si.jobs{j})];
                        pop_saveset(EEG,'filename',[root_fn,'.set'],'filepath',si.out_path);
                        
                        
                        % STOP HERE TO EXAMINE THE ICA COMPONENT ACTIVATIONS
                        % AND REJECT BAD TRIALS USING THE GUI.
                    elseif ~exist([si.out_path,sub,'_im_m_e_ar_i_v_i.set'],'file')
                        % DO SECOND-PASS ICA ON THE PRUNED DATA!
                        [EEG] = pop_loadset('filename',[sub,'_im_m_e_ar_i_v.set'],'filepath',si.out_path);
                        
                        tic
                        EEG = pop_runica(EEG,'icatype','runica','dataset',1,'options',{'extended',1});
                        toc
                        pop_expica(EEG,'weights',fullfile(si.out_path,[sub,'_ica_weights2.txt']));
                        
                        % Save Dataset after second-pass ICA:
                        root_fn = [sub,'_im_m_e_ar_i_v_i'];
                        pop_saveset(EEG,'filename',[root_fn,'.set'],'filepath',si.out_path);
                        
                        % STOP HERE AND RUN PLOT_ICA_COMPS.M AND INPUT THE
                        % COMPONENTS YOU WANT TO REJECT FOR EACH SUBJECT IN
                        % AB_SUBJECT_INFO.M
                        
                    else
                        
                        %data = pop_loadset('filename',[sub,'_im_m_e_i_v_i2.set'],'filepath',si.out_path);
                        % Load in the Epoched data before ICA (no trials
                        % rejected from this one) and apply ICA weights from
                        % 2nd ICA run:
                        data = pop_loadset('filename',[sub,'_im_m_e.set'],'filepath',si.out_path);
                        [data] = pop_editset(data,'icaweights',[si.out_path,sub,'_ica_weights2.txt']);
                        
                        % Save this dataset with the weights applied:
                        fn = [sub,'_im_m_e_icaweights2.set'];
                        pop_saveset(data,'filename',fn,'filepath',si.out_path);
                        
                        % Plot the top 32 components for inspection:
                        EEG = data;
                        pop_selectcomps(EEG,[1:32])
                        
                        % Subtracts the rejected ICA components from the data.
                        % Also, plots the original and ICA-processed data on
                        % the same plot for inspection and confirmation before
                        % rejecting:
                        if ~isempty(si.icacomps)
                            EEG = pop_subcomp(EEG,si.icacomps,1);
                        else
                            display('No ICA components rejected.')
                        end
                        % Save the dataset again with the components subtracted:
                        root_fn = [sub,'_im_m_e_icacorr'];
                        pop_saveset(EEG,'filename',[root_fn,'.set'],'filepath',si.out_path);
                    end
                    close all
                    
                case 'b' % Baseline Data
                    [EEG] = pop_rmbase(EEG, si.baseline.timerange);
                    sprintf('Done Baselining data of subject %s',sub)
                    % Save Baselined Dataset:
                    root_fn = [root_fn,'_',lower(si.jobs{j})];
                    pop_saveset(EEG,'filename',[root_fn,'.set'],'filepath',si.out_path);
                    
                    
                case 'r' % Re-reference Data
                    % Reconstructs Cz and adds it as the last channel.
                    
                    % Since the data has been epoched, need to make it
                    % continuous.
                    EEG.data = reshape(EEG.data, EEG.nbchan, EEG.pnts*EEG.trials);
                    
                    [q] = comreff(EEG.data');
                    EEG.nbchan = EEG.nbchan +1;
                    EEG.chanlocs(end+1).labels = 'Cz';
                    EEG.chanlocs(end).ref = '';
                    EEG.data = q';
                    
                    % Reshape data back into epochs:
                    EEG.data = reshape(EEG.data, EEG.nbchan, EEG.pnts, EEG.trials);
                    
                    % Re-load elp file, this time including Cz:
                    if si.remove_eog == 0
                        EEG.chanlocs = readlocs('Neuroscan65.elp');
                    else
                        EEG.chanlocs = readlocs('Neuroscan65_NO_EOG.elp');
                    end
                    % Save Re-referenced Dataset:
                    root_fn = [root_fn,'_',lower(si.jobs{j})];
                    pop_saveset(EEG,'filename',[root_fn,'.set'],'filepath',si.out_path);
                    
                    
                case 'in' % Interpolate Bad Channels
                    root_fn = [sub,'_im_m_e_icacorr'];
                    EEG = pop_loadset('filename',[root_fn,'.set'],'filepath',si.out_path);
                    eegplot(EEG.data,'srate',EEG.srate,'events',EEG.event)
                    if ~isempty(si.epochrange)
                        
                        for i = 1:length(si.epochrange)
                            EEG = kb_eeg_interp(EEG, si.badchans{i}, si.epochrange{i});
                        end % for i
                        
                        % View interpolated channels and pause:
                        eegplot(EEG.data,'srate',EEG.srate,'events',EEG.event)
                        %keyboard
                        
                        % Save Interpolated Dataset:
                        root_fn = [root_fn,'_',lower(si.jobs{j})];
                        pop_saveset(EEG,'filename',[root_fn,'.set'],'filepath',si.out_path);
                    else
                        display('No channels will be interpolated.')
                    end
                    
                    
                case 'a' % Do Artifact Rejection via Thresholding
                    
                    % Don't include eye electrodes in artifact rejection(?)
                    [EEG] = pop_eegthresh(EEG, si.thold1.typerej,si.thold1.chans, si.thold1.lowthresh,si.thold1.upthresh,...
                        si.thold1.starttime,si.thold1.endtime,si.thold1.superpose,si.thold1.reject);
                    display('Done first-pass threshold trial rejection.')
                    
                    %                 % This part is only valid if doing TF, and need a long
                    %                 % baseline for spectral power analysis...
                    %                 [EEG] = pop_eegthresh(EEG, si.thold2.typerej,si.thold2.chans, si.thold2.lowthresh,si.thold2.upthresh,...
                    %                     si.thold2.starttime,si.thold2.endtime,si.thold2.superpose,si.thold2.reject);
                    %                 display('Done second-pass threshold trial rejection.')
                    
                    % Save Artfiact-free Dataset:
                    root_fn = [root_fn,'_',lower(si.jobs{j})];
                    pop_saveset(EEG,'filename',[root_fn,'.set'],'filepath',si.out_path);
                    
                case 's' % Sort Data based on Retro-Cue or Specified Event
                    root_fn = [root_fn,'_',lower(si.jobs{j})];
                    for i = 1:length(si.codes)
                        % Select events:
                        [EEGout] = pop_selectevent(EEG,'type',si.codes{i});
                        
                        % Display the number of correct, clean trials:
                        sprintf('Subject %s has %s correct clean trials for condition %s', sub, num2str(EEGout.trials), si.labels{i})
                        
                        % Save EEG dataset with only the selected events:
                        pop_saveset(EEGout,'filename',[root_fn,'_',si.labels{i},'.set'],...
                            'filepath',si.out_path);
                    end % for i
                    
            end % switch
        end % for j
        
    end % for f
    sprintf('Done pre-processing EEG data for subject %s', sub)
    
end % for s