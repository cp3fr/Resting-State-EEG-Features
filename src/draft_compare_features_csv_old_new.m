clear all;close all;clc;
restoredefaultpath;

%%% PSD AVERAGE

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

%compare the data
mold = table2array(old(:,2:end));
mnew = table2array(new(:,2:end));
figure;
subplot(1,3,1);imagesc(mold);colorbar;
subplot(1,3,2);imagesc(mnew);colorbar;
subplot(1,3,3);imagesc(mold-mnew,[-1,1].*0.000000000000001);colorbar;

clear; close all; clc;



%%% PSD CLUSTER

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

%compare the data
mold = table2array(old(:,2:end));
mnew = table2array(new(:,2:end));
figure;
subplot(1,3,1);imagesc(mold);colorbar;
subplot(1,3,2);imagesc(mnew);colorbar;
subplot(1,3,3);imagesc(mold-mnew,[-1,1].*0.000000000000001);colorbar;

clear; close all; clc;


%%% PSD CHANNEL (checkthis)

new = readtable('/Volumes/methlab/HBN_RestingEEG_Features/results/csv/features_psd_channel.csv');
old = readtable('/Volumes/methlab/HBN_RestingEEG_Features/results_old/csv/RestingEEG_Spectro_Channelss.csv');

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

%compare the data
mold = table2array(old(:,2:end));
mnew = table2array(new(:,2:end));
figure;
subplot(1,3,1);imagesc(mold);colorbar;
subplot(1,3,2);imagesc(mnew);colorbar;
subplot(1,3,3);imagesc(mold-mnew,[-1,1].*0.000000000000001);colorbar;

clear; close all; clc;



%%% SPECTRO AVERAGE
%...

%%% SPECTRO CLUSTER
%...

%%% SPECTRO CHANNEL
%...



