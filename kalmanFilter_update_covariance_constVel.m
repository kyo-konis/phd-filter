function [covariance_updated, residualCovariance, kalmanGain, predictedObservation] ...
        = kalmanFilter_update_covariance_constVel(state, covariance, obsNoiseMat)
%/**
%* @brief Kalman filter update with constant velocity model (covariance)
%*
%* @detail
%* update the covariance of state vector, and output other value for update state vector
%*
%* @param[in] state the predicted state vector
%* @param[in] covariance the predicted covariance matrix
%* @param[in] obsNoiseMat the covariance matrix of observation noise in observation model
%*
%* @retval covariance_updated the covariance matrix of updated state vector
%* @retval residualCovariance the covariance matrix of residual vector
%* @retval kalmanGain the kalman gain
%* @retval predictedObservation the predicted observation derived from predicted state vector
%*
%*/

nDim_state = length(state);
nDim_pos = round(0.5 * nDim_state);
eye_pos = eye(nDim_pos);
zeros_pos = zeros(nDim_pos, nDim_pos);

% adjust shape of vector
x_pred = zeros(nDim_state, 1);
for iDim = 1:nDim_state
    x_pred(iDim) = state(iDim);
end

% observation matrix
H =[eye_pos, zeros_pos];

% residual matrix
S = H * covariance * H' + obsNoiseMat;
residualCovariance = S;

% Kalman gain
K = covariance * H' / S;
kalmanGain = K;

% updated covariance
covariance_updated = covariance - K * H * covariance;

% predicted observation
predictedObservation = H * x_pred;

% end of function
end
