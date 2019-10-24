function pl_processing_summary(s)

  %if this step is required
  if s.todo.processing_summary

    %find all input folders
    %here: eegdata.mat in results/process/SUBJFOLDER/
    folders = dir(s.path.process); 
    folders = folders(contains({folders.name},'NDAR'));

    %processing summary table
    tbl = table;

    %loop over subject folders
    for i = 1:length(folders)

      disp(sprintf('..appending info file %d/%d',i,length(folders)))

      %load info file
      fp = [folders(i).folder,filesep,folders(i).name,filesep];
      fn = 'info.mat';
      load([fp,fn],'info');

      %make a table for the current subject
      currtab = table;
      currtab.subject_id = {folders(i).name};

      %add info file information
      currtab = cat(2,currtab,struct2table(info,'AsArray',true));

      %add missing columns
      currhdr = currtab.Properties.VariableNames;
      hdr = tbl.Properties.VariableNames;
      ind = ones(1,length(hdr));
      for vn = currhdr
        ind(contains(hdr,vn))=0;
      end
      hdr=hdr(logical(ind));
      for vn = hdr
        currtab.(vn{1})=0;
      end


      %% here insert more information from the files in the subject folder


      %add the current subjects table to the overall table
      tbl = cat(1,tbl,currtab);

      %cleanup
      clear currtab info fp fn hdr currhdr ind;

    end

    %check if the outputfolder exists
    fp = s.path.tables;
    if ~isdir(fp)
      mkdir(fp);
    end

    %outputfile name
    fn = 'processing_summary.mat';

    %save the outputfile
    disp(['..saving ',fp,fn])
    save([fp,fn],'tbl')


  end
end



%% OLD STUFF -- use for adding more information to the summary table


%   disp(['..making processing summary table.'])

%   % make a table with one row per subject
%   folders = dir(settings.path.data);
%   folders = folders(contains({folders.name},'NDAR'));
%   tbl = struct2table(folders);
%   tbl = tbl(:,1:2);
%   tbl.Properties.VariableNames={'ID','Inputpath'};

%   % finds all input folders (makes the rows)
%   tbl.Inputpath = cellfun(@(x,y) [x,filesep,y,filesep],tbl.Inputpath,tbl.ID,'UniformOutput',false);

%   % in each input folder number of available EEG files
%   % name of input EEG file
%   tbl.NumInputfiles = zeros(size(tbl,1),1);
%   tbl.Inputfilename = cell(size(tbl,1),1);
%   tbl.Inputfilename(:) = {''};
%   for i = 1:size(tbl,1)

%     files = dir(tbl.Inputpath{i});

%     files = files(...
%       contains({files.name},'_RestingState_EEG') ...
%       & contains({files.name},'.mat') ...
%       & ~contains({files.name},'reduced') ...
%       );

%     tbl.NumInputfiles(i)=length(files);

%     if length(files)>0
%       tbl.Inputfilename(i)={files.name};
%     end

%   end

%   %local function to apply to each cell
%   function x=first_or_empty(x)
%     if isempty(x)
%       x='';
%     else
%       x=x(1);
%     end
%   end
%   %get the quality rating
%   tbl.QualityRating = cellfun(@(x) first_or_empty(x),tbl.Inputfilename,'UniformOutput',false);
%   %encode them as dummy variables
%   tbl.HasBadQuality = strcmpi(tbl.QualityRating,'b');
%   tbl.HasOkQuality = strcmpi(tbl.QualityRating,'o');
%   tbl.HasGoodQuality = strcmpi(tbl.QualityRating,'g');

%   % in output folder whether output folder exists
%   tbl.Outputpath = cellfun(@(x) [settings.path.process,x,filesep],tbl.ID,'UniformOutput',false);

%   % make dummy variables checking for several things, like
%   % presence of files
%   % crash report information
%   tbl.HasInfo = zeros(size(tbl,1),1);
%   tbl.HasEegSegments = zeros(size(tbl,1),1);
%   tbl.HasSpectroFeatures = zeros(size(tbl,1),1);
%   tbl.HasSpectroSegments = zeros(size(tbl,1),1);
%   tbl.HasFooofFeatures = zeros(size(tbl,1),1);
%   tbl.HasMicrostateFeatures = zeros(size(tbl,1),1);
%   tbl.CrashNoFile = zeros(size(tbl,1),1);
%   tbl.CrashZeroData = zeros(size(tbl,1),1);
%   tbl.CrashEventTrigger = zeros(size(tbl,1),1);
%   tbl.CrashRestingSpectro = zeros(size(tbl,1),1);
%   tbl.CrashMicrostate = zeros(size(tbl,1),1);
  
%   for i=1:size(tbl,1)

%     if isdir(tbl.Outputpath{i})

%       if exist([tbl.Outputpath{i},'info.mat'],'file')==2
%         load([tbl.Outputpath{i},'info.mat'],'info');
%         tbl.HasInfo(i)=1;
%         tbl.CrashNoFile(i) = double(info.nofile);
%         tbl.CrashZeroData(i) = double(info.zerodata);
%         tbl.CrashRestingSpectro(i) = double(info.crash_compute_resting_spectro);
%         if isfield(info,'crash_microstate')
%           tbl.CrashMicrostate(i)=double(info.crash_microstate);
%         end
%         if isfield(info,'crash_event_triggers')
%           tbl.CrashEventTrigger(i)=double(info.crash_event_triggers);
%         end
%         clear info;
%       end

%       if exist([tbl.Outputpath{i},'eeg_segments.mat'],'file')==2
%         tbl.HasEegSegments(i)=1;
%       end

%       if exist([tbl.Outputpath{i},'features_spectro.mat'],'file')==2
%         tbl.HasSpectroFeatures(i)=1;
%       end

%       if exist([tbl.Outputpath{i},'features_spectro_segments.mat'],'file')==2
%         tbl.HasSpectroSegments(i)=1;
%       end

%       if exist([tbl.Outputpath{i},'features_spectro_fooof.mat'],'file')==2
%         tbl.HasFooofFeatures(i)=1;
%       end

%       if (exist([tbl.Outputpath{i},'features_microstate.mat'],'file')==2) ...
%         && (exist([tbl.Outputpath{i},'/microstate/GEEG.mat'],'file')==2)
%         tbl.HasMicrostateFeatures(i)=1;
%       end

%     end

%   end




% end