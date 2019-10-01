%% Microstates Analysis 
% use GEEG with X GFP peak maps as input for segmentation
clear, clc;

RestingCreateSettings;
%% Backfitting
workingDirectory = '/Volumes/methlab-1/Neurometric/2017/GroupLevelData/Resting/';
mkdir([workingDirectory 'MicrostateResults/'])
% this is the path with the data:
eegpath =  '/Volumes/methlab-1/Neurometric/2017/TestRetestPilot_TestRetestPilot_results/';


% add EEGLAB path
addpath('./eeglab14_1_1b/')
eeglab
close

% add functions paths
addpath('./resting_functions/')

load([workingDirectory 'RestingEEG.mat'])
chanlocs = AllData(1).T1.spectro.eyesclosed.welch.chanlocs; % chanlocs for topoplots

i = 1;
for k=1:length(AllData)
    if ~isempty(AllData(k).T1) &&  ~isempty(AllData(k).T2) ...
            && ~strcmp(AllData(k).T1.ID(1),'b') && ~strcmp(AllData(k).T2.ID(1),'b') %% and if its a bad 

        CompleteData(i).T1 = AllData(k).T1;
        CompleteData(i).T2 = AllData(k).T2;      
        i = i + 1;
           
    end
end

%% A) SEGMENTATION on concatenated GFP peak maps (OUR STYLE)
% separate for T1 and T2
%% T1 
EEGtmp = eeg_emptyset();
EEGtmp.setname = 'GFPpeakmaps'
EEGtmp.chanlocs = chanlocs;
EEGtmp.nbchan = length(chanlocs)
EEGtmp.trials = 1
EEGtmp.srate = 500;

for i = 1:length(CompleteData) 
EEGtmp.data = [EEGtmp.data , CompleteData(i).T1.microstate.data];
end
EEGtmp.microstate.data = EEGtmp.data;
EEG.pnts = size(EEGtmp.data,2)
EEGtmp.times = (1:size(EEG.data,2))*1000/EEG.srate

% Segment Data into Microstates
EEG = pop_micro_segment ( EEGtmp, 'algorithm','modkmeans', 'Nmicrostates', settings.Microstate.Nmicrostates,'Nrepetitions',settings.Microstate.Nrepetitions)

