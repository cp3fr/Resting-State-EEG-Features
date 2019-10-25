function p05_write_features_to_csv(s)

 %if this step is required
  if s.todo.write_features_to_csv

    %find all input folders
    %here: eegdata.mat in results/process/SUBJFOLDER/
    folders = dir(s.path.process); 
    folders = folders(contains({folders.name},'NDAR'));

    %feature levels
    %-average
    %-clusters
    %-channel

    %feature types
    %-psd
    %-frequency bands
    %-fooof
    %-microstates


    %make feature tables, save to results, tables
    %save feature tables to csv










end



% %loop over subject data..
% for i=1:length(folders)
%   pl_power_spectral_densities(folders(i), folders(i), s);
% end
%
% %=============================================================
% %write_csv
% %writes out the features to csv files
% if write_csv==1
%
%   fp = [settings.path.group];
%   fold = dir(fp);
%   names = {fold.name};
%   fn = names{contains(names,'table')};
%   clear fold names;
%
%   load([fp,fn],'tbl');
%
%   %writing spectral features to csv
%   pl_write_csv_spectro_average(tbl,settings);
%   pl_write_csv_spectro_clusters(tbl,settings);
%   pl_write_csv_spectro_channels(tbl,settings);
%
%   %writing regular features to csv
%   pl_write_csv_feature_average(tbl,settings);
%   pl_write_csv_feature_clusters(tbl,settings);
%   pl_write_csv_feature_channels(tbl,settings);
%
%   %csv file checks
%   % tbl = readtable([settings.path.csv,'RestingEEG_Features_Channels.csv']);
%
% end
%