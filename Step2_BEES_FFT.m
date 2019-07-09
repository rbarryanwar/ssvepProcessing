%----------------------------------------------------------%
% This script takes cleaned data in the time domain and    %
% transforms it to the frequency domain using the          %
% FFT_spectrum.m function. The resulting amplitude data    %
% (pow) is saved as a file                                 %
% In PART 1 this is done on each individual file           %
% In PART 2 this is done on the grand avgerage
%----------------------------------------------------------%
%% PART 1: One pow file per condition per time point per participant

clear
clc

cd '/Users/rabarry/Documents/BEES Study/Flicker processing_BEES/Split_Condition/CLEAN CHAN/'
filematALL = dir('BEES_*_9_flick_*_CLEAN.set'); % This loads a struct of files of a specific condition e.g. (Pre)    
filemat = {filematALL.name}'; % This takes the just the names from that struct and transposes the list so its in the correct format
MYpath='/Users/rabarry/Documents/BEES Study/Flicker processing_BEES/'

for j = 1:size(filemat,1)
    subject = deblank(filemat(j,:));
    Csubject = char(subject);
    EEG = pop_loadset('filename',Csubject,'filepath',strcat(MYpath, 'Split_Condition/CLEAN CHAN/'));
    EEG = eeg_checkset( EEG );
    % puts the data into a 3d matrix: channels x time x trial
    inmat3d = EEG.data; 
    
    % averages over the trial to get a 2D matrix
    mat2d = nanmean(inmat3d, 3);
    
    %This removes the 100ms baseline and first second of data so that the
    %trials are 5000 ms (exactly 30 6Hz cycles and 25 5Hz cycles)
    % Then the data averaged in the time domain is transformed to the
    % frequency domain
    [pow, phase, freqs] = FFT_spectrum(mat2d(:, 551:end), 500); 
    
    % The resulting amplitude variable is saved
    save(strcat(MYpath,'pow files/cb1/', Csubject,'.mat'),'pow');
end

%% PART 2: Create a grand average in the time domain and perform FFT on this avg

clear
clc

cd '/Users/rabarry/Documents/BEES Study/Flicker processing_BEES/Split_Condition/CLEAN CHAN/'
filematALL = dir('BEES_*_9_flick_*_CLEAN.set'); % This loads a struct of files of a specific condition e.g. (Pre)    
filemat = {filematALL.name}'; % This takes the just the names from that struct and transposes the list so its in the correct format
MYpath='/Users/rabarry/Documents/BEES Study/Flicker processing_BEES/'

% create an empty matrix to add all data to
grandavg_ALL = zeros(109,3050,size(filemat,1));

for j = 1:size(filemat,1)
    subject = deblank(filemat(j,:));
    Csubject = char(subject);
    EEG = pop_loadset('filename',Csubject,'filepath',strcat(MYpath, 'Split_Condition/CLEAN CHAN/'));
    EEG = eeg_checkset( EEG );
    % puts the data into a 3d matrix: channels x time x trial
    inmat3d = EEG.data; 
    % averages over the trial to get a 2D matrix
    mat2d = nanmean(inmat3d, 3);
    % adds each participant's data to the avg matrix
    grandavg_ALL(:,:,j) = mat2d;
end 

% average over partiicpant go get a grand average in the time domain
grandavg_TIME = mean(grandavg_ALL,3);
% save this average as an EEGLAB .set file
EEG.data = single(grandavg_TIME);
EEG = pop_saveset( EEG, 'filename','grandavg_TIME.set');

% The grand average is then transformed to the frequency domain
[pow, phase, freqs] = FFT_spectrum(grandavg_TIME(:, 551:end), 500); 

save ('grandavg_pow.mat', 'pow')