HBN Resting EEG Features

This repository contains resting-state electroencephalography (EEG) features, and code to extract those features from data from the Child Mind Institute Healthy Brain Network dataset (http://fcon_1000.projects.nitrc.org/indi/cmi_healthy_brain_network/).


INPUT DATA:

Input data is continuous EEG, previously preprocessed with the Automagic toolbox (version 2.3.8., https://github.com/methlabUZH/automagic), including standard preprocessing pipeline with no EOG regression


OUTPUT DATA:

Features are available for 1479 subjects.

Features are stored in HBN_RestingEEG_Features/results/csv/
in files named:
* "RestingEEG_Spectro_LEVEL.csv" (power spectral densities)
* "RestingEEG_Feature_LEVEL.csv" (features based on power spectral densities)

where LEVEL refers to 
* channel (one feature for each of 105 EEG channels)
* cluster (one feature for each of 6 predefined channel clusters)
* average (one feature for the average signal across all EEG channels)


FEATURE NAMES:

Subject identifier (anonymized):
  id                              

EEG data quality rating (B=bad O=ok G=good) from Automagic:        
  quality_rating       

Power spectral densities:
  eyesclosed_specdata_FREQ_LEVEL
  eyesopen_specdata_FREQ_LEVEL
  (Note: FREQ refers to frequency-bins from 1-90 Hz, in steps of 0.5 Hz,
         and excluding 58-62 Hz, e.g. '01dot50hz'=1.5Hz, '70dot00hz'=70Hz)
 
Power for fixed frequency bands:
  eyesclosed_fband_delta_absmean_LEVEL 
  eyesclosed_fband_delta_relmean_LEVEL         
  eyesclosed_fband_theta_absmean_LEVEL         
  eyesclosed_fband_theta_relmean_LEVEL         
  eyesclosed_fband_alpha_absmean_LEVEL         
  eyesclosed_fband_alpha_relmean_LEVEL         
  eyesclosed_fband_beta_absmean_LEVEL          
  eyesclosed_fband_beta_relmean_LEVEL          
  eyesclosed_fband_gamma_absmean_LEVEL         
  eyesclosed_fband_gamma_relmean_LEVEL         
  eyesopen_fband_delta_absmean_LEVEL           
  eyesopen_fband_delta_relmean_LEVEL           
  eyesopen_fband_theta_absmean_LEVEL           
  eyesopen_fband_theta_relmean_LEVEL           
  eyesopen_fband_alpha_absmean_LEVEL           
  eyesopen_fband_alpha_relmean_LEVEL           
  eyesopen_fband_beta_absmean_LEVEL            
  eyesopen_fband_beta_relmean_LEVEL            
  eyesopen_fband_gamma_absmean_LEVEL           
  eyesopen_fband_gamma_relmean_LEVEL   

Individual alpha peak:        
  eyesclosed_alphapeak_max_freq                  
  eyesclosed_alphapeak_max_amplitude             
  eyesclosed_alphapeak_derivative_freq           
  eyesclosed_alphapeak_derivative_amplitude      
  eyesclosed_alphapeak_gravity_freq              
  eyesclosed_alphapeak_gravity_amplitude         
  eyesopen_alphapeak_max_freq                    
  eyesopen_alphapeak_max_amplitude               
  eyesopen_alphapeak_derivative_freq             
  eyesopen_alphapeak_derivative_amplitude        
  eyesopen_alphapeak_gravity_freq                
  eyesopen_alphapeak_gravity_amplitude           

Individual frequency band (limits relative to individual alpha peak frequency) power
  eyesclosed_indfband_theta_absmean_LEVEL      
  eyesclosed_indfband_theta_relmean_LEVEL      
  eyesclosed_indfband_lower1alpha_absmean_LEVEL
  eyesclosed_indfband_lower1alpha_relmean_LEVEL
  eyesclosed_indfband_lower2alpha_absmean_LEVEL
  eyesclosed_indfband_lower2alpha_relmean_LEVEL
  eyesclosed_indfband_upperalpha_absmean_LEVEL 
  eyesclosed_indfband_upperalpha_relmean_LEVEL 
  eyesclosed_indfband_beta_absmean_LEVEL       
  eyesclosed_indfband_beta_relmean_LEVEL       
  eyesopen_indfband_theta_absmean_LEVEL        
  eyesopen_indfband_theta_relmean_LEVEL        
  eyesopen_indfband_lower1alpha_absmean_LEVEL  
  eyesopen_indfband_lower1alpha_relmean_LEVEL  
  eyesopen_indfband_lower2alpha_absmean_LEVEL  
  eyesopen_indfband_lower2alpha_relmean_LEVEL  
  eyesopen_indfband_upperalpha_absmean_LEVEL   
  eyesopen_indfband_upperalpha_relmean_LEVEL   
  eyesopen_indfband_beta_absmean_LEVEL         
  eyesopen_indfband_beta_relmean_LEVEL         

FOOOF fit parameters:
  eyesclosed_fooof_aperiodic_intercept_LEVEL   
  eyesclosed_fooof_aperiodic_slope_LEVEL       
  eyesclosed_fooof_peak_freq_LEVEL             
  eyesclosed_fooof_peak_amplitude_LEVEL        
  eyesopen_fooof_aperiodic_intercept_LEVEL     
  eyesopen_fooof_aperiodic_slope_LEVEL         
  eyesopen_fooof_peak_freq_LEVEL               
  eyesopen_fooof_peak_amplitude_LEVEL          

christian.pfeiffer@uzh.ch
02.10.2019