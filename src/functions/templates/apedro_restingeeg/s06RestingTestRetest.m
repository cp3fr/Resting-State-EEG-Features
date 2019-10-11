%% Analyse test retest reliability (correlations)
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
for k=1:length(AllData)
    if ~isempty(AllData(k).T1) &&  ~isempty(AllData(k).T2)...
            && ~strcmp(AllData(k).T1.ID(1),'b') && ~strcmp(AllData(k).T2.ID(1),'b') %% and if its a bad 
        CompleteData(i).T1 = AllData(k).T1;
        CompleteData(i).T2 = AllData(k).T2;
        i = i + 1;
    end
end


% 1. Spectrogramm Welch
Structure = CompleteData;
structchainA = 'T1.spectro.eyesclosed.welch.specdata' 
structchainB = 'T2.spectro.eyesclosed.welch.specdata' 
A = reshape(getStruct(Structure,structchainA),105,501,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),105,501,length(CompleteData));

for i=1:size(A,1)
    for j = 1:size(A,2)
    R.spectro.eyesclosed.welch.specdata(i,j) = corr(squeeze(A(i,j,:)),squeeze(B(i,j,:)),'rows','pairwise');
    end
end

imagesc(R.spectro.eyesclosed.welch.specdata(:,1:100)>0.8)
histogram([R.spectro.eyesclosed.welch.specdata(:,1:100)])

% 2a. Frequency Bands 

for k = 1:7
    structchainA = ['T1.spectro.eyesclosed.welch.fbands(' num2str(k) ').absmean' ]
    structchainB = ['T2.spectro.eyesclosed.welch.fbands(' num2str(k) ').absmean' ]
    A = reshape(getStruct(Structure,structchainA),105,length(CompleteData));
    B = reshape(getStruct(Structure,structchainB),105,length(CompleteData));
    for i = 1:size(A,1)
        R.spectro.eyesclosed.welch.fbands(k).absmean(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
    end
end

for k = 1:7
    structchainA = ['T1.spectro.eyesclosed.welch.fbands(' num2str(k) ').relmean' ]
    structchainB = ['T2.spectro.eyesclosed.welch.fbands(' num2str(k) ').relmean' ]
    A = reshape(getStruct(Structure,structchainA),105,length(CompleteData));
    B = reshape(getStruct(Structure,structchainB),105,length(CompleteData));
    for i = 1:size(A,1)
        R.spectro.eyesclosed.welch.fbands(k).relmean(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
    end
end

for k = 1:7
    
    for m = 1:6
    structchainA = ['T1.spectro.eyesclosed.welch.fbands(' num2str(k) ').elecluster(' num2str(m) ').absmean' ]
    structchainB = ['T2.spectro.eyesclosed.welch.fbands(' num2str(k) ').elecluster(' num2str(m) ').absmean' ]
    A = getStruct(Structure,structchainA);
    B = getStruct(Structure,structchainB);

    R.spectro.eyesclosed.welch.fbands(k).elecluster(m).absmean = corr(A',B','rows','pairwise');
    R.spectro.eyesclosed.welch.fbands(k).elecluster(m).name = CompleteData(1).T1.spectro.eyesclosed.welch.fbands(m).elecluster.names;
    end
    
    R.spectro.eyesclosed.welch.fbands(k).name = CompleteData(1).T1.spectro.eyesclosed.welch.fbands(k).name;

end

%% Alpha Peak

structchainA = ['T1.spectro.eyesclosed.welch.alphaPeak.alphapeakfreqMax' ];
structchainB = ['T2.spectro.eyesclosed.welch.alphaPeak.alphapeakfreqMax' ];
A = getStruct(Structure,structchainA);
B = getStruct(Structure,structchainB);

R.spectro.eyesclosed.welch.alphaPeak.alphapeakfreqMax = corr(A',B','rows','pairwise');

structchainA = ['T1.spectro.eyesclosed.welch.alphaPeak.alphapeakamplitudeMax' ];
structchainB = ['T2.spectro.eyesclosed.welch.alphaPeak.alphapeakamplitudeMax' ];
A = getStruct(Structure,structchainA);
B = getStruct(Structure,structchainB);

R.spectro.eyesclosed.welch.alphaPeak.alphapeakamplitudeMax = corr(A',B','rows','pairwise');


structchainA = ['T1.spectro.eyesclosed.welch.alphaPeak.alphapeakfreqDerivative' ];
structchainB = ['T2.spectro.eyesclosed.welch.alphaPeak.alphapeakfreqDerivative' ];
A = getStruct(Structure,structchainA);
B = getStruct(Structure,structchainB);

R.spectro.eyesclosed.welch.alphaPeak.alphapeakfreqDerivative = corr(A',B','rows','pairwise');


structchainA = ['T1.spectro.eyesclosed.welch.alphaPeak.alphapeakamplitudeDerivative' ];
structchainB = ['T2.spectro.eyesclosed.welch.alphaPeak.alphapeakamplitudeDerivative' ];
A = getStruct(Structure,structchainA);
B = getStruct(Structure,structchainB);

R.spectro.eyesclosed.welch.alphaPeak.alphapeakamplitudeDerivative = corr(A',B','rows','pairwise');


structchainA = ['T1.spectro.eyesclosed.welch.alphaPeak.alphapeakfreqGravity' ];
structchainB = ['T2.spectro.eyesclosed.welch.alphaPeak.alphapeakfreqGravity' ];
A = getStruct(Structure,structchainA);
B = getStruct(Structure,structchainB);

R.spectro.eyesclosed.welch.alphaPeak.alphapeakfreqGravity = corr(A',B','rows','pairwise');


structchainA = ['T1.spectro.eyesclosed.welch.alphaPeak.alphapeakamplitudeGravity' ];
structchainB = ['T2.spectro.eyesclosed.welch.alphaPeak.alphapeakamplitudeGravity' ];
A = getStruct(Structure,structchainA);
B = getStruct(Structure,structchainB);

R.spectro.eyesclosed.welch.alphaPeak.alphapeakamplitudeGravity = corr(A',B','rows','pairwise');

structchainA = ['T1.spectro.eyesclosed.welch.alphaPeak.uniquelyIdentifiable' ];
structchainB = ['T2.spectro.eyesclosed.welch.alphaPeak.uniquelyIdentifiable' ];
A = getStruct(Structure,structchainA);
B = getStruct(Structure,structchainB);

R.spectro.eyesclosed.welch.alphaPeak.uniquelyIdentifiable = [A ;  B];

%% 1/f Noise

structchainA = ['T1.spectro.eyesclosed.welch.onefnoise.oneFall' ];
structchainB = ['T2.spectro.eyesclosed.welch.onefnoise.oneFall' ];
A = reshape(getStruct(Structure,structchainA),105,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),105,length(CompleteData));

    for i = 1:size(A,1)
        R.spectro.eyesclosed.welch.onefnoise.oneFall(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
    end


%% 1/f Fooof

structchainA = ['T1.spectro.eyesclosed.welch.oneFooof.bgparaAvg' ];
structchainB = ['T2.spectro.eyesclosed.welch.oneFooof.bgparaAvg' ];
A = reshape(getStruct(Structure,structchainA),2,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),2,length(CompleteData));

R.spectro.eyesclosed.welch.oneFooof.bgparaAvg1 = corr(A(1,:)',B(1,:)');
R.spectro.eyesclosed.welch.oneFooof.bgparaAvg2 = corr(A(2,:)',B(2,:)');




%%%% FFT %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%


structchainA = 'T1.spectro.eyesclosed.fft.specdata' 
structchainB = 'T2.spectro.eyesclosed.fft.specdata' 
A = reshape(getStruct(Structure,structchainA),105,151,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),105,151,length(CompleteData));

