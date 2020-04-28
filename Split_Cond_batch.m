function EEG = Split_Cond_batch(filemat, dirFolder, CB, Condition, event_file, epoch, HP, LP)
    %% BEES ssvep data processing
    % Created 12/19/2017
    %
    % Read in set file, filter & split data by condition so it's ready to
    % be cleaned and transformed to frequency domain
    %
    % Raw data and Event Info must have already been imported, and the file
    % must be saved as a .set file

for j = 1:size(filemat,1)
    subject_string = deblank(filemat(j,:));
    Csubject = char(subject_string);
    C2 = strsplit(Csubject,'.');
    Csubject = char(C2(1,1));
    file = strcat(dirFolder,Csubject);
    filename = strcat(dirFolder, Csubject, '.set');
    %if CB==2
    %    check for CB2 in the name
    %end
    EEG = pop_loadset('filename', filename);
    % Add channel locations
    EEG = pop_editset(EEG, 'setname', strcat(file, '_chan'));
    % Create Event List
    EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' } );
    EEG = pop_editset(EEG, 'setname', strcat(file,'_chan_elist'));
    
    % Bandpass filter 
    dataAK=double(EEG.data); 
    [alow, blow] = butter(6, (LP/250), 'low'); 
    [ahigh, bhigh] = butter(3,(HP/250), 'high'); 
     
    dataAKafterlow = filtfilt(alow, blow, dataAK'); 
    dataAKafterhigh = filtfilt(ahigh, bhigh, dataAKafterlow)'; 
     
    EEG.data = single(dataAKafterhigh); 
     
    EEG = pop_editset(EEG, 'setname', strcat(filename,'_chan_elist_filt'));
    %save the filtered file
    EEG = pop_saveset( EEG, 'filename',strcat(file,'_filt.set'));
    
    
    cd('../')
    % check for the Split_Condition folder and create it if it doesn't
    % exist
    
    if CB ~= 2
        if ~exist(strcat(cd, '/Split_Condition/'),'dir')
        mkdir(strcat(cd, '/Split_Condition/'))
        end
        NEWpath= strcat(cd, '/Split_Condition/');
    
        % check for the Split_Condition folder and create it if it doesn't
    % exist
    else
        if ~exist(strcat(cd, '/Split_Condition_CB2/'),'dir')
            mkdir(strcat(cd, '/Split_Condition_CB2/'))
        end
        NEWpath= strcat(cd, '/Split_Condition_CB2/');
    end
    
    % create epochs for the specified condition and save file
    EEG  = pop_binlister( EEG , 'BDF', strcat(cd, '/', event_file), 'IndexEL',  1, 'SendEL2',...
    'EEG', 'Voutput', 'EEG' );

    EEG = pop_editset(EEG, 'setname', strcat(Csubject,'_chan_elist_filt_bins'));

    % Create bin-based epochs, use pre for baseline correction
    EEG = pop_epochbin( EEG , epoch,  'pre'); 
    EEG = pop_editset(EEG, 'setname', strcat(Csubject,'_chan_elist_filt_bins_be'));

    EEG = pop_saveset( EEG, 'filename',strcat(NEWpath, Csubject,'_',Condition,'.set'));
end
 
 
%%Next run through check_data and FFT

