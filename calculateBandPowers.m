function bandPowers = calculateBandPowers(freq, signals, labels, bands, bandLimits, normalize)
    % INPUT:
    %   freq: frequency array (1 x n)
    %   signals: cell (epochs x channels) with arrays of signals
    %   labels: cell (1 x channels) with the labels of the channels
    %   bands: cell (1 x bands) bands' names
    %   bandLimits: cell (1 x bands) bands' limits
    %   normalize: bool for normalization of bands
    %
    % OUTPUT:
    %   bandPowers: table (epochs x (channels*bands)) with band powers

    if nargin < 6
        normalize = true;
    end

    nEpochs = size(signals, 1);
    nChannels = size(signals, 2);
    nBands = size(bandLimits, 1);

    powerData = zeros(nEpochs, nChannels * nBands);

    for e = 1:nEpochs
        for c = 1:nChannels
            spectrum = signals{e, c};
            bandPower = calculateSignalBandPowers(freq, spectrum, bandLimits);

            if normalize
                totalPower = sum(bandPower);
                if totalPower > 0
                    bandPower = bandPower / totalPower;
                end
            end

            idxStart = (c-1)*nBands + 1;
            idxEnd = c*nBands;
            powerData(e, idxStart:idxEnd) = bandPower;
        end
    end
    
    
    colNames = {};
    for c = 1:nChannels
        for b = 1:nBands
            colNames{end+1} = sprintf('%s_%s', labels{c}, bands{b});
        end
    end

    bandPowers = array2table(powerData, 'VariableNames', colNames);
end


function power = calculateSignalBandPowers(freq, spectrum, bandLimits)
    numBands = size(bandLimits, 1);
    power = zeros(1, numBands);

    for k = 1:numBands
        bandIndices = freq >= bandLimits(k, 1) & freq <= bandLimits(k, 2);
        power(k) = trapz(freq(bandIndices), spectrum(bandIndices).^2);
    end
end
