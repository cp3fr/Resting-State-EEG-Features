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
%% get the complete Datasets (with two timepoints) 
load('/Volumes/methlab-1/Neurometric/2017/GroupLevelData/Resting/RestingEEGwithMicrostates.mat')

i = 1;
GFPpeaksT1 = []; GFPpeaksT2 = [];
for k=1:length(AllData)
    if ~isempty(AllData(k).T1) &&  ~isempty(AllData(k).T2)...
            && ~strcmp(AllData(k).T1.ID(1),'b') && ~strcmp(AllData(k).T2.ID(1),'b') %% and if its a bad 
         CompleteData(i).T1 = AllData(k).T1;
         CompleteData(i).T2 = AllData(k).T2;
        
        GFPpeaksT1 = [GFPpeaksT1   AllData(k).T1.microstate.data];
        GFPpeaksT2 = [GFPpeaksT2   AllData(k).T2.microstate.data];
        i = i + 1;
    end
end


dlmwrite(['/Volumes/methlab-1/Neurometric/2017/GroupLevelData/Resting/','GFPpeaksT1.ep'], GFPpeaksT1','delimiter',' ')
dlmwrite(['/Volumes/methlab-1/Neurometric/2017/GroupLevelData/Resting/','GFPpeaksT2.ep'], GFPpeaksT2','delimiter',' ')




