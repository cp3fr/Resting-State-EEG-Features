%%pl_spectro(fp)
%
% christian.pfeiffer@uzh.ch
% 20.08.2019
%
function pl_spectro(inputfolder,outputfolder,settings)

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

    %compute the features
    try
      EEG = compute_resting_spectro(EEG,settings);
    end

    %check if features were computed
    if isfield(EEG,'spectro')

      %extract the features
      features = EEG.spectro;

      outputpath = [outputfolder,inputfolder.name,filesep];

      %make the output folder
      if ~isdir(outputpath)
        mkdir(outputpath);
      end

      %save the features to output folder
      save([outputpath,'features_spectro','.mat'],'features');

    end

  end


end