# ssvepProcessing

These scripts can be used to process data from an ssvep task. 

Step1_BEES_data_pipeline.m uses BEES_Split_Cond_batch.m and BEES_clean_data_batch.m and combines the time domain pre-processing into a streamlined step-by-step file. Run this file in chunks (Run Section) to first split and clean your files and then detect artifacts and remove bad trials.

Option1:
    Step2_BEES_FFT.m uses FFT_spectrum.m to perform a fast fourier transform on cleaned data. There are 2 parts to this   
    script. Part 1 performs the FFT on each file. Part 2 performs the FFT on a grand average.

Option2:
    Step2_BEES_avg_forLetswave.m prepares averages that can be imported into Letswave for further processing.
    Once imported, I perform an FFT on each file and then compute baseline corrected amplitudes (BCA) using the FFT files.
    I used bins 2-3 and use the subtract method for my data.
    
   After performing the BCA, I export those bca files to MATLAB

All of the included files are completely customizable.
