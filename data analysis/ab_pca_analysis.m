% ab_pca_analysis.m
%
% New Script based on ARCWW code and Bratislav's snippet for PCA.
%
% KB 6-Aug-2013, Modified 7-Nov-2013
% Adapted for Project AB on 02-Oct-2015
% K. Backer

% Set Initial Variables:
subjects = {'1' '3' '4' '5' '6' '7' '8' '9' '10' '11' '12' '13' '14' '15' '16' '17'};
group_dir = '/auto/iduna/kbacker/ARCWW/group/pca/n=16/';

% Groups/Conditions to include in the PCA:
conds = {'Spatial-Inf' 'Neutral'};

% Times used include 300 to 1800 ms post-retro-cue onset. (1804 gets cut
% off when epoching)
t = [0 1896];
numtorot = 3; % Number of factors to rotate.

stthold = 0.005; % for uncorrected p-values
fdr_flag = 1; % 1 for fdr correction, 0 for none.
fdr_alpha = 0.05; % p threshold for fdr correction.

% First, load in an EEG set to get time points and channel locations.
% Get paths:
[si] = ab_subject_info(397);
in_dir = si.out_path; % Path to pre-processed data.
root_fn = ['11_im_m_e_icacorr_in_r150_b_a_f_s_'];

% Load pre-processed dataset corresponding to the condition:
addpath(genpath('/auto/iduna/kbacker/home/EEGLAB/eeglab11_0_4_4b/'));
[EEG] = pop_loadset('filename',[root_fn,'Semantic-Inf','.set'],'filepath',in_dir);

f1 = find(EEG.times==t(1));
f2 = find(EEG.times==t(2));
ptimes = EEG.times(f1:f2);


% Load in ERP Data for each subject and condition:
data = [];
for s = 1:length(subjects)
    for c = 1:length(conds)
        % load "erps"
        load(['/auto/iduna/kbacker/ARCWW/subjects/',subjects{s},'/erps/Fall2013/',[subjects{s},'_',conds{c},'.mat']]);
        
        if strcmpi(conds{1},'Semantic-Inf_vs_Semantic-Neu') || strcmpi(conds{1},'Semantic-Inf_vs_Spatial-Inf')
            erps = derp;
        end
        
        % Transpose if necessary, should be time points x channels.
        if size(erps,1)<size(erps,2)
            erps = erps';
        end
        
        % Trim the time points:
        if length(EEG.times)~= length(erps)
            error('Number of time points in EEG dataset and erps do not match.')
        else % Trim the data:
            terps = erps(f1:f2,:);
        end
        
        % Now add the data to PCA data variable:
        data = [data; terps];
        
    end % for c
end % for s

% Now, run the PCA and Rotation %
data = zscore(data);
[coeff,score,latent] = princomp(data);
figure,scatter(1:length(latent),100*latent/length(latent))
la = [];
for x = 1:numtorot
    la(x) = 100*latent(x)/length(latent);
end
sum_var = sum(la);
sprintf('Total Variance accounted for by rotated factors is %s percent',num2str(sum_var))
keyboard
close
[rcoeff T] = rotatefactors(coeff(:,1:numtorot),'Method','varimax','Normalize','on');

% rotated scores (10528x5) = preData (10528x61) * rotated coefficients (61x5)
rscores = data * rcoeff;
%rscores = score; % unrotated

% rotated loadings (61x5) = correlate(rotated scores,data)
L = corr(rscores,data)';
%L = coeff(:,1:numtorot); % unrotated

% Plot Rotated Scores:
f = 1:numtorot; % Top 5 components.

tp = size(terps,1); % number of timepoints.
if length(conds)==2
    c1_idx = [1:tp*2:length(rscores)];
    c2_idx = [tp+1:tp*2:length(rscores)];
elseif length(conds)==1
    c1_idx = [1:tp:length(rscores)];
elseif length(conds)==3
    c1_idx = [1:tp*3:length(rscores)];
    c2_idx = [tp+1:tp*3:length(rscores)];
    c3_idx = [tp+tp+1:tp*3:length(rscores)];
end

%sf1c1_scores = [];
%sf2c1_scores = [];
%sf5c1_scores = [];
sfc1_scores = cell(size(f)); % All SF scores for Condition 1 (SEmantic)
msfc1 = cell(size(f)); % Mean SF scores for Condition 1 (Semantic)

if length(conds)>=2
    sfc2_scores = cell(size(f)); % All SF scores for Condition 2 (Spatial)
    msfc2 = cell(size(f)); % Mean SF scores for Condition 2 (Spatial)
end

if length(conds)==3
    sfc3_scores = cell(size(f)); % All SF scores for Condition 2 (Spatial)
    msfc3 = cell(size(f)); % Mean SF scores for Condition 2 (Spatial)
end


