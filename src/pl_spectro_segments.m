%%function pl_spectro_segments(inputfolder,outputfolder,settings)
%
% christian.pfeiffer@uzh.ch
% 01.10.2019
%
function pl_spectro_segments(inputfolder,outputfolder,settings)


  %% LOAD/SEGMENT EEG


  %filepath and name for segmented EEG
  fp = [outputfolder,inputfolder.name,filesep];
  fn = 'features_spectro.mat';

  %if segmented EEG already exists
  if exist([fp,fn])

    %load segmented EEG
    disp(['..loading ',fp,fn])
    load([fp,fn],'features');


    %outputtable
    tbl = table;

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

      fp = [outputfolder,inputfolder.name,filesep,'spectro_segments',filesep];

      if ~isdir(fp)
        mkdir(fp);
      end

      fn = sprintf('spectro_check_%s',eye{1});
      saveas(gcf,[fp,fn],'png');
      close;


      %vectorize (row)
      f=f(:)';
      p=p(:)';
      c=c(:)';

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
        fqstr=join(split(fqstr,'.'),'DOT');
        fqstr=[fqstr{1},'HZ'];

        header(i) = {sprintf('%s_specdata_chan%s_freq%s',eye{1},chanstr,fqstr)};

      end

      currtbl = array2table(p,'VariableNames',header);

      tbl = cat(2,tbl,currtbl);

    end


    features = tbl;

    fp = [outputfolder,inputfolder.name,filesep];
    fn = 'features_spectro_segments.mat';

    disp(['..saving ',fp,fn])
    save([fp,fn],'features');


  end


end