%%fooof_fit.m
%
%Fits the FOOOF to power spectral densities PSD
%
%INPUT
% data, double [chan x fq] array with PSD (in db scale)
% freqs, double [1 x fq] array with frequencies
% 'peak_width_limits', defaults to: [1.0 8.0]
%
%OUTPUT
% out, struct with fields
%      freqs
%      amp_scale
%      model_params
%      psd (log10 scale)
%      psd_fit (log10 scale)
%      ap_fit (log10 scale)
%      aperiodic_params
%      gaussian_params
%      fit
%
%DEPENDENCIES
% python (made available to matlab via pyversion)
% numpy
% fooof
%
%christian.pfeiffer@uzh.ch
%18.07.2019
%
function out = fooof_fit(data,freqs,settings)

%if input data is a vector put it in row orientation
if size(data,1)>1 && size(data,2)==1
  data=data';
end

%output structure
out = [];
out.psd = nan(size(data));
out.psd_fit = nan(size(data));
out.ap_fit = nan(size(data));
out.aperiodic_params = nan(size(data,1),2);%may be 2 or 3
out.fit.r2 = nan(size(data,1),1);
out.fit.error = nan(size(data,1),1);

%% Loop over channels
for ichan = 1:size(data,1)

  %power spectral density for current electrode 
  psd = data(ichan,:); %1xfreq
  psd = reshape(psd,[1 numel(psd)]);
  psd = py.numpy.array(psd);

  frequencies = py.numpy.array(freqs);

  %initiate new fooof object
  fooof_model = py.fooof.FOOOF();

  %set model parameters
  for fn = fieldnames(settings.fooof.modelparams)'
    if ~isempty(settings.fooof.modelparams.(fn{1}))
      fooof_model.(fn{1}) = py.list(settings.fooof.modelparams.(fn{1}));
    end
  end
  clear fn;

  %fit the fooof model
  fooof_model.fit(frequencies, psd);

  %on the first iteration save frequencies and model parameters
  if ichan==1
    out.freqs = cell2mat(cell(fooof_model.freqs.tolist()));
    out.freq_range = [freqs(1),freqs(end)];
    out.amp_scale = 'log10';
    out.model_params.peak_width_limits = cell2mat(cell(fooof_model.peak_width_limits));
    out.model_params.max_n_peaks = fooof_model.max_n_peaks;
    out.model_params.min_peak_height = fooof_model.min_peak_height;
    out.model_params.peak_threshold = fooof_model.peak_threshold;
    out.model_params.aperiodic_mode = char(fooof_model.aperiodic_mode);
    out.model_params.verbose  = fooof_model.verbose;

  end

  %extract parameters from FOOOF model and plot results
  fooof_res=fooof_model.get_results();

  %if fit did not work it will be skipped
  try

    %original psd (stored internally in log10 scale)
    %(see: https://fooof-tools.github.io/fooof/generated/fooof.FOOOF.html#fooof.FOOOF)
    out.psd(ichan,:) = cell2mat(cell(fooof_model.power_spectrum.tolist()));

    %fitted psd 
    out.psd_fit(ichan,:) = cell2mat(cell(fooof_model.fooofed_spectrum_.tolist()));

    %aperiodic/background psd
    out.ap_fit(ichan,:) = cell2mat(cell(py.getattr(fooof_model, '_ap_fit').tolist()));

    % aperiodic params:Parameters that define the aperiodic fit. 
    % As [Intercept, (Knee), Exponent]. The knee parameter is only included if aperiodic component is fit with a knee.
    out.aperiodic_params(ichan,:) = cell2mat(cell(fooof_res.aperiodic_params.tolist()));

    % peak parameters: Fitted parameter values for the peaks. Each row is a peak, as [CF, Amp, BW].
    tmp=cell(fooof_res.peak_params.tolist());
    peak_params = {};
    for i=1:length(tmp)
      peak_params{1,i}=cell2mat(cell(tmp{i}));
    end
    if ~isempty(peak_params)
      out.peak_params(ichan,1:length(peak_params)) = peak_params;
    end

    % gaussian parameters:
    tmp=cell(fooof_res.gaussian_params.tolist());
    gaussian_params = {};
    for i=1:length(tmp)
      gaussian_params{1,i}=cell2mat(cell(tmp{i}));
    end
    if ~isempty(gaussian_params)
      out.gaussian_params(ichan,1:length(gaussian_params)) = gaussian_params;
    end

    %fit metrics
    out.fit.r2(ichan,1) = fooof_res.r_squared;
    out.fit.error(ichan,1) = fooof_res.error;

  end

  %cleanup
  clear psd frequencies fooof_model fooof_res peak_params gaussian_params tmp;

end
    