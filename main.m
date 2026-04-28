clear
close all
clc


%% Loading data

load feature_mask.mat

% Number of subjects
numSubjects = 20;

features = cell(numSubjects, 1);
labels   = cell(numSubjects, 1);

for i = 1:numSubjects
    filename = sprintf('table_%d.mat', i);
    data = load(filename);
    
    T = data.featureTable(:,~to_remove);

    % Dividing features and labels
    features{i} = table2array(T(:, 1:end-1));
    labels{i}   = table2array(T(:, end));
end

%% Model Leave-One-Subject-Out

accuracies = zeros(numSubjects, 1);
allTrue = [];
allPred = [];

for i = 1:numSubjects
    fprintf('--- Loop %d/%d: test on subject %d ---\n', i, numSubjects, i);

    %Training set
    trainData = [];
    trainLabels = [];
    for j = 1:numSubjects
        if j ~= i
            x = features{j};
            x = (x - mean(x)) ./ std(x);
            trainData = [trainData; x];
            trainLabels = [trainLabels; labels{j}];
        end
    end

    %Test set
    testData = (features{i} - mean(features{i})) ./ std(features{i});
    testLabels = labels{i};

    %Train model and predict
    model = fitcensemble(trainData, trainLabels, 'Method', 'Bag', 'NumLearningCycles', 100);

    pred = predict(model, testData);
    accuracies(i) = mean(pred == testLabels);
    fprintf('Accuracy subject %d: %.2f%%\n', i, accuracies(i)*100);

    % Data for overall confusion matrix
    allTrue = [allTrue; testLabels];
    allPred = [allPred; pred];
end

%Overall results
mean_accuracy = mean(accuracies);
fprintf('\nMean Accuracy LOSO: %.2f%%\n', mean_accuracy * 100);

%Confusion matrix
figure
cm = confusionchart(allTrue, allPred);
cm.Title = 'Confusion Matrix - Leave-One-Subject-Out';
cm.RowSummary = 'row-normalized';
cm.ColumnSummary = 'column-normalized';

%exportgraphics(gcf, 'ConfusionMatrix.png', 'Resolution',300);
