function featuresEOG = extractEOGfeatures(freq, eog)
    % INPUT:
    %   freq: frequency array (1 x n)
    %   eog: cell (epochs x 1) with arrays of signals
    %
    % OUTPUT:
    %   featuresEOG: table (epochs x features)

    nEpochs = height(eog);
    colNames = {'EOG_rms','EOG_energy','EOG_var','EOG_std','EOG_range','EOG_mobility','EOG_complexity','EOG_zcr','EOG_theta/delta'};
    featuresEOG = zeros(nEpochs, length(colNames)-1);

    for i = 1:nEpochs
        signal = eog{i};
        
        %Root Mean Square, Energy, Variance, Standard Deviation, Range
        rms_val = rms(signal);
        energy_val = sum(signal.^2);
        var_val = var(signal);
        std_val = std(signal);
        range_val = max(signal) - min(signal);
        %Mobility, Complexity
        mob = sqrt(var(diff(signal)) / var_val);
        compl = sqrt(var(diff(diff(signal))) / var(diff(signal))) / mob;
        %Zero Crossing Rate
        zc = sum(diff(sign(signal)) ~= 0);
        zcr = zc / length(signal);
    
        featuresEOG(i, :) = [rms_val, energy_val, var_val, std_val, range_val, mob, compl, zcr];
    end

    %Calculating band powers
    transformedEOG = transform(eog);
    label = {'EOG'};
    bands = {'delta', 'theta'};
    bandLimits = [0.1, 4; 4, 8];
    bandPowers = calculateBandPowers(freq, transformedEOG, label, bands, bandLimits, false);
    delta_theta = bandPowers.(sprintf('%s_%s', label{1}, bands{2})) ./ bandPowers.(sprintf('%s_%s', label{1}, bands{1}));
    
    featuresEOG = [featuresEOG delta_theta];
    featuresEOG = array2table(featuresEOG, 'VariableNames', colNames);
end