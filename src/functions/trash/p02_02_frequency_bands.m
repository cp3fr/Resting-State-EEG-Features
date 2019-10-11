function p02_02_frequency_bands(s)

  %if this step is required
  if s.todo.frequency_bands

    %find all input folders
    %here: specdata.mat in results/process/SUBJFOLDER/
    folders = dir(s.path.process); 
    folders = folders(contains({folders.name},'NDAR'));

    %loop over subject data..
    %..parallel processing
    if s.isSciencecloud

      %just in case a parpool has been open before delete it here
      try
        delete(gcp('nocreate'))
      end

      %initialize a parallel pool
      parpool('local',s.parallel.workers);

      %loop over folders
      parfor(i=1:length(folders))
        pl_frequency_bands(folders(i), folders(i), s); 
      end

    %..serial processing
    else

      %loop over folders
      for i=1:length(folders)
        pl_frequency_bands(folders(i), folders(i), s);
      end

    end

  end

end