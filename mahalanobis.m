function [ distance ] = mahalanobis(stateVector_A, stateVector_B, covarianceMatrix)
%/**
%* @brief calculate mahalanobis distance
%*
%* @detail
%* calculate the distance between stateVector_A and B which is nomalized by
%* error covariance matrix;
%*
%* @param[in] stateVector_A value of point A in state space [size:n-by-1]
%* @param[in] stateVector_B value of point B in state space [size:n-by-1]
%* @param[in] covarianceMatrix error covariance matrix in state space [size:n-by-n]
%*
%* @retval mahalanobis distance [size:1-by-1]
%*
%* @see <a href='https://link.springer.com/referenceworkentry/10.1007/978-0-387-32833-1_240'></a>
%*
%*/

% adjuct shape of vector
if size(stateVector_A, 1) == 1
    stateVector_A = transpose(stateVector_A);
end
if size(stateVector_B, 1) == 1
    stateVector_B = transpose(stateVector_B);
end

diff = stateVector_A - stateVector_B;
distance = (diff' / covarianceMatrix) * diff;

% end of function
end
