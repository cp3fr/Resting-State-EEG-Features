%%pl_fooof(folder,settings)
%
% christian.pfeiffer@uzh.ch
% 20.08.2019
%
function pl_fooof(folder,settings)

  %path to data
  subjpath = [settings.path.process,folder.name,filesep];

  disp(['..loading ',subjpath,'features_spectro','.mat'])

  %loads the spectral features
  load([subjpath,'features_spectro','.mat'],'features');

  %computes fooof features for different conditions
  try
    features = add_fooof_spectro(features,settings);
  end

  %if any fooof output has been added...
  if isfield(features.eyesclosed.welch,'fooof') ...
    || isfield(features.eyesclosed.fft,'fooof') ...
    || isfield(features.eyesopen.welch,'fooof') ...
    || isfield(features.eyesopen.fft,'fooof')
  
    disp(['..saving ',subjpath,'features_spectro_fooof','.mat'])

    %save the features to output folder
    save([subjpath,'features_spectro_fooof','.mat'],'features');

  end

end