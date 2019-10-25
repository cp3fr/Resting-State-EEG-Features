function tbl = specdata_to_table(eyes, level, inputdata, s)

  tbl = table;

  %frequencies
  f = inputdata.freqs;

  %make this a row vector
  if diff(size(f))<0
    f=f';
  end

  %power
  p = inputdata.specdata;

  %select the frequencies outside the filter range
  ind = (f>=s.spectro.bandpass.lpf) ...
      & (f<=s.spectro.bandpass.hpf) ...
      & ~(f>=s.spectro.notch.lpf & f<=s.spectro.notch.hpf);

  %update frequencies
  f = f(ind);

  %update power
  p = p(:,ind);

  %make frequency matrix 
  f = repmat(f,[size(p,1),1]);

  %make channel matrix
  c = repmat([1:size(p,1)]',[1,size(p,2)]);

  %data structure for channel, cluster, and average

  %channel..
  data.chan.f = f;
  data.chan.p = p;
  data.chan.c = c;
  data.chan.chanlocs = inputdata.chanlocs;
  data.chan.channames = {inputdata.chanlocs.labels}';

  %cluster
  eleclusters = s.spectro.eleclusters;
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


  if strcmpi(level,'channel')
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

      header(i) = {sprintf('%s_psd_%s_chan%s',eyes,fqstr,chanstr)};

    end

    currtbl = array2table(p,'VariableNames',header);

    tbl = cat(2,tbl,currtbl);

    clear f p c header i chanstr fqstr currtbl;

  elseif strcmpi(level,'cluster')
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

      header(i) = {sprintf('%s_psd_%s_%s',eyes,fqstr,cluststr)};

    end

    currtbl = array2table(p,'VariableNames',header);

    tbl = cat(2,tbl,currtbl);

    clear f p c header i cluststr fqstr currtbl;

  elseif strcmpi(level,'average')
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

      header(i) = {sprintf('%s_psd_%s_average',eyes,fqstr)};

    end

    currtbl = array2table(p,'VariableNames',header);

    tbl = cat(2,tbl,currtbl);

    clear f p c header i cluststr fqstr currtbl;
  end


end
