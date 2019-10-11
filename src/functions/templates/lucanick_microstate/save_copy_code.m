%% code taken from methlab/HBN_Henzen/asc/
%01.10.2019

clc
clear
eeglab
close

%allGIP = dir('//Volumes/methlab/HBN_Henzen/*/gip_RestingState_EEG.mat');
%allOIP = dir('//Volumes/methlab/HBN_Henzen/*/oip_RestingState_EEG.mat');

allGIP = dir('Z:\HBN_Henzen/*/gip_RestingState_EEG.mat');
allOIP = dir('Z:\HBN_Henzen/*/oip_RestingState_EEG.mat');

EEGFolder = [allGIP; allOIP];  

% extract IDs of all subjects that have EEG for later joining with
% behavioural data and convert into table  with label 'Patient_ID'
IDsEEGList = {EEGFolder(:).folder}';
IDsEEGIdxs = cell2mat(strfind(IDsEEGList, 'NDAR'));
IDsEEEGClean = extractAfter(IDsEEGList, IDsEEGIdxs-1);
IDsEEEGCleanTab = table(string(IDsEEEGClean), 'VariableNames',{'Patient_ID'});
IDsEEEGCleanTab.folder=IDsEEGList;
IDsEEEGCleanTab.filename={EEGFolder.name}';

% read in selected behavioural data
%opts = detectImportOptions('V:/HBN_Henzen/Microstates_Nick/AllDataSmall.csv');
dir('Z:\HBN_Henzen/asd_analysis')
cd Z:\HBN_Henzen/asd_analysis
%get EHQ_Tot data and AllData
EHQ_Tot = readtable('Z:\HBN_Henzen\asd_analysis/9994_EHQ_20190625.csv');
AllData = readtable('Z:\HBN_Henzen\asd_analysis/AllData.csv');

%Prepare EHQ-Data
EHQ_id = EHQ_Tot(:,1);
EHQ_Tot_Score= EHQ_Tot(:,27);
EHQ_Tot = [EHQ_id EHQ_Tot_Score];
EHQ_Tot = EHQ_Tot(2:end,:);
EHQ_Tot = unique(EHQ_Tot,'rows');
EHQ_Tot.Properties.VariableNames([1]) = {'Anonymized_ID'};

%having a look at the data
test = AllData(1:5,:);
test2 = EHQ_Tot(1:5,:);

% join dataset using function innerjoin (works on tables) -> deletes all
% Data that has no EHQ_Tot-score
AllDataBig= innerjoin(EHQ_Tot,AllData);
writetable(AllDataBig,'AllDataBig.csv')

opts = detectImportOptions('Z:\HBN_Henzen\asd_analysis/AllDataBig.csv');
opts.SelectedVariableNames ={'Patient_ID','Sex','Age','DX_01_Cat', 'DX_01_Sub','DX_01','EHQ_Total','Release_Number'};

AllData = readtable('AllDataBig.csv',opts);
% convert Patient_IDs field into string as IDsEEEGCleanTab are strings
AllData.Patient_ID = string(AllData.Patient_ID);

% join dataset using function innerjoin (works on tables)
AllDataHuge = innerjoin(IDsEEEGCleanTab, AllData);

%% Autism Spectrum Disorder


% %Use all ASD and randomly choose same amount of no diagnosis given
% %matched for age and sex  -> Also do backfitting with this sample on all

% meangender = mean(AllDataBig.Sex)
% meanage = mean(AllDataBig.Age)
% stdage = std(AllDataBig.Age)

ASDIndex=find(strcmp(AllDataHuge.DX_01_Sub, 'Autism Spectrum Disorder'));
AllASD=AllDataHuge(ASDIndex,:);

% meangenderADHD = mean(AllASD.Sex)
% meanageADHD = mean(AllASD.Age)
% stdageADHD = std(AllASD.Age)

noDiagIndex=find(strcmp(AllDataHuge.DX_01_Cat,'No Diagnosis Given'));
AllNoDiag=AllDataHuge(noDiagIndex,:);
% 
% meangenderNoDiag = mean(AllNoDiag.Sex)
% meanageNoDiag = mean(AllNoDiag.Age)
% stdageNoDiag = std(AllNoDiag.Age)
% 


%% Preparation, make one table with all subjects

AllNoDiag.DX_01_Sub(:) = {'H'};
AllNoDiag.DX_01_Sub_num(:) = {0};
AllASD.DX_01_Sub(:) = {'A'};
AllASD.DX_01_Sub_num(:) = {1};

Mixtbl = cat(1,AllNoDiag,AllASD);
% STR = {'Patient_ID'} {'Sex'}, {'Age'}, {'folder'}
% AllASDandNoDiag=join(STR)

%change DX_01_Sub from cell to array
Mixtbl.DX_01_Sub_num = cell2mat(Mixtbl.DX_01_Sub_num);

disp(['all subjects: ',num2str(size(Mixtbl,1))])

%% Select subjects by age range, gender and righthandedness
%Zero means not selected for analysis (at this moment all)
Mixtbl.select = zeros(size(Mixtbl,1),1);