for i=1:size(A,1)
    for j = 1:size(A,2)
    R.spectro.eyesclosed.fft.specdata(i,j) = corr(squeeze(A(i,j,:)),squeeze(B(i,j,:)),'rows','pairwise');
    end
end

imagesc(R.spectro.eyesclosed.fft.specdata)
histogram([R.spectro.eyesclosed.fft.specdata])

% 2a. Frequency Bands 

for k = 1:7
    structchainA = ['T1.spectro.eyesclosed.fft.fbands(' num2str(k) ').absmean' ]
    structchainB = ['T2.spectro.eyesclosed.fft.fbands(' num2str(k) ').absmean' ]
    A = reshape(getStruct(Structure,structchainA),105,length(CompleteData));
    B = reshape(getStruct(Structure,structchainB),105,length(CompleteData));
    for i = 1:size(A,1)
        R.spectro.eyesclosed.fft.fbands(k).absmean(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
    end
end

for k = 1:7
    structchainA = ['T1.spectro.eyesclosed.fft.fbands(' num2str(k) ').relmean' ]
    structchainB = ['T2.spectro.eyesclosed.fft.fbands(' num2str(k) ').relmean' ]
    A = reshape(getStruct(Structure,structchainA),105,length(CompleteData));
    B = reshape(getStruct(Structure,structchainB),105,length(CompleteData));
    for i = 1:size(A,1)
        R.spectro.eyesclosed.fft.fbands(k).relmean(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
    end
end

for k = 1:7
    
    for m = 1:6
    structchainA = ['T1.spectro.eyesclosed.fft.fbands(' num2str(k) ').elecluster(' num2str(m) ').absmean' ]
    structchainB = ['T2.spectro.eyesclosed.fft.fbands(' num2str(k) ').elecluster(' num2str(m) ').absmean' ]
    A = getStruct(Structure,structchainA);
    B = getStruct(Structure,structchainB);

    R.spectro.eyesclosed.fft.fbands(k).elecluster(m).absmean = corr(A',B','rows','pairwise');
    R.spectro.eyesclosed.fft.fbands(k).elecluster(m).name = CompleteData(1).T1.spectro.eyesclosed.fft.fbands(m).elecluster.names;
    end
    
    R.spectro.eyesclosed.fft.fbands(k).name = CompleteData(1).T1.spectro.eyesclosed.fft.fbands(k).name;

end

%% Alpha Peak

structchainA = ['T1.spectro.eyesclosed.fft.alphaPeak.alphapeakfreqMax' ];
structchainB = ['T2.spectro.eyesclosed.fft.alphaPeak.alphapeakfreqMax' ];
A = getStruct(Structure,structchainA);
B = getStruct(Structure,structchainB);

R.spectro.eyesclosed.fft.alphaPeak.alphapeakfreqMax = corr(A',B','rows','pairwise');

structchainA = ['T1.spectro.eyesclosed.fft.alphaPeak.alphapeakamplitudeMax' ];
structchainB = ['T2.spectro.eyesclosed.fft.alphaPeak.alphapeakamplitudeMax' ];
A = getStruct(Structure,structchainA);
B = getStruct(Structure,structchainB);

R.spectro.eyesclosed.fft.alphaPeak.alphapeakamplitudeMax = corr(A',B','rows','pairwise');


structchainA = ['T1.spectro.eyesclosed.fft.alphaPeak.alphapeakfreqDerivative' ];
structchainB = ['T2.spectro.eyesclosed.fft.alphaPeak.alphapeakfreqDerivative' ];
A = getStruct(Structure,structchainA);
B = getStruct(Structure,structchainB);

R.spectro.eyesclosed.fft.alphaPeak.alphapeakfreqDerivative = corr(A',B','rows','pairwise');


structchainA = ['T1.spectro.eyesclosed.fft.alphaPeak.alphapeakamplitudeDerivative' ];
structchainB = ['T2.spectro.eyesclosed.fft.alphaPeak.alphapeakamplitudeDerivative' ];
A = getStruct(Structure,structchainA);
B = getStruct(Structure,structchainB);

R.spectro.eyesclosed.fft.alphaPeak.alphapeakamplitudeDerivative = corr(A',B','rows','pairwise');


structchainA = ['T1.spectro.eyesclosed.fft.alphaPeak.alphapeakfreqGravity' ];
structchainB = ['T2.spectro.eyesclosed.fft.alphaPeak.alphapeakfreqGravity' ];
A = getStruct(Structure,structchainA);
B = getStruct(Structure,structchainB);

R.spectro.eyesclosed.fft.alphaPeak.alphapeakfreqGravity = corr(A',B','rows','pairwise');


structchainA = ['T1.spectro.eyesclosed.fft.alphaPeak.alphapeakamplitudeGravity' ];
structchainB = ['T2.spectro.eyesclosed.fft.alphaPeak.alphapeakamplitudeGravity' ];
A = getStruct(Structure,structchainA);
B = getStruct(Structure,structchainB);

R.spectro.eyesclosed.fft.alphaPeak.alphapeakamplitudeGravity = corr(A',B','rows','pairwise');

structchainA = ['T1.spectro.eyesclosed.fft.alphaPeak.uniquelyIdentifiable' ];
structchainB = ['T2.spectro.eyesclosed.fft.alphaPeak.uniquelyIdentifiable' ];
A = getStruct(Structure,structchainA);
B = getStruct(Structure,structchainB);

R.spectro.eyesclosed.fft.alphaPeak.uniquelyIdentifiable = [A ;  B];

%% 1/f Noise

structchainA = ['T1.spectro.eyesclosed.fft.onefnoise.oneFall' ];
structchainB = ['T2.spectro.eyesclosed.fft.onefnoise.oneFall' ];
A = reshape(getStruct(Structure,structchainA),105,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),105,length(CompleteData));

    for i = 1:size(A,1)
        R.spectro.eyesclosed.fft.onefnoise(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
    end



%% 1/f Fooof
 
% not available for FFT


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% FOR EYES OPEN %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% 1. Spectrogramm Welch
Structure = CompleteData
structchainA = 'T1.spectro.eyesopen.welch.specdata' 
structchainB = 'T2.spectro.eyesopen.welch.specdata' 
A = reshape(getStruct(Structure,structchainA),105,501,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),105,501,length(CompleteData));

for i=1:size(A,1)
    for j = 1:size(A,2)
    R.spectro.eyesopen.welch.specdata(i,j) = corr(squeeze(A(i,j,:)),squeeze(B(i,j,:)),'rows','pairwise');
    end
end

imagesc(R.spectro.eyesopen.welch.specdata(:,1:100)>0.8)
histogram([R.spectro.eyesopen.welch.specdata(:,1:100)])

% 2a. Frequency Bands 

for k = 1:7
    structchainA = ['T1.spectro.eyesopen.welch.fbands(' num2str(k) ').absmean' ];
    structchainB = ['T2.spectro.eyesopen.welch.fbands(' num2str(k) ').absmean' ];
    A = reshape(getStruct(Structure,structchainA),105,length(CompleteData));
    B = reshape(getStruct(Structure,structchainB),105,length(CompleteData));
    for i = 1:size(A,1)
        R.spectro.eyesopen.welch.fbands(k).absmean(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
    end
end

for k = 1:7
    structchainA = ['T1.spectro.eyesopen.welch.fbands(' num2str(k) ').relmean' ];
    structchainB = ['T2.spectro.eyesopen.welch.fbands(' num2str(k) ').relmean' ];
    A = reshape(getStruct(Structure,structchainA),105,length(CompleteData));
    B = reshape(getStruct(Structure,structchainB),105,length(CompleteData));
    for i = 1:size(A,1)
        R.spectro.eyesopen.welch.fbands(k).relmean(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
    end
end

for k = 1:7
    
    for m = 1:6
    structchainA = ['T1.spectro.eyesopen.welch.fbands(' num2str(k) ').elecluster(' num2str(m) ').absmean' ];
    structchainB = ['T2.spectro.eyesopen.welch.fbands(' num2str(k) ').elecluster(' num2str(m) ').absmean' ];
    A = getStruct(Structure,structchainA);
    B = getStruct(Structure,structchainB);

    R.spectro.eyesopen.welch.fbands(k).elecluster(m).absmean = corr(A',B','rows','pairwise');
    R.spectro.eyesopen.welch.fbands(k).elecluster(m).name = CompleteData(1).T1.spectro.eyesopen.welch.fbands(m).elecluster.names;
    end
    
    R.spectro.eyesopen.welch.fbands(k).name = CompleteData(1).T1.spectro.eyesopen.welch.fbands(k).name;

end

%% Alpha Peak

structchainA = ['T1.spectro.eyesopen.welch.alphaPeak.alphapeakfreqMax' ];
structchainB = ['T2.spectro.eyesopen.welch.alphaPeak.alphapeakfreqMax' ];
A = getStruct(Structure,structchainA);
B = getStruct(Structure,structchainB);

R.spectro.eyesopen.welch.alphaPeak.alphapeakfreqMax = corr(A',B','rows','pairwise');

structchainA = ['T1.spectro.eyesopen.welch.alphaPeak.alphapeakamplitudeMax' ];
structchainB = ['T2.spectro.eyesopen.welch.alphaPeak.alphapeakamplitudeMax' ];
A = getStruct(Structure,structchainA);
B = getStruct(Structure,structchainB);

R.spectro.eyesopen.welch.alphaPeak.alphapeakamplitudeMax = corr(A',B','rows','pairwise');


structchainA = ['T1.spectro.eyesopen.welch.alphaPeak.alphapeakfreqDerivative' ];
structchainB = ['T2.spectro.eyesopen.welch.alphaPeak.alphapeakfreqDerivative' ];
A = getStruct(Structure,structchainA);
B = getStruct(Structure,structchainB);

R.spectro.eyesopen.welch.alphaPeak.alphapeakfreqDerivative = corr(A',B','rows','pairwise');


structchainA = ['T1.spectro.eyesopen.welch.alphaPeak.alphapeakamplitudeDerivative' ];
structchainB = ['T2.spectro.eyesopen.welch.alphaPeak.alphapeakamplitudeDerivative' ];
A = getStruct(Structure,structchainA);
B = getStruct(Structure,structchainB);

R.spectro.eyesopen.welch.alphaPeak.alphapeakamplitudeDerivative = corr(A',B','rows','pairwise');


structchainA = ['T1.spectro.eyesopen.welch.alphaPeak.alphapeakfreqGravity' ];
structchainB = ['T2.spectro.eyesopen.welch.alphaPeak.alphapeakfreqGravity' ];
A = getStruct(Structure,structchainA);
B = getStruct(Structure,structchainB);

R.spectro.eyesopen.welch.alphaPeak.alphapeakfreqGravity = corr(A',B','rows','pairwise');


structchainA = ['T1.spectro.eyesopen.welch.alphaPeak.alphapeakamplitudeGravity' ];
structchainB = ['T2.spectro.eyesopen.welch.alphaPeak.alphapeakamplitudeGravity' ];
A = getStruct(Structure,structchainA);
B = getStruct(Structure,structchainB);

R.spectro.eyesopen.welch.alphaPeak.alphapeakamplitudeGravity = corr(A',B','rows','pairwise');

structchainA = ['T1.spectro.eyesopen.welch.alphaPeak.uniquelyIdentifiable' ];
structchainB = ['T2.spectro.eyesopen.welch.alphaPeak.uniquelyIdentifiable' ];
A = getStruct(Structure,structchainA);
B = getStruct(Structure,structchainB);

R.spectro.eyesopen.welch.alphaPeak.uniquelyIdentifiable = [A ;  B];

%% 1/f Noise

structchainA = ['T1.spectro.eyesopen.welch.onefnoise.oneFall' ];
structchainB = ['T2.spectro.eyesopen.welch.onefnoise.oneFall' ];
A = reshape(getStruct(Structure,structchainA),105,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),105,length(CompleteData));

    for i = 1:size(A,1)
        R.spectro.eyesopen.welch.onefnoise(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
    end



%% 1/f Fooof

structchainA = ['T1.spectro.eyesopen.welch.oneFooof.bgparaAvg' ];
structchainB = ['T2.spectro.eyesopen.welch.oneFooof.bgparaAvg' ];
A = reshape(getStruct(Structure,structchainA),2,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),2,length(CompleteData));

R.spectro.eyesopen.welch.oneFooof.bgparaAvg1 = corr(A(1,:)',B(1,:)');
R.spectro.eyesopen.welch.oneFooof.bgparaAvg2 = corr(A(2,:)',B(2,:)');




%%%% FFT %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%


structchainA = 'T1.spectro.eyesopen.fft.specdata' 
structchainB = 'T2.spectro.eyesopen.fft.specdata' 
A = reshape(getStruct(Structure,structchainA),105,151,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),105,151,length(CompleteData));

for i=1:size(A,1)
    for j = 1:size(A,2)
    R.spectro.eyesopen.fft.specdata(i,j) = corr(squeeze(A(i,j,:)),squeeze(B(i,j,:)),'rows','pairwise');
    end
end

imagesc(R.spectro.eyesopen.fft.specdata)
histogram([R.spectro.eyesopen.fft.specdata])

% 2a. Frequency Bands 

for k = 1:7
    structchainA = ['T1.spectro.eyesopen.fft.fbands(' num2str(k) ').absmean' ];
    structchainB = ['T2.spectro.eyesopen.fft.fbands(' num2str(k) ').absmean' ];
    A = reshape(getStruct(Structure,structchainA),105,length(CompleteData));
    B = reshape(getStruct(Structure,structchainB),105,length(CompleteData));
    for i = 1:size(A,1)
        R.spectro.eyesopen.fft.fbands(k).absmean(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
    end
end

for k = 1:7
    structchainA = ['T1.spectro.eyesopen.fft.fbands(' num2str(k) ').relmean' ];
    structchainB = ['T2.spectro.eyesopen.fft.fbands(' num2str(k) ').relmean' ];
    A = reshape(getStruct(Structure,structchainA),105,length(CompleteData));
    B = reshape(getStruct(Structure,structchainB),105,length(CompleteData));
    for i = 1:size(A,1)
        R.spectro.eyesopen.fft.fbands(k).relmean(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
    end
end

for k = 1:7
    
    for m = 1:6
    structchainA = ['T1.spectro.eyesopen.fft.fbands(' num2str(k) ').elecluster(' num2str(m) ').absmean' ];
    structchainB = ['T2.spectro.eyesopen.fft.fbands(' num2str(k) ').elecluster(' num2str(m) ').absmean' ];
    A = getStruct(Structure,structchainA);
    B = getStruct(Structure,structchainB);

    R.spectro.eyesopen.fft.fbands(k).elecluster(m).absmean = corr(A',B','rows','pairwise');
    R.spectro.eyesopen.fft.fbands(k).elecluster(m).name = CompleteData(1).T1.spectro.eyesopen.fft.fbands(m).elecluster.names;
    end
    
    R.spectro.eyesopen.fft.fbands(k).name = CompleteData(1).T1.spectro.eyesopen.fft.fbands(k).name;

end

%% Alpha Peak

structchainA = ['T1.spectro.eyesopen.fft.alphaPeak.alphapeakfreqMax' ];
structchainB = ['T2.spectro.eyesopen.fft.alphaPeak.alphapeakfreqMax' ];
A = getStruct(Structure,structchainA);
B = getStruct(Structure,structchainB);

R.spectro.eyesopen.fft.alphaPeak.alphapeakfreqMax = corr(A',B','rows','pairwise');

structchainA = ['T1.spectro.eyesopen.fft.alphaPeak.alphapeakamplitudeMax' ];
structchainB = ['T2.spectro.eyesopen.fft.alphaPeak.alphapeakamplitudeMax' ];
A = getStruct(Structure,structchainA);
B = getStruct(Structure,structchainB);

R.spectro.eyesopen.fft.alphaPeak.alphapeakamplitudeMax = corr(A',B','rows','pairwise');


structchainA = ['T1.spectro.eyesopen.fft.alphaPeak.alphapeakfreqDerivative' ];
structchainB = ['T2.spectro.eyesopen.fft.alphaPeak.alphapeakfreqDerivative' ];
A = getStruct(Structure,structchainA);
B = getStruct(Structure,structchainB);

R.spectro.eyesopen.fft.alphaPeak.alphapeakfreqDerivative = corr(A',B','rows','pairwise');


structchainA = ['T1.spectro.eyesopen.fft.alphaPeak.alphapeakamplitudeDerivative' ];
structchainB = ['T2.spectro.eyesopen.fft.alphaPeak.alphapeakamplitudeDerivative' ];
A = getStruct(Structure,structchainA);
B = getStruct(Structure,structchainB);

R.spectro.eyesopen.fft.alphaPeak.alphapeakamplitudeDerivative = corr(A',B','rows','pairwise');


structchainA = ['T1.spectro.eyesopen.fft.alphaPeak.alphapeakfreqGravity' ];
structchainB = ['T2.spectro.eyesopen.fft.alphaPeak.alphapeakfreqGravity' ];
A = getStruct(Structure,structchainA);
B = getStruct(Structure,structchainB);

R.spectro.eyesopen.fft.alphaPeak.alphapeakfreqGravity = corr(A',B','rows','pairwise');


structchainA = ['T1.spectro.eyesopen.fft.alphaPeak.alphapeakamplitudeGravity' ];
structchainB = ['T2.spectro.eyesopen.fft.alphaPeak.alphapeakamplitudeGravity' ];
A = getStruct(Structure,structchainA);
B = getStruct(Structure,structchainB);

R.spectro.eyesopen.fft.alphaPeak.alphapeakamplitudeGravity = corr(A',B','rows','pairwise');

structchainA = ['T1.spectro.eyesopen.fft.alphaPeak.uniquelyIdentifiable' ];
structchainB = ['T2.spectro.eyesopen.fft.alphaPeak.uniquelyIdentifiable' ];
A = getStruct(Structure,structchainA);
B = getStruct(Structure,structchainB);

R.spectro.eyesopen.fft.alphaPeak.uniquelyIdentifiable = [A ;  B];

%% 1/f Noise

structchainA = ['T1.spectro.eyesopen.fft.onefnoise.oneFall' ];
structchainB = ['T2.spectro.eyesopen.fft.onefnoise.oneFall' ];
A = reshape(getStruct(Structure,structchainA),105,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),105,length(CompleteData));

    for i = 1:size(A,1)
        R.spectro.eyesopen.fft.onefnoise(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
    end




%% 1/f Fooof
 
% not available for FFT




%%%%%%% Eyetracking Measures %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


structchainA = ['T1.ET.pupilsize_block_mean' ];
structchainB = ['T2.ET.pupilsize_block_mean'  ];
A = reshape(getStruct(Structure,structchainA),5,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),5,length(CompleteData));

for i = 1:size(A,1)
    R.ET.pupilsize_block_mean(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
end


structchainA = ['T1.ET.pupilsize_block_median' ];
structchainB = ['T2.ET.pupilsize_block_median'  ];
A = reshape(getStruct(Structure,structchainA),5,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),5,length(CompleteData));

for i = 1:size(A,1)
    R.ET.pupilsize_block_median(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
end


structchainA = ['T1.ET.pupilsize_overall_mean' ];
structchainB = ['T2.ET.pupilsize_overall_mean'  ];
A = getStruct(Structure,structchainA);
B = getStruct(Structure,structchainB);

R.ET.pupilsize_overall_mean = corr(A',B','rows','pairwise');



structchainA = ['T1.ET.pupilsize_overall_mean' ];
structchainB = ['T2.ET.pupilsize_overall_mean'  ];
A = getStruct(Structure,structchainA);
B = getStruct(Structure,structchainB);

R.ET.pupilsize_overall_mean = corr(A',B','rows','pairwise');


structchainA = ['T1.ET.pupilsize_overall_median' ];
structchainB = ['T2.ET.pupilsize_overall_median'  ];
A = getStruct(Structure,structchainA);
B = getStruct(Structure,structchainB);

R.ET.pupilsize_overall_median = corr(A',B','rows','pairwise');


structchainA = ['T1.ET.mdl_full.Coefficients.Estimate(2)' ];
structchainB = ['T2.ET.mdl_full.Coefficients.Estimate(2)'  ];
A = getStruct(Structure,structchainA);
B = getStruct(Structure,structchainB);

R.ET.mdl_full.Coefficients = corr(A',B','rows','pairwise');

%% Microstate Analyse

%% our Version T1 f�r T1 / T2 f�r T2

structchainA = 'T1.microstateOurVers.stats.GEVtotal';
structchainB = 'T2.microstateOurVers.stats.GEVtotal';
A = getStruct(Structure,structchainA);
B = getStruct(Structure,structchainB);

R.microstateOurVers.stats.GEVtotal = corr(A',B','rows','pairwise');


structchainA = 'T1.microstateOurVers.stats.Gfp';
structchainB = 'T2.microstateOurVers.stats.Gfp';
A = reshape(getStruct(Structure,structchainA),4,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),4,length(CompleteData));

for i = 1:size(A,1)
    R.microstateOurVers.stats.Gfp(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
end

structchainA = 'T1.microstateOurVers.stats.Occurence';
structchainB = 'T2.microstateOurVers.stats.Occurence';
A = reshape(getStruct(Structure,structchainA),4,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),4,length(CompleteData));

for i = 1:size(A,1)
    R.microstateOurVers.stats.Occurence(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
end


structchainA = 'T1.microstateOurVers.stats.Duration';
structchainB = 'T2.microstateOurVers.stats.Duration';
A = reshape(getStruct(Structure,structchainA),4,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),4,length(CompleteData));

for i = 1:size(A,1)
    R.microstateOurVers.stats.Duration(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
end

structchainA = 'T1.microstateOurVers.stats.Coverage';
structchainB = 'T2.microstateOurVers.stats.Coverage';
A = reshape(getStruct(Structure,structchainA),4,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),4,length(CompleteData));

for i = 1:size(A,1)
    R.microstateOurVers.stats.Coverage(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
end

structchainA = 'T1.microstateOurVers.stats.GEV';
structchainB = 'T2.microstateOurVers.stats.GEV';
A = reshape(getStruct(Structure,structchainA),4,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),4,length(CompleteData));

for i = 1:size(A,1)
    R.microstateOurVers.stats.GEV(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
end


structchainA = 'T1.microstateOurVers.stats.MspatCorr';
structchainB = 'T2.microstateOurVers.stats.MspatCorr';
A = reshape(getStruct(Structure,structchainA),4,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),4,length(CompleteData));

for i = 1:size(A,1)
    R.microstateOurVers.stats.MspatCorr(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
end

structchainA = 'T1.microstateOurVers.stats.TP';
structchainB = 'T2.microstateOurVers.stats.TP';
A = reshape(getStruct(Structure,structchainA),4,4,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),4,4,length(CompleteData));

for i = 1:size(A,1)
    for j=1:size(A,2)
    R.microstateOurVers.stats.TP(i,j) = corr(squeeze(A(i,j,:)),squeeze(B(i,j,:)),'rows','pairwise');
    
    end
end

%% our Version T1T2 zusammen als Prototype

structchainA = 'T1.microstateOurVersT1T2.stats.GEVtotal';
structchainB = 'T2.microstateOurVersT1T2.stats.GEVtotal';
A = getStruct(Structure,structchainA);
B = getStruct(Structure,structchainB);

R.microstateOurVersT1T2.stats.GEVtotal = corr(A',B','rows','pairwise');


structchainA = 'T1.microstateOurVersT1T2.stats.Gfp';
structchainB = 'T2.microstateOurVersT1T2.stats.Gfp';
A = reshape(getStruct(Structure,structchainA),4,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),4,length(CompleteData));

for i = 1:size(A,1)
    R.microstateOurVersT1T2.stats.Gfp(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
end

structchainA = 'T1.microstateOurVersT1T2.stats.Occurence';
structchainB = 'T2.microstateOurVersT1T2.stats.Occurence';
A = reshape(getStruct(Structure,structchainA),4,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),4,length(CompleteData));

for i = 1:size(A,1)
    R.microstateOurVersT1T2.stats.Occurence(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
end


structchainA = 'T1.microstateOurVersT1T2.stats.Duration';
structchainB = 'T2.microstateOurVersT1T2.stats.Duration';
A = reshape(getStruct(Structure,structchainA),4,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),4,length(CompleteData));

for i = 1:size(A,1)
    R.microstateOurVersT1T2.stats.Duration(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
end

structchainA = 'T1.microstateOurVersT1T2.stats.Coverage';
structchainB = 'T2.microstateOurVersT1T2.stats.Coverage';
A = reshape(getStruct(Structure,structchainA),4,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),4,length(CompleteData));

for i = 1:size(A,1)
    R.microstateOurVersT1T2.stats.Coverage(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
end

structchainA = 'T1.microstateOurVersT1T2.stats.GEV';
structchainB = 'T2.microstateOurVersT1T2.stats.GEV';
A = reshape(getStruct(Structure,structchainA),4,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),4,length(CompleteData));

for i = 1:size(A,1)
    R.microstateOurVersT1T2.stats.GEV(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
end


structchainA = 'T1.microstateOurVersT1T2.stats.MspatCorr';
structchainB = 'T2.microstateOurVersT1T2.stats.MspatCorr';
A = reshape(getStruct(Structure,structchainA),4,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),4,length(CompleteData));

for i = 1:size(A,1)
    R.microstateOurVersT1T2.stats.MspatCorr(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
end

structchainA = 'T1.microstateOurVersT1T2.stats.TP';
structchainB = 'T2.microstateOurVersT1T2.stats.TP';
A = reshape(getStruct(Structure,structchainA),4,4,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),4,4,length(CompleteData));

for i = 1:size(A,1)
    for j=1:size(A,2)
    R.microstateOurVersT1T2.stats.TP(i,j) = corr(squeeze(A(i,j,:)),squeeze(B(i,j,:)),'rows','pairwise');
    
    end
end


%% Thomas Version T1 f�r T1 / T2 f�r T2

structchainA = 'T1.microstateThomas.stats.GEVtotal';
structchainB = 'T2.microstateThomas.stats.GEVtotal';
A = getStruct(Structure,structchainA);
B = getStruct(Structure,structchainB);

R.microstateThomas.stats.GEVtotal = corr(A',B','rows','pairwise');


structchainA = 'T1.microstateThomas.stats.Gfp';
structchainB = 'T2.microstateThomas.stats.Gfp';
A = reshape(getStruct(Structure,structchainA),4,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),4,length(CompleteData));

