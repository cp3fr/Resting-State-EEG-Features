%% Merge all files to one structure
clear, clc;

warning('off','all')
% this is the path with the main analyses
workingDirectory = pwd;

% this is the path with the results:
rootpath =  '/Volumes/methlab-1/Neurometric/2017/TestRetestPilot/';
% path eye-tracker files
% add EEGLAB path
addpath('./eeglab14_1_1b/')
eeglab
close
% add functions paths
addpath('./resting_functions/');


% file to be processed:
ftype = '*REST_Results.mat';
%ftype = '*RES_EEG.mat'
% find the files that are folders
cd(rootpath)
dirInfo = dir;
%folder = find(arrayfun(@(n) 1 ~= strncmp(dirInfo(n).name,'.',1) && dirInfo(n).isdir == 1,1:length(dirInfo)));
folderA = find(arrayfun(@(n) 1 ~= strncmp(dirInfo(n).name,'.',1) && dirInfo(n).isdir == 1 && 1 == strncmp(dirInfo(n).name,'A',1),1:length(dirInfo)));
folderB = find(arrayfun(@(n) 1 ~= strncmp(dirInfo(n).name,'.',1) && dirInfo(n).isdir == 1 && 1 == strncmp(dirInfo(n).name,'B',1),1:length(dirInfo)));

%% loop throug each folder (=subject)
%sub = 1;
for sub=1:length(folderA)
    
    tic()
    
        %% EEG ANALYSIS:
        cd([rootpath dirInfo(folderA(sub)).name '/Results/Resting/'])
        %cd(dirInfo(folder(sub)).name);
        file = dir(ftype);
        
        if ~isempty(file)
            % load the EEG file
            load(file.name);
            
            %% move the data to a single structure with both timepoints...
            AllData(sub).T1.spectro = EEG.spectro;
            AllData(sub).T1.microstate = EEG.microstate ;
            AllData(sub).T1.ID = file.name;
            AllData(sub).T1.automagic = automagic;
            AllData(sub).T1.settings = settings;
            
            % add the Eyetracking data
            AllData(sub).T1.ET = ET_resting;
                  
            %% load T2
            % search through the folders if there is a folder called B..
            t2 = [];
            t2 = find(ismember({dirInfo(folderB).name}, ['B' dirInfo(folderA(sub)).name(2:3)]));
            if ~isempty(t2)
                cd([rootpath dirInfo(folderB(t2)).name '/Results/Resting/'])
                %cd(dirInfo(folder(sub)).name);
                file = dir(ftype);
                
                if ~isempty(file)
                    
                load(file.name);
                AllData(sub).T2.spectro = EEG.spectro;
                AllData(sub).T2.microstate = EEG.microstate ;
                AllData(sub).T2.ID = file.name;
                AllData(sub).T2.automagic = automagic;
                AllData(sub).T2.settings = settings;

                % add the Eyetracking data
                AllData(sub).T2.ET = ET_resting;
                    
                else
                    AllData(sub).T2 = [];
                    
                end
            else
                AllData(sub).T2 = [];
                
            end
            
        else
            
            AllData(sub).T1 = [];
            %AllData(sub).T1.ID = [];
        end
                 
    toc()
    
end
warning('on','all')

save('/Volumes/methlab-1/Neurometric/2017/GroupLevelData/Resting/RestingEEG.mat','AllData','-v7.3')