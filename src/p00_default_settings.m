function settings = p00_default_settings()

  settings = struct();

  addpath([pwd,filesep,'functions',filesep])

  %set path to data directory, find data folders 
  settings.path.mountpoint = [filesep,'Volumes',filesep];
  settings.isSciencecloud = false;
  if ~exist(settings.path.mountpoint)
    settings.path.mountpoint = [filesep,'mnt',filesep,'methlab-drive',filesep];
    settings.isSciencecloud = true;
  end
  settings.path.data=[settings.path.mountpoint,'methlab',filesep,'HBN_resting_without_EOG Kopie',filesep];
  settings.path.project=[settings.path.mountpoint,'methlab',filesep,'HBN_RestingEEG_Features',filesep];

  settings.path.results=[settings.path.project,'results',filesep];
  settings.path.process=[settings.path.results,'process',filesep];
  settings.path.tables=[settings.path.results,'tables',filesep];
  settings.path.csv=[settings.path.results,'csv',filesep];
  settings.path.group=[settings.path.results,'group',filesep];


  settings.path.src=[settings.path.project,'src',filesep]; 
  settings.path.functions=[settings.path.project,'src',filesep,'functions',filesep];
  settings.path.ext=[settings.path.project,'ext',filesep];
  settings.path.eeglab=[settings.path.project,'ext',filesep,'eeglab_dev_july2019',filesep];
  settings.path.fooof=[settings.path.project,'ext',filesep,'fooof',filesep];
  settings.path.microstates=[settings.path.project,'ext',filesep,'Microstates1.1',filesep];
  settings.path.mst=[settings.path.project,'ext',filesep,'MST1.0',filesep];
  settings.path.python = '/Library/Frameworks/Python.framework/Versions/3.7/bin/python3';

  addpath(settings.path.src);
  addpath(settings.path.functions);
  addpath(settings.path.eeglab);
  eeglab; close;
  addpath(settings.path.mst);
  addpath(settings.path.microstates);

  %% Parallel processing settings ------------------------------------
  settings.parallel.run = true;
  settings.parallel.cluster = parcluster('local');
  settings.parallel.workers = settings.parallel.cluster.NumWorkers;

  %% Plotting settings -----------------------------------------------
  settings.figure.visible = 'on';

  %% Eye tracking settings -------------------------------------------
  settings.ET_resting.trig_eyeo = 20;
  settings.ET_resting.trig_eyec = 30;
  settings.ET_resting.seg_time = 500; % how much should be cutted in addition on the beginning and end of each segment in ms
  settings.ET_resting.outlierstd = 2;

  %% do average re-referencing
  settings.averageref = 1; 

  %% Segmentation 
  settings.segment = {};
  settings.segment.fun = 'restingsegment';
  settings.segment.path = {};
  settings.segment.eyesclosed.events = '30'; % == eyes closed
  settings.segment.eyesclosed.timelimits = [1 39]; % cut out 1 sec at the onset and 1 sec before the end
  settings.segment.eyesopen.events = '20'; % == eyes open
  settings.segment.eyesopen.timelimits = [1 19]; % cut out 1 sec at the onset and 1 sec before the end

  %% spectrogram Analysis 
  settings.spectro = {};
  settings.spectro.fun = 'restingspectro';
  settings.spectro.path = {};
  settings.spectro.sr = 500; %Hz
  settings.spectro.notch.lpf = 58; %
  settings.spectro.notch.hpf = 62; %
  settings.spectro.bandpass.lpf = 1; %
  settings.spectro.bandpass.hpf = 90; %
  settings.spectro.winlength = 1000; % = 2 Seconds
  settings.spectro.timelimits = [0 1000]; % 0 to 2 Seconds
  settings.spectro.mvmax = 90; % maximum millivoltage to clean data
  settings.spectro.numsegments = [5 15 30 45 60 75 90]; %how many good segements to include for separate analyses
  settings.spectro.fbands = {};
  settings.spectro.doplot= 1;

  % the frequencies of interest. Define the lower and upper limits of the
  % relative power normalization 
  fbands =    {'delta','theta','alpha','alpha1','alpha2','beta','beta1','beta2','beta3','gamma','gamma1','gamma2'};
  lowfreqs =  [  1.5,   4.0,     8.5,    8.5,    10.5,    12.5,  12.5,   18.5,   21.5,   30.5,   30.5,    45.5   ];
  highfreqs = [  3.5,   8.0,    12.0,   10.0,    12.0,    30.0,  18.0,   21.0,   30.0,   80.0,   45.0,    80.0   ];

  for i=1:length(fbands)
      settings.spectro.fbands(i).name = fbands{i};
      settings.spectro.fbands(i).lowfreqs = lowfreqs(i);
      settings.spectro.fbands(i).highfreqs = highfreqs(i);
  end
  clear fbands lowfreqs highfreqs;

  % electrode arrays to average frequency bands
  eleclusters.names = {'l_front','m_front','r_front', 'l_pari','m_pari','r_pari'};
  eleclusters.chans = {{'E33' , 'E26' , 'E22' , 'E34' , 'E27' , 'E23' , 'E35' , 'E28' , 'E24' , 'E19' , 'E36' , 'E29'  , 'E20' , 'E30' , 'E13' }, ...
                       {'E18' , 'E12' , 'E6'  , 'E7'  , 'E31' , 'E15' , 'E16' , 'E11' , 'Cz'  , 'E10' , 'E5'  , 'E106' , 'E80' }, ...
                       {'E9'  , 'E4'  , 'E118', 'E112', 'E105', 'E3'  , 'E124', 'E111', 'E104', 'E2'  , 'E123', 'E117' , 'E110', 'E116', 'E122'}, ...
                       {'E45' , 'E50' , 'E58' , 'E65' , 'E70' , 'E46' , 'E51' , 'E59' , 'E66' , 'E41' , 'E47' , 'E52'  , 'E60' , 'E42' , 'E53' , 'E37' }, ... 
                       {'E54' , 'E61' , 'E67' , 'E71' , 'E75' , 'E55' , 'E62' , 'E72' , 'E79' , 'E78' , 'E77' , 'E76'  }, ...
                       {'E83' , 'E90' , 'E96' , 'E101', 'E108', 'E84' , 'E91' , 'E97' , 'E102', 'E85' , 'E92' , 'E98'  , 'E103', 'E86' , 'E93' , 'E87' }};

  for i=1:length(eleclusters.names)
      settings.spectro.eleclusters(i).names = eleclusters.names{i};
      settings.spectro.eleclusters(i).chans = eleclusters.chans{i};
  end                           
               
  %% settings for alpha peak
  %  %  Reference: Grandy et al. 2014: Mean spectrum of posterior electrodes
  %  1. Alpha individual peak = largest power between 7.5 and 12.5
  %  2. Weighted mean: IAF = (Sum(a(f) x  f))/(Sum a(f)). (Klimesch)
  %  3. First derivative changeing point

  % Alpha amplitude was defined as the mean amplitude
  % of the frequency spectrum of the 17 posterior electrodes
  % 1Hz around the IAF. 

  settings.alphapeak.postelectrodes = {   'E53' , 'E61' , 'E62' , 'E78' , 'E86' , 'E52' , 'E60' , 'E67' , ...
                                          'E72' , 'E77' , 'E85' , 'E92' , 'E59' , 'E66' , 'E71' , 'E76' , ...
                                          'E84' , 'E91' , 'E70' , 'E75' , 'E83' };

  settings.alphapeak.type = 'deriv'; % 'max', 'wmean'
  settings.alphapeak.lower = 7.5; %% reference: Grandy et al., 2014 use 'deriv'
  settings.alphapeak.upper = 12.5;
  settings.alphapeak.window = 1; % Amplitude +- 1 Hz around peak is the mean individual alpha amplitude

    
  %% Fooof
  settings.fooof.freq_range = [3, 40];
  settings.fooof.modelparams.peak_width_limits = [1.0, 8.0]; %[]=use default=[0.5, 12.0]
  settings.fooof.modelparams.max_n_peaks=[];%[]=use default=inf
  settings.fooof.modelparams.min_peak_amplitude=[]; %[]=use default=0.0
  settings.fooof.modelparams.peak_threshold=[]; %[]=use default=2.0
  settings.fooof.modelparams.aperiodic_mode=[]; %[]=use default='fixed'
  settings.fooof.modelparams.verbose=[]; %[]=use default=True

  %% Microstates Analysis 
  settings.microstate = [];

  %gfppeak selection settings (within subjects)
  settings.microstate.gfppeaks.datatype = 'spontaneous'
  settings.microstate.gfppeaks.avgref = 1;
  settings.microstate.gfppeaks.normalise = 1;
  settings.microstate.gfppeaks.MinPeakDist = 10;
  settings.microstate.gfppeaks.Npeaks = 500;
  settings.microstate.gfppeaks.GFPthresh = 1

  %microstate segmentation settings (across subjects)
  settings.microstate.segmentation.algorithm = 'modkmeans';
  settings.microstate.segmentation.sorting = 'Global explained variance';
  settings.microstate.segmentation.normalise = 0;
  settings.microstate.segmentation.Nmicrostates = 2:8;
  settings.microstate.segmentation.verbose = 1;
  settings.microstate.segmentation.Nrepetitions = 50;
  settings.microstate.segmentation.fitmeas = 'CV';
  settings.microstate.segmentation.max_iterations = 1000;
  settings.microstate.segmentation.threshold = 1e-06;
  settings.microstate.segmentation.optimised = 1 ;

  %microstate segmentation settings (across subjects)
  settings.microstate.backfitting.label_type = 'backfit';
  settings.microstate.backfitting.smooth_type = 'reject segments';
  settings.microstate.backfitting.minTime = 30;
  settings.microstate.backfitting.polarity = 0;

  % %microstate old settings apedro
  % settings.microstate.Fun = 'RestingMicrostate';
  % settings.microstate.Path = {};
  % settings.microstate.avgref = 1; % re-reference
  % settings.microstate.Npeaks = 500; % how many peaks per subject do you want to extract
  % settings.microstate.MinPeakDist = 10; % in ms
  % settings.microstate.GFPthresh = 1; % exclude GFP peaks if they exceed X sd. 
  % settings.microstate.normalise = 1; % Normalise by average channel std.  
  % settings.microstate.lpf = 2;
  % settings.microstate.hpf = 20;
  % % clustering
  % settings.microstate.Nmicrostates = 4;
  % settings.microstate.Nrepetitions = 100;


end