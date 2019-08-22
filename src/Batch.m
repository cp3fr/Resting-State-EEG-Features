%%Batch.m
%
%Batch script for extracting Resting EEG features from HBN data
%works in two steps: first, computes spectral features (can be done in serial or parallel), 
%then computes fooof parameters (needs matlab to call python and use the fooof toolbox)
%files that raise an error during processing are skipped
%makes a summary table listing for each subject the available input and outputfiles
%finally allows adding the output features to the summary table for later processing
%
clear all; close all; clc;

%=============================================================
%manual switches
%whether to skip previously processed files (1) or to compute them again (0)
%applies only to compute_spectro and compute_fooof
skip_already_processed = 1;
%what tasks shall be done
compute_spectro    = 0;
compute_fooof      = 0;
processing_summary = 0;
write_csv          = 1;  

%=============================================================
%load the processing settings
settings = default_settings();

%=============================================================
%pipeline_spectro
%loads the file, computes the features, saves the features
if compute_spectro==1

  %find all inputdata folders
  folders = dir(settings.path.data);
  folders = folders(contains({folders.name},'NDAR'));

  %skip the ones for which an output already exists
  if skip_already_processed==1
    tbl = pl_processing_summary(settings);
    files_of_interest = tbl.ID(tbl.HasSpectroFeatures==0);
    ind = zeros(length(folders),1);
    for fn = files_of_interest'
      ind(strcmpi({folders.name},fn{1}))=1;
    end
    ind = logical(ind);
    folders = folders(ind);
    clear tbl files_of_interest ind fn;
  end

  %loop over subject data..
  %..parallel processing
  if isSciencecloud

    parpool('local',16);

    parfor(i=1:length(folders),16)
      pl_spectro(folders(i),settings.path.results,settings); 
    end

  %..serial processing
  else
    
    for i=1:length(folders)
      pl_spectro(folders(i),path.results,settings);
    end

  end

end

%=============================================================
%pipeline fooof
%loads the features, computes and adds fooof parameters, thesaves features
if compute_fooof==1

  %add python and fooof 
  [~, ~, isloaded] = pyversion;
  if isloaded
      disp('To change the Python version, restart MATLAB, then call pyversion.')
  else
      pyversion(settings.path.python);
  end
  insert(py.sys.path,int32(0),settings.path.fooof(1:en-1));
  addpath(settings.path.fooof)
  clear isloaded
  pyversio
  %list of data folder
  folders = dir(settings.path.results)
  folders = folders(contains({folders.name},'NDAR'))
  %skip the ones for which an output already exist
  if skip_already_processed==1
    tbl = pl_processing_summary(settings)
    files_of_interest = tbl.ID(tbl.HasSpectroFeatures==1 & tbl.HasFooofFeatures==0);
    ind = zeros(length(folders),1)
    for fn = files_of_interest
      ind(strcmpi({folders.name},fn{1}))=1
    end
    ind = logical(ind);
    folders = folders(ind);
    clear tbl files_of_interest ind fn;
  end

  %loop over subject data..
  %..serial processing
  for i=1:length(folders)
    pl_fooof(folders(i), settings);
  end


end

%=============================================================
%processing summary
%lists all input and outputfiles in processing_summary table
if processing_summary==1

  tbl = pl_processing_summary(settings);

  save([settings.path.results,filesep,'processing_summary.mat'],'tbl');

end

%=============================================================
%write_csv
%writes out the features to csv files
if write_csv==1

  %load processing summary table
  load([settings.path.results,filesep,'processing_summary.mat'],'tbl');

  %select files with good/ok data quality and for who features were extracted
  % ind = ( logical(tbl.HasOkQuality) | logical(tbl.HasGoodQuality) ) ...
  %     & logical(tbl.HasFooofFeatures);
  %select all subjects for whom features are available
  ind = logical(tbl.HasFooofFeatures);
  tbl = tbl(ind,:);

  %write csv of features at electrode cluster level (302 columns = 50 features x 6 clusters + 2 info)
  pl_write_csv_clusters(tbl,settings);

  %write csv of features at channels level (5054 columns = 50 features x 105 channels + 2 info)
  pl_write_csv_channels(tbl,settings);

  %write csv of features at channels level (52 columns = 50 features + 2 info)
  pl_write_csv_average(tbl,settings);

  %check the loaded csv file
  % tbl_clust = readtable([settings.path.results,'resting_eeg_clusters.csv']);
  % tbl_chans = readtable([settings.path.results,'resting_eeg_channels.csv']);
  % tbl_avg = readtable([settings.path.results,'resting_eeg_average.csv']);

end


















