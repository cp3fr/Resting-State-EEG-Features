function pl_features_to_csv_preprocessing(s)

    %make sure output folders exist
    if ~isdir(s.path.tables)
        mkdir(s.path.tables)
    end
    if ~isdir(s.path.csv)
        mkdir(s.path.csv)
    end

    %load the processing summary
    fpn = [s.path.tables,'summary.mat'];
    if ~(exist(fpn)==2)
      p06_processing_summary(s);
    end
    disp(['..loading ',fpn])
    load([fpn],'summary');

    %select only the samples with no processing errors
    rowind = summary.nofile==0 & summary.zerodata==0 & summary.badtrigger==0;
    
    %select only some features or interest
    colidx = [];
    for colname = {'id','qualityrating','numsamples_eyesclosed','numsamples_eyesopen'}
        colidx(1,end+1) = find(strcmpi(summary.Properties.VariableNames,colname));
    end
    
    %apply sample and feature selection
    features = summary(rowind, colidx);

    %save the features
    fpn = [s.path.tables,'features_preprocessing.mat'];
    disp(['..saving ',fpn])
    save(fpn,'features')

    fpn = [s.path.csv,'features_preprocessing.csv'];
    disp(['..saving ',fpn])
    writetable(features, fpn, 'Delimiter', ',');


end