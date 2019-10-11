%%Batch.m
%
%Script for extracting features from HBN Resting EEG data
%
%christian.pfeiffer@uzh.ch
%02.10.2019
clear all; close all; clc;
restoredefaultpath;

%=============================================================
% Todo
% -make the script modular and incremental
% -add a function for subject selection based on available output files 
% -add some prerequisite check at the beginning of each module
% -add a info output for each module reporting on the level of success of each step

%=============================================================
%processing settings

%load default settings
s = p00_default_settings();

%some manual settings
s.todo.override                 = false;
s.todo.load_segment_data        = true;
s.todo.power_spectral_densities = true;
s.todo.fooof                    = false;
s.todo.microstates_gfppeaks     = true;
s.todo.microstates_segmentation = true;
s.todo.microstates_backfitting  = true;


%=============================================================
%batch processing

p01_load_segment_data(s) 

p02_01_power_spectral_densities(s)

p02_02_fooof(s)

p03_01_microstates_gfppeaks(s)

p03_02_microstates_segmentation(s)

p03_03_microstates_backfitting(s)

% p04_functional_connectivity(s)

% p05_write_features_to_csv(s)