for i = 1:size(A,1)
    R.microstateThomas.stats.Gfp(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
end

structchainA = 'T1.microstateThomas.stats.Occurence';
structchainB = 'T2.microstateThomas.stats.Occurence';
A = reshape(getStruct(Structure,structchainA),4,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),4,length(CompleteData));

for i = 1:size(A,1)
    R.microstateThomas.stats.Occurence(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
end


structchainA = 'T1.microstateThomas.stats.Duration';
structchainB = 'T2.microstateThomas.stats.Duration';
A = reshape(getStruct(Structure,structchainA),4,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),4,length(CompleteData));

for i = 1:size(A,1)
    R.microstateThomas.stats.Duration(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
end

structchainA = 'T1.microstateThomas.stats.Coverage';
structchainB = 'T2.microstateThomas.stats.Coverage';
A = reshape(getStruct(Structure,structchainA),4,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),4,length(CompleteData));

for i = 1:size(A,1)
    R.microstateThomas.stats.Coverage(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
end

structchainA = 'T1.microstateThomas.stats.GEV';
structchainB = 'T2.microstateThomas.stats.GEV';
A = reshape(getStruct(Structure,structchainA),4,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),4,length(CompleteData));

for i = 1:size(A,1)
    R.microstateThomas.stats.GEV(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
end


structchainA = 'T1.microstateThomas.stats.MspatCorr';
structchainB = 'T2.microstateThomas.stats.MspatCorr';
A = reshape(getStruct(Structure,structchainA),4,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),4,length(CompleteData));

