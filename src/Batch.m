%%Batch.m
%
%Script for extracting features from HBN Resting EEG data
%
%christian.pfeiffer@uzh.ch
%25.10.2019
%
clear all; close all; clc;
restoredefaultpath;

%=============================================================
%(Note 24.10.2019): in p03_02_microstates_segmentation(s) using a modified function 'pop_micro_segment_nofitstats' where some memory-intensive fit statistics are commented out 

%=============================================================
%processing settings

%load default settings
s = p00_default_settings();

%some manual settings
s.todo.override                 = false;
s.todo.load_segment_data        = false;
s.todo.power_spectral_densities = false;
s.todo.frequency_bands          = false;
s.todo.fooof                    = false; %run fooof for all files on local machine
s.todo.microstates_gfppeaks     = false;
s.todo.microstates_segmentation = false; 
s.todo.microstates_backfitting  = false;
% s.todo.functional_connectivity  = false;
s.todo.write_features_to_csv    = true; %temporarily uncommented spectro until fooof is done
s.todo.processing_summary       = false;


%=============================================================
%batch processing

p01_load_segment_data(s);
p02_01_power_spectral_densities(s);
p02_02_frequency_bands(s);
p02_03_fooof(s);
p03_01_microstates_gfppeaks(s);
p03_02_microstates_segmentation(s); 
p03_03_microstates_backfitting(s);
% p04_functional_connectivity(s);
p05_features_to_csv(s);
p06_processing_summary(s);
