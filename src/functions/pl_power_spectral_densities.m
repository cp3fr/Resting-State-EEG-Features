function pl_power_spectral_densities(inputfolder,outputfolder,settings)

  %input path and names
  fp_input = [inputfolder.folder,filesep,inputfolder.name,filesep];
  fn_eegdata_eyesclosed = 'eegdata_eyesclosed.mat';
  fn_eegdata_eyesopen = 'eegdata_eyesopen.mat';

  %check if input files exist
  infilepathnames = {};
  infilepathnames(1,end+1) = {[fp_input,fn_eegdata_eyesclosed]};
  infilepathnames(1,end+1) = {[fp_input,fn_eegdata_eyesopen]};
  ind = [];
  for fpn = infilepathnames
    ind(1,end+1)=exist(fpn{1})==2;
  end
  input_files_exist = sum(ind)==length(ind);


  %output path and names
  fp_output = [outputfolder.folder,filesep,outputfolder.name,filesep];
  fn_output_specdata_eyesclosed = 'specdata_eyesclosed.mat';
  fn_output_specdata_eyesopen = 'specdata_eyesopen.mat';
  fn_output_features = 'features_specdata.mat';

  %check if input files exist
  outfilepathnames = {};
  outfilepathnames(1,end+1) = {[fp_output,fn_output_specdata_eyesclosed]};
  outfilepathnames(1,end+1) = {[fp_output,fn_output_specdata_eyesopen]};
  outfilepathnames(1,end+1) = {[fp_output,fn_output_features]};
  ind = [];
  for fpn = outfilepathnames
    ind(1,end+1)=exist(fpn{1})==2;
  end
  output_files_exist = sum(ind)==length(ind);


  %% ALL INPUT FILE EXIST? OUTPUT EXISTS? PROCESS THE DATA AGAIN?


  if input_files_exist && (~output_files_exist || settings.todo.override)

    %output folder for plots
    fp_plots = [fp_output,'specdata',filesep];

    %make sure output folder for plots exists
    if ~isdir(fp_plots)
      mkdir(fp_plots);
    end


    %% COMPUTE POWER SPECTRAL DENSITIES

    spectro = [];

    for eyes = {'eyesclosed','eyesopen'}

      fn = ['eegdata_',eyes{1},'.mat'];

      %loading EEG
      load([fp_input,fn],'EEG');

      %Spectrogram (using spectopo) for all good segments of the data (i.e. 1min30sec for eyesopen and 3min10sec for eyesclosed)
      spectro.(eyes{1}) = RestingSpectro(EEG, settings.spectro, eyes{1});

      %extract specdata for the current condition
      specdata = spectro.(eyes{1});

      %save specdata
      fn = ['specdata_',eyes{1},'.mat'];
      save([fp_output,fn],'specdata');

      %make power spectrum plot...
      figure;
      subplot(2,1,1),imagesc(specdata.welch.specdata),colorbar,title('welch')
      subplot(2,1,2),imagesc(specdata.fft.specdata),colorbar,title('fft')

      %save the plot
      fn = sprintf('specdata_%s',eyes{1});
      saveas(gcf,[fp_plots,fn],'png');
      close;

      
    end
    clear specdata;


    %% COMPUTE POWER SPECTRAL DENSITY FEATURES


    %outputtable
    tbl_chan = table;
    tbl_clust = table;
    tbl_avg = table;

    %loop over eye conditions
    for eyes = {'eyesclosed','eyesopen'}

      %frequencies
      f = spectro.(eyes{1}).welch.freqs;

      %make this a row vector
      if diff(size(f))<0
        f=f';
      end

      %power
      p = spectro.(eyes{1}).welch.specdata;

      %select the frequencies outside the filter range
      ind = (f>=settings.spectro.bandpass.lpf) ...
          & (f<=settings.spectro.bandpass.hpf) ...
          & ~(f>=settings.spectro.notch.lpf & f<=settings.spectro.notch.hpf);

      %update frequencies
      f = f(ind);

      %update power
      p = p(:,ind);

      %make frequency matrix 
      f = repmat(f,[size(p,1),1]);

      %make channel matrix
      c = repmat([1:size(p,1)]',[1,size(p,2)]);

      %plot for checks
      figure,
      subplot(3,1,1),imagesc(f),colorbar,title('frequencies')
      subplot(3,1,2),imagesc(c),colorbar,title('channels')
      subplot(3,1,3),imagesc(p),colorbar,title('power'),xlabel('fq sampling point'),ylabel('channel')

    
      %save the plot
      fn = sprintf('features_specdata_%s',eyes{1});
      saveas(gcf,[fp_plots,fn],'png');
      close;

      %data structure for channel, cluster, and average

      %channel..
      data = [];
      data.chan.f = f;
      data.chan.p = p;
      data.chan.c = c;
      data.chan.chanlocs = spectro.(eyes{1}).welch.chanlocs;
      data.chan.channames = {spectro.(eyes{1}).welch.chanlocs.labels}';

      %cluster
      eleclusters = settings.spectro.eleclusters;
      data.clust.eleclusters = eleclusters;
      data.clust.f = f(1:length(eleclusters),:);
      tmpdata = []; tmpname = {}; tmpind = [];
      for i = 1:length(eleclusters)
        %pointer to channels of this cluster
        ind = zeros(size(data.chan.channames));
        for j = 1:length(eleclusters(i).chans)
          ind(strcmpi(data.chan.channames,eleclusters(i).chans(j)))=1;
        end
        ind=logical(ind);
        %save the pointer for checks
        tmpind(:,i)=ind;
        %compute cluster average
        tmpdata(i,:)=nanmean(data.chan.p(ind,:),1);%cluster average
        %cluster name
        strname=eleclusters(i).names;
        strname=strname(strname~='_');
        tmpname(1,i)={strname};
      end
      data.clust.p = tmpdata;
      data.clust.c = repmat([1:size(tmpdata,1)]',[1,size(tmpdata,2)]);
      data.clust.clustname = repmat(tmpname',[1,size(tmpdata,2)]);
      data.clust.ind = tmpind;
      clear i j tmpdata tmpname tmpind strname;

      %average..
      data.avg.f = f(1,:);
      data.avg.p = nanmean(p,1);
      data.avg.c = ones(size(data.avg.p));

      clear f p c;

      
      %%CHANNEL FEATURES ==============================================

      %vectorize (row)
      f=data.chan.f(:)';
      p=data.chan.p(:)';
      c=data.chan.c(:)';

      %header
      header = cell(size(f));

      for i = 1:length(f)

        chanstr = sprintf('%d',c(i));
        while length(chanstr)<3
          chanstr = ['0',chanstr];
        end

        fqstr = sprintf('%3.2f',f(i));
        while length(fqstr)<5
          fqstr = ['0',fqstr];
        end
        fqstr=join(split(fqstr,'.'),'dot');
        fqstr=[fqstr{1},'hz'];

        header(i) = {sprintf('%s_specdata_%s_chan%s',eyes{1},fqstr,chanstr)};

      end

      currtbl = array2table(p,'VariableNames',header);

      tbl_chan = cat(2,tbl_chan,currtbl);

      clear f p c header i chanstr fqstr currtbl;


      %%CLUSTER FEATURES ==============================================

      %vectorize (row)
      f=data.clust.f(:)';
      p=data.clust.p(:)';
      c=data.clust.clustname(:)';

      %header
      header = cell(size(f));

      for i = 1:length(f)

        cluststr = c{i}; 

        fqstr = sprintf('%3.2f',f(i));
        while length(fqstr)<5
          fqstr = ['0',fqstr];
        end
        fqstr=join(split(fqstr,'.'),'dot');
        fqstr=[fqstr{1},'hz'];

        header(i) = {sprintf('%s_specdata_%s_%s',eyes{1},fqstr,cluststr)};

      end

      currtbl = array2table(p,'VariableNames',header);

      tbl_clust = cat(2,tbl_clust,currtbl);

      clear f p c header i cluststr fqstr currtbl;


      %%AVG FEATURES ==============================================

      %vectorize (row)
      f=data.avg.f(:)';
      p=data.avg.p(:)';
      c=data.avg.c(:)';

      %header
      header = cell(size(f));

      for i = 1:length(f)

        fqstr = sprintf('%3.2f',f(i));
        while length(fqstr)<5
          fqstr = ['0',fqstr];
        end
        fqstr=join(split(fqstr,'.'),'dot');
        fqstr=[fqstr{1},'hz'];

        header(i) = {sprintf('%s_specdata_%s_average',eyes{1},fqstr)};

      end

      currtbl = array2table(p,'VariableNames',header);

      tbl_avg = cat(2,tbl_avg,currtbl);

      clear f p c header i cluststr fqstr currtbl;


    end

    %% COMBINE ALL THE FEATURES =========================================

    features = [];
    features.chan = tbl_chan;
    features.clust = tbl_clust;
    features.avg = tbl_avg;

    disp(['..saving ',fp_output,fn_output_features])
    save([fp_output,fn_output_features],'features');

  end


end