for i = 1:size(A,1)
    R.microstateThomas.stats.MspatCorr(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
end

structchainA = 'T1.microstateThomas.stats.TP';
structchainB = 'T2.microstateThomas.stats.TP';
A = reshape(getStruct(Structure,structchainA),4,4,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),4,4,length(CompleteData));

for i = 1:size(A,1)
    for j=1:size(A,2)
    R.microstateThomas.stats.TP(i,j) = corr(squeeze(A(i,j,:)),squeeze(B(i,j,:)),'rows','pairwise');
    
    end
end

%% our Version T1T2 zusammen als Prototype

structchainA = 'T1.microstateThomasT1T2.stats.GEVtotal';
structchainB = 'T2.microstateThomasT1T2.stats.GEVtotal';
A = getStruct(Structure,structchainA);
B = getStruct(Structure,structchainB);

R.microstateThomasT1T2.stats.GEVtotal = corr(A',B','rows','pairwise');


structchainA = 'T1.microstateThomasT1T2.stats.Gfp';
structchainB = 'T2.microstateThomasT1T2.stats.Gfp';
A = reshape(getStruct(Structure,structchainA),4,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),4,length(CompleteData));

for i = 1:size(A,1)
    R.microstateThomasT1T2.stats.Gfp(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
end

structchainA = 'T1.microstateThomasT1T2.stats.Occurence';
structchainB = 'T2.microstateThomasT1T2.stats.Occurence';
A = reshape(getStruct(Structure,structchainA),4,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),4,length(CompleteData));

