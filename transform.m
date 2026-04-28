function transformedSignals = transform(signals)
    % INPUT:
    %   signals: cell (epochs x channels) with arrays of signals
    %
    % OUTPUT:
    %   transformedSignals: cell (epochs x channels) with arrays of transformed signals

    [nEpochs, nChannels] = size(signals);
    transformedSignals = cell(nEpochs, nChannels);

    for e = 1:nEpochs
        for c = 1:nChannels
            signal = signals{e,c};
            N = length(signal);
            
            window = hann(N);   %Hann window
            signal = signal .* window;

            %FFT
            fftResult = fft(signal);
            
            A = abs(fftResult)/N;   %Normalize
            A = A(1:floor(N/2)+1);  %Keeping only the positive half

            %Double the mid frequencies
            if N > 1
                A(2:end-1) = 2*A(2:end-1);
            end

            transformedSignals{e,c} = A;
        end
    end
end