%Age between 5-18
ageRange = [5 18];

%gender
gender = 0;

%righthandedness
rgthanded =48;

% Aplying Filter: For example: Up to 5.99 years equals 5 years etc.
indKeep = floor(Mixtbl.Age)>=ageRange(1) & floor(Mixtbl.Age)<=ageRange(2) & Mixtbl.EHQ_Total>=rgthanded & Mixtbl.Sex>=gender & Mixtbl.Release_Number <=3 & Mixtbl.DX_01_Sub_num >=0;

Mixtbl = Mixtbl(indKeep,:);

disp(['subjects of intrest: ',num2str(size(Mixtbl,1))])


%% Selection by Age Gender Matching

for age = ageRange(1):ageRange(2)
    
    indA = floor(Mixtbl.Age)==age & strcmpi(Mixtbl.DX_01_Sub,'A');
    
    indH = floor(Mixtbl.Age)==age & strcmpi(Mixtbl.DX_01_Sub,'H');

    count_diag = [sum(indA),sum(indH)];
    
    if diff(count_diag)==0 %number of subjects match between ADHD and Healthy, don't remove anything
        
        Mixtbl.select(indA)=1;
        
        Mixtbl.select(indH)=1;
        
        %implement gender matching?
        
    else %number of subjects does not match between ADHD and Healthy... perform gender matching

        if count_diag(1)>count_diag(2) %more ADHD than Healthy

            indGroupRemove = indA;
            indGroupKeep = indH;

        else %more Healthy than ADHD

            indGroupRemove = indH;
            indGroupKeep = indA;

        end
        
        Mixtbl.select(indGroupKeep) = 1; %keep all trials of group which has less trials overall

        for sex = [0 1]

            nkeep = sum(indGroupKeep & Mixtbl.Sex==sex);

            idx = find(Mixtbl.Sex==sex & indGroupRemove);

            if length(idx)>nkeep

                for i = 1:3

                    idx = idx(randperm(length(idx)));

                end

                idx = idx(1:nkeep);

            end

            Mixtbl.select(idx) = 1;

        end

    end
    
end

Mixtbl = Mixtbl(logical(Mixtbl.select),:);

disp(['subjects after matching: ',num2str(size(Mixtbl,1))])
  %counts probands left after matching
%% stats age

ageA = Mixtbl.Age(strcmpi(Mixtbl.DX_01_Sub,'A'));
ageH = Mixtbl.Age(strcmpi(Mixtbl.DX_01_Sub,'H'));

meanAge = [mean(ageA), mean(ageH)]
%compute standard_error

[H,P,CI,STATS] = ttest2(ageA,ageH,0.05)

%% stats

[chitbl,chi2stat,pval] = crosstab(Mixtbl.DX_01_Sub, Mixtbl.Sex)


% n1 = 51; N1 = 8193;
% n2 = 74; N2 = 8201;
% x1 = [repmat('a',N1,1); repmat('b',N2,1)];
% x2 = [repmat(1,n1,1); repmat(2,N1-n1,1); repmat(1,n2,1); repmat(2,N2-n2,1)];
% [tbl,chi2stat,pval] = crosstab(x1,x2)

%% eeglab -> MST (microstates)
ind=strcmpi(Mixtbl.DX_01_Sub,'A');

MixtblA = Mixtbl(ind,:);

Mixtbl.n30 = zeros(size(Mixtbl,1),1);
Mixtbl.loaded = zeros(size(Mixtbl,1),1);

for i=1:5%:length(Mixtbl.folder) 
    clear EEG EEGEyesClosed_2D EEGEyesClosed
     EEG = pop_loadset( 'filename', Mixtbl.filename(i), 'filepath', cell2mat(Mixtbl.folder(i)));
    
     n30 = sum(contains({EEG.event(:).type},'30'));
     
     Mixtbl.n30(i) = n30;
    
    if n30 > 1 %selection threshold
        
        disp(['..loading ',Mixtbl.folder{i},Mixtbl.filename{i}])
     
        Mixtbl.loaded(i) = 1;
        
        %%EEG.event Field name is "sample" instead Latency. Add Field called "latency" for pop_epoch function

        for i=1:length(EEG.event)
            EEG.event(i).latency=EEG.event(i).sample;
        end

        EEGEyesClosed = pop_epoch(EEG, {'30 '} , [2 38]);


        %2D: reshape from 3D to 2D with "reshape(A,2,[])"
        %permute(EEGEyesClosed.dat,1,3,2)

        EEGEyesClosed_2D = EEGEyesClosed;

        EEGEyesClosed_2D.data = reshape(permute(EEGEyesClosed.data,[2,3,1]),[],EEGEyesClosed.nbchan)';

        EEGEyesClosed_2D.pnts = size(EEGEyesClosed_2D.data,2);

         [ALLEEG, EEGEyesClosed_2D, CURRENTSET] = eeg_store( ALLEEG, EEGEyesClosed_2D, 0 );
         % eeglab redraw
         
    else
        
        disp(['..skipping ',Mixtbl.folder{i},Mixtbl.filename{i}])
         
    end

