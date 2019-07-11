function [EEG_IT, EEG_IU, EEG_CT, EEG_CU, EEG_UN] = BEES_Split_Cond_batch(filemat, pathToFiles, dirFolder)
    %% BEES ssvep data processing
    % Created 12/19/2017
    %
    % Read in set file, filter & split data by condition so it's ready to
    % be cleaned and transformed to frequency domain
    %
    % Raw data and Event Info must have already been imported, and the file
    % must be saved as a .set file: BEES_PRE(orPOST)_#_age (e.g., BEES_PRE_2_9)

for j = 1:size(filemat,1)
    subject_string = deblank(filemat(j,:));
    Csubject = char(subject_string);
    C = strsplit(Csubject,'_');
    subject = char(C(1,3));
    timepoint = char(C(1,2));
    age = char(C(1,4));
    C2 = strsplit(Csubject,'.');
    Csubject = char(C2(1,1));
    file = strcat(dirFolder,Csubject);
    filename = strcat(dirFolder, Csubject, '.set');
    
    
    EEG = pop_loadset('filename', filename);
    % Add channel locations
    EEG = pop_editset(EEG, 'setname', strcat(file, '_chan'));
    % Create Event List
    EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' } );
    EEG = pop_editset(EEG, 'setname', strcat(file,'_chan_elist'));
    
    % Bandpass filter from 0.5-30 Hz
    dataAK=double(EEG.data); 
    [alow, blow] = butter(6, 0.12); 
    [ahigh, bhigh] = butter(3,0.002, 'high'); 
     
    dataAKafterlow = filtfilt(alow, blow, dataAK'); 
    dataAKafterhigh = filtfilt(ahigh, bhigh, dataAKafterlow)'; 
     
    EEG.data = single(dataAKafterhigh); 
     
    EEG = pop_editset(EEG, 'setname', strcat(filename,'_chan_elist_filt'));
    %save the filtered file
    EEG = pop_saveset( EEG, 'filename',strcat(file,'_filt.set'));
    
    % check for the Split_Condition folder and create it if it doesn't
    % exist
    if ~exist(strcat(pathToFiles, 'Split_Condition/'),'dir')
        makedir(strcat(pathToFiles, 'Split_Condition/'))
    end

    NEWpath= strcat(pathToFiles, 'Split_Condition/');
    
    % Run through all 5 conditions and create epochs and save file
    Condition = 'Ind-trained';
        EEG_IT  = pop_binlister( EEG , 'BDF', strcat(pathToFiles, 'Ind-trained.txt'), 'IndexEL',  1, 'SendEL2',...
        'EEG', 'Voutput', 'EEG' );

        EEG_IT = pop_editset(EEG_IT, 'setname', strcat(pathToFiles, 'DATA FILES/BEES_',num2str(subject),'_',num2str(age),'_chan_elist_filt_bins'));

        % Create bin-based epochs from -100 to 6000ms, use pre for baseline
        % correction
        EEG_IT = pop_epochbin( EEG_IT , [-100.0  6000.0],  'pre'); 
        EEG_IT = pop_editset(EEG_IT, 'setname', strcat(pathToFiles, 'DATA FILES/BEES_',num2str(subject),'_',num2str(age),'_chan_elist_filt_bins_be'));

        EEG_IT = pop_saveset( EEG_IT, 'filename',strcat(NEWpath, Csubject,'_',Condition,'.set'));
            
    Condition = 'Ind-untrained';

        EEG_IU  = pop_binlister( EEG , 'BDF', strcat(pathToFiles, 'Ind-untrained.txt'), 'IndexEL',  1, 'SendEL2',...
        'EEG', 'Voutput', 'EEG' );

        EEG_IU = pop_editset(EEG_IU, 'setname', strcat(pathToFiles, 'DATA FILES/BEES_',num2str(subject),'_',num2str(age),'_chan_elist_filt_bins'));

        % Create bin-based epochs
        EEG_IU = pop_epochbin( EEG_IU , [-100.0  6000.0],  'pre'); 
        EEG_IU = pop_editset(EEG_IU, 'setname', strcat(pathToFiles, 'DATA FILES/BEES_',num2str(subject),'_',num2str(age),'_chan_elist_filt_bins_be'));

        EEG_IU = pop_saveset( EEG_IU, 'filename',strcat(NEWpath, Csubject,'_',Condition,'.set'));

    Condition = 'Cat-trained';

        EEG_CT  = pop_binlister( EEG , 'BDF', strcat(pathToFiles, 'Cat-trained.txt'), 'IndexEL',  1, 'SendEL2',...
        'EEG', 'Voutput', 'EEG' );

        EEG_CT = pop_editset(EEG_CT, 'setname', strcat(pathToFiles, 'DATA FILES/BEES_',num2str(subject),'_',num2str(age),'_chan_elist_filt_bins'));

        % Create bin-based epochs
        EEG_CT = pop_epochbin( EEG_CT , [-100.0  6000.0],  'pre'); 
        EEG_CT = pop_editset(EEG_CT, 'setname', strcat(pathToFiles, 'DATA FILES/BEES_',num2str(subject),'_',num2str(age),'_chan_elist_filt_bins_be'));

        EEG_CT = pop_saveset( EEG_CT, 'filename',strcat(NEWpath, Csubject,'_',Condition,'.set'));

    Condition = 'Cat-untrained';

        EEG_CU  = pop_binlister( EEG , 'BDF', strcat(pathToFiles, 'Cat-untrained.txt'), 'IndexEL',  1, 'SendEL2',...
        'EEG', 'Voutput', 'EEG' );

        EEG_CU = pop_editset(EEG_CU, 'setname', strcat(pathToFiles, 'DATA FILES/BEES_',num2str(subject),'_',num2str(age),'_chan_elist_filt_bins'));
        
        % Create bin-based epochs
        EEG_CU = pop_epochbin( EEG_CU , [-100.0  6000.0],  'pre'); 
        EEG_CU = pop_editset(EEG_CU, 'setname', strcat(pathToFiles, 'DATA FILES/BEES_',num2str(subject),'_',num2str(age),'_chan_elist_filt_bins_be'));

        EEG_CU = pop_saveset( EEG_CU, 'filename',strcat(NEWpath, Csubject,'_',Condition,'.set'));

    Condition = 'Untrained';

        EEG_UN  = pop_binlister( EEG , 'BDF', strcat(pathToFiles, 'Untrained.txt'), 'IndexEL',  1, 'SendEL2',...
        'EEG', 'Voutput', 'EEG' );

        EEG_UN = pop_editset(EEG_UN, 'setname', strcat(pathToFiles, 'DATA FILES/BEES_',num2str(subject),'_',num2str(age),'_chan_elist_filt_bins'));
        
        % Create bin-based epochs
        EEG_UN = pop_epochbin( EEG_UN , [-100.0  6000.0],  'pre'); 
        EEG_UN = pop_editset(EEG_UN, 'setname', strcat(pathToFiles, 'DATA FILES/BEES_',num2str(subject),'_',num2str(age),'_chan_elist_filt_bins_be'));

        EEG_UN = pop_saveset( EEG_UN, 'filename',strcat(NEWpath, Csubject,'_',Condition,'.set'));

end
 
 
%%Next run through check_data and FFT

