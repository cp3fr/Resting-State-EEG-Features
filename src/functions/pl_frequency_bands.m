function pl_frequency_bands(folders, s)

  for eyes = {'eyesclosed','eyesopen'}


    %input and outputfile name and paths
    fp_input = [folders.folder,filesep,folders.name,filesep];
    fn_input = sprintf('specdata_%s.mat',eyes{1});
    fp_output = [folders.folder,filesep,folders.name,filesep]
    fn_output = sprintf('specdata_fbands_%s.mat',eyes{1});

    %only do this step if inputfile exists, if no outputfile exists or override was requested
    if (exist([fp_input,fn_input])==2) && (  ~(exist([fp_output,fn_output])==2) || s.todo.override )

      %load input data
      disp(['..loading ',fp_input,fn_input])
      load([fp_input,fn_input],'specdata');

      %loop over methods
      for method = {'fft','welch'}

        %compute alphapeaks
        specdata.(method{1}).alphaPeak = RestingAlphaPeak(specdata.(method{1}), s, eyes{1});

        %compute individual alpha
        specdata.(method{1}) = IndividualSpectro(specdata.(method{1}), s.spectro);

      end

      %rename the structure
      specdata_fbands = specdata;

      %save outputfile
      disp(['..saving ',fp_output,fn_output])
      save([fp_output,fn_output],'specdata_fbands');

      %cleanup
      clear specdata specdata_fbands;

    end


end