function featuresEMG = extractEMGfeatures(emg)
    % INPUT:
    %   emg: cell (epochs x 1) with arrays of signals
    %
    % OUTPUT:
    %   featuresEOG: table (epochs x features)

    nEpochs = height(emg);
    
    colNames = {'EMG_mean','EMG_std','EMG_range','EMG_slope'};
    nFeats = numel(colNames);
    feats = NaN(nEpochs, nFeats);
    
    for i = 1:nEpochs
        epoch_vec = emg{i};
        
        %Mean, Standard Deviation, Range
        mean_val = mean(epoch_vec);
        std_val = std(epoch_vec);
        range_val = max(epoch_vec)-min(epoch_vec);
        
        %Slope
        t = (0:length(epoch_vec)-1)';
        p = polyfit(t, epoch_vec, 1);
        slope = p(1);
    
        feats(i, :) = [mean_val, std_val, range_val, slope];
    end
    
    featuresEMG = array2table(feats, 'VariableNames', colNames);
end