end

cd('Z:\HBN_Henzen\asd_analysis\Microstate_Workspace')
save('asdloaded.mat', '-v7.3')



[EEG, ALLEEG] = pop_micro_selectdata(EEGEyesClosed_2D, ALLEEG, 'datatype', 'spontaneous', 'avgref', 1, 'normalise', 0, ...
    'MinPeakDist', 10, 'Npeaks', 1000, 'GFPthresh', 1, 'dataset_idx', 1:5)%change!!!!!!!;
%the next line of code probably does not change anything (probably not needed)
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET); %1:length(Mixtbl.folder), cant usw cuz 218

 write the GFP peaks of all subjects into the EEG variable. ALLEEG stays unchanged 
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, [1:5] ,'retrieve',5+1,'study',0); 
% 1:lenght+1 = dataset MicroGFPpeakData
% PROBLEM: 1:length(Mixtbl.folder) may have more Datasets than ALLEEG!!

% Segment into microstates: Anzahl random initialisations per microstate 50
EEG = pop_micro_segment( EEG, 'algorithm', 'modkmeans', 'sorting', 'Global explained variance', 'normalise', 0, ...
    'Nmicrostates', 2:8, 'verbose', 1, ... 
    'Nrepetitions', 50, 'fitmeas', 'CV', 'max_iterations', 1000, 'threshold', 1e-06, 'optimised', 1 );
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

cd('Z:\HBN_Henzen\asd_analysis\Microstate_Workspace')%ordner erstellen/path anpassen!!!!
save('asd_Workspace.mat', '-v7.3')



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
clc
eeglab
close
cd('Z:\HBN_Henzen\asd_analysis\Microstate_Workspace')
load('MixFiftyFifty1_Workspace.mat')


% load('/Volumes/methlab/HBN_Henzen/Microstates_Nick/Microstates Workspace/Workspace/FiftyFifty_workspace.mat')
% Review and select microstate segmentation: Plot microstate prototyp
% topographies

figure;MicroPlotTopo( EEG, 'plot_range', [] );


% Select active number of microstates: W, KL and KLnorm are not polarity   
% invariant, z.B. 5   Mit GUI und Graphik ausw�hlen oder vorbestimmt?
EEG = pop_micro_selectNmicro( EEG,'Measures',{'CV', 'GEV'}, 'do_subplots',1);%'Nmicro',4
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);



Allasd = [AllASD; AllNoDiag];



for i = 1:size(Allasd,1) fprintf('Importing prototypes and backfitting for dataset %i\n',i)
    
    clear EEG EEGEyesClosed_2D EEGEyesClosed
    
    load([Allasd.folder{i},'/',Allasd.filename{i}])
    
    
    n30 = sum(contains({EEG.event(:).type},'30'));
     
     Allasd.n30(i) = n30;
    
    if n30 > 1 %selection threshold
        
        disp(['..loading ',Allasd.folder{i},Allasd.filename{i}])
     
        Allfifties.loaded(i) = 1;
        
        
    for j=1:length(EEG.event)
        EEG.event(j).latency=EEG.event(j).sample;
    end
    
    EEGEyesClosed = pop_epoch(EEG, {'30 '} , [2 38]);
    
    %2D: reshape from 3D to 2D with "reshape(A,2,[])"
    permute(EEGEyesClosed.dat,1,3,2)
    
    EEGEyesClosed_2D = EEGEyesClosed;
    
    EEGEyesClosed_2D.data = reshape(permute(EEGEyesClosed.data,[2,3,1]),[],EEGEyesClosed.nbchan)';
    
    EEGEyesClosed_2D.pnts = size(EEGEyesClosed_2D.data,2);
    
    
    
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEGEyesClosed_2D, CURRENTSET,'retrieve',i,'study',0);
    
    %3.6 Back-fit microstates on all EEG
    EEG = pop_micro_import_proto( EEG, ALLEEG, 217); %217=dataset MicroGFPpeakdata with 216 proband datasets
    
    EEG = pop_micro_fit( EEG, 'polarity', 0 );
    
% 3.7 Temporally smooth microstates labels
EEG = pop_micro_smooth( EEG, 'label_type', 'backfit','smooth_type', 'reject segments', 'minTime', 30, 'polarity', 0 );

% 3.9 Calculate microstate statistics
EEG = pop_micro_stats( EEG, 'label_type', 'backfit', 'polarity', 0 );
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

Allasd.GEVtotal(i) = EEG.microstate.stats.GEVtotal;
Allasd.Gfp{i} = EEG.microstate.stats.Gfp;
Allasd.Occurence{i} = EEG.microstate.stats.Occurence;
Allasd.Duration{i} = EEG.microstate.stats.Duration;
Allasd.Coverage{i} = EEG.microstate.stats.Coverage;
Allasd.Duration{i} = EEG.microstate.stats.Duration;
Allasd.GEV{i} = EEG.microstate.stats.GEV;
Allasd.MspatCorr{i} = EEG.microstate.stats.MspatCorr;
Allasd.TP{i} = EEG.microstate.stats.TP;

end
