
%----------------------------------------------------------%
% This script takes cleaned data in the time domain and    %
% removes the baseline plus first second of the trial and  %
% then averages across trials within a condition (Script 1)%
% or within a participant (Script 2)- depending on what    %
% your question is.                                        %
% Various values in the EEG struct are also updated so     %
% that the data structure corresponds to the info in the   %
% EEG struct. A new .set file is saved                     %
% Script 3 does the same thing but keeps the baseline and  %
% first second                                             %
%----------------------------------------------------------%
%% SCRIPT 1: Average across trial within a condition in time domain then send to letswave

clear

% 1. Enter the path of the folder that has the cleaned data files
clean_loc = '';

% 2. Enter the path of the folder where you want to save the averaged files
output_location = '';

cd(clean_loc)

% 3. Enter the pattern you want to search for-- or enter a full filename
filematALL = dir('BEES_POST_155_*_CLEAN.set'); % This loads a struct of files of a specific participant e.g. (Pre 206 or Pre 206 IT)    
filemat = {filematALL.name}'; % This takes the just the names from that struct and transposes the list so its in the correct format


% To test a case/ for debugging, set j = 1 and run the preceding lines and then run just the code between 'for' and 'end' 

for j = 1:size(filemat,1)
    subject = deblank(filemat(j,:));
    Csubject = char(subject);
    C = strsplit(Csubject,'.'); % splits the filename up by '.' and puts pieces into a cell array 'C'
    sub = char(C(1,1)); % saves the first half of that split as sub
    D = strsplit(sub,'_'); % splits the subject info by '_' and puts pieces into a cell array 'D'
        % use those pieces in D to create a filename for saving-- may need
        % to adjust the last cell to use depending on how the files are
        % named!!-- Either 6 or 7 will be the condition
    subj = strcat(char(D(1,1)), '_',char(D(1,2)), '_',char(D(1,3)), '_',char(D(1,4)), '_',char(D(1,5)), '_',char(D(1,7))); 
    EEG = pop_loadset('filename',Csubject,'filepath',clean_loc);
    EEG = eeg_checkset( EEG );
    
        % puts the data into a 3d matrix: channels x time x trial
        % This also removes the 100ms baseline and first second of data so that the
        % trials are 5000 ms (exactly 30 6Hz cycles and 25 5Hz cycles)
    inmat3d = EEG.data(:,551:end,:); 
    
    mat2d = nanmean(inmat3d, 3); % averages over the trial to get a 2D matrix
    
    EEG.data = single(mat2d); % saves that average in the EEGLAB format
    EEG.pnts = 2500; %updates number of data points to reflect 5s
    EEG.xmin=0; %updates start time to be 0 instead of -100
    EEG.xmax=4.9980; % updates end time to be 5s instead of 6s
    EEG.event(1).latency=0; %changes latency of the first event to 0 
    EEG = pop_saveset( EEG, 'filename',strcat(output_location, '/',subj, '_avg.set'));

end



%% SCRIPT 2: Average across cond in time domain then send to letswave-- used for face vs. object comparisons

clear

% 1. Enter the path of the folder that has the cleaned data files
clean_loc = '';

% 2. Enter the path of the folder where you want to save the averaged files
output_location = '';

cd(clean_loc)

% 3. Enter the pattern you want to search for-- must run one participant at a time
filematALL = dir('BEES_POST_155_*_CLEAN.set'); % This loads a struct of files of a specific participant e.g. (Pre 206 or Pre 206 IT)    
filemat = {filematALL.name}'; % This takes the just the names from that struct and transposes the list so its in the correct format

alltrials = zeros(109,2500,size(filemat,1)); %creates an empty matrix that will get filled in with the for loop

for j = 1:size(filemat,1)
    subject = deblank(filemat(j,:));
    Csubject = char(subject);
    C = strsplit(Csubject,'.');
    sub = char(C(1,1));
    D = strsplit(sub,'_');
    EEG = pop_loadset('filename',Csubject,'filepath',clean_loc);
    EEG = eeg_checkset( EEG );
    % puts the data into a 3d matrix: channels x time x trial
    %This also removes the 100ms baseline and first second of data so that the
    %trials are 5000 ms (exactly 30 6Hz cycles and 25 5Hz cycles)
    inmat3d = EEG.data(:,551:end,:); 
    mat2d = nanmean(inmat3d, 3); % averages over the trial to get a 2D matrix
    alltrials(:,:,j) = mat2d; % puts this average into our matrix
    
end

avg = nanmean(alltrials,3); %averages over all of the conditions
EEG.data = single(avg);
EEG.pnts = 2500;
EEG.xmin=0;
EEG.xmax=4.9980;
EEG.event(1).latency=0;
subj = strcat(char(D(1,1)), '_',char(D(1,2)), '_',char(D(1,3)), '_',char(D(1,4)), '_',char(D(1,5))); 
EEG = pop_saveset( EEG, 'filename',strcat(output_location, '/',subj, '_avg.set'));

%% SCRIPT 3: Average across cond in time domain KEEPING baseline-- used for plotting

clear

% 1. Enter the path of the folder that has the cleaned data files
clean_loc = '';

% 2. Enter the path of the folder where you want to save the averaged files
output_location = '';

cd(clean_loc)

% 3. Enter the pattern you want to search for-- must run one participant at a time
filematALL = dir('BEES_PRE_315_*_CLEAN.set'); % This loads a struct of files of a specific condition e.g. (Pre)    
filemat = {filematALL.name}'; % This takes the just the names from that struct and transposes the list so its in the correct format

alltrials = zeros(109,3050,size(filemat,1));

for j = 1:size(filemat,1)
    subject = deblank(filemat(j,:));
    Csubject = char(subject);
    C = strsplit(Csubject,'.');
    sub = char(C(1,1));
    D = strsplit(sub,'_');
    EEG = pop_loadset('filename',Csubject,'filepath',clean_loc);
    EEG = eeg_checkset( EEG );
    % puts the data into a 3d matrix: channels x time x trial
    inmat3d = EEG.data; 
    % averages over the trial to get a 2D matrix
    mat2d = nanmean(inmat3d, 3);
    alltrials(:,:,j) = mat2d;
    
    
end

avg = nanmean(alltrials,3);
EEG.data = single(avg);
subj = strcat(char(D(1,1)), '_',char(D(1,2)), '_',char(D(1,3)), '_',char(D(1,4)), '_',char(D(1,5))); 
EEG = pop_saveset( EEG, 'filename',strcat(output_location, '/',subj, '_avg_baseline.set'));

