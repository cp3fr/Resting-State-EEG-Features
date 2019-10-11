function pl_microstates_segmentation(settings)


  fp = [settings.path.group,'microstates',filesep];

  for eyes = {'eyesclosed'}

    fn_gfppeaks = ['gfppeaks_',eyes{1},'.mat'];

    fn_segmentation = ['microstate_segmentation_',eyes{1},'.mat'];
    fn_prototypes = ['microstate_prototypes_',eyes{1},'.mat'];


    if   (exist([fp,fn_gfppeaks])==2)  ...
      && ( ~((exist([fp,fn_segmentation])==2) && (exist([fp,fn_prototypes])==2)) ...
           || settings.todo.override)

      disp(['..loading ',fp,'chanlocs.mat'])
      load([fp,'chanlocs.mat'],'chanlocs');

      disp(['..loading ',fp,fn_gfppeaks])
      load([fp,fn_gfppeaks],'GEEG');

      %make a dataset with gfp peaks from all subjects concatenated
      EEG = eeg_emptyset();
      EEG.setname = 'GFPpeakmaps';
      EEG.chanlocs = chanlocs;
      EEG.nbchan = length(chanlocs);
      EEG.trials = 1;
      EEG.srate = settings.spectro.sr;
      EEG.data = GEEG;
      EEG.pnts = size(EEG.data,2);
      EEG.times = (1:size(EEG.data,2))*1000/EEG.srate;
      EEG.nbchan = size(EEG.data,1);
      EEG.microstate.data = EEG.data;

      %segment the data
      EEG = pop_micro_segment( ...
        EEG, ...
        'algorithm',      settings.microstate.segmentation.algorithm, ...
        'sorting',        settings.microstate.segmentation.sorting, ...
        'normalise',      settings.microstate.segmentation.normalise, ...
        'Nmicrostates',   settings.microstate.segmentation.Nmicrostates, ...
        'verbose',        settings.microstate.segmentation.verbose, ... 
        'Nrepetitions',   settings.microstate.segmentation.Nrepetitions, ...
        'fitmeas',        settings.microstate.segmentation.fitmeas, ...
        'max_iterations', settings.microstate.segmentation.max_iterations, ...
        'threshold',      settings.microstate.segmentation.threshold, ...
        'optimised',      settings.microstate.segmentation.optimised );

      %save segmentation results
      microstate = [];
      microstate = EEG.microstate;
      disp(['..saving ',fp,fn_segmentation])
      save([fp,fn_segmentation],'microstate','-v7.3')

      %make and save the prototype figure
      figure;
      MicroPlotTopo( EEG, 'plot_range', [] );
      fn_plot = ['microstate_prototypes_',eyes{1}];
      disp(['..saving ',fp,fn_plot])
      saveas(gcf,[fp,fn_plot],'png');
      close;

      % Select active number of microstates: W, KL and KLnorm are not polarity   
      % invariant, z.B. 5   Mit GUI und Graphik ausw�hlen oder vorbestimmt?
      EEG = pop_micro_selectNmicro( ...
        EEG, ...
        'Measures', {'CV', 'GEV'}, ...
        'do_subplots', 1, ...
        'Nmicro', 4);

      %save the selected prototypes
      microstate = [];
      microstate = EEG.microstate;
      disp(['..saving ',fp,fn_prototypes])
      save([fp,fn_prototypes],'microstate','-v7.3')

      clear EEG microstate;

    end

  end

end