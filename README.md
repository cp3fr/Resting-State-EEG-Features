# HBN Resting EEG Features

This dataset contains resting-state electroencephalography (EEG) features based on the 
Child Mind Institute Healthy Brain Network dataset (http://fcon_1000.projects.nitrc.org/indi/cmi_healthy_brain_network/).

## Filenames

* README.md
* RestingEEG_Microstates.csv
* RestingEEG_PSD_Average.csv
* RestingEEG_PSD_Channel.csv
* RestingEEG_PSD_Cluster.csv
* RestingEEG_Preprocessing.csv
* RestingEEG_Spectro_Channel.csv
* RestingEEG_Spectro_Cluster.csv
* RestingEEG_Spectro_Ratios.csv
* RestingEEG_Spectro_Average.csv


## Samples

The dataset consists data from 1485 subjects in two experimental condtions:
- eyesclosed: several blocks of 40sec eyes-closed resting-state EEG
- eyesopen: several blocks of 20sec eyes-open resting-state EEG

block order was interleaved, 
first and last second of each block was removed during preprocessing

EEG data was preprocessed with the Automagic toolbox (version 2.3.8., https://github.com/methlabUZH/automagic), 
including standard preprocessing pipeline with no EOG regression 

Data from different subjects are stored in different rows, subjects can be identified via the unique identifier 'id'.


## Features

There are four kinds of features:
* Preprocessing: Data quality information and number of data samples related to preprocessing
* Power Spectral Densities (PSD): Frequency-wise spectral power from 1-90 Hz
* Spectro: Spectrogram-based features, such as frequency band, individual alpha power, and FOOOF parameters
* Microstates: Microstate segmentation based features

There are three feature levels: 
* Channel: one feature for each of 105 EEG channels
* Cluster: one feature for each of 6 channel clusters
* Average: one feature for the average all EEG channels


## Feature Names

PREPROCESSING:

  id: Subject identifier (anonymized):
  quality_rating: EEG data quality rating (B=bad O=ok G=good) from Automagic:            

PSD:

  CONDITION_psd_FREQUENCY_LEVEL
    where...
    - CONDITION refers to experimental conditions: eyesclosed, eyesopen
    - FREQUENCY refers to frequency bins: 01dot00Hz to 90dot00Hz in steps of 00dot50Hz
    - LEVEL refers to the different feature levels (channels, cluster, average)

SPECTRO:       
  fband: fixed frequency bands
  alphapeak: individual alpha peak
  indfband: individual frequency bands relative to individual alpha peak
  fooof: 1/f aperiodic signal fit and oscillatory peak parameters
  ratios: individual frequency band-power x electrode-cluster ratios
    where...
    - relmean is band power relative to the mean overall power
    - absmean is absolute band power

MICROSTATES                                  
  eyesclosed_microstates_gevtotal            
  eyesclosed_microstates_gfp_prototypeNB      
  eyesclosed_microstates_occurence_prototypeNB
  eyesclosed_microstates_duration_prototypeNB 
  eyesclosed_microstates_coverage_prototypeNB 
  eyesclosed_microstates_gev_prototypeNB      
  eyesclosed_microstates_mspatcorr_prototypeNB
    where NB refers to Microstate prototype number: 1, 2, 3, 4


christian.pfeiffer@uzh.ch
28.10.2019