for i = 1:size(A,1)
    R.microstateThomasT1T2.stats.Occurence(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
end


structchainA = 'T1.microstateThomasT1T2.stats.Duration';
structchainB = 'T2.microstateThomasT1T2.stats.Duration';
A = reshape(getStruct(Structure,structchainA),4,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),4,length(CompleteData));

for i = 1:size(A,1)
    R.microstateThomasT1T2.stats.Duration(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
end

structchainA = 'T1.microstateThomasT1T2.stats.Coverage';
structchainB = 'T2.microstateThomasT1T2.stats.Coverage';
A = reshape(getStruct(Structure,structchainA),4,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),4,length(CompleteData));

for i = 1:size(A,1)
    R.microstateThomasT1T2.stats.Coverage(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
end

structchainA = 'T1.microstateThomasT1T2.stats.GEV';
structchainB = 'T2.microstateThomasT1T2.stats.GEV';
A = reshape(getStruct(Structure,structchainA),4,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),4,length(CompleteData));

for i = 1:size(A,1)
    R.microstateThomasT1T2.stats.GEV(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
end


structchainA = 'T1.microstateThomasT1T2.stats.MspatCorr';
structchainB = 'T2.microstateThomasT1T2.stats.MspatCorr';
A = reshape(getStruct(Structure,structchainA),4,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),4,length(CompleteData));

