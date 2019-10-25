function make_processing_summary(folders,s)


  %processing summary table
  summary = table;

  %loop over subject folders
  for i = 1:length(folders)

    disp(sprintf('..making summary, subject %d/%d',i,length(folders)))

    %subject filepath
    fp = [folders(i).folder,filesep,folders(i).name,filesep];

    %make a table for the current subject
    tbl = table;

    %add subject id
    tbl.id = {folders(i).name};

    %add subject filepath
    tbl.filepath = {fp};

    %add info file fields
    fn = 'info.mat';
    load([fp,fn],'info');
    tbl = cat(2,tbl, struct2table(info,'AsArray',true));
    clear fn info;

    %add overview of files present in the subject folder
    for vn = {'info','eegdata','eegdata_eyesclosed','eegdata_eyesopen','specdata_eyesclosed','specdata_eyesopen','specdata_fbands_eyesclosed','specdata_fbands_eyesopen','specdata_fooof_eyesclosed','specdata_fooof_eyesopen','gfppeaks_eyesclosed','gfppeaks_eyesopen','microstates_eyesclosed','microstates_eyesopen'}

      tbl.(sprintf('has_%s',vn{1}))=(exist([fp,vn{1},'.mat'])==2);

    end

    %finally add missing columns
    currhdr = tbl.Properties.VariableNames;
    hdr = summary.Properties.VariableNames;
    ind = ones(1,length(hdr));
    for vn = currhdr
      ind(contains(hdr,vn))=0;
    end
    hdr=hdr(logical(ind));
    for vn = hdr
      tbl.(vn{1})=NaN;
    end
    clear currhdr hdr ind vn;

    %add the current subjects table to the overall table
    summary = cat(1, summary, tbl);

    %cleanup
    clear info fp fn;

  end

  %check if the outputfolder exists
  fp = s.path.tables;
  if ~isdir(fp)
    mkdir(fp);
  end

  %outputfile name
  fn = 'summary.mat';

  %save the outputfile
  disp(['..saving ',fp,fn])
  save([fp,fn],'summary')



end