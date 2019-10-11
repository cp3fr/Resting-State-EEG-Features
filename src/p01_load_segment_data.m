function p01_load_segment_data(s)

  %if this step is required
  if s.todo.load_segment_data

    %find all input folders
    %here: gip_SUBJNAME__RestingState_EEG.mat in automagic output folder..
    folders = dir(s.path.data);
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

      %loop over folders..
      parfor(i=1:length(folders))
        pl_load_segment_data(folders(i), s.path.process, s); 
      end

    %..serial processing
    else

      %loop over folders..
      for i=1:length(folders)
        pl_load_segment_data(folders(i), s.path.process, s);
      end

    end

  end

end