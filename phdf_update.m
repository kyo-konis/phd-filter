function [ gc_now ] = phdf_update( gc_predicted, detection, param )
%/**
%* @brief GM-PHD filter update step
%*
%* @detail
%* update the Gaussian components with/without detections
%*     - step 1: update the GCs without detection (memory track)
%*     - step 2: prepare Kalman filter, calculate the covariance and etc. in advance
%*     - step 3: update the GCs with detection
%*
%* @param[in] gc_predicted the predicted gaussian component in now time frame, gaussianComponentClass
%* @param[in] detection the detection in now time frame, detectionClass
%* @param[in] param the set of parameters for GM-PHD filter, parameterClass
%*
%* @retval gc_now the gaussian component in now time frame, gaussianComponentClass
%*
%*/

gc_now = gaussianComponentClass(0, gc_predicted.stateDim());

% step 1: update the GCs without detection (memory track)
[gc_mem] = phdf_update_withoutDetection(gc_predicted, param);
gc_now.append(gc_mem);

% step 2: prepare Kalman filter
[covUpdList, residualCovList, kalmanGainList, predictedObsList] ...
    = phdf_update_preparingKalman(gc_predicted, param);

% step 3: update the GCs with detection
[gc_upd] ...
    = phdf_update_withDetection(...
        gc_predicted, ...
        detection, ...
        covUpdList, ...
        residualCovList, ...
        kalmanGainList, ...
        predictedObsList, ...
        param);
gc_now.append(gc_upd);

% end of function
end

function [gc_updated] = phdf_update_withoutDetection(gc_predicted, param)
%/**
%* @brief GM-PHD filter update without detection step in update step
%*
%*/

pd = param.probabilityDetection;

nGc = gc_predicted.number();
gc_updated = gaussianComponentClass(nGc, gc_predicted.stateDim());
for iGc = 1:nGc
    thisGc = gc_predicted.getOne(iGc);
    thisWeight = thisGc.weight(1);
    thisHistory = thisGc.history;

    % weight of memory track
    weight_upd = (1.0 - pd) * thisWeight;

    % set update result
    gc_updated.weight(iGc, :) = weight_upd;
    gc_updated.mean(iGc, :) = thisGc.mean;
    gc_updated.covariance(iGc, :, :) = thisGc.covariance;
    gc_updated.label(iGc, :) = thisGc.label;
    gc_updated.history(iGc, :) = [0, thisHistory(1, 2:end)];
end

% end of function
end


function [covUpdList, residualCovList, kalmanGainList, predictedObsList] ...
    = phdf_update_preparingKalman(gc_predicted, param)
%/**
%* @brief GM-PHD filter preparing of Kalman filter step in update step
%*
%*/

obsNoiseMat = param.observationNoiseMatrix;

nGc = gc_predicted.number();
covUpdList = cell(nGc, 1);
residualCovList = cell(nGc, 1);
kalmanGainList = cell(nGc, 1);
predictedObsList = cell(nGc, 1);
for iGc = 1:nGc
    thisGc = gc_predicted.getOne(iGc);
    thisMean = thisGc.mean(1, :)';
    thisCov = squeeze(thisGc.covariance(1, :, :));

    % Kalman filter (update covariance only)
    [covUpd, residualCov, kalmanGain, predictedObs] ...
        = kalmanFilter_update_covariance_constVel(thisMean, thisCov, obsNoiseMat);

    % storage prepared values
    covUpdList{iGc} = covUpd;
    residualCovList{iGc} = residualCov;
    kalmanGainList{iGc} = kalmanGain;
    predictedObsList{iGc} = predictedObs;
end

% end of function
end


function [gc_updated] ...
    = phdf_update_withDetection(...
        gc_predicted, ...
        detection, ...
        covUpdList, ...
        residualCovList, ...
        kalmanGainList, ...
        predictedObsList, ...
        param)
%/**
%* @brief GM-PHD filter update with detection step in update step
%*
%*/

pd = param.probabilityDetection;
gate = param.updateGate;
kappa = param.falseDensity;
obsNoiseMat = param.observationNoiseMatrix;
nDim_obs = size(obsNoiseMat, 1);

nGc = gc_predicted.number();
nDim_state = gc_predicted.stateDim();
nDetection = detection.number();
gc_updated = gaussianComponentClass(nGc * nDetection, nDim_state);
for iDetection = 1:nDetection
    thisDetection = detection.getOne(iDetection);
    thisId_detect = thisDetection.id;

    if nDim_obs == 2
        % This is 2D detection.
        thisObs = [thisDetection.x(1,1); thisDetection.y(1,1)];
    elseif nDim_obs == 3
        % This is 3D detection.
        thisObs = [thisDetection.x(1,1); thisDetection.y(1,1); thisDetection.z(1,1)];
    else
        error("Dimension of observation data is undefined.");
    end

    weightUpdList = zeros(nGc, 1);
    sumWeight = 0;
    for iGc = 1:nGc
        thisGc = gc_predicted.getOne(iGc);
        thisWeight = thisGc.weight(1);
        thisMean = thisGc.mean(1, :)';
        thisCov = squeeze(thisGc.covariance(1, :, :));
        thisHistory = thisGc.history;

        % get prepared values
        cov_upd = covUpdList{iGc};
        residualCov = residualCovList{iGc};
        kalmanGain = kalmanGainList{iGc};
        predictedObs = predictedObsList{iGc};

        % Kalman filter (update state only)
        [mean_upd] ...
            = kalmanFilter_update_state(thisMean, thisObs, predictedObs, kalmanGain);

        % gating
        diffPos = (thisObs - predictedObs);
        [ distance ] = mahalanobis(thisObs, predictedObs, residualCov);
        if distance < gate
            % likelihood of updated GC
            likelihood = mvnPdf(thisObs', predictedObs', residualCov);
        else
            likelihood = 0;
        end

        % update_weight (before normalize)
        weight_upd = pd * likelihood * thisWeight;
        weightUpdList(iGc) = weight_upd;

        % set update result (except for 'weight')
        thisIndex = iGc + (iDetection - 1) * nGc;
        gc_updated.mean(thisIndex, :) = mean_upd;
        gc_updated.covariance(thisIndex, :, :) = cov_upd;
        gc_updated.label(thisIndex, :) = thisGc.label;
        gc_updated.history(thisIndex, :) = [thisId_detect, thisHistory(1, 2:end)];
    end

    % set update result (normalized weight)
    normalizeFactor = kappa + sum(weightUpdList(:));
    weightUpdList(:, 1) = weightUpdList(:) / normalizeFactor;
    thisIndex = (1:nGc) + (iDetection - 1) * nGc;
    gc_updated.weight(thisIndex, 1) = weightUpdList(:, 1);
end

% end of function
end
