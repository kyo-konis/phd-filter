classdef parameterClass < handle
%/**
%* @brief tracking parameter class
%*
%* @detail
%* This class is for parameters of tracking.
%* Parameter is value preset before tracking process.
%*
%*/
    properties
        % for prediction
        timeInterval;
        probabilitySurvival;
        processNoise;

        % for update
        probabilityDetection;
        observationNoiseMatrix;
        updateGate;
        falseDensity;

        % for pruning
        weightThreshold;
        mergeThreshold;
        numberOfGcThreshold;

        % for extraction
        extractionThreshold;
    end

    methods
        function obj = parameterClass()
            % constructor
        end
    end
end
