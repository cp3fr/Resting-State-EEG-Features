function p05_features_to_csv(s)

 %if this step is required
  if s.todo.write_features_to_csv

    %find all input folders
    %here: in results/process/SUBJFOLDER/
    folders = dir(s.path.process); 
    folders = folders(contains({folders.name},'NDAR'));

    %% add here the possibility to run all 7 feature extraction methods in parallel...

    %microstate features
    pl_features_to_csv_microstates(folders, s);

    %feature levels
    levels = {'average','cluster','channel'};

    for i = 1:length(levels)

        % %temporarily uncommented spectro until fooof is done
        % %spectro features: frequency bands, individual alpha, fooof
        % pl_features_to_csv_spectro(levels{i}, folders, s); 

        %power spectral density (psd) features
        pl_features_to_csv_psd(levels{i}, folders, s); 

    end

end

