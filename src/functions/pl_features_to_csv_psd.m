function pl_features_to_csv_psd(level, folders, s)

  %output path for intermediate csv files
  fp_folder = sprintf('%sfeatures_psd_%s/',s.path.csv,level);

  %only run this step if outputfiles do not exist or if override was requested
  if   ~isdir(fp_folder) ...
      || s.todo.override

    %make the intermediate folder
    if isdir(fp_folder)
      rmdir(fp_folder,'s');
    end
    if ~isdir(fp_folder)
      mkdir(fp_folder);
    end

    %% COLLECT FEATURES AND SAVE TO INTERMEDIATE CSV

    row = 1;
    header = {};

    %loop over subjects
    for i = 1:length(folders)

      disp(sprintf('..PSD %s features, save intermediate file (row_*.csv), subject %d/%d',level,i,length(folders)))

      %subject data folder
      fp = [folders(i).folder,filesep,folders(i).name,filesep];

      %feature table for current subject
      tbl = table;
      
      %add subject id to subject feature table
      tbl.id = {folders(i).name};

      %loop over eyes conditions (only eyesclosed for now)
      for eyes = {'eyesclosed','eyesopen'}

        %input datafile
        fn = ['specdata_',eyes{1},'.mat'];

        %if file exists
        if exist([fp,fn])==2

          % disp(['..loading ',fp,fn])
          load([fp,fn],'specdata')

          %feature tables for average, cluster, channel data for the current eye condtion
          currtab = features_to_table_psd(eyes{1}, level, specdata.welch, s);

          %append table of interest (for the feature level of this subject) to subject's feature table
          tbl = cat(2, tbl, currtab);

          %cleanup
          clear specdata currtab;

        end
      end
      
      %save the header of the first file
      if row == 1
        header = tbl.Properties.VariableNames;
      end

      %add subject features to output table
      %but only if some microstate features were collected
      if size(tbl,2)>1

        %check if headers match
        currheader = tbl.Properties.VariableNames;
        ind = cellfun(@(x,y) strcmpi(x,y),header,currheader);
        if sum(ind)~=length(header)
          error('ERROR: headers do not match.')
        end

        %save current row
        %first row has both a header and values
        %second and following rows only have the values
        if row==1
          writevariablenames = 1;
        else
          writevariablenames = 0;
        end
        fn = sprintf('row_%d.csv',row);
        fp = fp_folder;
        % disp(['..saving ',fp,fn])
        writetable(tbl, [fp,fn], ...
          'delimiter', ',', ...
          'writevariablenames', writevariablenames);

        %raise the row count
        row = row + 1;

      end

      clear tbl;

    end 

    %% NOW USE PYTHON TO CONCATENATE INTERMEDIATE CSV FILES
    disp('NOW USE PYTHON TO CONCATENATE INTERMEDIATE CSV FILES')

  end

  %% MAKE FINAL CSV FILE

  fp_csv = s.path.csv;
  fn_csv  = sprintf('features_psd_%s.csv',level);
  fp_table = s.path.tables;
  fn_table  = sprintf('features_psd_%s.mat',level);

  %only perform this step if the csv folder exists, table does not exist or override is requested
  if (exist([fp_csv,fn_csv])==2) ...
    && (~(exist([fp_table,fn_table])==2) || s.todo.override)

   %% SAVE FEATURE TABLE
    
    features = readtable([fp_csv, fn_csv]);

    %..save table
    if ~isdir(fp_table)
      mkdir(fp_table);
    end
    disp(['..saving ',fp_table,fn_table])
    save([fp_table,fn_table],'features')
    

    %..save table to csv
    if ~isdir(fp_csv)
      mkdir(fp_csv);
    end
    disp(['..saving ',fp_csv,fn_csv])
    writetable(features, [fp_csv,fn_csv], 'Delimiter', ',');

  end

end