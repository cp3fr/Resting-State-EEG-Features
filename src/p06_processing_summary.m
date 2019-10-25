function p06_processing_summary(s)

  %if this step is required
  if s.todo.processing_summary

    %find all input folders
    %here: results/process/SUBJFOLDER/
    folders = dir(s.path.process); 
    folders = folders(contains({folders.name},'NDAR'));

    pl_summary_make(folders,s);

    pl_summary_print(s)

  end

end