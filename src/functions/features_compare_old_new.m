clear all;close all;clc;
restoredefaultpath;

%settings
todo.psd_compare_average = false;
todo.psd_compare_cluster = false;
todo.psd_compare_channel = false;
todo.spectro_compare_average = true;
todo.spectro_compare_cluster = false;
todo.spectro_compare_channel = false;


%%% PSD AVERAGE

if todo.psd_compare_average

  new = readtable('/Volumes/methlab/HBN_RestingEEG_Features/results/csv/features_psd_average.csv');
  old = readtable('/Volumes/methlab/HBN_RestingEEG_Features/results_old/csv/RestingEEG_Spectro_Average.csv');

  %compare column names
  hdr_new = new.Properties.VariableNames;
  hdr_old = old.Properties.VariableNames;
  ind = cellfun(@(x,y) strcmpi(x,y),hdr_old,hdr_new);
  sprintf('header comparison old new: %d/%d match',sum(ind),length(ind))
  [hdr_old',hdr_new']

  %select the same subjects
  ind = zeros(size(new,1),1);
  for i = 1:size(new,1)
    ind(i) = sum(strcmpi(old.id,new.id(i)))>0;
  end
  new = new(logical(ind),:);
  old = sortrows(old,1);
  new = sortrows(new,1);

  %select the same subjects
  ind = zeros(size(old,1),1);
  for i = 1:size(old,1)
    ind(i) = sum(strcmpi(new.id,old.id(i)))>0;
  end
  old = old(logical(ind),:);
  old = sortrows(old,1);
  new = sortrows(new,1);

  %compare the data
  mold = table2array(old(:,2:end));
  mnew = table2array(new(:,2:end));
  figure;
  subplot(1,3,1);imagesc(mold);colorbar;; title('PSD AVERAGE')
  subplot(1,3,2);imagesc(mnew);colorbar;
  subplot(1,3,3);imagesc(mold-mnew,[-1,1].*0.000000000000001);colorbar;

end


%%% PSD CLUSTER

if todo.psd_compare_cluster

  new = readtable('/Volumes/methlab/HBN_RestingEEG_Features/results/csv/features_psd_cluster.csv');
  old = readtable('/Volumes/methlab/HBN_RestingEEG_Features/results_old/csv/RestingEEG_Spectro_Clusters.csv');

  %compare column names
  hdr_new = new.Properties.VariableNames;
  hdr_old = old.Properties.VariableNames;
  ind = cellfun(@(x,y) strcmpi(x,y),hdr_old,hdr_new);
  sprintf('header comparison old new: %d/%d match',sum(ind),length(ind))
  [hdr_old',hdr_new']

  %select the same subjects
  ind = zeros(size(new,1),1);
  for i = 1:size(new,1)
    ind(i) = sum(strcmpi(old.id,new.id(i)))>0;
  end
  new = new(logical(ind),:);
  old = sortrows(old,1);
  new = sortrows(new,1);

  %select the same subjects
  ind = zeros(size(old,1),1);
  for i = 1:size(old,1)
    ind(i) = sum(strcmpi(new.id,old.id(i)))>0;
  end
  old = old(logical(ind),:);
  old = sortrows(old,1);
  new = sortrows(new,1);

  %compare the data
  mold = table2array(old(:,2:end));
  mnew = table2array(new(:,2:end));
  figure;
  subplot(1,3,1);imagesc(mold);colorbar; title('PSD CLUSTER')
  subplot(1,3,2);imagesc(mnew);colorbar;
  subplot(1,3,3);imagesc(mold-mnew,[-1,1].*0.000000000000001);colorbar;

end


%%% PSD CHANNEL

if todo.psd_compare_channel

  new = readtable('/Volumes/methlab/HBN_RestingEEG_Features/results/csv/features_psd_channel.csv');
  old = readtable('/Volumes/methlab/HBN_RestingEEG_Features/results_old/csv/RestingEEG_Spectro_Channels.csv');

  %compare column names
  hdr_new = new.Properties.VariableNames;
  hdr_old = old.Properties.VariableNames;
  ind = cellfun(@(x,y) strcmpi(x,y),hdr_old,hdr_new);
  sprintf('header comparison old new: %d/%d match',sum(ind),length(ind))
  [hdr_old',hdr_new']

  %select the same subjects
  ind = zeros(size(new,1),1);
  for i = 1:size(new,1)
    ind(i) = sum(strcmpi(old.id,new.id(i)))>0;
  end
  new = new(logical(ind),:);
  old = sortrows(old,1);
  new = sortrows(new,1);

  %select the same subjects
  ind = zeros(size(old,1),1);
  for i = 1:size(old,1)
    ind(i) = sum(strcmpi(new.id,old.id(i)))>0;
  end
  old = old(logical(ind),:);
  old = sortrows(old,1);
  new = sortrows(new,1);

  %compare the data
  mold = table2array(old(:,2:end));
  mnew = table2array(new(:,2:end));
  figure;
  subplot(1,3,1);imagesc(mold);colorbar;; title('PSD CHANNEL')
  subplot(1,3,2);imagesc(mnew);colorbar;
  subplot(1,3,3);imagesc(mold-mnew,[-1,1].*0.000000000000001);colorbar;

end





%%% SPECTRO AVERAGE
if todo.spectro_compare_average

  new = readtable('/Volumes/methlab/HBN_RestingEEG_Features/results/csv/features_spectro_average.csv');
  old = readtable('/Volumes/methlab/HBN_RestingEEG_Features/results_old/csv/RestingEEG_Feature_Average.csv');

  %remove the quality rating column
  ind = ~strcmpi(old.Properties.VariableNames,'quality_rating');
  old = old(:,ind);

  %compare column names
  hdr_new = new.Properties.VariableNames;
  hdr_old = old.Properties.VariableNames;
  [~,idx_new] = sort(hdr_new);
  [~,idx_old] = sort(hdr_old);
  old = old(:,idx_old);
  new = new(:,idx_new);
  hdr_new = new.Properties.VariableNames;
  hdr_old = old.Properties.VariableNames;

  ind = cellfun(@(x,y) strcmpi(x,y),hdr_old,hdr_new);
  sprintf('header comparison old new: %d/%d match',sum(ind),length(ind))
  [hdr_old',hdr_new']

  %select the same subjects
  ind = zeros(size(new,1),1);
  for i = 1:size(new,1)
    ind(i) = sum(strcmpi(old.id,new.id(i)))>0;
  end
  new = new(logical(ind),:);
  old = sortrows(old,1);
  new = sortrows(new,1);

  %select the same subjects
  ind = zeros(size(old,1),1);
  for i = 1:size(old,1)
    ind(i) = sum(strcmpi(new.id,old.id(i)))>0;
  end
  old = old(logical(ind),:);
  old = sortrows(old,1);
  new = sortrows(new,1);

  %compare the data
  ind = ~strcmpi(old.Properties.VariableNames,'id');
  mold = table2array(old(:,ind));
  mnew = table2array(new(:,ind));
  figure;
  subplot(1,3,1);imagesc(mold);colorbar;; title('SPECTRO AVERAGE')
  subplot(1,3,2);imagesc(mnew);colorbar;
  diffvals = mold-mnew;
  ind = isnan(mold) & isnan(mnew);
  diffvals(ind)=0;
  subplot(1,3,3);imagesc(diffvals,[-1,1].*0.000000000000001);colorbar;

end

%%% SPECTRO CLUSTER
%...

%%% SPECTRO CHANNEL
%...



