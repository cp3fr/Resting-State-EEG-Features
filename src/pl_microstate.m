%%function pl_microstate(inputfolder,outputfolder,settings)
%
%christian.pfeiffer@uzh.ch
%01.10.2019
%
function pl_microstate(inputfolder,outputfolder,settings)


  %% LOAD/SEGMENT EEG


  %filepath and name for segmented EEG
  fp_eeg_segments = [outputfolder,inputfolder.name,filesep];
  fn_eeg_segments = 'eeg_segments.mat';

  %if segmented EEG already exists
  if exist([fp_eeg_segments,fn_eeg_segments])

    %load segmented EEG
    load([fp_eeg_segments,fn_eeg_segments],'EEG');

  %if segmented EEG does not exist
  else

    %find the relevant files
    files = dir([inputfolder.folder,filesep,inputfolder.name,filesep]);
    files = files(...
      contains({files.name},'_RestingState_EEG') ...
      & contains({files.name},'.mat') ...
      & ~contains({files.name},'reduced') ...
      );

    if isempty(files)

      disp(['..skipping ',inputfolder.folder,filesep,inputfolder.name])

    else
    
      disp(['..loading ',files.folder,filesep,files.name])

      %load the EEG file
      load([files.folder,filesep,files.name],'EEG');

      %fix the missing latency field
      for i = 1:length(EEG.event)
        EEG.event(i).latency = EEG.event(i).sample;
      end

      %compute the segments
      try
        EEG = compute_resting_spectro(EEG,settings);
      end

      %remove the spectro field
      if isfield(EEG,'spectro')
        EEG = rmfield(EEG,'spectro');
      end

    end

  end


  %% COMPUTE MICROSTATES


  %compute microstates (segmentation on single subject level)
  try

    %segmentation Eyes Closed for Microstate peaks
    EEGtmp = RestingSegment(EEG,settings.segment.eyesclosed);

    %get GFP peaks
    EEGtmp = pop_micro_selectdata( EEGtmp, [], ...
        'datatype', 'spontaneous',...
        'avgref', settings.microstate.avgref, ...
        'normalise', settings.microstate.normalise, ...
        'MinPeakDist', settings.microstate.MinPeakDist, ...
        'Npeaks', settings.microstate.Npeaks, ...
        'GFPthresh', settings.microstate.GFPthresh);

    %microstate segmentation on the single level
    EEGtmp = pop_micro_segment( EEGtmp, ...
      'algorithm','modkmeans', ...
      'Nmicrostates', settings.microstate.Nmicrostates, ...
      'Nrepetitions',settings.microstate.Nrepetitions);
    EEG.microstate = EEGtmp.microstate;

  end


  %% SAVE THE FEATURES, PLOTS, GFP (AND SEGMENTED EEG)


  %check if features were computed
  if isfield(EEG,'microstate')

    %extract the features
    features = EEG.microstate;

    %outputpath for the features
    outputpath = [outputfolder,inputfolder.name,filesep];

    %make the output folder
    if ~isdir(outputpath)
      mkdir(outputpath);
    end

    %save the features to output folder
    save([outputpath,'features_microstate','.mat'],'features');

    %make the plot
    fh=figure('visible','off'); 
    MicroPlotTopo( EEGtmp, 'plot_range', settings.microstate.Nmicrostates );

    %outputpath for the plot
    outputpath = [outputfolder,inputfolder.name,filesep,'microstate',filesep];

    %make the output folder
    if ~isdir(outputpath)
      mkdir(outputpath);
    end

    %save the plot
    saveas(fh,[outputpath,'MicroPrototypes','.fig'])
    saveas(fh,[outputpath,'MicroPrototypes','.png'])
    close;

    %get gfp peaks and chanlocs for backfitting
    GEEG = EEG.microstate.data;
    chanlocs = EEGtmp.chanlocs;

    %outputpath for gfp peaks and chanlocs
    outputpath = [outputfolder,inputfolder.name,filesep,'microstate',filesep];

    %make the output folder
    if ~isdir(outputpath)
      mkdir(outputpath);
    end

    %save the features to output folder
    save([outputpath,'GEEG','.mat'],'GEEG');
    save([outputpath,'chanlocs','.mat'],'chanlocs');

    
    %if segmented EEG does not exist
    if ~exist([fp_eeg_segments,fn_eeg_segments])

      %remove the microstate field because it is saved in the features file
      if isfield(EEG,'microstate')
        EEG = rmfield(EEG,'microstate');
      end
    
      %save the EEG data
      save([fp_eeg_segments,fn_eeg_segments],'EEG')

    end

  end
end