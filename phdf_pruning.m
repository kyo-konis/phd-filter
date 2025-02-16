function [ gc_pruned ] = phdf_pruning( gc, param )
%/**
%* @brief GM-PHD filter pruning step
%*
%* @detail
%* prune the Gaussian Components (delete negligible GCs, and merge neighbor GCs)
%*     - step 1: delete the GCs whose weight is negligible small
%*     - step 2: merge neighbor GCs
%*     - step 3: limit the number of GCs
%*
%* @param[in] gc the gaussian component before pruning, gaussianComponentClass
%* @param[in] param the set of parameters for GM-PHD filter, parameterClass
%*
%* @retval gc_pruned the gaussian component after pruning, gaussianComponentClass
%*
%*/

weightThreshold = param.weightThreshold;
mergeThreshold = param.mergeThreshold;
numberOfGcThreshold = param.numberOfGcThreshold;

gc_tmp = gc;

% step 1: delete the GCs whose weight is negligible small
[ gc_tmp ] = phdf_pruning_weightThreshold(gc_tmp, weightThreshold);

% step 2: merge neighbor GCs
[ gc_tmp ] = phdf_pruning_merge(gc_tmp, mergeThreshold);

% step 3: limit the number of GCs
[ gc_tmp ] = phdf_pruning_numberThreshold(gc_tmp, numberOfGcThreshold);

gc_pruned = gc_tmp;

% end of function
end

function [ gc_pruned ] = phdf_pruning_weightThreshold(gc, weightThreshold)
%/**
%* @brief GM-PHD filter delete the GCs whose weight is negligible small
%*/

gc_pruned = gaussianComponentClass(0, gc.stateDim());
nGc = gc.number();
for iGc = 1:nGc
    thisGc = gc.getOne(iGc);
    if thisGc.weight(1) > weightThreshold
        % append gc
        gc_pruned.append(thisGc);
    end
end

% end of function
end


function [ gc_pruned ] = phdf_pruning_merge(gc, mergeThreshold)
%/**
%* @brief GM-PHD filter merge neighbor GCs
%*/

gate = mergeThreshold;
gc_pruned = gaussianComponentClass(0, gc.stateDim());
nGc = gc.number();

% list of (weight, index in GC Class, flag whether merged or not)
list_weight_index_mergedFlag = [gc.weight, (1:nGc)', false(nGc, 1)];

% sort with weight, descend
list_weight_index_mergedFlag ...
    = sortrows(list_weight_index_mergedFlag, -1);

for iGc_large = 1:nGc

    mergedFlag_large = list_weight_index_mergedFlag(iGc_large, 3);
    if mergedFlag_large
        % skip if this GC is already merged
        continue;
    end

    thisIndex_large = list_weight_index_mergedFlag(iGc_large, 2);
    thisGc_large = gc.getOne(thisIndex_large);
    thisWeight_large = thisGc_large.weight(1);
    thisMean_large = thisGc_large.mean(1, :)';
    thisCov_large = squeeze(thisGc_large.covariance(1, :, :));
    thisLabel_large = thisGc_large.label(1);
    thisHistory_large = thisGc_large.history(1, :);

    weight_merge = thisWeight_large;
    mean_merge = thisWeight_large * thisMean_large;
    cov_merge = thisWeight_large * thisCov_large;
    label_merge = thisLabel_large;

    list_weight_index_mergedFlag(iGc_large, 3) = true;

    for iGc_small = (iGc_large + 1):nGc
        mergedFlag_small = list_weight_index_mergedFlag(iGc_small, 3);
        if mergedFlag_small
            % skip if this GC is already merged
            continue;
        end

        thisIndex_small = list_weight_index_mergedFlag(iGc_small, 2);
        thisGc_small = gc.getOne(thisIndex_small);
        thisWeight_small = thisGc_small.weight(1);
        thisMean_small = thisGc_small.mean(1, :)';
        thisCov_small = squeeze(thisGc_small.covariance(1, :, :));
        thisLabel_small = thisGc_small.label(1);

        isSameLabel = (label_merge == thisLabel_small);
        [ distance ] = mahalanobis(thisMean_small, thisMean_large, thisCov_small);
        if isSameLabel && (distance <= gate)
            weight_merge = weight_merge + thisWeight_small;
            mean_merge = mean_merge + thisWeight_small * thisMean_small;

            thisDiff = (thisMean_small - thisMean_large);
            cov_merge = cov_merge ...
                        + thisWeight_small * (thisCov_small + thisDiff * thisDiff');

            list_weight_index_mergedFlag(iGc_small, 3) = true;
        end
    end

    % normalize with sum of weight
    mean_merge = mean_merge ./ weight_merge;
    cov_merge = cov_merge ./ weight_merge;

    % set merged GC
    gc_merge = gaussianComponentClass(1, gc.stateDim());
    gc_merge.weight(1) = weight_merge;
    gc_merge.mean(1, :) = mean_merge';
    gc_merge.covariance(1, :, :) = cov_merge;
    gc_merge.label(1) = label_merge;
    gc_merge.history(1, :) = thisHistory_large;
    gc_pruned.append(gc_merge);

end

% end of function
end


function [ gc_pruned ] = phdf_pruning_numberThreshold(gc, numberOfGcThreshold)
%/**
%* @brief GM-PHD filter limit the number of GCs
%*/

nGc = gc.number();
if nGc <= numberOfGcThreshold
    gc_pruned = gc;
else
    % GCs with small weight is deleted.
    gc_pruned = gaussianComponentClass(numberOfGcThreshold, gc.stateDim());
    list_weight_index = [gc.weight, (1:nGc)'];
    list_weight_index = sortrows(list_weight_index, -1); % sort with weight, descend
    for iGc = 1:numberOfGcThreshold
        thisIndex = list_weight_index(iGc, 2);
        thisGc = gc.getOne(thisIndex);
        gc_pruned.setOne(iGc, thisGc);
    end
end

% end of function
end
