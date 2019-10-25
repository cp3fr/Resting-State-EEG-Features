function print_processing_summary(s)

  fp = s.path.tables;
  fn = 'summary.mat';

  if exist([fp,fn])==2

    %save the outputfile
    disp(['..loading ',fp,fn])
    load([fp,fn],'summary')

    str = sprintf('PROCESSING SUMMARY\n');

    colnames = summary.Properties.VariableNames;
    ind = contains(colnames,'has_')

    %add overview of files present in the subject folder
    for vn = [{'nofile','zerodata','badtrigger'},colnames(ind)]

      tbl.(sprintf('has_%s',vn{1}))=(exist([fp,vn{1},'.mat'])==2);

      str = sprintf('%sTotal=%4.0f ''1''=%4.0f(%3.0f%%) ''0''=%4.0f(%3.0f%%) ''NaN''=%4.0f(%3.0f%%) : %s\n',...
      str,...
      length(summary.(vn{1})),...
      sum(summary.(vn{1})==1),...
      100 * sum(summary.(vn{1})==1) / length(summary.(vn{1})),...
      sum(summary.(vn{1})==0),...
      100 * sum(summary.(vn{1})==0) / length(summary.(vn{1})),...
      sum(isnan(summary.(vn{1}))),...
      100 * sum(isnan(summary.(vn{1}))) / length(summary.(vn{1})),...
      vn{1});

    end

    %display the summary string
    disp(str)

  end
end