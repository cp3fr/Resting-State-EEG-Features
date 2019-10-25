function tbl = features_to_table_fooof(eyes, level, inputdata, s)

  tbl = table;
  header = {};
  line = {};

  %===========================================================================
  %%% FOOOF PARAMETERS
  %===========================================================================
  if strcmpi(level,'average')

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

  %===========================================================================
  elseif strcmpi(level,'cluster')

    header = {};
    line = {};
    for dn = {'aperiodic','peak'}
      for param = 1:2
        for clust = 1:6

          %compose the header
          cn = {inputdata.fooof.clust{clust}.clustname};

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

          header(1,end+1) = {[eyes,'_','fooof','_',dn{1},'_',tmpstr,'_',cn{1}(~(cn{1}=='_'))]};
 
          
          %line to write to csv file
          if isfield(inputdata.fooof.clust{clust},[dn{1},'_','params'])
            vals = inputdata.fooof.clust{clust}.([dn{1},'_','params']);
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

  %===========================================================================
  elseif strcmpi(level,'channel')

    for dn = {'aperiodic','peak'}
      for param = 1:2
        for chan = chans

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

          header(1,end+1) = {[eyes,'_','fooof','_',dn{1},'_',tmpstr,'_',chanlabels{chan}]};
   
          
          %line to write to csv file
          if isfield(inputdata.fooof.chans,[dn{1},'_','params'])
            vals = inputdata.fooof.chans.([dn{1},'_','params']);
            if iscell(vals)
              if size(vals)>=chan
                vals=vals{chan,1};
                if isempty(vals)
                  vals = [NaN,NaN];
                end
              else
                vals = [NaN,NaN];
              end
            else
              vals = vals(chan,:);               
            end
          else
            vals = [NaN,NaN];
          end
          line(1,end+1) = {vals(param)};

        end
      end
    end


  end

  %output table
  tbl = cell2table(line,'variablenames',header);


end



