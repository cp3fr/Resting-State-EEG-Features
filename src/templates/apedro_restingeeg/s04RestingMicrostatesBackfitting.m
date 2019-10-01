%% Microstate Backfitting
clear, clc;

% this is the path with the main analyses
workingDirectory = '/Volumes/methlab-1/Neurometric/2017/GroupLevelData/Resting/';

% this is the path with the data:
eegpath =  '/Volumes/methlab-1/Neurometric/2017/TestRetestPilot/';

% add EEGLAB path
addpath('~/Dropbox/EEG_analysis/GeneralMatlab/eeglab14_1_1b/')
eeglab
close

% add functions paths
% add functions paths
addpath('./resting_functions/')

%% Create a structure with all settings for analyses
RestingCreateSettings;

%% load the prototypes maps
load([workingDirectory 'MicrostateResults/Prototypes.mat'])



% files to be processed (here we can select different quality standards p
% is all preprocessed datasets
ftype = '*REST_Results.mat';
cd(eegpath)
dirInfo = dir;
folder = find(arrayfun(@(n) 1 ~= strncmp(dirInfo(n).name,'.',1) && dirInfo(n).isdir == 1,1:length(dirInfo)));

%% loop throug each folder (=subject)
for sub=1:length(folder)
    
    tic()
    
    %% EEG ANALYSIS:
    cd([eegpath dirInfo(folder(sub)).name '/Results/Resting/'])
    %cd(dirInfo(folder(sub)).name);
    file = dir(ftype);
    
    
    if isempty(file)
        continue
    end
    
    %% load the EEG file
    load(file.name);
    if size(EEG.data,2) < 30000 % if EEG file is smaller than 60 seconds break
        continue
    end    
    
    %%% Our Version Prototypes
    EEGtmp = [];       
    EEGtmp = pop_eegfiltnew(EEG, settings.Microstate.lpf,settings.Microstate.hpf);
    EEGtmp = pop_resample(EEGtmp,100);
    % Segmentation Eyes Closed
    EEGtmp = RestingSegment(EEGtmp,settings.segment.eyesclosed);
    
    EEGtmp = rmfield(EEGtmp,{'microstate'})
    
    %% use either of both Prototype maps... T1 or T2
    if strcmp(dirInfo(folder(sub)).name(1),'A')
        EEGtmp.microstate.prototypes =  Prototypes.OurVersion.T1.prototypes;
    elseif strcmp(dirInfo(folder(sub)).name(1),'B')
        EEGtmp.microstate.prototypes =  Prototypes.OurVersion.T2.prototypes;
    else
        warning('Wrong kind of folder')
        continue
    end
    

    
    % Do the backfitting
    EEGtmp = pop_micro_fit( EEGtmp, 'polarity', 0 );
    EEGtmp= pop_micro_smooth( EEGtmp, 'label_type', 'backfit', ...
        'smooth_type', 'reject segments', ...
        'minTime', 20, ...
        'polarity', 0 );
    EEGtmp = pop_micro_stats( EEGtmp, 'label_type', 'backfit', ...
        'polarity', 0 );
        
    EEG.microstateOurVers = EEGtmp.microstate;
    
    %% use the overall Prototypes
    EEGtmp = rmfield(EEGtmp,{'microstate'})
    EEGtmp.microstate.prototypes =  Prototypes.OurVersion.T1T2.prototypes;
    
    EEGtmp = pop_micro_fit( EEGtmp, 'polarity', 0 );  
    EEGtmp= pop_micro_smooth( EEGtmp, 'label_type', 'backfit', ...
        'smooth_type', 'reject segments', ...
        'minTime', 20, ...
        'polarity', 0 );
    % 3.6 Calculate microstate statistics
    EEGtmp = pop_micro_stats( EEGtmp, 'label_type', 'backfit', ...
        'polarity', 0 );
    EEG.microstateOurVersT1T2 = EEGtmp.microstate;
    
    
    %%% Thomas Version Prototypes
    
    %% use either of both Prototype maps... T1 or T2
    EEGtmp = rmfield(EEGtmp,{'microstate'})
    if strcmp(dirInfo(folder(sub)).name(1),'A')
        EEGtmp.microstate.prototypes =  Prototypes.Thomas.T1.prototypes';
    elseif strcmp(dirInfo(folder(sub)).name(1),'B')
        EEGtmp.microstate.prototypes =  Prototypes.Thomas.T2.prototypes';
    else
        warning('Wrong kind of folder')
        continue
    end
    
    % Do the backfitting
    EEGtmp = pop_micro_fit( EEGtmp, 'polarity', 0 );
    EEGtmp= pop_micro_smooth( EEGtmp, 'label_type', 'backfit', ...
        'smooth_type', 'reject segments', ...
        'minTime', 20, ...
        'polarity', 0 );
    EEGtmp = pop_micro_stats( EEGtmp, 'label_type', 'backfit', ...
        'polarity', 0 );
    EEG.microstateThomas = EEGtmp.microstate;
    
    %% use the overall Prototypes
    EEGtmp = rmfield(EEGtmp,{'microstate'})
    EEGtmp.microstate.prototypes =  Prototypes.Thomas.T1T2.prototypes';
    
    EEGtmp = pop_micro_fit( EEGtmp, 'polarity', 0 );  
    EEGtmp= pop_micro_smooth( EEGtmp, 'label_type', 'backfit', ...
        'smooth_type', 'reject segments', ...
        'minTime', 20, ...
        'polarity', 0 );
    % 3.6 Calculate microstate statistics
    EEGtmp = pop_micro_stats( EEGtmp, 'label_type', 'backfit', ...
        'polarity', 0 );
    EEG.microstateThomasT1T2 = EEGtmp.microstate;
    
    
    
    %%% Backfitt the sorted individual maps... 
    %% but only with the subjects that are part of the test-retest...
    
    if sum(ismember(Prototypes.Thomas.T1.Subjects, file.name)) > 0 || ...
            sum(ismember(Prototypes.Thomas.T2.Subjects, file.name)) > 0
        EEGtmp = rmfield(EEGtmp,{'microstate'})
        %% use either of both Prototype maps... T1 or T2
        idx = [];
        if strcmp(dirInfo(folder(sub)).name(1),'A')
            idx = find(ismember(Prototypes.Thomas.T1.Subjects, file.name))
            EEGtmp.microstate.prototypes =  squeeze(Prototypes.Thomas.T1.sortedprototypes(idx,:,:))';
        elseif strcmp(dirInfo(folder(sub)).name(1),'B')
            idx = find(ismember(Prototypes.Thomas.T2.Subjects, file.name))
            EEGtmp.microstate.prototypes =  squeeze(Prototypes.Thomas.T2.sortedprototypes(idx,:,:))';
        else
            warning('Wrong kind of folder')
            continue
        end
        
        % Do the backfitting
        EEGtmp = pop_micro_fit( EEGtmp, 'polarity', 0 );
        EEGtmp= pop_micro_smooth( EEGtmp, 'label_type', 'backfit', ...
            'smooth_type', 'reject segments', ...
            'minTime', 20, ...
            'polarity', 0 );
        EEGtmp = pop_micro_stats( EEGtmp, 'label_type', 'backfit', ...
            'polarity', 0 );
        
        EEG.microstateThomasSingleSubject = EEGtmp.microstate;

        
    end

    %% save the results (note that EEG.data has avg-referenced and filtered data)
    save(file.name,'EEG','ET_resting','automagic','settings','-v7.3');
   
    % go back to the EEGpath
    cd(eegpath);
        
    toc()
end    