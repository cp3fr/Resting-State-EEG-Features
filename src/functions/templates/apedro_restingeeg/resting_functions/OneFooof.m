% This script parametrizes the spectrogram according to the Voytek Python scripts. 
% It uses the python functions so they need to be made available to matlab:
% This works for Mac OS: Note to make a Python package working (if it is not installed by using pip)
% 1. CREATE A FILE CALLED XYZ.pth in
% ~/anaconda/lib/python3.6/site-packages/
% 2. the path of the library that you want to include in
% e.g. ~/Dropbox/EEG_analysis/fooof-master/
% inputs:
% EEG = eeglab EEG
% settings = settings from RestingCreateSettings
% filename = filename for figure titles
% eyes = 'eyesclosed', 'eyesopen'
% outpathfile = where to save the figures
% outputs: 
%      bgpara: background noise parameters
%    oscpara: oscillatory parameters
%         r2: goodness of fit
%      error: error 

function out = OneFooof(EEG,settings,outpathfile,eyes)
fprintf('\n:::FOOOF...\n')
settings

% Choose index of Cz and Oz (E75) to only plot those
outpathfile = [outpathfile, eyes, '_FOOOF_Report']
whicheltoplot = find(ismember({EEG.chanlocs.labels}, settings.el));
freq_range = settings.freq_range;

% FOOOF
foof_model = py.fooof.FOOOF([1.0, 8.0]);

freqs = EEG.freqs';
freqs = reshape(freqs,[1 numel(freqs)]);
freqs = py.numpy.array(freqs);


% loop through each electrode
k = 1;
for e = 1:size(EEG.specdata,1) % the +1 iteration is the average of the EEG

    
    
    psd = EEG.specdata(e,:);
    psd = reshape(psd,[1 numel(psd)]);
    psd = py.numpy.array(psd);
    
    foof_model.fit(freqs, psd, freq_range)
    %foof_model.save_report(outpathfile);
    
    %% extract parameters from FOOOF model and plot results
    foof_res=foof_model.get_results();
    
    %frequencies:
    freqsfoof=cell2mat(cell(foof_model.freqs.tolist()));
    %original psd:
    psdfoof_orig=cell2mat(cell(foof_model.power_spectrum.tolist()));
    %new fitted psd:
    psdfoof_fitted=cell2mat(cell(foof_model.fooofed_spectrum_.tolist()));
    % fitted background (1/f)
    bgfoof_fitted = cell2mat(cell(py.getattr(foof_model, '_bg_fit').tolist()));
    
    % ------------------------ parameters ------------------------------------
    
    % background (1/f) parameters:
    bgParamsTmp = foof_model.background_params_;
    bgParams{e,1} = cell2mat(cell(bgParamsTmp.tolist()));
    
    % parameters of oscillations:
    peakTmp = [];
    peakTmp=cell(foof_res.peak_params.tolist());
    for i=1:size(peakTmp,2)
        peakParams{i,e}=cell2mat(cell(peakTmp{i}));
    end
    
    % ------------------------------------------------------------------------
    
    r2(e) = foof_model.r_squared_ ;
    error(e) = foof_model.error_ ;
    
end

% do it with the average
psd = mean(EEG.specdata,1);
psd = reshape(psd,[1 numel(psd)]);
psd = py.numpy.array(psd);

foof_model.fit(freqs, psd, freq_range)
foof_model.save_report(outpathfile);

%% extract parameters from FOOOF model and plot results
foof_res=foof_model.get_results();

%frequencies:
freqsfoof=cell2mat(cell(foof_model.freqs.tolist()));
%original psd:
psdfoof_orig=cell2mat(cell(foof_model.power_spectrum.tolist()));
%new fitted psd:
psdfoof_fitted=cell2mat(cell(foof_model.fooofed_spectrum_.tolist()));
% fitted background (1/f)
bgfoof_fitted = cell2mat(cell(py.getattr(foof_model, '_bg_fit').tolist()));

% background (1/f) parameters:
bgParamsTmp = foof_model.background_params_;
bgParamsAvg = cell2mat(cell(bgParamsTmp.tolist()));

% parameters of oscillations:
peakTmp = [];
peakParamsAvg = {}; 

peakTmp=cell(foof_res.peak_params.tolist());
if ~isempty(peakTmp)
    for i=1:size(peakTmp,2)
        peakParamsAvg{i} = cell2mat(cell(peakTmp{i}));
    end
end

r2Avg = foof_model.r_squared_ ;
errorAvg = foof_model.error_ ;


%% save to Parameters

out.bgpara = bgParams
out.oscpara = peakParams

out.r2 = r2
out.error = error

out.bgparaAvg = bgParamsAvg;
if ~isempty(peakParamsAvg)
out.oscparaAvg = peakParamsAvg;
end

out.r2Avg = r2Avg;
out.errorAvg = errorAvg;



end



