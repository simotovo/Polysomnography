clear
close all
clc

% Total number of subjects
numSubjects = 20;

for i = 1:numSubjects
    
    %Defining parameters
    IDpatient = i;
    
    numEpochs = 2000;
    fs1 = 100;      %EEG, EOG
    fs2 = 1;        %EMG
    duration = 30;
    startSec = 0;
    time = linspace(startSec, startSec+duration, duration*fs1);   %Time vector
    
    hannWindow = hann(duration*fs1);        %Hann window
    hannLength = length(hannWindow);
    freq = linspace(0, fs1/2, floor(hannLength/2)+1);
    
    passband1 = [0.3, 35];  %Frequency passband EEG
    passband2 = [0.05, 15]; %Frequency passband EOG
    
    %Loading data
    psg = getSignals(IDpatient, numEpochs);
    
    eeg = table2cell(psg(:, {'EEGFpz_Cz', 'EEGPz_Oz'}));
    eog = table2cell(psg(:, 'EOGHorizontal'));
    emg = table2cell(psg(:, 'EMGSubmental'));
    
    %EEG
    filtEEG = butterworth(eeg, fs1, passband1);
    featureEEG = extractEEGfeatures(freq, filtEEG);
    %EOG
    filtEOG = butterworth(eog, fs1, passband2);
    featureEOG = extractEOGfeatures(freq, filtEOG);
    %EMG
    featureEMG = extractEMGfeatures(emg);
    
    features = [featureEEG featureEOG featureEMG];
    
    %Adding context
    n_before = 1;
    n_after  = 1;
    features_context = addTemporalContext(features, n_before, n_after);
    featureTable = features_context;
    
    %Adding sleep stages
    psg.Stage(psg.Stage == '4') = '3';          %Merging sleep stages number 3 and 4
    sleepStage = psg.Stage(1 + n_before : numEpochs - n_after);
    featureTable.Stage = categorical(sleepStage);
    
    missingIdx = ismissing(featureTable.Stage);
    featureTable(missingIdx, :) = [];
    
    %Saving features table
    save(sprintf('table_%d.mat', IDpatient), 'featureTable');
end