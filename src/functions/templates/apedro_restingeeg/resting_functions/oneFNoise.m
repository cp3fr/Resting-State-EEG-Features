% Calculates the slope of the spectrogram using a robust linear regression.
% Note that there is a more sophisticated method in fooof
% input: 
% EEG = eeglab EEG
% settings = settings from RestingCreateSettings.
% output: 
% oneFall = slope for each electrode

function out = oneFNoise(EEG, settings)
fprintf('OneFNoise')
% the window of anylsis {default = upper, lower }
lower = find(EEG.freqs == settings.lower);
upper = find(EEG.freqs == settings.upper);
lu = lower:upper;
ex = ismember(EEG.freqs,settings.exclude);
index = setxor(lu,find(ex));

% pull the data of interest
P = pow2db(EEG.specdata(:,index));
f = EEG.freqs(index)';
%plot(f,P)
out.oneFall = oneFslope(P,f,EEG)

    function coeffs = oneFslope(P,f,EEG)
        w = warning ('off','all');
        % regress the Power from the frequency
        % the second coefficient is the slope (typically negative))
        % the first is the intercept
        % [coeffs] = regress(P(1,:)',[ones(size(f))' f'])

        coeffs = nan(2,size(EEG.chanlocs,2));
        for i=1:size(EEG.chanlocs,2)
            %[coeffs(:,i)] = [ones(size(f))' log(f)']\P(i,:)';
            %[coeffs(:,i)] = regress(P(i,:)',[ones(size(f))' f'])
            [coeffs(:,i)] = robustfit(f',P(i,:)');
           
        end
        
        coeffs = coeffs(2,:)';
    end

fprintf('\n')
end
