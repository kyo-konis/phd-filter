function [state_updated] ...
    = kalmanFilter_update_state(state, observation, predictedObservation, kalmanGain)
%/**
%* @brief Kalman filter update with constant velocity model (state vector)
%*
%* @detail
%* update the state vector using observation data
%*
%* @param[in] state the predicted state vector
%* @param[in] observation the vector of observation data (e.g. detected signal position by thresholding)
%* @param[in] predictedObservation the predicted observation derived from predicted state vector
%* @param[in] kalmanGain the kalman gain
%*
%* @retval state_updated the state vector updated
%*
%*/

% adjust shape of vector
nDim_state = length(state);
x_pred = zeros(nDim_state, 1);
for iDim = 1:nDim_state
    x_pred(iDim) = state(iDim);
end

% adjust shape of vector
nDim_obs = length(observation);
z = zeros(nDim_obs, 1);
Hx = zeros(nDim_obs, 1);
for iDim = 1:nDim_obs
    z(iDim) = observation(iDim);
    Hx(iDim) = predictedObservation(iDim);
end

% update
state_updated = x_pred + kalmanGain * (z - Hx);

% end of function
end
