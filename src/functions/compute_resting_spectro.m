%%compute_resting_spectro(EEG)
%
%This function computes spectral features, channel x time densities, absolute and relative power for fixed frequency bands, individual alpha peak, and individual frequency bands (based on alpha peak). 
%
% INPUT:
%  EEG: EEG structure with continuous 105-channel EEG (EGI system Langer-Lab cap layout) data.
%       The data should be based on eyes open and eyes closed from resting state recordings
%       EEG.events structure should contain the following types:
%       1 x '90' event (start of the recording)
%       5 x '20' events (eyes open condition, 20 sec duration)
%       5 x '30' events (eyes closed condition, 40 sec duration)
%       The data should already be preprocessed (e.g. using the Automagic toolbox) and 
%       should not contain eye, ecg, or other than EEG channels
%
% OUTPUT:
%   EEG: EEG structure, EEG.data contains notch (48-52 Hz) and bandpass (1-90 Hz) filtered continuous data
%        EEG.spectro contains several substructures containing the outputs:
%        eyesclosed / eyesopen : refers to the different experimental condition
%        welch / fft : refers to different methods used for spectral decomposition
%        specdata : channel x frequency matrix of power spectral densities 
%        freqs : frequency x 1 vector of frequencies
%        fbands : structure containing absolute and relative power for fixed frequency bands (delta to gamma),
%                 across all channels and for selected frequency clusters
%        alphaPeak : structure containing individual alpha peak frequency and amplitude using different detection methods 
%                    (Maximum, Derivative, Amplitude)
%        indfbands : individual frequency bands, defined relative to individual alpha peak
%        (see subfunctions for detailled description of how outputs are computed)
%
% DEPENDENCIES:
%   eeglab added to the matlab path
%   script requires the current directory to be set to the location of the script location (as it needs to add the function folder to the path)
%
%
% christian.pfeiffer@uzh.ch
% 20.08.2019
%
function EEG = compute_resting_spectro(EEG,settings)

  %notch filter
  EEG = pop_eegfiltnew(EEG, settings.spectro.notch.lpf,    settings.spectro.notch.hpf,   [], 1); %[]=default filter order, and 'revfilt'=1 for notch
  
  %bandpass filter
  EEG = pop_eegfiltnew(EEG, settings.spectro.bandpass.lpf, settings.spectro.bandpass.hpf      );

  %re-referencing to average
  if settings.averageref == 1
      EEG = pop_reref(EEG,[]);
  end

  %checks for the presence of the correct number of events (i.e. 5 x '20' and 5 x '30' trigger)
  %and remove leading or trailing whitespaces, and additional events of no interest
  [EEG,isvalid] = fix_event_structure(EEG);

  %if the event structure does not contain a valid amount of events, don't continue
  if ~isvalid

    disp(['..skipping file. Number of events is not valid.'])

  %otherwise, continue the analysis..
  else

    %% SPECTRO ANALYSIS 
    for eyes = {'eyesclosed','eyesopen'}
      
      %Segmentation, cuts out segments interest (e.g. eyesclosed only), and concatenates them into a "continuous" dataset
      EEGtmp = RestingSegment(EEG,settings.segment.(eyes{1}));
      
      %Spectrogram (using spectopo) for all good segments of the data (i.e. 1min30sec for eyesopen and 3min10sec for eyesclosed)
      EEG.spectro.(eyes{1}) = RestingSpectro(EEGtmp, settings.spectro, eyes{1});
      
      clear EEGtmp;
        
    end

    %% INDIVIDUAL ALPHA PEAK
    for eyes = {'eyesclosed','eyesopen'}
      for mn = {'fft','welch'}
        
        %Individual alpha peak for all the data
        EEG.spectro.(eyes{1}).(mn{1}).alphaPeak = RestingAlphaPeak(EEG.spectro.(eyes{1}).(mn{1}), settings, eyes{1});
        
      end
    end

    %% Individually defined frequency bands and frequency ratios
    for eyes = {'eyesclosed','eyesopen'}
      for mn = {'fft','welch'}
      
        %for all the data
        EEG.spectro.(eyes{1}).(mn{1}) = IndividualSpectro(EEG.spectro.(eyes{1}).(mn{1}),settings.spectro);

      end
    end

  end
end
