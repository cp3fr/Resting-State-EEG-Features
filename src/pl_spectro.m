%%pl_spectro(fp)
%
% christian.pfeiffer@uzh.ch
% 01.10.2019
%
%update 01.10.2019 
%-checks if outputfile 'features_spectro.mat' already exists
%-makes an info structure that logs any file processing errors and saves
% it even if not features were extracted
%
function pl_spectro(inputfolder,outputfolder,settings)

  %output filenames
  fn_info = 'info.mat';
  fn_eeg_segments ='eeg_segments.mat';
  fn_spectro = 'features_spectro.mat';
  
  %output folder
  fp_output = [outputfolder,inputfolder.name,filesep];
  
  %make sure the output folder exists
  if ~isdir(fp_output)
    mkdir(fp_output);
  end

  %setup info structure (for error monitoring
  info.inputfolder = [inputfolder.folder,filesep,inputfolder.name,filesep];
  info.filepathname = '';
  info.nofile = false;
  info.zerodata = false;
  info.crash_event_triggers = false;
  info.crash_compute_resting_spectro = false;
  info.crash_compute_resting_spectro_msg = [];

  %list all files in the inputfolder
  files = dir([inputfolder.folder,filesep,inputfolder.name,filesep]);
  
  files = files(...
    contains({files.name},'_RestingState_EEG') ...
    & contains({files.name},'.mat') ...
    & ~contains({files.name},'reduced') ...
    );


  %if there is no file in the folder
  if isempty(files)
    
    %update info structure
    info.nofile = true;
    
    disp(['..skipping ',inputfolder.folder,filesep,inputfolder.name])
    
    %if there is a file in the folder
  else
    
    %update info structure
    info.filepathname = [files.folder,filesep,files.name];
    
    %load the EEG file
    disp(['..loading ',files.folder,filesep,files.name])
    load([files.folder,filesep,files.name],'EEG');
    
    %add some check for zero/empty EEG
    if (min(EEG.data(:))==0) && (max(EEG.data(:))==0)
      info.zerodata = true;
    end
    
    %only run this if the data is not bad in the first place
    if ~info.zerodata
      
      %fix the missing latency field
      for i = 1:length(EEG.event)
        EEG.event(i).latency = EEG.event(i).sample;
      end
      
      %compute the spectral features
      try
        [EEG,isvalid] = compute_resting_spectro(EEG,settings);
        info.crash_event_triggers = ~isvalid;
        %if it crashes, save this info
      catch me
        info.crash_compute_resting_spectro = true;
        info.crash_compute_resting_spectro_msg = me;
      end


      
      %check if features were computed
      if isfield(EEG,'spectro')
        
        %extract the features
        features = EEG.spectro;
        
        %save the features to output folder
        save([fp_output,fn_spectro],'features');
        
        %if segmented EEG does not exist
        if ~exist([fp_output,fn_eeg_segments])
          
          %remove the microstate field because it is saved in the features file
          if isfield(EEG,'spectro')
            EEG = rmfield(EEG,'spectro');
          end
          
          %save the EEG data
          save([fp_output,fn_eeg_segments],'EEG')
          
        end
        
      end
      
    end
    
  end
  
  %save the info file
  save([fp_output,fn_info],'info');
  
end