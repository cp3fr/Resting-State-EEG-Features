%% Batch Script to call the analysis functions for the Resting State Data
% that FOOOF runs it must run on the methlab account, which has anaconda...
% see the functions in resting_functions for descriptions
% A Pedroni 2019

%% 
clear, clc;

% do you want to do only the first level analyses?
% firstlevel = 1;
% do you want to continue with processing or start from scratch
continueWithProcessing = 1;
nSubAlreadyDone = 0;

%% Create a structure with all settings for analyses
RestingCreateSettings;

%%
% this is the path with the main analyses
tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename));
workingDirectory = [ fileparts(tmp.Filename) '/' ];

% add EEGLAB path
addpath('./eeglab14_1_1b/')
eeglab
close

% add functions
addpath('./resting_functions/')

% this is the path with the data:
eegpath =  '/Volumes/methlab-1/Neurometric/2017/TestRetestPilot_TestRetestPilot_results/';

% path of eye-tracker files
etpath = '/Volumes/methlab-1/Neurometric/2017/TestRetestPilot/';

% Create a directory for the GroupLevelData (i.e. microstate GFP peaks)
if continueWithProcessing == 1
    
    if exist('/Volumes/methlab-1/Neurometric/2017/GroupLevelData/Resting/','dir')
        load('/Volumes/methlab-1/Neurometric/2017/GroupLevelData/Resting/GEEG.mat');       
        nSubAlreadyDone = size(GEEG,2) ./ settings.Microstate.Npeaks;
        fprintf('group folder exists. Keep it and contiue with subject %d\n',nSubAlreadyDone)
        
    end
    
else
    if exist('/Volumes/methlab-1/Neurometric/2017/GroupLevelData/Resting/','dir')
        
        answer = questdlg('restart and remove Group-data?', ...
            'Yes', ...
            'No, dont do this');
       % Handle response
        switch answer
            case 'Yes'
                rmdir( '/Volumes/methlab-1/Neurometric/2017/GroupLevelData/Resting/','s')
                fprintf('removing group folder\n')
                mkdir( '/Volumes/methlab-1/Neurometric/2017/GroupLevelData/Resting/')
                fprintf('creating new group folder\n')
            case 'No, dont do this'
                
        end
        
    end
end

% if this file not already exists... 
if ~isfile('/Volumes/methlab-1/Neurometric/2017/GroupLevelData/Resting/GroupRestingEEG.mat')
    GEEG = []; % intialize this matrix to aggregate GFP peak maps for the microstate analysis
    chanlocs = [];
    GEEGfile = '/Volumes/methlab-1/Neurometric/2017/GroupLevelData/Resting/GEEG.mat';
    save(GEEGfile,'GEEG','chanlocs')
end



