function features_context = addTemporalContext(features, nBefore, nAfter)
    % INPUT:
    %   features: table (epochs x features)
    %   n_before: number of previous epochs to add
    %   n_after:  number of successive epochs to add
    %
    % OUTPUT:
    %   features_context: table with temporal context
    
    T = table2array(features);
    [~, nFeat] = size(T);

    T_context = T;

    %Adding previous feats
    for i = 1:nBefore
        T_shift = [nan(i, nFeat); T(1:end-i, :)];
        T_context = [T_context, T_shift];
    end

    %Adding successive feats
    for i = 1:nAfter
        T_shift = [T(i+1:end, :); nan(i, nFeat)];
        T_context = [T_context, T_shift];
    end

    %Removing NaN rows (first and last ones)
    valid_idx = all(~isnan(T_context), 2);
    T_context = T_context(valid_idx, :);

    feature_names = features.Properties.VariableNames;
    new_names = feature_names;

    %Names for added feats
    for i = 1:nBefore
        new_names = [new_names, strcat(feature_names, "_prev", string(i))];
    end
    for i = 1:nAfter
        new_names = [new_names, strcat(feature_names, "_next", string(i))];
    end

    features_context = array2table(T_context, 'VariableNames', new_names);
end
