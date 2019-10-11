%% this is the main Structure that holds all analysis paramters
settings = struct()

%% Eye tracking settings
settings.ET_resting.trig_eyeo = 20;
settings.ET_resting.trig_eyec = 30;
settings.ET_resting.seg_time = 500; % how much should be cutted in addition on the beginning and end of each segment in ms
settings.ET_resting.outlierstd = 2;

%% do average re-referencing
settings.averageref = 1; 

%% Segmentation 
settings.segment = {}
settings.segment.fun = 'restingsegment'
settings.segment.path = {}
settings.segment.eyesclosed.events = '30'; % == eyes closed
settings.segment.eyesclosed.timelimits = [1 39]; % cut out 1 sec at the onset and 1 sec before the end
settings.segment.eyesopen.events = '20'; % == eyes open
settings.segment.eyesopen.timelimits = [1 19]; % cut out 1 sec at the onset and 1 sec before the end

%% spectrogram Analysis 
settings.spectro = {}
settings.spectro.fun = 'restingspectro'
settings.spectro.path = {}
settings.spectro.lpf = 1 %
settings.spectro.hpf = 50 %
settings.spectro.winlength = 1000 % = 2 Seconds
settings.spectro.timelimits = [0 1000] % 0 to 2 Seconds
settings.spectro.mvmax = 90 % maximum millivoltage to clean data
settings.spectro.fbands = {}
settings.spectro.doplot= 1;

% the frequencies of interest. Define the lower and upper limits of the
% relative power normalization 
fbands =    {'delta', 'theta' ,'alpha1' ,'alpha2' ,'beta1' ,'beta2' ,'beta3'}
lowfreqs =  [ 1.5 , 4 , 8.5 , 10.5 , 12.5 , 18.5 , 21.5 ]
highfreqs = [ 3.5 , 8 , 10 , 12 , 18 , 21 , 30  ]

for i=1:length(fbands)
    settings.spectro.fbands(i).name = fbands{i}
    settings.spectro.fbands(i).lowfreqs = lowfreqs(i)
    settings.spectro.fbands(i).highfreqs = highfreqs(i)
end


% electrode arrays to average frequency bands
eleclusters.names = {'l_front','m_front','r_front', 'l_pari','m_pari','r_pari'};
eleclusters.chans = {      {'E33' , 'E26' , 'E22' , 'E34' , 'E27' , 'E23' , 'E35' , 'E28' , 'E24' , 'E19' , 'E36' , 'E29' , 'E20' , 'E30' , 'E13' }, ...
                           {'E18' , 'E12' , 'E6' , 'E7' , 'E31' , 'E15' , 'E16' , 'E11' , 'Cz' , 'E10' , 'E5' , 'E106' , 'E80' }, ...
                           {'E9' ,  'E4' , 'E118' , 'E112' , 'E105' , 'E3' , 'E124' , 'E111' , 'E104' , 'E2' , 'E123' , 'E117' , 'E110' , 'E116' , 'E122' }, ...
                           {'E45' , 'E50' , 'E58' , 'E65' , 'E70' , 'E46' , 'E51' , 'E59' , 'E66' , 'E41' , 'E47' , 'E52' , 'E60' , 'E42' , 'E53' , 'E37' }, ... 
                           {'E54' , 'E61' , 'E67' , 'E71' , 'E75' , 'E55' , 'E62' , 'E72' , 'E79' , 'E78' , 'E77' , 'E76' }, ...
                           {'E83' , 'E90' , 'E96' , 'E101' , 'E108' , 'E84' , 'E91' , 'E97' , 'E102' , 'E85' , 'E92' , 'E98' , 'E103' , 'E86' , 'E93' , 'E87' }};

for i=1:length(eleclusters.names)
    settings.spectro.eleclusters(i).names = eleclusters.names{i}
    settings.spectro.eleclusters(i).chans = eleclusters.chans{i}
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

settings.alphapeak.type = 'deriv' % 'max', 'wmean'
settings.alphapeak.lower = 7.5; %% reference: Grandy et al., 2014 use 'deriv'
settings.alphapeak.upper = 12.5;
settings.alphapeak.window = 1; % Amplitude +- 1 Hz around peak is the mean individual alpha amplitude
settings.alphapeak.saveplot = 1; % save a plot 

%% 1/f Noise cf. Voytek 2015
%% check also for the settings of the spectrogramm. They use 50 % of overlap... 

% frequencies to analyse: ref: Voytek 2015 J Neurosci
settings.onefnoise.lower = 2 %settings.spectro.lpf 
settings.onefnoise.upper = 24 % settings.spectro.hpf % 
settings.onefnoise.exclude = 7:0.5:14 

%% Fooof
settings.fooof.el = {'Cz','E75'};
settings.fooof.freq_range = [1, 50];

%% Indidivual Frequency Bands
% The settings are done in the function, because they are dependent on the
% individual alpha peak that needs to be computed. 
% Doppelmayr M, Klimesch W, Pachinger T, Ripper B. Individual differences
% in brain dynamics: important implications for the calculation of
% event-related band power. Biol Cybern 1998;79:49?57:  
% 0.4*IAF?0.6*IAF, 0.6*IAF?0.8*IAF, 0.8*IAF?IAF, IAF?1.2*IAF, and
% 1.2*IAF?25 Hz for theta, lower-1-alpha, lower-2-alpha, upper alpha, and
% beta, respectively (Doppelmayr et al. 1998).

                            
%% Microstates Analysis 
settings.Microstate = {}
settings.Microstate.Fun = 'RestingMicrostate'
settings.Microstate.Path = {}
settings.Microstate.avgref = 1; % re-reference
settings.Microstate.Npeaks = 500; % how many peaks per subject do you want to extract
settings.Microstate.MinPeakDist  = 10 ; % in ms
settings.Microstate.GFPthresh = 1 ; % exclude GFP peaks if they exceed X sd. 
settings.Microstate.normalise = 1 ; % Normalise by average channel std.  
settings.Microstate.lpf = 2;
settings.Microstate.hpf = 20;
% clustering
settings.Microstate.Nmicrostates = 4;
settings.Microstate.Nrepetitions = 100;
clc
%save('Restingsettings.mat','settings')




