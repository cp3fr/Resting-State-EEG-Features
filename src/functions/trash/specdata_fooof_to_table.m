function tbl = specdata_fooof_to_table(eyes, level, inputdata, s)

  tbl = table;

  %%% FIXED FREQUENCY BANDS, ELECTRODE CLUSTERS

  for fn = {'delta','theta','alpha','beta','gamma'}
    for dn = {'absmean','relmean'}

      %column name
      colname = sprintf('%s_%s_%s_%s_%s',eyes,'fband',fn{1},dn{1},level);

      %pointer to frequeny band
      ind_f = strcmpi({inputdata.fbands.name},fn{1});

      %rowval
      rowval = nanmean(inputdata.fbands(ind_f).(dn{1}));

      %add rowvalue to new data column in table
      tbl.(colname) = rowval;

      %cleanup
      clear colname ind_f rowval;

    end
  end

  clear fn dn;


  %%% ALPHA PEAK INFORMATION

  %quality rating
  for mn = {'Max','Derivative','Gravity'}
    for dn = {'freq','amplitude'}

      %column name
      colname = sprintf('%s_%s_%s_%s',eyes,'alphapeak',lower(mn{1}),dn{1});

      %rowval
      rowval = inputdata.alphaPeak.(['alphapeak',dn{1},mn{1}]);

      %add rowvalue to new data column in table
      tbl.(colname) = rowval;

      %cleanup
      clear colname rowval;

    end
  end

  clear mn dn;


  %%% INDIVIDUAL FREQUENCY BANDS

  for fn = {'theta__','lower_1_alpha__','lower_2_alpha__','upper_alpha__','beta__'}        
    for dn = {'absmean','relmean'}

      %column name
      colname = sprintf('%s_%s_%s_%s_%s',eyes,'indfband',fn{1}(~(fn{1}=='_')),dn{1},level);

      %pointer to frequeny band
      ind_f = strcmpi({inputdata.Indfbands.name},fn{1});

      %rowval
      rowval = nanmean(inputdata.Indfbands(ind_f).(dn{1}));

      %add rowvalue to new data column in table
      tbl.(colname) = rowval;

      %cleanup
      clear colname ind_f rowval;

    end
  end

  clear fn dn;


  %%% FOOOF PARAMETERS

  header = {};
  line = {};
  for dn = {'aperiodic','peak'}
    for param = 1:2

      %compose the header
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
      header(1,end+1) = {[eyes,'_','fooof','_',dn{1},'_',tmpstr,'_','average']};

      
      %line to write to csv file
      if isfield(inputdata.fooof.avg,[dn{1},'_','params'])
        vals = inputdata.fooof.avg.([dn{1},'_','params']);
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

  currtab = cell2table(line,'variablenames',header);
  tbl = cat(2, tbl, currtab);

  clear header line dn param tmpstr vals currtab;


end
