%--------------------------------------------------%
% BEES STUDY DATA PROCESSING PIPELINE              %
%                                                  %
%1. Create EEGLAB .set files for your data files    %
%                                                   %
%2. Downsample to 500Hz                             %
%                                                   %
%3. Set your current directory (cd- line 29) to the %
%   folder containing your .set files               %
%                                                   %
%4. Use the filematALL (line 31) to set the pattern %
%   you want to use to look for files to split      %
%                                                   %
%4. Use the filematALLSplit (line 47) to set the    % 
%   pattern you want to use to look for files to    %
%   clean (these files should be in the             %
%   Split_Condition folder from above)              %
%                                                   %
%---------------------------------------------------%
%% PART 1: filter, create event list, assign bins, %
%          filter 1-30Hz                           %
%          segment by condition (-100ms to 6000ms),%
%          baseline correct,                       %
%          and save a separate file per condition. %
%          The resulting files will be in          %
%          pathToFiles/Split_Condition             %
%   Run Section to run PARTS 1&2                    %
%--------------------------------------------------%

clear

% 1. Enter the directory to the folder containing your set files
dirFolder = '/Volumes/Ryan Data/FLICKER/BEES flicker/mff and set files/';
cd(dirFolder)

% 2. Enter the directory where you want the split files to be saved
SplitFolder = '/Volumes/Ryan Data/FLICKER/BEES flicker/Split_Condition/'; 

% 3. Enter the pattern you want to use to find files
filematALL = dir('BEES_PRE_207_*.set'); % This loads a struct of files fitting a specific pattern   
filemat = {filematALL.name}'; % This takes the just the names from that struct and transposes the list so its in the correct format

BEES_Split_Cond_batch(filemat, dirFolder);

%--------------------------------------------------%
%  PART 2: outer band of electrodes removed (if 1),%
%          bad channel replacement and avg ref     %
%          resulting files saved in                %
%          pathToFiles/Split_Condition/CLEAN CHAN  %
%          A list of interpolated channels for each%
%          trial saved as interpvec_filename       %
%--------------------------------------------------%

cd(SplitFolder)
filematALLSplit = dir('BEES_PRE_207_*.set'); % This loads a struct of files of a specific condition e.g. (Pre)    
filematSplit = {filematALLSplit.name}'; % This takes the just the names from that struct and transposes the list so its in the correct format


%(filemat, path, Remove outer band? 0 (no) or 1 (yes), Baby? 0 (no) or 1 (yes))
BEES_clean_data_batch(filematSplit, SplitFolder,1,1);

result_path = strcat(pathToFilesSplit,'CLEAN CHAN/')
cd(result_path)
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
