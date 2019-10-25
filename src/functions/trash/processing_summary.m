%processing summary
%lists all input and outputfiles in processing_summary table
if processing_summary==1

  tbl = pl_processing_summary(settings);
  save([settings.path.tables,filesep,'processing_summary.mat'],'tbl');

end