for i = 1:size(A,1)
    R.microstateThomasT1T2.stats.MspatCorr(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
end

structchainA = 'T1.microstateThomasT1T2.stats.TP';
structchainB = 'T2.microstateThomasT1T2.stats.TP';
A = reshape(getStruct(Structure,structchainA),4,4,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),4,4,length(CompleteData));

for i = 1:size(A,1)
    for j=1:size(A,2)
    R.microstateThomasT1T2.stats.TP(i,j) = corr(squeeze(A(i,j,:)),squeeze(B(i,j,:)),'rows','pairwise');
    
    end
end



%% Thomas Single Subjects

structchainA = 'T1.microstateThomasSingleSubject.stats.GEVtotal';
structchainB = 'T2.microstateThomasSingleSubject.stats.GEVtotal';
A = getStruct(Structure,structchainA);
B = getStruct(Structure,structchainB);

R.microstateThomasSingleSubject.stats.GEVtotal = corr(A',B','rows','pairwise');


structchainA = 'T1.microstateThomasSingleSubject.stats.Gfp';
structchainB = 'T2.microstateThomasSingleSubject.stats.Gfp';
A = reshape(getStruct(Structure,structchainA),4,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),4,length(CompleteData));

for i = 1:size(A,1)
    R.microstateThomasSingleSubject.stats.Gfp(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
end

structchainA = 'T1.microstateThomasSingleSubject.stats.Occurence';
structchainB = 'T2.microstateThomasSingleSubject.stats.Occurence';
A = reshape(getStruct(Structure,structchainA),4,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),4,length(CompleteData));