h = figure
for z = 1:4
    subplot(1,4,z)
    title(['Map ' num2str(z)])
    topoplot(EEG.microstate.prototypes(:,z)',chanlocs )
end
saveas(h,[workingDirectory 'MicrostateResults/ProtoMapsT1_from_concatenated_GFPpeaks.png']);

T1 = EEG.microstate;

%% T2 
EEG = eeg_emptyset();
EEG.setname = 'GFPpeakmaps'
EEG.chanlocs = chanlocs;
EEG.nbchan = length(chanlocs)
EEG.trials = 1
EEG.srate = 500;

for i = 1:length(CompleteData) 
EEG.data = [EEG.data , CompleteData(i).T2.microstate.data];
end

EEG.microstate.data = EEG.data;
EEG.pnts = size(EEG.data,2);
EEG.times = (1:size(EEG.data,2))*1000/EEG.srate;

% Segment Data into Microstates
EEG = pop_micro_segment ( EEGtmp, 'algorithm','modkmeans', 'Nmicrostates', settings.Microstate.Nmicrostates,'Nrepetitions',settings.Microstate.Nrepetitions)

h = figure
for z = 1:4
    subplot(1,4,z)
    title(['Map ' num2str(z)])
    topoplot(EEG.microstate.prototypes(:,z)',chanlocs )
end
saveas(h,[workingDirectory 'MicrostateResults/ProtoMapsT2_from_concatenated_GFPpeaks.png']);

T2 = EEG.microstate



%% B) SEGMENTATION on concatenated GFP peak maps (OUR STYLE)
% T1 and T2 combined 

EEG = eeg_emptyset();
EEG.setname = 'GFPpeakmaps'
EEG.chanlocs = chanlocs;
EEG.nbchan = length(chanlocs)
EEG.trials = 1
EEG.srate = 500;

for i = 1:length(CompleteData) 
EEG.data = [EEG.data ,  CompleteData(i).T1.microstate.data, CompleteData(i).T2.microstate.data ];
end
EEG.microstate.data =  EEG.data;
EEG.pnts = size(EEG.data,2)
EEG.times = (1:size(EEG.data,2))*1000/EEG.srate

% Segment Data into Microstates
EEG = pop_micro_segment ( EEGtmp, 'algorithm','modkmeans', 'Nmicrostates', settings.Microstate.Nmicrostates,'Nrepetitions',settings.Microstate.Nrepetitions)

h = figure
for z = 1:4
    subplot(1,4,z)
    title(['Map ' num2str(z)])
    topoplot(EEG.microstate.prototypes(:,z)',chanlocs )
end
saveas(h,[workingDirectory 'MicrostateResults/ProtoMapsT1T2_from_concatenated_GFPpeaks.png']);

T1T2 = EEG.microstate

Prototypes.chanlocs = chanlocs;
Prototypes.OurVersion.T1 = T1;
Prototypes.OurVersion.T2 = T2;
Prototypes.OurVersion.T1T2 = T1T2;


%% C) Sorting the microstates with thomas' algorithm... 
% T1
SingleProtos = []
for i = 1:length(CompleteData) 
SingleProtos(i,:,:) = CompleteData(i).T1.microstate.prototypes';
end

tmp2 = squeeze(SingleProtos(2,1,:))

[MeanMap,SortedMaps,OldMapFit] = PermutedMeanMaps(double(SingleProtos),0);

h = figure;
for z = 1:4
    subplot(1,4,z)
    title(['Map ' num2str(z)])
    topoplot(MeanMap(z,:),chanlocs )
end
saveas(h,[workingDirectory 'MicrostateResults/ProtoMapsT1_KoenigVersion.png']);

%plot all Microstate Segmentations
% figure;
% o = 1;
% for k = 1:size(SortedMaps,1)
%     for z = 1:4
%         map = squeeze(SortedMaps(k,:,:));
%         subplot(size(SortedMaps,1),4,o)
%         topoplot(map(z,:)',chanlocs ,'style','fill','conv','on','electrodes','off')
%         o = o + 1 ;
%     end
% end
% for z = 1:4
%     subplot(size(SortedMaps,1)+1,4,z+o-1)
%     title(['Map ' num2str(z)])
%     topoplot(MeanMap(z,:)',chanlocs,'style','fill','conv','on','electrodes','off' )
% end


for i = 1:length(CompleteData)
Subjects{i,:} = CompleteData(i).T1.ID
end


Prototypes.Thomas.T1.prototypes =  MeanMap;
Prototypes.Thomas.T1.sortedprototypes =  SortedMaps;
Prototypes.Thomas.T1.Subjects = Subjects

%save([workingDirectory 'MicrostateResults/ProtosSubThomasT1.mat'],'MeanMap','SortedMaps','-v7.3');

% T2
SingleProtos = []
for i = 1:length(CompleteData) 
SingleProtos(i,:,:) = CompleteData(i).T2.microstate.prototypes';
end

for i = 1:length(CompleteData)
Subjects{i,:} = CompleteData(i).T2.ID
end

[MeanMap,SortedMaps,OldMapFit] = PermutedMeanMaps(double(SingleProtos),0);

h = figure;
for z = 1:4
    subplot(1,4,z)
    title(['Map ' num2str(z)])
    topoplot(MeanMap(z,:),chanlocs )
end
saveas(h,[workingDirectory 'MicrostateResults/ProtoMapsT2_KoenigVersion.png']);

% plot all Microstate Segmentations
% figure;
% o = 1;
% for k = 1:size(SortedMaps,1)
%     for z = 1:4
%         map = squeeze(SortedMaps(k,:,:));
%         subplot(size(SortedMaps,1),4,o)
%         topoplot(map(z,:)',chanlocs ,'style','fill','conv','on','electrodes','off')
%         o = o + 1 ;
%     end
% end
% for z = 1:4
%     subplot(size(SortedMaps,1)+1,4,z+o-1)
%     title(['Map ' num2str(z)])
%     topoplot(MeanMap(z,:)',chanlocs,'style','fill','conv','on','electrodes','off' )
% end

for i = 1:length(CompleteData)
Subjects{i,:} = CompleteData(i).T2.ID
end

Prototypes.Thomas.T2.prototypes =  MeanMap;
Prototypes.Thomas.T2.sortedprototypes =  SortedMaps;
Prototypes.Thomas.T2.Subjects = Subjects

%save([workingDirectory 'MicrostateResults/ProtosSubThomasT2.mat'],'MeanMap','SortedMaps','-v7.3');


%% T1T2

for i = 1:length(CompleteData) 
SingleProtos1(i,:,:) = CompleteData(i).T1.microstate.prototypes';
SingleProtos2(i,:,:) = CompleteData(i).T2.microstate.prototypes';
end

SingleProtos = [SingleProtos1 ; SingleProtos2]

[MeanMap,SortedMaps,OldMapFit] = PermutedMeanMaps(double(SingleProtos),0);

h = figure;
for z = 1:4
    subplot(1,4,z)
    title(['Map ' num2str(z)])
    topoplot(MeanMap(z,:),chanlocs )
end
saveas(h,[workingDirectory 'MicrostateResults/ProtoMapsT1T2_KoenigVersion.png']);

% plot all Microstate Segmentations
% figure;
% o = 1;
% for k = 1:size(SortedMaps,1)
%     for z = 1:4
%         map = squeeze(SortedMaps(k,:,:));
%         subplot(size(SortedMaps,1),4,o)
%         topoplot(map(z,:)',chanlocs ,'style','fill','conv','on','electrodes','off')
%         o = o + 1 ;
%     end
% end
% for z = 1:4
%     subplot(size(SortedMaps,1)+1,4,z+o-1)
%     title(['Map ' num2str(z)])
%     topoplot(MeanMap(z,:)',chanlocs,'style','fill','conv','on','electrodes','off' )
% end

Prototypes.Thomas.T1T2.prototypes =  MeanMap;
Prototypes.Thomas.T1T2.sortedprototypes =  SortedMaps;

%save([workingDirectory 'MicrostateResults/ProtosSubThomasT1T2.mat'],'MeanMap','SortedMaps','-v7.3');
   

save([workingDirectory 'MicrostateResults/Prototypes.mat'],'Prototypes','-v7.3') 
