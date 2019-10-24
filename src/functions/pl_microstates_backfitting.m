function pl_microstates_backfitting(groupfolder,subjectfolder,settings)

  %current subject's id
  subject_id = subjectfolder.name;

  %load subject info (will be updated in any case)
  fp_subject_info = [subjectfolder.folder,filesep,subjectfolder.name,filesep];
  fn_subject_info = 'info.mat';
  disp(['..loading ',fp_subject_info,fn_subject_info])
  load([fp_subject_info,fn_subject_info],'info');
  subject_info = info;
  clear info

  %loop over eyes, but use only eyesclosed for now
  for eyes = {'eyesclosed'}

    %set defaults in subject info file
    subject_info.(['microstate_segmentation_',eyes{1}]) = false;
    subject_info.(['microstate_backfitting_',eyes{1}]) = false;

    %filepaths
    fp_segmentation_info = groupfolder;
    fp_proto = groupfolder;
    fp_eeg = [subjectfolder.folder,filesep,subjectfolder.name,filesep];
    fp_out = fp_eeg;

    %filenames
    fn_segmentation_info = ['info_',eyes{1},'.mat'];
    fn_proto = ['microstate_prototypes_',eyes{1},'.mat'];
    fn_eeg = ['eegdata_',eyes{1},'.mat'];
    fn_out = ['microstates_',eyes{1},'.mat'];

    %% Prerequisite Check 1/2
    
    %only perform the backfitting if all input files present, no output files are present,
    %or override is requested..
    if    ( (exist([fp_segmentation_info,fn_segmentation_info])==2) ...
            && (exist([fp_proto,fn_proto])==2) ...
            && (exist([fp_eeg,fn_eeg])==2)  ) ...
         && ...
          ( ~(exist([fp_eeg,fn_out])==2) ...
            || settings.todo.override )

      %load the microstate segmentation info file
      disp(['..loading ',fp_segmentation_info,fn_segmentation_info])
      load([fp_segmentation_info,fn_segmentation_info]);
      segmentation_info = info;
      clear info;

      %% Prerequisite Check 2/2
      
      %only perform backfitting if current subject's data was used for segmentation
      if sum(contains(segmentation_info.subject_id, subject_id))>0

        %load the EEG data
        disp(['..loading ',fp_eeg,fn_eeg])
        load([fp_eeg,fn_eeg],'EEG');

        %load the microstate prototypes
        disp(['..loading ',fp_proto,fn_proto])
        load([fp_proto,fn_proto],'microstate');

        %add prototypes to EEG data
        EEG.microstate = [];
        EEG.microstate.prototypes = microstate.prototypes;
        clear microstate;
            
        %perform the backfitting
        EEG = pop_micro_fit( ...
          EEG, ...
          'polarity', settings.microstate.backfitting.polarity  );

        %temporally smooth microstates labels
        EEG = pop_micro_smooth( ...
          EEG, ...
          'label_type',  settings.microstate.backfitting.label_type , ...
          'smooth_type', settings.microstate.backfitting.smooth_type, ...
          'minTime',     settings.microstate.backfitting.minTime, ...
          'polarity',    settings.microstate.backfitting.polarity  );

        %calculate microstate statistics
        EEG = pop_micro_stats( ...
          EEG, ...
          'label_type', settings.microstate.backfitting.label_type, ...
          'polarity',   settings.microstate.backfitting.polarity  );

        microstate = EEG.microstate;

        %save the microstate backfitting results
        disp(['..saving ',fp_out,fn_out])
        save([fp_out,fn_out],'microstate');

        %update the subject info file
        subject_info.(['microstate_segmentation_',eyes{1}]) = true;
        subject_info.(['microstate_backfitting_',eyes{1}]) = true;

      end
    end
  end

  %saving the updated subject info file
  info = subject_info;
  disp(['..saving ',fp_subject_info,fn_subject_info])
  save([fp_subject_info,fn_subject_info],'info');

end