% files to be processed (here we can select different quality standards p
% is all preprocessed datasets
ftype = '*p*RES_EEG.mat';

%cd(eegpath)

dirInfo = dir(eegpath);
fprintf('Number of available EEG files: %d\n',length(dirInfo))
folder = find(arrayfun(@(n) 1 ~= strncmp(dirInfo(n).name,'.',1) && dirInfo(n).isdir == 1,1:length(dirInfo)));

%% loop throug each folder (=subject)
for sub=nSubAlreadyDone+1:length(folder)
    
    fprintf('Processing file %d...\n',sub)
       
    tic()
    
    %% Eye-Tracking Analysis
    
    % Extract Pupil Size
    load([etpath,dirInfo(folder(sub)).name,'/',dirInfo(folder(sub)).name,'_RES_ET.mat']); 
    [ET_resting]=Resting_pupil(data,settings.ET_resting,eyeevent,event,colheader);
    
    
    %% EEG ANALYSIS:
    file = dir([eegpath dirInfo(folder(sub)).name '/' ftype]);
        
    if isempty(file)
        fprintf('Warning, file %d is empty and is skipped\n',sub)
        continue
    end
    
    %% load the EEG file
    load([eegpath dirInfo(folder(sub)).name '/' file.name]);
    if size(EEG.data,2) < 30000 % if EEG file is smaller than 60 seconds break
        fprintf('Warning, file %d is very small and is skipped\n',sub)
        continue
        
    end    
       
    %% Update fields in EEG structure
    EEG.filename = file.name;
    EEG.settings = settings;
    % use this path to save pics and other results
    if exist([etpath dirInfo(folder(sub)).name '/Results/Resting/'],'dir')
        rmdir([etpath dirInfo(folder(sub)).name '/Results/Resting/'],'s')
    end
    outpathfile = [etpath dirInfo(folder(sub)).name '/Results/Resting/' EEG.filename([1 , end-15:end-11])];
    
    % create folder
    mkdir([etpath dirInfo(folder(sub)).name '/Results/Resting/' ])
    
    
    %% Resting EEG Spectro Analysis
    
    % Filter
    EEG = pop_eegfiltnew(EEG, settings.spectro.lpf,settings.spectro.hpf);
    
    % Re-reference to average reference
    if settings.averageref == 1
        EEG = pop_reref(EEG,[]);
    end
    
    %%
    % *%% SPECTRO ANALYSIS*
    
    %% Segmentation Eyes Closed
    EEGtmp = RestingSegment(EEG,settings.segment.eyesclosed);
    
    %% Spectrogram (using spectopo)
    out = RestingSpectro(EEGtmp, settings.spectro,'eyesclosed',outpathfile);
    EEG.spectro.eyesclosed = out;
    
    %% Segmentation Eyesopen
    EEGtmp = RestingSegment(EEG,settings.segment.eyesopen);
    
    %% Spectrogram (using spectopo)
    out = RestingSpectro(EEGtmp, settings.spectro,'eyesopen',outpathfile);
    EEG.spectro.eyesopen = out;
    
    %% Individual Alpha Peak Eyesclosed
    out = RestingAlphaPeak(EEG.spectro.eyesclosed.fft,settings,EEG.filename,'eyesclosed',outpathfile);
    EEG.spectro.eyesclosed.fft.alphaPeak = out;
    out = RestingAlphaPeak(EEG.spectro.eyesclosed.welch,settings,EEG.filename,'eyesclosed',outpathfile);
    EEG.spectro.eyesclosed.welch.alphaPeak = out;
    
    %% Individual Alpha Peak Eyesopen
    out = RestingAlphaPeak(EEG.spectro.eyesopen.fft,settings,EEG.filename,'eyesopen',outpathfile);
    EEG.spectro.eyesopen.fft.alphaPeak = out;
    out = RestingAlphaPeak(EEG.spectro.eyesopen.welch,settings,EEG.filename,'eyesopen',outpathfile);
    EEG.spectro.eyesopen.welch.alphaPeak = out;
    
    %% 1/f noise using a simple robust regression
    out = oneFNoise(EEG.spectro.eyesclosed.fft,settings.onefnoise);
    EEG.spectro.eyesclosed.fft.onefnoise = out;
    out = oneFNoise(EEG.spectro.eyesopen.fft,settings.onefnoise);
    EEG.spectro.eyesopen.fft.onefnoise = out;
   
    out = oneFNoise(EEG.spectro.eyesclosed.welch,settings.onefnoise);
    EEG.spectro.eyesclosed.welch.onefnoise = out;
    out = oneFNoise(EEG.spectro.eyesopen.welch,settings.onefnoise);
    EEG.spectro.eyesopen.welch.onefnoise = out;
    
    %% 1/f noise Fooof (works better with welch and eyes closed fft analyses 
    % are commented because they lead to python errors that are hard to handle)
    out = OneFooof(EEG.spectro.eyesclosed.welch,settings.fooof,outpathfile,'eyesclosed');
    EEG.spectro.eyesclosed.welch.oneFooof = out;

    out = OneFooof(EEG.spectro.eyesopen.welch,settings.fooof,outpathfile,'eyesopen');
    EEG.spectro.eyesopen.welch.oneFooof = out;
    
    %% Individualy defined frequency bands and frequency ratios
    out = IndividualSpectro(EEG.spectro.eyesclosed.welch,settings.spectro);
    EEG.spectro.eyesclosed.welch = out;
    
    out = IndividualSpectro(EEG.spectro.eyesopen.welch,settings.spectro);
    EEG.spectro.eyesopen.welch = out;
    %%
    % *%% MICROSTATE ANALYSIS*
    
    
    %% Segmentation Eyes Closed for Microstate peaks
    EEGtmp = RestingSegment(EEG,settings.segment.eyesclosed);
    
    %Get GFP peaks
    EEGtmp = pop_micro_selectdata( EEGtmp, ALLEEG, 'datatype', 'spontaneous',...
        'avgref', settings.Microstate.avgref, ...
        'normalise', settings.Microstate.normalise, ...
        'MinPeakDist', settings.Microstate.MinPeakDist, ...
        'Npeaks', settings.Microstate.Npeaks, ...
        'GFPthresh', settings.Microstate.GFPthresh);
    
    %% microstate segmentation on the single level
    EEGtmp = pop_micro_segment( EEGtmp, 'algorithm','modkmeans', 'Nmicrostates', settings.Microstate.Nmicrostates,'Nrepetitions',settings.Microstate.Nrepetitions);
    EEG.microstate = EEGtmp.microstate;
    
    figure; MicroPlotTopo( EEGtmp, 'plot_range', settings.Microstate.Nmicrostates );
    saveas(gcf,[outpathfile,'MicroPrototypes','.png'])
    close;
    
    %% save the results (note that EEG.data has avg-referenced and filtered data)
    save([outpathfile 'REST_Results.mat'],'EEG','ET_resting','automagic','settings','-v7.3');
    
    % go back to the EEGpath
    cd(eegpath);
    
    %% collect the GFP peak maps and save them to a growing matfile. 
    
    GEEGObj = matfile(GEEGfile,'Writable',true);
    GEEGObj.GEEG = [GEEGObj.GEEG EEG.microstate.data];
    GEEGObj.chanlocs = EEGtmp.chanlocs;
         
    %save(['/Users/methlab/Dropbox/AA_Neurometric/ANALYSES/GroupLevelResults/Resting/','AllGFPpeakMaps.mat'] ,'GEEG','chanlocs','-v7.3');
    %dlmwrite(['/Users/methlab/Dropbox/AA_Neurometric/ANALYSES/GroupLevelResults/Resting/','AllGFPpeakMaps.ep'], 'GEEG','delimiter',' ')
    
%     %% collect the single subject segmentations
%     Seg(sub,:,:) = EEG.microstate.prototypes';
%     save(['/Users/methlab/Dropbox/AA_Neurometric/ANALYSES/GroupLevelResults/Resting/','SingleSubjectSegmentation' size(EEG.microstate.prototypes,2) '.mat' ],'Seg','-v7.3');
    toc()
end