# HBN Resting EEG Features

This dataset contains resting-state electroencephalography (EEG) features based on the 
Child Mind Institute Healthy Brain Network dataset (http://fcon_1000.projects.nitrc.org/indi/cmi_healthy_brain_network/).

## Filenames

* README.md
* RestingEEG_Preprocessing.csv
* RestingEEG_PSD_Channel.csv
* RestingEEG_PSD_Cluster.csv
* RestingEEG_PSD_Average.csv
* RestingEEG_Spectro_Channel.csv
* RestingEEG_Spectro_Cluster.csv
* RestingEEG_Spectro_Average.csv
* RestingEEG_Spectro_Ratios.csv
* RestingEEG_Microstates.csv


## Samples

The dataset is based on data from 1485 subjects from two experimental condtions:
- eyesclosed: eyes-closed resting-state EEG recordings, 40-sec duration, presented in 5 blocks
- eyesopen: eyes-open resting-state EEG, 20-sec duration, presented in 5 blocks

Block order was interleaved,first and last second of each block were removed during preprocessing.

EEG data was preprocessed with the Automagic toolbox (version 2.3.8., https://github.com/methlabUZH/automagic), 
including standard preprocessing pipeline with no EOG regression.

Data of different subjects are stored in different rows.


## Features

There are four kinds of features, stored in different files:
* Preprocessing: Data quality information and number of data samples related to preprocessing, 
* Power Spectral Densities (PSD): Frequency-wise spectral power from 1-90 Hz
* Spectro: Spectrogram-based features, such as frequency band, individual alpha power, and FOOOF parameters
* Microstates: Microstate segmentation based features

There are three feature levels for PSD and Spectro features: 
* Channel: features for each of 105 EEG channels
* Cluster: features for each of 6 EEG channel clusters
* Average: features for the average across all EEG channels


## Feature Names

PREPROCESSING:

  id:             Subject identifier (anonymized):
  quality_rating: EEG data quality rating (B=bad O=ok G=good) from Automagic:            

PSD:

  CONDITION_psd_FREQUENCY_LEVEL

    where...
    - CONDITION refers to experimental conditions: eyesclosed, eyesopen
    - FREQUENCY refers to frequency bins: 01dot00Hz to 90dot00Hz in steps of 00dot50Hz
    - LEVEL     refers to the different feature levels (channels, cluster, average)

SPECTRO:      

  fband:     fixed frequency bands
  alphapeak: individual alpha peak
  indfband:  individual frequency bands relative to individual alpha peak
  fooof:     1/f aperiodic signal fit and oscillatory peak parameters
  ratios:    individual frequency band-power x electrode-cluster ratios

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

    where...
    - NB refers to Microstate prototype number: 1, 2, 3, 4




christian.pfeiffer@uzh.ch

28.10.2019