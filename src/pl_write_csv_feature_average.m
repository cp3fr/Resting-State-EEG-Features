%%function tbl = pl_write_csv_feature_average(tbl,settings)
%
%
function tbl = pl_write_csv_feature_average(tbl,settings)

  %rename the input table
  input_table = tbl;
  clear tbl;
  
  M = {};

  %loop over data rows
  for row = 1:size(input_table,1)

    if row == 1
      header = {};
    end
    line = {};

    %current row of the table
    tbl = input_table(row,:);

    disp(['..adding features type:average, row:',num2str(row),', id:',tbl.ID{1}])

    %%% SUBJECT AND DATA QUALITY INFORMATION

    %load subject's features file
    load([tbl.Outputpath{1},'features_spectro_fooof.mat'],'features')

    %subj name
    if row == 1
      header(1,end+1)={'id'};
    end
    line(1,end+1)=tbl.ID;

    %quality rating
    if row == 1
      header(1,end+1)={'quality_rating'};
    end
    line(1,end+1)={upper(tbl.QualityRating{1})};

    %%% FIXED FREQUENCY BANDS, ELECTRODE CLUSTERS

    for en = {'eyesclosed','eyesopen'}
      for fn = {'delta','theta','alpha','beta','gamma'}
          for dn = {'absmean','relmean'}

            %compose the header
            if row == 1
              header(1,end+1) = {[en{1},'_','fband','_',fn{1},'_',dn{1},'_','average']};
            end
            
            %pointer to frequeny band
            ind_f = strcmpi({features.(en{1}).welch.fbands.name},fn{1});

            %line to write to csv file
            line(1,end+1) = {nanmean(features.(en{1}).welch.fbands(ind_f).(dn{1}))};

        end
      end
    end
    
    %%% ALPHA PEAK INFORMATION

    %quality rating
    for en = {'eyesclosed','eyesopen'}
      for mn = {'Max','Derivative','Gravity'}
        for dn = {'freq','amplitude'}

          %compose the header
          if row == 1
            header(1,end+1) = {[en{1},'_','alphapeak','_',lower(mn{1}),'_',dn{1}]};
          end
          
          %line to write to csv file
          line(1,end+1) = {features.(en{1}).welch.alphaPeak.(['alphapeak',dn{1},mn{1}])};

        end
      end
    end

    %%% INDIVIDUAL FREQUENCY BANDS, ELECTRODE CLUSTERS

    for en = {'eyesclosed','eyesopen'}
      for fn = {'theta__','lower_1_alpha__','lower_2_alpha__','upper_alpha__','beta__'}        
        for dn = {'absmean','relmean'}
     
          %compose the header
          if row == 1
            header(1,end+1) = {[en{1},'_','indfband','_',fn{1}(~(fn{1}=='_')),'_',dn{1},'_','average']};
          end
          
          %pointer to frequeny band
          ind_f = strcmpi({features.(en{1}).welch.Indfbands.name},fn{1});

          %line to write to csv file
          line(1,end+1) = {nanmean(features.(en{1}).welch.Indfbands(ind_f).(dn{1}))};

        end
      end
    end

    %%% FOOOF PARAMETERS, ELECTRODE CLUSTERS

    for en = {'eyesclosed','eyesopen'}
      for dn = {'aperiodic','peak'}
        for param = 1:2

          %compose the header
          if row == 1

            if strcmpi(dn{1},'aperiodic') && param==1
              tmpstr='intercept';
            elseif strcmpi(dn{1},'aperiodic') && param==2
              tmpstr='slope';
            elseif strcmpi(dn{1},'peak') && param==1
              tmpstr='freq';
            elseif strcmpi(dn{1},'peak') && param==2
              tmpstr='amplitude';
            else
              tmpstr='UNKNOWN';
            end

            header(1,end+1) = {[en{1},'_','fooof','_',dn{1},'_',tmpstr,'_','average']};
          end
          
          %line to write to csv file
          if isfield(features.(en{1}).welch.fooof.avg,[dn{1},'_','params'])
            vals = features.(en{1}).welch.fooof.avg.([dn{1},'_','params']);
            if iscell(vals)
              vals=vals{1};
              if isempty(vals)
                vals = [NaN,NaN];
              end
            end
          else
            vals = [NaN,NaN];
          end
          line(1,end+1) = {vals(param)};

        end
      end
    end

    %%% APPEND DATA LINE TO DATA MATRIX

    %add data to data matrix
    M(row,:)=line;

  end
  
  %make a table out of data matrix
  T = cell2table(M,'VariableNames',header);

  %write table to csv
  writetable(...
    T,...
    [settings.path.csv,'RestingEEG_Feature_Average.csv'],...
    'Delimiter',','...
    );

  %make the output table
  clear tbl;
  tbl = cat(2,input_table,T);

end
