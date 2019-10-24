function [d,t] = collect_gfppeaks_all_subjects(d,t,eyes,folder,settings)

  %input path and names
  fp = [folder.folder,filesep,folder.name,filesep];
  fn_gfppeaks = ['gfppeaks_',eyes,'.mat'];
  fn_info = 'info.mat';

  %load info file and add some defaults
  load([fp,fn_info],'info')

  %determine if data quality is sufficient
  is_usable = false;
  for val = settings.microstate.segmentation.qualityratings
    if strcmpi(lower(info.qualityrating),lower(val))
      is_usable = true;
    end
  end
  clear val ind;

  %if file exists and data quality is sufficient
  if exist([fp,fn]) && is_usable


    %load info file and add some defaults
    load([fp,fn_gfppeaks],'GEEG')

    tbl = table;

    %number of old sampling points already in the data
    if isempty(d)
      n_old = 0;
    else
      n_old = size(d,2);
    end

    %number of new sampling points in GEEG
    n = size(GEEG,2);

    tbl.sp = [1:n]+n_old;
    tbl.subject_sp = [1:n]';
    tbl.subject_id = cell(n,1);
    tbl.subject_id(:) = {folder.name};
    tbl.filepathname = cell(n,1);
    tbl.filepathname = {fp};

    t = cat(1,t,tbl);

    d = cat(2,d,GEEG);   

  end

end