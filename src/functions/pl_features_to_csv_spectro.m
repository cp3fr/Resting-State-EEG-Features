function pl_features_to_csv_spectro(level, folders, s)

  %output files path and names
  fp_table = s.path.tables;
  fn_table = sprintf('features_spectro_%s.mat',level);
  fp_csv = s.path.csv;
  fn_csv = sprintf('features_spectro_%s.csv',level);

  %only run this step if outputfiles do not exist or if override was requested
  if   ~( (exist([fp_table,fn_table])==2) && (exist([fp_csv,fn_csv])==2) ) ...
      || s.todo.override


    %% COLLECT SPECTRO FEATURES

    %feature output table
    features = table;

    %loop over subjects
    for i = 1:length(folders)

      disp(sprintf('..collecting spectro %s features, subject %d/%d',level,i,length(folders)))

      %subject data folder
      fp = [folders(i).folder,filesep,folders(i).name,filesep];

      %feature table for current subject
      tbl = table;
      
      %add subject id to subject feature table
      tbl.id = {folders(i).name};
      
      

      %loop over eyes conditions (only eyesclosed for now)
      for eyes = {'eyesclosed','eyesopen'}

        %fbands features
        fn = sprintf('specdata_fbands_%s.mat',eyes{1});
        if exist([fp,fn])==2
          load([fp,fn],'specdata_fbands');
          currtab = features_to_table_fbands(eyes{1}, level, specdata_fbands.welch, s);
          tbl = cat(2, tbl, currtab);
          clear specdata_fbands currtab;
        end
  
        %fooof features
        fn = sprintf('specdata_fooof_%s.mat',eyes{1});
        if exist([fp,fn])==2
          load([fp,fn],'specdata_fooof');
          currtab = features_to_table_fooof(eyes{1}, level, specdata_fooof.welch, s);
          tbl = cat(2, tbl, currtab);
          clear specdata_fooof currtab;
        end
        
      end

      %add subject features to output table
      %but only if some microstate features were collected
      if size(tbl,2)>1

        %add missing columns as NaN values
        hdrRef = features.Properties.VariableNames;
        hdr = tbl.Properties.VariableNames;
        ind = ones(1,length(hdrRef));
        for vn = hdr
          ind(contains(hdrRef,vn))=0;
        end
        hdrRef=hdrRef(logical(ind));
        for vn = hdrRef
          tbl.(vn{1})=NaN;
        end
        clear hdrRef hdr ind vn;

        %add subject features to feature output table
        features = cat(1, features, tbl);

      end

      clear tbl;

    end 


    %% SAVE MICROSTATE FEATURE TABLE
    if ~isdir(fp_table)
      mkdir(fp_table);
    end
    disp(['..saving ',fp_table,fn_table])
    save([fp_table,fn_table],'features')
    

    %% SAVE MICROSTATE FEATURES TO CSV 
    if ~isdir(fp_csv)
      mkdir(fp_csv);
    end
    disp(['..saving ',fp_csv,fn_csv])
    writetable(features, [fp_csv,fn_csv], 'Delimiter', ',');

  end


end