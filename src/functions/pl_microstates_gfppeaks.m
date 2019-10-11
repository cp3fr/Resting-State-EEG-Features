function pl_microstates_gfppeaks(inputfolder,outputfolder,settings)

  %input path and names
  fp_input = [inputfolder.folder,filesep,inputfolder.name,filesep];
  fn_info = 'info.mat';
  fn_eegdata_eyesclosed = 'eegdata_eyesclosed.mat';
  fn_eegdata_eyesopen = 'eegdata_eyesopen.mat';

  %check if input files exist
  infilepathnames = {};
  infilepathnames(1,end+1) = {[fp_input,fn_info]};
  infilepathnames(1,end+1) = {[fp_input,fn_eegdata_eyesclosed]};
  infilepathnames(1,end+1) = {[fp_input,fn_eegdata_eyesopen]};
  ind = [];
  for fpn = infilepathnames
    ind(1,end+1)=exist(fpn{1})==2;
  end
  input_files_exist = sum(ind)==length(ind);


  %output path and names
  fp_output = [outputfolder.folder,filesep,outputfolder.name,filesep];
  fn_gfppeaks_eyesclosed = 'gfppeaks_eyesclosed.mat';
  fn_gfppeaks_eyesopen = 'gfppeaks_eyesopen.mat';

  %check if input files exist
  outfilepathnames = {};
  outfilepathnames(1,end+1) = {[fp_output,fn_gfppeaks_eyesclosed]};
  outfilepathnames(1,end+1) = {[fp_output,fn_gfppeaks_eyesopen]};
  ind = [];
  for fpn = outfilepathnames
    ind(1,end+1)=exist(fpn{1})==2;
  end
  output_files_exist = sum(ind)==length(ind);


  %% ALL INPUT FILE EXIST? OUTPUT EXISTS? PROCESS THE DATA AGAIN?


  if input_files_exist && (~output_files_exist || settings.todo.override)

    %load info file and add some defaults
    disp(['..loading ',fp_input,fn_info]);
    load([fp_input,fn_info],'info')
    info.numgfppeaks_eyesclosed = 0;
    info.numgfppeaks_eyesopen = 0;

    for eyes = {'eyesclosed','eyesopen'}


      %load the segmented eegdata
      fn = ['eegdata_',eyes{1},'.mat'];
      disp(['..loading ',fp_input,fn]);
      load([fp_input,fn],'EEG')

      %try gfp peak detection 
      try

        %get GFP peaks
        EEG = pop_micro_selectdata( ...
            EEG, ... 
            [], ...
            'datatype',    settings.microstate.gfppeaks.datatype, ...
            'avgref',      settings.microstate.gfppeaks.avgref, ...
            'normalise',   settings.microstate.gfppeaks.normalise, ...
            'MinPeakDist', settings.microstate.gfppeaks.MinPeakDist, ...
            'Npeaks',      settings.microstate.gfppeaks.Npeaks, ...
            'GFPthresh',   settings.microstate.gfppeaks.GFPthresh);

        % %microstate segmentation on the single level
        % EEG = pop_micro_segment( EEG, ...
        %   'algorithm','modkmeans', ...
        %   'Nmicrostates', settings.microstate.Nmicrostates, ...
        %   'Nrepetitions',settings.microstate.Nrepetitions);

        % %microstate structure
        % microstate = EEG.microstate;

        %gfp peak data only
        GEEG = EEG.microstate.data;

        %update info file
        eval(['info.numgfppeaks_',eyes{1},'=size(GEEG,2);']);

        %save gfp peaks
        fn = ['gfppeaks_',eyes{1},'.mat'];
        save([fp_output,fn],'GEEG')

        %save chanlocs
        chanlocs = EEG.chanlocs;
        fn = ['chanlocs.mat'];
        save([fp_output,fn],'chanlocs')

      end

    end

    %save info file
    save([fp_output,fn_info],'info');

  end
end