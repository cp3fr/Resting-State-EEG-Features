function pl_power_spectral_densities(inputfolder,outputfolder,settings)

  %input path and names
  fp_input = [inputfolder.folder,filesep,inputfolder.name,filesep];
  fn_eegdata_eyesclosed = 'eegdata_eyesclosed.mat';
  fn_eegdata_eyesopen = 'eegdata_eyesopen.mat';

  %check if input files exist
  infilepathnames = {};
  infilepathnames(1,end+1) = {[fp_input,fn_eegdata_eyesclosed]};
  infilepathnames(1,end+1) = {[fp_input,fn_eegdata_eyesopen]};
  ind = [];
  for fpn = infilepathnames
    ind(1,end+1)=exist(fpn{1})==2;
  end
  input_files_exist = sum(ind)==length(ind);


  %output path and names
  fp_output = [outputfolder.folder,filesep,outputfolder.name,filesep];
  fn_output_specdata_eyesclosed = 'specdata_eyesclosed.mat';
  fn_output_specdata_eyesopen = 'specdata_eyesopen.mat';
  fn_output_specdata_alphapeak_eyesclosed = 'specdata_alphapeak_eyesclosed.mat';
  fn_output_specdata_alphapeak_eyesopen = 'specdata_alphapeak_eyesopen.mat';

  %check if input files exist
  outfilepathnames = {};
  outfilepathnames(1,end+1) = {[fp_output,fn_output_specdata_eyesclosed]};
  outfilepathnames(1,end+1) = {[fp_output,fn_output_specdata_eyesopen]};
  outfilepathnames(1,end+1) = {[fp_output,fn_output_specdata_alphapeak_eyesclosed]};
  outfilepathnames(1,end+1) = {[fp_output,fn_output_specdata_alphapeak_eyesopen]};
  ind = [];
  for fpn = outfilepathnames
    ind(1,end+1)=exist(fpn{1})==2;
  end
  output_files_exist = sum(ind)==length(ind);


  %% ALL INPUT FILE EXIST? OUTPUT EXISTS? PROCESS THE DATA AGAIN?


  if input_files_exist && (~output_files_exist || settings.todo.override)

    %output folder for plots
    fp_plots = [fp_output,'specdata',filesep];

    %make sure output folder for plots exists
    if ~isdir(fp_plots)
      mkdir(fp_plots);
    end


    %% COMPUTE POWER SPECTRAL DENSITIES

    spectro = [];

    for eyes = {'eyesclosed','eyesopen'}

      fn = ['eegdata_',eyes{1},'.mat'];

      %loading EEG
      load([fp_input,fn],'EEG');

      %Spectrogram (using spectopo) for all good segments of the data (i.e. 1min30sec for eyesopen and 3min10sec for eyesclosed)
      spectro.(eyes{1}) = RestingSpectro(EEG, settings.spectro, eyes{1});

      %extract specdata for the current condition
      specdata = spectro.(eyes{1});

      %save specdata
      fn = ['specdata_',eyes{1},'.mat'];
      save([fp_output,fn],'specdata');

      %make power spectrum plot...
      figure;
      subplot(2,1,1),imagesc(specdata.welch.specdata),colorbar,title('welch')
      subplot(2,1,2),imagesc(specdata.fft.specdata),colorbar,title('fft')

      %save the plot
      fn = sprintf('specdata_%s',eyes{1});
      saveas(gcf,[fp_plots,fn],'png');
      close;

    end
    clear specdata;


  end


end



