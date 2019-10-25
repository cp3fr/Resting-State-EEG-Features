function tbl = features_to_table_fbands(eyes, level, inputdata, s)

  %number channel index and label for the column names
  chans = 1:105;
  chanlabels = cell(size(chans));
  for chan = 1:105
    chanstr = 'chan000';
    tmpstr = num2str(chan);
    chanstr(end-length(tmpstr)+1:end)=tmpstr;
    chanlabels{chan}=chanstr;
  end
  clear chanstr tmpstr chan;

  tbl = table;

  %===========================================================================
  %%% FIXED FREQUENCY BANDS
  %===========================================================================
  if strcmpi(level,'average')

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

  %===========================================================================
  elseif strcmpi(level,'cluster')

    for fn = {'delta','theta','alpha','beta','gamma'}
        for dn = {'absmean','relmean'}
          for cn = {'l_front','m_front','r_front','l_pari','m_pari','r_pari'}

            %column name
            colname = sprintf('%s_%s_%s_%s_%s',eyes,'fband',fn{1},dn{1},cn{1}(~(cn{1}=='_')));

            %pointer to frequeny band
            ind_f = strcmpi({inputdata.fbands.name},fn{1});

            %pointer to cluster
            ind_c = strcmpi({inputdata.fbands(ind_f).elecluster.names},cn{1});

            %rowval
            rowval = inputdata.fbands(ind_f).elecluster(ind_c).(dn{1});

            %add rowvalue to new data column in table
            tbl.(colname) = rowval;

            %cleanup
            clear colname ind_f ind_c rowval;

        end
      end
    end
    clear fn dn cn;

  %===========================================================================
  elseif strcmpi(level,'channel')

    for fn = {'delta','theta','alpha','beta','gamma'}
      for dn = {'absmean','relmean'}
        for chan = chans

          %column name
          colname = sprintf('%s_%s_%s_%s_%s',eyes,'fband',fn{1},dn{1},chanlabels{chan});
          
          %pointer to frequeny band
          ind_f = strcmpi({inputdata.fbands.name},fn{1});
          
          %rowval
          rowval = inputdata.fbands(ind_f).(dn{1})(chan);
          
          %add rowvalue to new data column in table
          tbl.(colname) = rowval;
          
          %cleanup
          clear colname ind_f rowval;

        end
      end
    end
    clear fn dn chan;

  end

  %===========================================================================
  %%% INDIVIDUAL ALPHA PEAK
  %===========================================================================
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


  %===========================================================================
  %%% INDIVIDUAL FREQUENCY BANDS
  %===========================================================================
  if strcmpi(level,'average')

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
  
  %===========================================================================
  elseif strcmpi(level,'cluster')

    for fn = {'theta__','lower_1_alpha__','lower_2_alpha__','upper_alpha__','beta__'}        
      for dn = {'absmean','relmean'}
        for cn = {'l_front','m_front','r_front','l_pari','m_pari','r_pari'}

          %column name
          colname = sprintf('%s_%s_%s_%s_%s',eyes,'indfband',fn{1}(~(fn{1}=='_')),dn{1},cn{1}(~(cn{1}=='_')));

          %pointer to frequeny band
          ind_f = strcmpi({inputdata.Indfbands.name},fn{1});

          %pointer to cluster
          ind_c = strcmpi({inputdata.Indfbands(ind_f).elecluster.names},cn{1});

          %rowval
          rowval = inputdata.Indfbands(ind_f).elecluster(ind_c).(dn{1});

          %add rowvalue to new data column in table
          tbl.(colname) = rowval;

          %cleanup
          clear colname ind_f ind_c rowval;

        end
      end
    end
    clear fn dn cn;

  %===========================================================================
  elseif strcmpi(level,'channel')

    for fn = {'theta__','lower_1_alpha__','lower_2_alpha__','upper_alpha__','beta__'}        
      for dn = {'absmean','relmean'}
        for chan = chans

          %column name
          colname = sprintf('%s_%s_%s_%s_%s',eyes,'indfband',fn{1}(~(fn{1}=='_')),dn{1},chanlabels{chan});

          %pointer to frequeny band
          ind_f = strcmpi({inputdata.Indfbands.name},fn{1});

          %rowval
          rowval = inputdata.Indfbands(ind_f).(dn{1})(chan);

          %add rowvalue to new data column in table
          tbl.(colname) = rowval;

          %cleanup
          clear colname ind_f rowval;

        end
      end
    end
    clear fn dn chan;


  end


end
