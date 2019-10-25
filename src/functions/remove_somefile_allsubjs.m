clear all;close all;clc;

folder = dir('/Volumes/methlab/HBN_RestingEEG_Features/results/process/');
ind = contains({folder.name},'NDAR');
folder =folder(ind);



for i = 1:length(folder)

  disp(sprintf('..removing file %d/%d',i,length(folder)))

  % fn = 'microstates_eyesclosed.mat';
  fn = 'features_specdata.mat';

  fp = [folder(i).folder,filesep,folder(i).name,filesep];

  try
    delete([fp,fn]);
  end
end