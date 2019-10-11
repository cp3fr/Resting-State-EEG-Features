function p03_01_microstates_gfppeaks(s)

%if this step is required
if s.todo.microstates_gfppeaks==1

  %find all input folders
  %here: eegdata.mat in results/process/SUBJFOLDER/
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
      pl_microstates_gfppeaks(folders(i), folders(i), s); 
    end

  %..serial processing
  else

    %loop over folders
    for i=1:length(folders)
      pl_microstates_gfppeaks(folders(i), folders(i), s);
    end

  end

end
