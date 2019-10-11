function p05_write_features_to_csv()
%=============================================================
%write_csv
%writes out the features to csv files
if write_csv==1

  fp = [settings.path.group];
  fold = dir(fp);
  names = {fold.name};
  fn = names{contains(names,'table')};
  clear fold names;

  load([fp,fn],'tbl');

  %writing spectral features to csv
  pl_write_csv_spectro_average(tbl,settings);
  pl_write_csv_spectro_clusters(tbl,settings);
  pl_write_csv_spectro_channels(tbl,settings);

  %writing regular features to csv
  pl_write_csv_feature_average(tbl,settings);
  pl_write_csv_feature_clusters(tbl,settings);
  pl_write_csv_feature_channels(tbl,settings);

  %csv file checks
  % tbl = readtable([settings.path.csv,'RestingEEG_Features_Channels.csv']);

end