for i = 1:size(A,1)
    R.microstateThomasSingleSubject.stats.Occurence(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
end


structchainA = 'T1.microstateThomasSingleSubject.stats.Duration';
structchainB = 'T2.microstateThomasSingleSubject.stats.Duration';
A = reshape(getStruct(Structure,structchainA),4,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),4,length(CompleteData));

for i = 1:size(A,1)
    R.microstateThomasSingleSubject.stats.Duration(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
end

structchainA = 'T1.microstateThomasSingleSubject.stats.Coverage';
structchainB = 'T2.microstateThomasSingleSubject.stats.Coverage';
A = reshape(getStruct(Structure,structchainA),4,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),4,length(CompleteData));

for i = 1:size(A,1)
    R.microstateThomasSingleSubject.stats.Coverage(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
end

structchainA = 'T1.microstateThomasSingleSubject.stats.GEV';
structchainB = 'T2.microstateThomasSingleSubject.stats.GEV';
A = reshape(getStruct(Structure,structchainA),4,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),4,length(CompleteData));

for i = 1:size(A,1)
    R.microstateThomasSingleSubject.stats.GEV(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
end


structchainA = 'T1.microstateThomasSingleSubject.stats.MspatCorr';
structchainB = 'T2.microstateThomasSingleSubject.stats.MspatCorr';
A = reshape(getStruct(Structure,structchainA),4,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),4,length(CompleteData));

for i = 1:size(A,1)
    R.microstateThomasSingleSubject.stats.MspatCorr(i,:) = corr(A(i,:)',B(i,:)','rows','pairwise');
end

structchainA = 'T1.microstateThomasSingleSubject.stats.TP';
structchainB = 'T2.microstateThomasSingleSubject.stats.TP';
A = reshape(getStruct(Structure,structchainA),4,4,length(CompleteData));
B = reshape(getStruct(Structure,structchainB),4,4,length(CompleteData));

for i = 1:size(A,1)
    for j=1:size(A,2)
    R.microstateThomasSingleSubject.stats.TP(i,j) = corr(squeeze(A(i,j,:)),squeeze(B(i,j,:)),'rows','pairwise');
    
    end
end


save('/Volumes/methlab-1/Neurometric/2017/GroupLevelData/Resting/TestRetestRestingResults.mat','R')