function p03_02_microstates_segmentation(s)

%if this step is required
if s.todo.microstates_segmentation==1

  %find all input folders
  %here: eegdata.mat in results/process/SUBJFOLDER/
  folders = dir(s.path.process); 
  folders = folders(contains({folders.name},'NDAR'));

  %outputfolder
  fp_output = [s.path.group,'microstates',filesep];
  if ~isdir(fp_output)
    mkdir(fp_output);
  end


  %% COLLECT GFP PEAKS FROM ALL SUBJECTS


  %collect gfp peaks
  for eyes = {'eyesclosed'}

    %outputfiles
    fn_gfppeaks = ['gfppeaks_',eyes{1},'.mat'];
    fn_info = ['info_',eyes{1},'.mat'];

    %only do this if no output exists or override is requested
    if ~(exist([fp_output,fn_gfppeaks])==2) || s.todo.override

      GEEG = [];
      info = table;
      for i = 1:length(folders)

        %make a copy of the chanlocs file
        if strcmpi(eyes,'eyesclosed') && (i==1)
          copyfile([folders(i).folder,filesep,folders(i).name,filesep,'chanlocs.mat'],...
                   [fp_output,'chanlocs.mat'])
        end

        %append GFP peaks
        disp(sprintf('..appending GFP peaks, %s, file: %d/%d (%.2f%%)',...
          eyes{1},i,length(folders),100*i/length(folders)))

        [GEEG, info] = collect_gfppeaks_all_subjects(GEEG, info, eyes{1}, folders(i), s);

      end

      %saving the output

      disp(['..saving ',fp_output,fn_info])
      save([fp_output,fn_info],'info');

      disp(['..saving ',fp_output,fn_gfppeaks])
      save([fp_output,fn_gfppeaks],'GEEG','-v7.3');

    end

  end


  %% SEGMENTATION

  %using a modified function 'pop_micro_segment_nofitstats' where some memory-intensive fit statistics are commented out (24.10.2019)
  pl_microstates_segmentation(s);


end
