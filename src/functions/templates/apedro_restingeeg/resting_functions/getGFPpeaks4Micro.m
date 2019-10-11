function [EEG] = getGFPpeaks4Micro(EEG, settings)

Npeaks = settings.Npeaks;
MinPeakDist  = settings.MinPeakDist;
GFPthresh = settings.GFPthresh;

% Normalise by average channel std.
if settings.normalise 
    X = EEG.data ./ mean(std(EEG.data,0,2));
end

%% Parse GFP peaks
% do the segmentation on the GFP peaks, because they are high in
% signal-to-noise

% calculate the GFP
GFP = double(std(X,[],1));
%        plot(GFP)

% Minimum distance in ms:
MinTFdistance = MinPeakDist * EEG.srate/1000;
[~, peakidx] = findpeaks(GFP,'MinPeakDistance',MinTFdistance);
% check if the peak searching algorithm does something appropriate
% findpeaks(GFP(1:500),'MinPeakDistance',1,'Annotate','extents');

GFPpeaks = GFP(peakidx);

% OPTION, which may be included: to avoid extreme GFP peaks that are likely caused by artifacts
if GFPthresh > 0
    noisepeaks = peakidx(GFP(peakidx) > mean(GFP) + GFPthresh * std(GFP));
    %plot(GFP)
else
    noisepeaks =  []; 
end

% find a number of random peaks
peakidx = setdiff(peakidx,noisepeaks);

selection = randperm(length(peakidx));
if Npeaks < length(peakidx) - length(noisepeaks);
peakidx = peakidx(selection(1:Npeaks));
end



EEG.Micro.peakidx = peakidx; 
EEG.Micro.GFP = GFP;

end