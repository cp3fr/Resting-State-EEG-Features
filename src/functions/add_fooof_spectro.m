%%features = add_fooof_spectro(features,settings)
%
%Computes FOOOF on Power Spectral Densities for single channels, electrode clusters, and the average across channels
%Loops over different EEG substructures
%
%INPUT
% tbl, table with filepath and filename information for loading the data
% settings, struct with path and processing settings
% >>loads EEG, ET_resting, automagic from project/results/processing/no_eog_regression/subj/*REST_Results.mat
%
%OUTPUT
% none
% >>saves EEG, ET_resting, automagic to project/results/processing/no_eog_regression/subj/*REST_Results.mat
% (this should be improved to be able to keep track which files are already processed)
%
%DEPENDENCIES
% python (made available to matlab via pyversion)
% numpy
% fooof_fit
%
%christian.pfeiffer@uzh.ch
%08.07.2019
%
%===================================================================
% FOOOF DOCUMENTATION: 
%
% https://fooof-tools.github.io/fooof/index.html
%
% Commonly used abbreviations used in FOOOF include CF: center frequency, Amp: amplitude, BW: Bandwidth, ap: aperiodic
% Input power spectra must be provided in linear scale. Internally they are stored in log10 scale, as this is what the model operates upon.
%
%Input power spectra should be smooth, as overly noisy power spectra may lead to bad fits. In particular, raw FFT inputs are not appropriate, we recommend using either Welch’s procedure, or a median filter smoothing on the FFT output before running FOOOF.
%
% Where possible and appropriate, use longer time segments for power spectrum calculation to get smoother power spectra, as this will give better FOOOF fits.
%
% Example: fm = FOOOF(peak_width_limits=[1.0, 8.0], max_n_peaks=6, min_peak_amplitude=0.1, peak_threshold=2.0)
%
% Default parameters, if not specified: 
%   peak_width_limits=[0.5, 12.0],
%   max_n_peaks=inf,
%   min_peak_amplitude=0.0,
%   peak_threshold=2.0,
%   aperiodic_mode='fixed',
%   verbose=True
%
% peak_width_limits sets the possible lower- and upper-bounds for the fitted peak widths.
% max_n_peaks sets the maximum number of peaks to fit.
% min_peak_amp sets an absolute limit on the minimum amplitude (above aperiodic) for any extracted peak.
% peak_threshold, also sets a threshold above which a peak amplitude must cross to be included 
% in the model. This parameter is in terms of standard deviation above the noise of the flattened spectrum.
%===================================================================
%
function features = add_fooof_spectro(features,settings)

  %loops over different EEG substructures
  for vn = {'eyesclosed','eyesopen'}
    for mn = {'welch','fft'}

      %extracts a subjstructure, passes it to the fooof processing function (local function see below) and 
      %returns the output into the structure field where it came from
      features.(vn{1}).(mn{1}) = locfun_fooof_pipeline(features.(vn{1}).(mn{1}),settings);
      
    end
  end
  
end

%% LOCAL FUNCTION ==================================================================
function s=locfun_fooof_pipeline(s,settings)

   %pointer to the frequency range 
    ind_fq = s.freqs>=settings.fooof.freq_range(1) & s.freqs<=settings.fooof.freq_range(2);
    
    %frequencies in the frequency range
    freqs = s.freqs(ind_fq)';
    %freqs = reshape(freqs,[1 numel(freqs)])'
    
    %channel information
    chanlocs = s.chanlocs;
    channames =  {chanlocs(:).labels}';
    eleclusters = settings.spectro.eleclusters;
    
    %FOOOF for individual channels
    data = s.specdata(:,ind_fq); %chan x freq
    s.fooof.chans = fooof_fit(data,freqs,settings);
    s.fooof.chans.chanlocs = chanlocs; %add channel information
    s.fooof.chans.channames = channames;
    clear data;
    
    %FOOOF for electrode clusters
    s.fooof.clust = cell(length(eleclusters),1);
    for iclust = 1:length(eleclusters)
      
      ind_clust = zeros(size(channames));
      for ichan = 1:length(eleclusters(iclust).chans)
        ind_clust(strcmpi(channames,eleclusters(iclust).chans(ichan)))=1;
      end
      ind_clust = logical(ind_clust);
      
      data = nanmean(s.specdata(ind_clust,ind_fq),1); %chan x freq

      out = fooof_fit(data,freqs,settings);
      out.clustname = eleclusters(iclust).names; %add channel information
      out.clustchans = eleclusters(iclust).chans;
      out.ind_chans = ind_clust;
      out.channames = channames;
      out.chanlocs = chanlocs;
      
      s.fooof.clust(iclust) = {out};
      
      clear data ind_clust out;
    end

    %FOOOF on average across channels
    data = nanmean(s.specdata(:,ind_fq),1); %1 x freq
    s.fooof.avg = fooof_fit(data,freqs,settings);

end

