function pl_microstates_backfitting(groupfolder,subjectfolder,settings)

  %filepaths
  fp_proto = groupfolder;
  fp_eeg = [subjectfolder.folder,filesep,subjectfolder.name,filesep];
  fp_out = fp_eeg;

  %loop over eyes, but use only eyesclosed
  for eyes = {'eyesclosed'}

    fn_proto = ['microstate_prototypes_',eyes{1},'.mat'];
    fn_eeg = ['eegdata_',eyes{1},'.mat'];
    fn_out = ['microstates_',eyes{1},'.mat'];

    %only perform the backfitting if all input files present, no output files are present,
    %or override is requested..
    if ((exist([fp_proto,fn_proto])==2) && (exist([fp_eeg,fn_eeg])==2)) ...
       && ( ~(exist([fp_eeg,fn_out])) || settings.todo.override)

      %load the EEG data
      load([fp_eeg,fn_eeg],'EEG');

      %load the microstate prototypes
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

      save([fp_out,fn_out],'microstate');

    end

  end
end









