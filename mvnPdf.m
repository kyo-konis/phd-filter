function [ y ] = mvnPdf(X, mu, Sigma)
%/**
%* @brief pdf value of multivariate normal distribution
%*
%* @detail
%* returns an n-by-1 vector y containing the probability density function (pdf)
%* values for the d-dimensional multivariate normal distribution.
%* This function is same as the 'mvnpdf' in Matlab toolbox, but number of
%* input must be 3.
%*
%* @param[in] X evaluation points [size:n-by-d]
%* @param[in] mu means of multivariate normal distributions [size:n-by-d]
%* @param[in] Sigma covariances of multivariate normal distributions [size:d-by-d]
%*
%* @retval y pdf values [size:n-by-1]
%*
%* @see <a href='https://jp.mathworks.com/help/stats/mvnpdf.html'></a>
%*
%*/

[n, d] = size(X);
diffList = X - mu;
detSigma = det(Sigma);
if detSigma < eps
    error('det(Sigma) is zero');
end
normalize_factor = 1.0 / sqrt(detSigma * ((2 * pi) ^ d));

y = zeros(n, 1);
for i = 1:n
    thisDiff = diffList(i, :)';
    expTerm = exp(-0.5 * (thisDiff' / Sigma) * thisDiff);
    y(i) = normalize_factor * expTerm;
end

% end of function
end
