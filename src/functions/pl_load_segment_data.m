function pl_load_segment_data(inputfolder,outputfolder,s)

  %set output filepath and filename
  fp_output = [outputfolder,inputfolder.name,filesep];
  if ~isdir(fp_output)
    mkdir(fp_output);
  end
  fn_info = 'info.mat';
  fn_eegdata = 'eegdata.mat';
  fn_eegdata_eyesclosed = 'eegdata_eyesclosed.mat';
  fn_eegdata_eyesopen = 'eegdata_eyesopen.mat';

  %check if all outputfiles exist
  allfilepathnames = {};
  allfilepathnames(1,end+1) = {[fp_output,fn_info]};
  allfilepathnames(1,end+1) = {[fp_output,fn_eegdata]};
  allfilepathnames(1,end+1) = {[fp_output,fn_eegdata_eyesclosed]};
  allfilepathnames(1,end+1) = {[fp_output,fn_eegdata_eyesopen]};
  ind = [];
  for fpn = allfilepathnames
    ind(1,end+1)=exist(fpn{1})==2;
  end
  all_files_exist = sum(ind)==length(ind);


  %% ALL OUTPUT FILE EXIST, PROCESS THE DATA AGAIN ?


  %if not all files exist or override requested
  if ~all_files_exist || s.todo.override

    %make info file
    info = [];
    info.inputpath = [inputfolder.folder,filesep,inputfolder.name,filesep];
    info.inputname = '';
    info.inputpathname = '';
    info.outputpath = '';
    info.qualityrating = '';
    info.numsamples_eyesclosed = 0;
    info.numsamples_eyesopen = 0;
    info.nofile = false;
    info.zerodata = false;
    info.badtrigger = false;

    %check if file of interest in the input folder
    files = dir([inputfolder.folder,filesep,inputfolder.name,filesep]);
    files = files(...
      contains({files.name},'_RestingState_EEG') ...
      & contains({files.name},'.mat') ...
      & ~contains({files.name},'reduced') ...
      );
    info.nofile = isempty(files);%true if no file


    %% NO INPUT FILE, SKIP PROCESSING


    %if no files of interest in the folder..
    if info.nofile

      disp(['..skipping ',inputfolder.folder,filesep,inputfolder.name])

    %if files of interest in the folder
    else

      %update info file
      info.inputname = [files.name];
      info.qualityrating = info.inputname(1);
      info.inputpathname = [files.folder,filesep,files.name];
      
      %load the EEG file
      disp(['..loading ',files.folder,filesep,files.name])
      load([files.folder,filesep,files.name],'EEG');
      
      %check if some zero/empty EEG, add to info structure
      info.zerodata = (min(EEG.data(:))==0) && (max(EEG.data(:))==0);

      %add filepath and name to info 
      info.inputpathname = [files.folder,filesep,files.name];


      %% ZERO DATA, SKIP PROCESSING

      
      %if not zero/empty EEG
      if ~info.zerodata
        
        %add latency field to EEG.event for compatibility with pipeline
        for i = 1:length(EEG.event)
          EEG.event(i).latency = EEG.event(i).sample;
        end

        %check/correct type/sequence/number of events (i.e. 5 x '20' and 5 x '30' trigger)
        %remove leading or trailing whitespaces and additional events of no interest
        [EEG,isvalid] = fix_event_structure(EEG);
        info.badtrigger = ~isvalid;


        %% EVENT TRIGGER PROBLEMS, SKIP PROCESSING


        %if all trigger are correct
        if ~info.badtrigger

          %notch filter
          EEG = pop_eegfiltnew(EEG, ...
            s.spectro.notch.lpf, ...
            s.spectro.notch.hpf, ...
            [], ... %[]=default filter order
            1); %'revfilt'=1 for notch

          %bandpass filter
          EEG = pop_eegfiltnew(EEG, ...
            s.spectro.bandpass.lpf, ...
            s.spectro.bandpass.hpf);

          %re-referencing to average
          if s.averageref == 1
            EEG = pop_reref(EEG,[]);
          end

          %update info file
          info.outputpath = fp_output;

          %save continuous EEG
          save([fp_output,fn_eegdata],'EEG');

          %make a copy of the continuous data
          EEG_cnt = EEG;

          %loop over eye conditions
          for eyes = {'eyesclosed','eyesopen'}
            
            %Segmentation, cuts out segments interest (e.g. eyesclosed only), and concatenates them into a "continuous" dataset
            EEG = RestingSegment(EEG_cnt,s.segment.(eyes{1}));

            eval(['info.numsamples_',eyes{1},'= EEG.pnts;']);

            %save segmented and concatenated EEG
            fn = ['eegdata_',eyes{1},'.mat'];
            save([fp_output,fn],'EEG');
            
          end
        end
      end
    end

    %save the info file
    save([fp_output,fn_info],'info');

  end
end     