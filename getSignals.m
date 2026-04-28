function signalsTable = getSignals(ID, numEpochs)
    % INPUT:
    %   ID: number of subject
    %   numEpochs: number of epochs
    %
    % OUTPUT:
    %   signalsTable: table (epochs x (signals + sleepStages))

    %Loading data
    edfPsg = sprintf("Dataset/%d-PSG.edf",ID);
    psg = edfread(edfPsg);          %timetable
    edfHyp = sprintf("Dataset/%d-H.edf",ID);
    info_hyp = edfinfo(edfHyp);
    ann = info_hyp.Annotations;     %table
    
    %Parameters
    epoch_len = 30;     %Epoch duration
    
    num_epochs = height(psg);
    
    %Label vector
    epoch_labels = strings(num_epochs,1);
    
    for i = 1:height(ann)
        onset_sec = seconds(ann.Onset(i));
        duration_sec = seconds(ann.Duration(i));
        
        start_epoch = floor(onset_sec / epoch_len) + 1;
        end_epoch = floor((onset_sec + duration_sec) / epoch_len);
        
        %Defining range
        start_epoch = max(start_epoch,1);
        end_epoch = min(end_epoch,num_epochs);
        
        %Labels to corresponding epochs
        epoch_labels(start_epoch:end_epoch) = string(ann.Annotations(i));
    end
    
    epoch_labels = epoch_labels(1:numEpochs);
    psg = psg(1:numEpochs, {'EEGFpz_Cz', 'EEGPz_Oz', 'EOGHorizontal', 'EMGSubmental'});

    epoch_labels = extractAfter(epoch_labels, "Sleep stage ");  %Extract the sleep stage
    psg.Stage = epoch_labels;
    
    signalsTable = psg;
end
