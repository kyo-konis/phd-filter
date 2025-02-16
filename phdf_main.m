function [track, gc_now] = phdf_main(detection, gc_previous, param, nowTime)
%/**
%* @brief gaussian mixture - PHD filter main function
%*
%* @detail
%* main sequence of GM-PHD filter
%*
%* @param[in] detection the detection data in now time frame, detectionClass
%* @param[in] gc_previous the gaussian component in previous time frame, gaussianComponentClass
%* @param[in] param the set of parameters for GM-PHD filter, parameterClass
%* @param[in] nowTime the now time, for making tracking data
%*
%* @retval track the result of tracking in now time frame, trackClass
%* @retval gc_now the gaussian component in now time frame, gaussianComponentClass
%*
%*/

% prediction step
[gc_predicted] = phdf_prediction(gc_previous, param);

% update step
[gc_now] = phdf_update(gc_predicted, detection, param);

% pruning step
[gc_now] = phdf_pruning(gc_now, param);

% extraction step
[gc_extracted] = phdf_extraction(gc_now, param);

% make track data
[track] = convertGcToTrack(gc_extracted, nowTime);

% end of function
end


function [ gc_predicted ] = phdf_prediction( gc_previous, param )
%/**
%* @brief GM-PHD filter prediction step
%*
%* @detail
%* predict the Gaussian components from previous time frame to now time frame;
%*
%*
%* @param[in] gc_previous the gaussian component in previous time frame, gaussianComponentClass
%* @param[in] param the set of parameters for GM-PHD filter, parameterClass
%*
%* @retval gc_predicted the predicted gaussian component in now time frame, gaussianComponentClass
%*
%*/

ps = param.probabilitySurvival;
dt = param.timeInterval;
q = param.processNoise;

nGc = gc_previous.number();
gc_predicted = gaussianComponentClass(nGc, gc_previous.stateDim());
for iGc = 1:nGc
    thisGc = gc_previous.getOne(iGc);
    thisWeight = thisGc.weight(1);
    thisMean = thisGc.mean(1, :)';
    thisCov = squeeze(thisGc.covariance(1, :, :));
    thisHistory = thisGc.history(1, :);

    weight_pred = ps * thisWeight;

    % Kalman filter prediction
    [mean_pred, cov_pred] ...
        = kalmanFilter_prediction_constVel(thisMean, thisCov, dt, q);

    % set prediction result
    gc_predicted.weight(iGc, :) = weight_pred;
    gc_predicted.mean(iGc, :) = mean_pred';
    gc_predicted.covariance(iGc, :, :) = cov_pred;
    gc_predicted.label(iGc, :) = thisGc.label(1);
    gc_predicted.history(iGc, 2:end) = thisHistory(1, 1:(end-1));
end

% end of function
end


function [ gc_extracted ] = phdf_extraction( gc, param )
%/**
%* @brief GM-PHD filter extraction step
%*
%* @detail
%* extract the Gaussian components whose weight is large
%*
%* @param[in] gc gaussianComponentClass
%* @param[in] param the set of parameters for GM-PHD filter, parameterClass
%*
%* @retval gc_extracted the extracted gaussian component, gaussianComponentClass
%*
%*/

threshold = param.extractionThreshold;

nGc = gc.number();
gc_extracted = gaussianComponentClass(0, gc.stateDim());
for iGc = 1:nGc
    thisGc = gc.getOne(iGc);
    if thisGc.weight(1) > threshold
        % append gc
        gc_extracted.append(thisGc);
    end
end

% end of function
end


function [ track ] = convertGcToTrack( gc, nowTime )
%/**
%* @brief convert from GC class to track class
%*
%* @param[in] gc gaussianComponentClass
%* @param[in] nowTime the now time
%*
%* @retval track trackClass
%*
%*/
nGc = gc.number();
track = trackClass(nGc);
for iGc = 1:nGc
    thisGc = gc.getOne(iGc);
    track.time(iGc) = nowTime;
    [track.x(iGc), track.y(iGc)] = thisGc.xyPos();
    [track.vx(iGc), track.vy(iGc)] = thisGc.xyVel();
    track.label(iGc) = thisGc.label;
end
% end of function
end
