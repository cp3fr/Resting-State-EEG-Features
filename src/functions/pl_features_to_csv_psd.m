function pl_features_to_csv_psd(level, folders, s)

  %output files path and names
  fp_table = s.path.tables;
  fn_table = sprintf('features_psd_%s.mat',level);
  fp_csv = s.path.csv;
  fn_csv = sprintf('features_psd_%s.csv',level);
  fp_folder = sprintf('%sfeatures_psd_%s/',s.path.csv,level);

  %only run this step if outputfiles do not exist or if override was requested
  if   ~( (exist([fp_table,fn_table])==2) && (exist([fp_csv,fn_csv])==2) ) ...
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

      disp(sprintf('..PSD %s features, step 1/3 save intermediate file (row_*.csv), subject %d/%d',level,i,length(folders)))

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



    %% MAKE FEATURE TABLE FROM INTERMEDIATE CSV FILES

    fp = fp_folder;
    tmp = dir(fp_folder);
    filenames = {tmp.name};
    filenames = filenames(contains(filenames,'row'));
    n=length(filenames);

    features = table;
    for row = 1:n
      disp(sprintf('..PSD %s features, step 2/3 make feature table, file %d/%d',level,row,n))
      if row == 1
        readvariablenames = true;
      else
        readvariablenames = false;
      end
      fn=sprintf('row_%d.csv',row);
      tbl = readtable([fp,fn],'readvariablenames',readvariablenames);
      if row ~=1
        tbl.Properties.VariableNames = features.Properties.VariableNames;
      end
      features = cat(1,features,tbl);
      clear tbl;
    end


    %% SAVE FEATURE TABLE
    
    disp(sprintf('..PSD %s features, step 3/3 save feature table, file %d/%d',level))

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