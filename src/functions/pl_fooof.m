function pl_fooof(inputfolder,outputfolder,settings)


  fp = [inputfolder.folder,filesep,inputfolder.name,filesep];
  fn_specdata_eyesclosed = 'specdata_eyesclosed.mat';
  fn_specdata_eyesopen = 'specdata_eyesopen.mat';
  fn_fooof_eyesclosed = 'specdata_fooof_eyesclosed.mat';
  fn_fooof_eyesopen = 'specdata_fooof_eyesopen.mat';

  input_files_exist = (exist([fp,fn_specdata_eyesclosed])==2)  ....
                     && (exist([fp,fn_specdata_eyesopen])==2);
                   
  output_files_exist = (exist([fp,fn_fooof_eyesclosed])==2)  ....
                     && (exist([fp,fn_fooof_eyesopen])==2);


  if input_files_exist  && (~output_files_exist || settings.todo.override)


    %% LOAD SPECDATA AND COMBINE IN SPECTRO STRUCTURE

    spectro = [];

    for eyes = {'eyesclosed','eyesopen'}

      fn = ['specdata_',eyes{1},'.mat'];

      disp(['..loading ',fp,fn])

      load([fp,fn],'specdata');

      spectro.(eyes{1}) = specdata;

      clear specdata;

    end


    %% ADD FOOOF TO SPECTRO STRUCTURE


    try
      disp(['..computing FOOOF'])
      spectro = add_fooof_spectro(spectro,settings);
    end


    %% SAVE SPECDATA WITH FOOOF

    for eyes = {'eyesclosed','eyesopen'}

      specdata_fooof = spectro.(eyes{1});

      %save specdata, simply overwrite
      fn = ['specdata_fooof_',eyes{1},'.mat'];

      disp(['..saving ',fp,fn])
      save([fp,fn],'specdata_fooof');

      clear specdata_fooof;

    end


  end


end