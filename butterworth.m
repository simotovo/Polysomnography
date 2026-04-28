function filteredSignals = butterworth(signals, fs, passband)
    % INPUT:
    %   signals: cell (epochs x channels) with arrays of signals
    %   fs: sampling frequency
    %   passband: array with passband frequencies
    %
    % OUTPUT:
    %   filteredSignals: cell (epochs x channels) with arrays of filtered signals


    %Parameters of the Butterworth filter
    fLow = passband(1);     %Low band frequency
    fHigh = passband(2);    %High band frequency
    [b, a] = butter(4, [fLow, fHigh] / (fs / 2), 'bandpass');   %4th order filter

    %Filtering
    filteredSignals = cell(size(signals));
    for i = 1:size(signals,1)
        for j = 1:size(signals,2)
            filteredSignals{i,j} = filtfilt(b, a, signals{i,j});
        end
    end
end