figure;
for y = 1:length(f)
    % Gather Condition 1 Scores:
    for x = 1:length(c1_idx)
        idx1 = c1_idx(x);
        idx2 = c1_idx(x)+tp-1;
        temp = rscores([idx1:idx2],f(y))';
        %temp2 = score([idx1:idx2],2)';
        %temp3 = score([idx1:idx2],5)';
        sfc1_scores{y} = [sfc1_scores{y}; temp];
    end % for x
    % Now take the mean scores:
    msfc1{y} = mean(sfc1_scores{y});
    
    
    % Gather Condition 2 Scores:
    if length(conds)>=2
        for x = 1:length(c2_idx)
            idx1 = c2_idx(x);
            idx2 = c2_idx(x)+tp-1;
            temp = rscores([idx1:idx2],f(y))';
            sfc2_scores{y} = [sfc2_scores{y}; temp];
        end % for x
        msfc2{y} = mean(sfc2_scores{y});               
    end
    
    if length(conds)==3
        for x = 1:length(c3_idx)
            idx1 = c3_idx(x);
            idx2 = c3_idx(x)+tp-1;
            temp = rscores([idx1:idx2],f(y))';
            sfc3_scores{y} = [sfc3_scores{y}; temp];
        end % for x
        msfc3{y} = mean(sfc3_scores{y});               
    end
    
    
    % Statistically compare the 2 time courses:
    temp_data = {};
    if length(conds)>=2
        temp_data{1} = sfc1_scores{y}';
        temp_data{2} = sfc2_scores{y}';
        
        if length(conds)==3
            temp_data{3} = sfc3_scores{y}';
        end
        
        num_perms = 5000;
        
        [stats,df,pvals] = statcond(temp_data,'paired','on','method','perm','naccu',num_perms);
        % Just look at it with a simple t-test of the difference waves:
        %diff_scores = sfc1_scores{y} - sfc2_scores{y};
        %[h,pvals,ci,stats]=ttest(diff_scores);
        
        if fdr_flag == 1
            [p_fdr,p_masked]=fdr(pvals,fdr_alpha);
            p_fdr
        else
            p_masked = zeros(length(pvals),1);
            fi = find(pvals<=stthold);
            p_masked(fi) = 1;
        end
    end % if 
    
    
    %figure,plot(EEG2.times,msfc1{y})
    if numtorot == 16
        subplot(4,4,y);
    elseif numtorot == 8
        subplot(4,2,y);
    elseif numtorot == 5 || numtorot == 6
        subplot(3,2,y);
    elseif numtorot == 4
        subplot(2,2,y);
    elseif numtorot == 3
        subplot(3,1,y);
    elseif numtorot == 2
        subplot(2,1,y);
    end
    
%     if y == 3
%         % Flip the orientation
%         msfc1{y} = msfc1{y}*-1;
%         msfc2{y} = msfc2{y}*-1;
%         msfc3{y} = msfc3{y}*-1;
%     end
    
    if length(conds)>=2        
        for k = 1:length(p_masked)
            if p_masked(k)==1 % Significant
               plot([ptimes(k) ptimes(k)],[4.5 5],'k','LineWidth',3); 
               %plot([ptimes(k) ptimes(k)],[2 2.5],'k','LineWidth',3); 
               hold on
            end
        end % for k
        hold on
        plot(ptimes,msfc1{y},'r') % Semantic
        hold on
        plot(ptimes,msfc2{y},'b') % Spatial
        if length(conds)==3
            hold on
            plot(ptimes,msfc3{y},'k') % Neutral
        end
    else
        plot(ptimes,msfc1{y},'r') % Semantic
    end
    grid on
    title(['Spatial Factor ',num2str(f(y))])
    %axis([0 2000 -5 2.5])
    %legend(conds)
end % for y
legend(conds)


% KB: Added 16 October 2013
% Plot TOPOGRAPHIES OF THE ROTATED FACTORS (i.e., Loadings, L):

num_comps = size(L,2); % Top factors to do the rotation with.
figure, title(['Rotated Factors - Top ',num2str(num_comps)]);
for x = 1:num_comps
       
    if num_comps ==16
        subplot(4,4,x)
    elseif num_comps == 8 || num_comps == 7
        subplot(4,2,x)
    elseif num_comps == 5 || num_comps == 6
        subplot(3,2,x)
    elseif num_comps == 4
        subplot(2,2,x);
    elseif numtorot == 3
        subplot(3,1,x);
    elseif numtorot == 2
        subplot(2,1,x);
    end
    
    title(['Spatial Factor ',num2str(x)])
%     if x == 3
%         topoplot(L(:,x)*-1,EEG.chanlocs,'maplimits',[-1 1],'style','map');
%     else
        topoplot(L(:,x),EEG.chanlocs,'maplimits',[-1 1],'style','map');
        colorbar
    %end
end % for x
