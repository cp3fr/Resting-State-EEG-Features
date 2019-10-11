function p03_02_microstates_across_subjects()



%=============================================================
%microstate across subject segmentation and backfitting
if microstate_across==1

  %select the group of subjects for segmentation

  load([settings.path.tables,filesep,'processing_summary.mat'],'tbl');
  ind = tbl.HasMicrostateFeatures==1;
  tbl=tbl(ind,:);
  n = size(tbl,1);

  fp_group = settings.path.group;
  fn_groupdata = sprintf('GEEG_n=%d.mat',n);
  fn_grouptable = sprintf('GEEG_n=%d_table.mat',n);

  %if output data does not exist load GFP peaks for all subjects in one file
  if ~ ( exist([fp_group,fn_groupdata]) && exist([fp_group,fn_grouptable]) )

    %load gfp data from all subjects
    data = []
    for i = 1:n
      fp = [tbl.Outputpath{i},'microstate/'];
      fn = 'GEEG.mat';
      disp(sprintf('file %d/%d: %s',i,n,[fp,fn]))
      load([fp,fn],'GEEG');
      data=cat(2,data,GEEG);
      clear GEEG;
    end

    GEEG = data;
    clear data;

    if ~isdir(fp_group)
      mkdir(fp_group);
    end

    disp(['..saving ',fp_group,fn_groupdata]);
    save([fp_group,fn_groupdata],'GEEG','-v7.3');
    disp(['..saving ',fp_group,fn_grouptable]);
    save([fp_group,fn_grouptable],'tbl');

    %make a copy of the chanlocs
    if i==1
      fp = [tbl.Outputpath{1},'microstate/'];
      fn = 'chanlocs.mat';
      disp(['..saving ',fp_group,fn]);
      copyfile([fp,fn],[fp_group,fn]);
    end

  %if output data does exist, load it
  else
    disp(['..loading ',fp_group,fn_groupdata]);
    load([fp_group,fn_groupdata],'GEEG');
    disp(['..loading ',fp_group,fn_grouptable]);
    load([fp_group,fn_grouptable],'tbl');
    disp(['..loading ',fp_group,'chanlocs.mat']);
    load([fp_group,'chanlocs.mat'],'chanlocs');
  end


  % %quick hack for pipeline testing
  % GEEG = GEEG(:,1:5000);

  %% SEGMENTATION =========

  %make a dataset with gfp peaks from all subjects concatenated
  EEGtmp = eeg_emptyset();
  EEGtmp.setname = 'GFPpeakmaps';
  EEGtmp.chanlocs = chanlocs;
  EEGtmp.nbchan = length(chanlocs);
  EEGtmp.trials = 1;
  EEGtmp.srate = settings.spectro.sr;
  EEGtmp.data = GEEG;
  EEGtmp.pnts = size(EEGtmp.data,2);
  EEGtmp.times = (1:size(EEGtmp.data,2))*1000/EEG.srate;
  EEGtmp.nbchan = size(EEGtmp.data,1);
  EEGtmp.microstate.data = EEGtmp.data;

  %segment the data
  EEG = pop_micro_segment( ...
    EEGtmp, ...
    'algorithm', 'modkmeans', ...
    'sorting', 'Global explained variance', ...
    'normalise', 0, ...
    'Nmicrostates', 2:8, ...
    'verbose', 1, ... 
    'Nrepetitions', 50, ...
    'fitmeas', 'CV', 'max_iterations', 1000, ...
    'threshold', 1e-06, ...
    'optimised', 1 );

  %ERROR on Sciencecloud
  % Starting initialisations no. 50 out of 50. Finished in 177 iterations.
  % Error using bsxfun
  % Requested 563116x563116 (1181.3GB) array exceeds maximum array size preference.
  % Creation of arrays greater than this limit may take a long time and cause
  % MATLAB to become unresponsive. See <a href="matlab: helpview([docroot
  % '/matlab/helptargets.map'], 'matlab_env_workspace_prefs')">array size limit</a>
  % or preference panel for more information.

  % Error in calc_fitmeas (line 107)
  %         Dk(k) = sum(sum(bsxfun(@plus,clstrsq',clstrsq)-2*(cluster'*cluster)));

  % Error in pop_micro_segment (line 278)
  % [KL, KL_nrm, W, CV, GEV] = calc_fitmeas(data, EEG.microstate.Res.A_all, ...

  % Error in Batch (line 335)
  %   EEG = pop_micro_segment( ...







  %make the outputfolder
  fp =[fp_group,'microstate/'];
  if ~isdir(fp)
    mkdir(fp);
  end

  %save the prototypes
  fp =[fp_group,'microstate/'];
  fn = 'prototypes.mat';
  disp(['..saving ',fp,fn])
  save([fp,fn],'EEG','-v7.3')

  %make and save the protype figure
  figure;
  MicroPlotTopo( EEG, 'plot_range', [] );
  fp =[fp_group,'microstate/'];
  fn = 'prototypes';
  disp(['..saving ',fp,fn])
  saveas(gcf,[fp,fn],'png');
  close;

  % Select active number of microstates: W, KL and KLnorm are not polarity   
  % invariant, z.B. 5   Mit GUI und Graphik ausw�hlen oder vorbestimmt?
  EEG = pop_micro_selectNmicro( EEG,'Measures',{'CV', 'GEV'}, 'do_subplots',1,'Nmicro',4);%

  %save the selected prototypes
  fp =[fp_group,'microstate/'];
  fn = 'prototypes_selected.mat';
  disp(['..saving ',fp,fn])
  save([fp,fn],'EEG','-v7.3')

  %% BACKFITTING ============

  %implement..
  %loop over subjects 
  %loop over condition eyesopen eyesclosed
  %do the backfitting
  %save the output features


  % for i = 1:size(Allasd,1) fprintf('Importing prototypes and backfitting for dataset %i\n',i)
      
  %     clear EEG EEGEyesClosed_2D EEGEyesClosed
      
  %     load([Allasd.folder{i},'/',Allasd.filename{i}])
      
      
  %     n30 = sum(contains({EEG.event(:).type},'30'));
      
  %     Allasd.n30(i) = n30;
      
  %     if n30 > 1 %selection threshold
          
  %         disp(['..loading ',Allasd.folder{i},Allasd.filename{i}])
          
  %         Allasd.loaded(i) = 1;
          
          
  %         for j=1:length(EEG.event)
  %             EEG.event(j).latency=EEG.event(j).sample;
  %         end
          
  %         EEGEyesClosed = pop_epoch(EEG, {'30 '} , [2 38]);
          
  %         %2D: reshape from 3D to 2D with "reshape(A,2,[])"
  %         %permute(EEGEyesClosed.data,1,3,2)
          
  %         EEGEyesClosed_2D = EEGEyesClosed;
          
  %         EEGEyesClosed_2D.data = reshape(permute(EEGEyesClosed.data,[2,3,1]),[],EEGEyesClosed.nbchan)';
          
  %         EEGEyesClosed_2D.pnts = size(EEGEyesClosed_2D.data,2);
          
  %         EEG = EEGEyesClosed_2D;
          
  %         % [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEGEyesClosed_2D, CURRENTSET,'retrieve',i,'study',0);
          
  %         %3.6 Back-fit microstates on all EEG
  %         EEG = pop_micro_import_proto( EEG, ALLEEG, 24); %change
          
  %         EEG = pop_micro_fit( EEG, 'polarity', 0 );
          
  %         % 3.7 Temporally smooth microstates labels
  %         EEG = pop_micro_smooth( EEG, 'label_type', 'backfit','smooth_type', 'reject segments', 'minTime', 30, 'polarity', 0 );
          
  %         % 3.9 Calculate microstate statistics
  %         EEG = pop_micro_stats( EEG, 'label_type', 'backfit', 'polarity', 0 );
  %         %[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
          
  %         Allasd.GEVtotal(i) = EEG.microstate.stats.GEVtotal;
  %         Allasd.Gfp{i} = EEG.microstate.stats.Gfp;
  %         Allasd.Occurence{i} = EEG.microstate.stats.Occurence;
  %         Allasd.Duration{i} = EEG.microstate.stats.Duration;
  %         Allasd.Coverage{i} = EEG.microstate.stats.Coverage;
  %         Allasd.Duration{i} = EEG.microstate.stats.Duration;
  %         Allasd.GEV{i} = EEG.microstate.stats.GEV;
  %         Allasd.MspatCorr{i} = EEG.microstate.stats.MspatCorr;
  %         Allasd.TP{i} = EEG.microstate.stats.TP;
          
  %     elseif n30 <= 1 %selection threshold   
   
  %         Allasd.GEVtotal(i) = nan;lgo
  %         Allasd.Gfp{i} = nan;
  %         Allasd.Occurence{i} = nan;
  %         Allasd.Duration{i} = nan;
  %         Allasd.Coverage{i} = nan;
  %         Allasd.Duration{i} = nan;
  %         Allasd.GEV{i} = nan;
  %         Allasd.MspatCorr{i} = nan;
  %         Allasd.TP{i} = nan;
  %     end
  % end




end