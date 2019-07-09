%--------------------------------------------------%
% BEES STUDY DATA PROCESSING PIPELINE              %
%                                                  %
%1. Create EEGLAB .set files for your data files   %
%                                                  %
%2. Downsample to 500Hz                            %
%                                                  %
%3. Navigate to the folder containing your files   %
%                                                  %
%4. Use the filematALL (line 33) to set the pattern%
%   you want to use to look for files and both cd  %
%   (line 32) &pathToFiles (line 35) to specify the%
%   directory                                      %
%                                                  %
%5. Use the filematALLSplit (line 49) to set the   % 
%   pattern you want to use to look for files and  %
%   both cd (line 48) & pathToFilesSplit (line 51) %
%   to specify the directory. (these files should  %
%   be in the Split_Condition folder from above)   %
%                                                  %
%--------------------------------------------------%
%% PART 1: filter, create event list, assign bins, %
%          segment by condition (-100ms to 6000ms),%
%          baseline correct,                       %
%          and save a separate file per condition. %
%          The resulting files will be in          %
%          pathToFiles/Split_Condition             %
%   Run Section to run PARTS 1&2                    %
%--------------------------------------------------%

clear
cd '/Users/rabarry/Documents/BEES Study/Flicker processing_BEES/Data Files/'
filematALL = dir('BEES_POST_TEST_*.set'); % This loads a struct of files of a specific condition e.g. (Pre)    
filemat = {filematALL.name}'; % This takes the just the names from that struct and transposes the list so its in the correct format
pathToFiles='/Users/rabarry/Documents/BEES Study/Flicker processing_BEES/'

BEES_Split_Cond_batch(filemat, pathToFiles);

%--------------------------------------------------%
%  PART 2: outer band of electrodes removed,       %
%          bad channel replacement and avg ref     %
%          resulting files saved in                %
%          pathToFiles/Split_Condition/CLEAN CHAN  %
%          A list of interpolated channels for each%
%          trial saved as interpvec_filename       %
%--------------------------------------------------%

cd '/Users/rabarry/Documents/BEES Study/Flicker processing_BEES/Split_Condition/'
filematALLSplit = dir('BEES_POST_TEST_*.set'); % This loads a struct of files of a specific condition e.g. (Pre)    
filematSplit = {filematALLSplit.name}'; % This takes the just the names from that struct and transposes the list so its in the correct format
pathToFilesSplit='/Users/rabarry/Documents/BEES Study/Flicker processing_BEES/Split_Condition/'

BEES_clean_data_batch(filematSplit, pathToFilesSplit);

cd '/Users/rabarry/Documents/BEES Study/Flicker processing_BEES/Split_Condition/CLEAN CHAN/'
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

cd '/Users/rabarry/Documents/BEES Study/Flicker processing_BEES/Split_Condition/CLEAN CHAN/'
% I like to do this for one person and time point at a time
filematALL = dir('BEES_POST_TEST_9_*_CLEAN.set'); % This loads a struct of files of a specific condition e.g. (Pre)    
filemat = {filematALL.name}'; % This takes the just the names from that struct and transposes the list so its in the correct format
pathToFilesAD='/Users/rabarry/Documents/BEES Study/Flicker processing_BEES/Split_Condition/CLEAN CHAN/'


 for j = 1:size(filemat,1)
    subject_string = deblank(filemat(j,:));
    Csubject = char(subject_string);
    C = strsplit(Csubject,'.');
    file = char(C(1,1));
    filename = strcat(pathToFilesAD,Csubject);
    EEG = pop_loadset('filename',filename);
    % here, I'm using a simple voltage threshold- you can find other
    % methods in ERPlab
    EEG  = pop_artextval( EEG , 'Channel',  1:109, 'Flag',  1, 'Threshold', [ -300 300], 'Twindow', [ 1000 5998] ); % GUI: 05-Jun-2019 09:04:06
    EEG = eeg_checkset( EEG );
    pop_eegplot(EEG, 1,1,1)
    % this saves a copy of the file were the bad trials are marked but
    % still included in the file
    EEG = pop_saveset( EEG, 'filename',strcat(file, '_AD.set'));
 end

%% PART 4: remove bad trials
% 
clear

%list out the file you want to remove trials from
filename = 'BEES_POST_TEST_9_flick_Untrained_CLEAN.set';
C = strsplit(filename,'.');
file = char(C(1,1));

EEG = pop_loadset('filename',filename);
% pop_eegplot(EEG, 1,1,1)

% in brackets, list the trials you want to remove (no comma needed)
EEG = pop_select( EEG,'notrial',[1 2]);

%save this file 
EEG = pop_saveset( EEG, 'filename',strcat(file, '_BadRemoved.set'));

