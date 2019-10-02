


clear all;close all;clc;


if contains(pwd,'/Volumes/methlab/')
  mountpath='/Volumes/methlab/';
elseif contains(pwd,'/mnt/methlab-drive/methlab/')
  mountpath='/mnt/methlab-drive/methlab/';
else
  mountpath= 'UNKNOWN_MOUNTPATH';
end



load([mountpath,'HBN_RestingEEG_Features/results/tables/processing_summary.mat'])

for an = {
  'all data',logical(ones(size(tbl,1),1));...
  'no crash',[tbl.CrashNoFile==0 & tbl.CrashZeroData==0 & tbl.CrashEventTrigger==0 & tbl.CrashMicrostate==0]...
  }'

  name = an{1};
  ind = an{2};

  n = sum(ind);
  s=sprintf('%s\nTotal number of subjects: %d\n',upper(name),n);
  for vn = {...
    'HasEegSegments',...
    'HasSpectroFeatures',...
    'HasSpectroSegments',...
    'HasFooofFeatures',...
    'HasMicrostateFeatures',...
    'CrashNoFile',...
    'CrashZeroData',...
    'CrashEventTrigger',...
    'CrashMicrostate'}

    s = sprintf('%s%4.0f/%4.0f (%3.2f%%): %s\n',...
      s,...
      sum(tbl.(vn{1})(ind)),...
      n,...
      100*sum(tbl.(vn{1})(ind))/n,...
      vn{1});
  end
  s
end













% %check some special cases

% ind=tbl.HasEegSegments==0 & tbl.CrashZeroData==0 & tbl.CrashNoFile==0 & tbl.CrashEventTrigger==0;
% tbl.ID(ind)
% {'NDARKE650TFQ'}
% {'NDARWB685NUG'}

% ind=tbl.HasSpectroFeatures==1 & tbl.HasMicrostateFeatures==0;
% tbl.ID(ind)
% {'NDARKE650TFQ'}
% {'NDARWB685NUG'}
% {'NDARFA860RPD'}
% {'NDARMP784KKE'}
% {'NDARMR277TT7'}
% {'NDARNK241ZXA'}
% {'NDARPL201YL4'}
% {'NDARTK878GZK'}




% %% remove directories
% ids = [
% {'NDARKE650TFQ'}
% {'NDARWB685NUG'}
% {'NDARFA860RPD'}
% {'NDARMP784KKE'}
% {'NDARMR277TT7'}
% {'NDARNK241ZXA'}
% {'NDARPL201YL4'}
% {'NDARTK878GZK'}
% ]';

% for id = ids
%   fp = ['/Volumes/methlab/HBN_RestingEEG_Features/results/process/',id{1}];
%   disp(['..removing ',fp])
%   rmdir(fp);
% end