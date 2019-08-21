%%fooof_fit_aperiodic.m
%
%Function that computes the 1/f aperiodic signal based on fit parameters [intercept,(knee),exponent] from FOOOF.
%Note that the script operates on parameters and produces output in log10 scale. 
%The output of this function should match to the ap_fit data computed by FOOOF
%
%INPUT
% freqs, double [1xf] or [fx1] vector where f are frequencies
% params, double [nxp] matrix where n are the number of fits to be performed (e.g. for different EEG channels) and
%         p the number of fit parameters in the order [intercept,(knee),exponent]. Note that knee is omitted if
%         lenght of p is 2
%
%OUTPUT
% ap_fit, double [nxf] matrix of n fits along f frequencies
%
%DEPENDENCIES
% none
%
%christian.pfeiffer@uzh.ch
%06.07.2019
%
function ap_fit = fooof_fit_aperiodic(freqs,params)

n = size(params,1); %number of fits to be done

if diff(size(freqs))<0
  freqs=freqs';
end

F = repmat(freqs,n,1); %nxfreqs, frequencies

b = params(:,1); %nx1, intercept parameter

if size(params,2)==3
  k = params(:,2); %nx1, knee parameter
else
  k = zeros(size(b)); %nx1, by default set knee parameter to zero
end

x = params(:,end); %nx1, exponent parameter

ap_fit = b - log10(k + F.^x); %compute the aperiodic fit
