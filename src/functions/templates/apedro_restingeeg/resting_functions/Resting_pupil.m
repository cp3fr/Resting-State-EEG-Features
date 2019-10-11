function [ET_resting] = Resting_pupil(data,settings,eyeevent, event,colheader)

% Trigger definieren
eyeo = find(event(:,2) == settings.trig_eyeo);
eyec = find(event(:,2) == settings.trig_eyec);


% Index f�r Pupilleninformation in eyeevent.fixations
for i = 1:size(eyeevent.fixations.colheader,2)
    
    if strmatch('fix_avgpupilsize',eyeevent.fixations.colheader(1,i)) == 1
        index_pupil = i;
    end
end
%% Alle Datenpunkte welche im gew�nschten Zeitfenster (eyesopen) werden
%% extrahiert und bereinigt

pupil_per_block_fulldata_tmp={};

for i=1:size(eyeo,1)-1
    tmp=[];
    for ii=1:size(data,1)
        if data(ii,1) > event(eyeo(i),1) + settings.seg_time && data(ii,1) < event(eyec(i),1)- settings.seg_time % segments +1 and -1 seconds for each eyesopen segment (+500 and -500)
            %correct for blinks, cut out 0s with [-100 +500]ms
            if ~ any ([data(ii,1) > eyeevent.saccades.data(:,1)]' & [data(ii,1) < eyeevent.saccades.data(:,2)]')
                if  any ([data(ii,1) > eyeevent.blinks.data(:,1)-60]' & [data(ii,1) < eyeevent.blinks.data(:,2)+100]')
                    tmp(end+1)=NaN;
                else
                    tmp(end+1)=data(ii,4);
                end
            else
                tmp(end+1)=NaN;
            end
        end
    end
    pupil_per_block_fulldata_tmp{i}=tmp;
end

% get rid of outlier Data at beginning (Data > mean +2sd of data, without beginning part) 
% or impossible small values (maybe near blinks) (Data < mean -4sd) 
deleted=[];
for i=1:5

    dat=pupil_per_block_fulldata_tmp{i};
    tmp_mean=nanmean(dat(2000:end));
    tmp_std=nanstd(dat(2000:end));
    
    for ii=1:length(pupil_per_block_fulldata_tmp{i})
        if dat(ii)> (tmp_mean+(3*tmp_std)) || dat(ii)< (tmp_mean-(4*tmp_std))
            deleted(i,end+1)=ii;
            dat(ii)=NaN;
        end
    end
    pupil_per_block_fulldata_tmp{i}=dat(5000:end);%dat(2000:end); %discard first 2 seconds
end

% % dont do linear interpolation, values do not make sense in some cases!
% % linear interpolation of missing values due to blinks and saccades
% for i=1:size(pupil_per_block_fulldata_tmp,2)
%     pupil_per_block_fulldata_tmp{i}=fillmissing(pupil_per_block_fulldata_tmp{i},'linear');
% end
% %check: idx=any(isnan(pupil_per_block_fulldata_tmp{1}));
%
minsize = min(cellfun('size', pupil_per_block_fulldata_tmp, 2));

for i=1:5
    tmp=pupil_per_block_fulldata_tmp{i};
    pupil_per_block_fulldata(i,:)=tmp(1:minsize);
end

%% calculate average pupil size based on full cleaned trialdata
all_values_full_concat = [];
for i = 1:size(pupil_per_block_fulldata,1)
    pupilsize_block_mean(i) = nanmean(pupil_per_block_fulldata(i,:));
    pupilsize_block_median(i) = nanmedian(pupil_per_block_fulldata(i,:));
    all_values_full_concat = [all_values_full_concat pupil_per_block_fulldata(i,:)];
end

all_values_full=pupil_per_block_fulldata;
all_values_full_concat([find(isnan(all_values_full_concat))])=[];

for i=1:5
    tmp=all_values_full(i,:);
    tmp([find(isnan(tmp))])=[];
    all_values_full_noNaN{i} = tmp;
    if i==1
        trialSizes(i)=length(tmp);
    else
        trialSizes(i)=trialSizes(i-1)+length(tmp);
    end
end

% pupil_slope_full_tmp = polyfit(1:1:(size(all_values_full_concat,2)),all_values_full_concat,1);
% pupil_slope_full = pupil_slope_full_tmp (1,1);
% pupil_intercept_full = pupil_slope_full_tmp (1,2);
mdl_full = LinearModel.fit(1:1:(size(all_values_full_concat,2)),all_values_full_concat);

for i=1:5
    if isempty(all_values_full_noNaN{i})
        mdl_trial{i}=[];
    else
        mdl_trial{i}=LinearModel.fit(1:length(all_values_full_noNaN{i}),all_values_full_noNaN{i});
    end
end

pupilsize_overall_mean=mean(all_values_full_concat);
pupilsize_overall_median=median(all_values_full_concat);


% figure; plot (mdl_full)
% hold on
% for i=1:5
% line([trialSizes(i) trialSizes(i)], [300, 600]);
% end
% hold off;
%
% figure;plot([1:20000],[pupil_intercept_full + pupil_slope_full * [1:10]])

%% Speichere Daten
ET_resting.pupilsize_block_mean=pupilsize_block_mean;
ET_resting.pupilsize_block_median=pupilsize_block_median;
ET_resting.pupilsize_overall_mean=pupilsize_overall_mean;
ET_resting.pupilsize_overall_median=pupilsize_overall_median;
ET_resting.mdl_full=mdl_full;
ET_resting.mdl_trial=mdl_trial;

% speichere Rohsignal w�hrend gesamtem Resting:

% finde startpunkt von erstem augenauf bis letztem augenauf
startResting=event(eyeo(1));
startRestingSample=find(data(:,1)<=startResting);

stopResting=event(eyeo(end));
stoptRestingSample=find(data(:,1)<=stopResting);

ET_resting.rawSignal=data(startRestingSample(end):stoptRestingSample(end),4);

