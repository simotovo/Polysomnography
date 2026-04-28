clear
close all
clc

numSubjects = 20;
allData = [];

for i = 1:numSubjects
    load(sprintf('table_%d.mat', i));
    allData = [allData; featureTable];
end

X = table2array(allData(:, 1:end-1));
y = allData.Stage;
labels=allData.Properties.VariableNames;

%Matrix of correlation
R = abs(corrcoef(X));
R = triu(R,1);

threshold = 0.9;
to_remove = any(R > threshold,1);
to_remove(end+1) = 0;           %stage column

disp('Features correlated:')
disp(labels(to_remove))


save('feature_mask.mat', 'to_remove');