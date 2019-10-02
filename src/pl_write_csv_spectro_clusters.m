%%function tbl = pl_write_csv_spectro_clusters(tbl,settings)

function tbl = pl_write_csv_spectro_clusters(tbl,settings)

  T=table;

  %loop over data rows
  for row = 1:size(tbl,1)

    fp = tbl.Outputpath{row};
    fn = 'features_spectro_segments.mat';

    disp(sprintf('..loading file %d/%d: %s',row,size(tbl,1),[fp,fn]))
    load([fp,fn],'features');

    %add subject id to the beginning of the table
    tmp=table;
    tmp.id = tbl.ID(row);
    features.clust = cat(2,tmp,features.clust);

    %append subject data to group table
    T=cat(1,T,features.clust);

    clear features tmp fp fn;

  end

  fp = settings.path.csv;
  fn = 'RestingEEG_Spectro_Clusters.csv';

  %write table to csv
  disp(['..saving ',fp,fn])
  writetable(...
    T,...
    [fp,fn],...
    'Delimiter',','...
    );


end
