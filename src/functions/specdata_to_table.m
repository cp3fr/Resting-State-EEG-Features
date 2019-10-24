function tbl = specdata_to_table(specdata)


    %outputtable
    tbl_chan = table;
    tbl_clust = table;
    tbl_avg = table;

    %loop over eye conditions
    for eye = {'eyesclosed','eyesopen'}

      %frequencies
      f = features.(eye{1}).welch.freqs;

      %make this a row vector
      if diff(size(f))<0
        f=f';
      end

      %power
      p = features.(eye{1}).welch.specdata;

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

      %output folder for plots
      fp = [outputfolder,inputfolder.name,filesep,'spectro_segments',filesep];

      %make sure folder exists
      if ~isdir(fp)
        mkdir(fp);
      end

      %save the plot
      fn = sprintf('spectro_check_%s',eye{1});
      saveas(gcf,[fp,fn],'png');
      close;

      %data structure for channel, cluster, and average

      %channel..
      data.chan.f = f;
      data.chan.p = p;
      data.chan.c = c;
      data.chan.chanlocs = features.eyesclosed.welch.chanlocs;
      data.chan.channames = {features.eyesclosed.welch.chanlocs.labels}';

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

        header(i) = {sprintf('%s_specdata_%s_chan%s',eye{1},fqstr,chanstr)};

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

        header(i) = {sprintf('%s_specdata_%s_%s',eye{1},fqstr,cluststr)};

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

        header(i) = {sprintf('%s_specdata_%s_average',eye{1},fqstr)};

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

    fp = [outputfolder,inputfolder.name,filesep];
    fn = 'features_spectro_segments.mat';

    disp(['..saving ',fp,fn])
    save([fp,fn],'features');

  end


end