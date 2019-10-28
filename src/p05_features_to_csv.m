function p05_features_to_csv(s)

 %if this step is required
  if s.todo.features_to_csv

    %find all input folders
    %here: in results/process/SUBJFOLDER/
    folders = dir(s.path.process); 
    folders = folders(contains({folders.name},'NDAR'));

    %PREPROCESSING features
    pl_features_to_csv_preprocessing(s)

    %MICROSTATE features
    pl_features_to_csv_microstates(folders, s);

    %SPECTRO individual fbands x cluster features
    pl_features_to_csv_ratios(folders, s);

    %PSD and SPECTRO level-wise features
    levels = {'average','cluster','channel'};
    for i = 1:length(levels)

        %spectro features: frequency bands, individual alpha, fooof
        pl_features_to_csv_spectro(levels{i}, folders, s); 

        %power spectral density (psd) features
        pl_features_to_csv_psd(levels{i}, folders, s); 

    end

end

