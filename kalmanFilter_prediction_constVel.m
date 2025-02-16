function [state_pred, covariance_pred] ...
        = kalmanFilter_prediction_constVel(state, covariance, timeInterval, processNoise)
%/**
%* @brief Kalman filter prediction with constant velocity model
%*
%* @detail
%* predict state and covariance using constant velocity model
%*
%* @param[in] state the state vector in previous time frame
%* @param[in] covariance the covariance matrix in previous time frame
%* @param[in] timeInterval the interval from previous time to now time frame
%* @param[in] processNoise the standard deviation of process noise in prediction model
%*
%* @retval state_pred the predicted state vector in now time frame
%* @retval covariance_pred the predicted covariance matrix in now time frame
%*
%*/

nDim_state = length(state);
nDim_pos = round(0.5 * nDim_state);
eye_pos = eye(nDim_pos);

% adjust shape of vector
x_prev = zeros(nDim_state, 1);
for iDim = 1:nDim_state
    x_prev(iDim) = state(iDim);
end

% calculate transition matrix
transitionMat = eye(nDim_state);
transitionMat(1:nDim_pos, (nDim_pos+1):(2*nDim_pos)) ...
    = timeInterval * eye(nDim_pos);

% calculate process noise matrix
processNoiseVector ...
    = (processNoise^2) * ...
        [0.5 * (timeInterval^2) * eye_pos; ...
         timeInterval * eye_pos];
processNoiseMat = zeros(nDim_state, nDim_state);
processNoiseMat(1:(2*nDim_pos), 1:(2*nDim_pos)) ...
    = processNoiseVector * processNoiseVector';

% predict
state_pred = transitionMat * x_prev;
covariance_pred = transitionMat * covariance * transitionMat' + processNoiseMat;

% end of function
end
