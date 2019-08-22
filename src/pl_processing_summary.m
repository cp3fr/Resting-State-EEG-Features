function tbl = pl_processing_summary(settings)

  disp(['..making processing summary table.'])

  % make a table with one row per subject
  folders = dir(settings.path.data);
  folders = folders(contains({folders.name},'NDAR'));
  tbl = struct2table(folders);
  tbl = tbl(:,1:2);
  tbl.Properties.VariableNames={'ID','Inputpath'};

  % finds all input folders (makes the rows)
  tbl.Inputpath = cellfun(@(x,y) [x,filesep,y,filesep],tbl.Inputpath,tbl.ID,'UniformOutput',false);

  % in each input folder number of available EEG files
  % name of input EEG file
  tbl.NumInputfiles(:) = 0;
  tbl.Inputfilename(:) = {''};
  for i = 1:size(tbl,1)

    files = dir(tbl.Inputpath{i});

    files = files(...
      contains({files.name},'_RestingState_EEG') ...
      & contains({files.name},'.mat') ...
      & ~contains({files.name},'reduced') ...
      );

    tbl.NumInputfiles(i)=length(files);

    if length(files)>0
      tbl.Inputfilename(i)={files.name};
    end

  end

  % in output folder whether output folder exists
  tbl.Outputpath = cellfun(@(x) [settings.path.results,x,filesep],tbl.ID,'UniformOutput',false);

  % whether spectro features exists
  % whether fooof features exists
  tbl.HasSpectroFeatures(:) = 0;
  tbl.HasFooofFeatures(:) = 0;
  for i=1:size(tbl,1)

    if isdir(tbl.Outputpath{i})

      if exist([tbl.Outputpath{i},'features_spectro.mat'],'file')==2
        tbl.HasSpectroFeatures(i)=1;
      end

      if exist([tbl.Outputpath{i},'features_spectro_fooof.mat'],'file')==2
        tbl.HasFooofFeatures(i)=1;
      end

    end

  end




end