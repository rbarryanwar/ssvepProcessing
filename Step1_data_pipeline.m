% ************************************************************************
% The University of Florida Developmental EEG Pipeline
% Version 1.0
% Developed at the Brain, Cognition, & Development Lab, University of
% Florida
%
% Author:
% Ryan Barry-Anwar (rbarryanwar@ufl.edu)
%
% This pipeline uses EEGLAB toolbox and some of its plugins. Before running 
% the pipeline, you have to install the following:
% EEGLab:  https://sccn.ucsd.edu/eeglab/downloadtoolbox.php/download.php
%
%       Before running this pipeline:               
% 1. Create EEGLAB .set files for your data files    
%                                                   
% 2. Downsample to 500Hz                             
%                                  
%% User input: user provide relevant information to be used for data processing
%
clear
%
% 1. Enter the directory to the folder containing your .set files
dirFolder = '/Users/rabarry/Documents/ssvepProcessing/Data Files/';
cd(dirFolder)
%
% 2. Enter the directory where you want the split files to be saved
SplitFolder = '/Users/rabarry/Documents/ssvepProcessing/Split_Condition_CB2/'; 
%
% 3. Enter the pattern you want to use to find files
filematALL = dir('BEES_PRE_205_*.set'); % This loads a struct of files fitting that pattern   
filemat = {filematALL.name}'; % This takes just the names from that struct and transposes the list so its in the correct format
%
% 4. Enter in the counterbalance
CB = 2; %(enter 0 if there are no counterbalances or if CB=1, enter 2 for CB=2)
%
% 5. Enter in the filter cut-offs
LP = 30; % low pass
HP = 1; % high pass
%
% 6. Enter in the condition you want to process, name of the file
% containing event information, and length of the epochs
Condition = 'Ind-trained';
event_file = 'Ind-trained.txt';
epoch = [-100 6000]; 
%
%7. Do you want to remove the outer band of electrodes?
outerband = 1; %0 for No, 1 for Yes
% If necessary, the electodes included in the outerband can be updated on
% line 22 of the clean_data_batch.m file

%8. Is this a baby?
Baby = 1; %0 for No, 1 for Yes

%% PART 1: filter, create event list, assign bins, split up the conditions,
%          and baseline correct. Output will be in SplitFolder
%
Split_Cond_batch(filemat, dirFolder, CB, Condition, event_file, epoch, HP, LP);
%% PART2: remove outer band of electrodes, identify and replace bad electrodes,
%         apply average reference. Output will be in SplitFolder inside
%         CLEAN CHAN folder
%
%         Also, a list of interpolated channels for each trial saved as 
%         interpvec_filename in the SplitFolder

cd(SplitFolder)

%(filemat, path, outerband, Baby? 0 (no) or 1 (yes))
clean_data_batch(filematALL, SplitFolder,outerband,1);


%% 
%--------------------------------------------------%
%  The resulting files can then be viewed, artifact%
%  detection can be performed, and bad trials can  %
%  be removed. I like to use the following for this%
%--------------------------------------------------%
%% PART 3: Artifact Detection                      %
%

clear
clc

pathToFilesAD='/Volumes/Ryan Data/FLICKER/BEES flicker/Split_Condition/CLEAN CHAN/'
cd(pathToFilesAD)
% I like to do this for one person and time point at a time
filematALL = dir('BEES_POST_207_6_*_CLEAN.set'); % This loads a struct of files of a specific condition e.g. (Pre)    
filemat = {filematALL.name}'; % This takes the just the names from that struct and transposes the list so its in the correct format



 for j = 1:size(filemat,1)
    %extract filename
    subject_string = deblank(filemat(j,:));
    Csubject = char(subject_string);
    C = strsplit(Csubject,'.');
    file = char(C(1,1));
    filename = strcat(pathToFilesAD,Csubject);
    
    %load file
    EEG = pop_loadset('filename',filename);
    
    % Check for artifacts. Here, I'm using a simple voltage threshold- you can find other
    % methods in ERPlab
    EEG  = pop_artextval( EEG , 'Channel',  1:109, 'Flag',  1, 'Threshold', [ -400 400], 'Twindow', [ 1000 5998] ); % GUI: 05-Jun-2019 09:04:06
    EEG = eeg_checkset( EEG );
    %plot the data
    pop_eegplot(EEG, 1,1,1)
    
    % this saves a copy of the file were the bad trials are marked but
    % still included in the file
   % EEG = pop_saveset( EEG, 'filename',strcat(file, '_AD.set'));
 end

%% PART 4: remove bad trials
% 
clear

%list out the file you want to remove trials from
filename = 'BEES_POST_207_6_flick_Cat-untrained_CLEAN.set';

%this extracts filename without extension
C = strsplit(filename,'.');
file = char(C(1,1));

%load the file
EEG = pop_loadset('filename',filename);
% pop_eegplot(EEG, 1,1,1)

% in brackets, list the trials you want to remove (no comma needed)
EEG = pop_select( EEG,'notrial',[1]);

%save this file 
%EEG = pop_saveset( EEG, 'filename',strcat(file, '_BadRemoved.set'));
EEG = pop_saveset( EEG, 'filename',file);
