function p03_01_microstates_within_subjects()

  
%=============================================================
%pipeline_microstates
if compute_microstate==1

  %find all inputdata folders
  folders = dir(settings.path.data);
  folders = folders(contains({folders.name},'NDAR'));

   %process all subjects for who the output is incomplete
  if processing_mode==1
    fp = settings.path.tables;
    fn = 'processing_summary.mat';
    load([fp,fn],'tbl');
    ind = ~ (...
        (tbl.HasMicrostateFeatures==1)...
      );
    files_of_interest = tbl.ID(ind);
    ind = zeros(length(folders),1);
    for fn = files_of_interest'
      ind(strcmpi({folders.name},fn{1}))=1;
    end
    ind = logical(ind);
    folders = folders(ind);
    clear tbl files_of_interest ind fn;

  %process subjects of interest only
  elseif processing_mode==2
    fp = settings.path.tables;
    fn = 'processing_summary.mat';
    load([fp,fn],'tbl');
    ind = zeros(size(tbl,1),1);
    for sn = subjects_of_interest
      ind(strcmpi(tbl.ID,sn))=1;
    end
    ind=logical(ind);
    files_of_interest = tbl.ID(ind);
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
  if settings.isSciencecloud
    %just in case a parpool has been open before delete it here
    try
      delete(gcp('nocreate'))
    end
    %initialize a parallel pool
    parpool('local',settings.parallel.workers);
    %gfp peak extraction and microstate individual fitting
    parfor(i=1:length(folders))
      pl_microstate(folders(i),settings.path.process,settings); 
    end
  %..serial processing
  else
    %gfp peak extraction and microstate individual fitting
    for i=1:length(folders)
      pl_microstate(folders(i),settings.path.process,settings);
    end
  end

end
