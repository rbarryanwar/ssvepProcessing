# ssvepProcessing

## These scripts can be used to process data from an ssvep task. 

The file structure I use is as follows (*you can use a different structure but will need to adjust the script*):

* I have a main Study folder. In this folder I have the following folders: 'Data Files' and 'Split_Condition'
    * All of my raw data files are in Study folder/Data files
    * All of my output from Step1 goes into Study folder/Split_Condition
* The event info files (Ind-trained.text, etc) are in the main Study folder

**Step1_data_pipeline.m uses Split_Cond_batch.m and clean_data_batch.m and combines the time domain pre-processing into a streamlined step-by-step file. Run this file in chunks (Run Section) to first split and clean your files and then detect artifacts and remove bad trials.**

Option1:
    Step2_BEES_FFT.m uses FFT_spectrum.m to perform a fast fourier transform on cleaned data. There are 2 parts to this   
    script. Part 1 performs the FFT on each file. Part 2 performs the FFT on a grand average.

Option2:
    Step2_BEES_avg_forLetswave.m prepares averages that can be imported into Letswave for further processing.
    Once imported, I perform an FFT on each file and then compute baseline corrected amplitudes (BCA) using the FFT files.
    I used bins 2-3 and use the subtract method for my data.
    
   After performing the BCA, I export those bca files to MATLAB

All of the included files are completely customizable.
