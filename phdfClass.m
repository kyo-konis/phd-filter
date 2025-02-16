classdef phdfClass < handle
%/**
%* @brief GM-PHD filter
%*
%* @detail
%* GM-PHD (Gaussian Mixture Probability Hypothesis Density) filter is one of
%* tracking algorithm for multi-object tracking problem.
%* This is main class of GM-PHD filter.
%*
%* @see <a href='https://ieeexplore.ieee.org/document/1710358'></a>
%*
%*/
    properties
        % tracking parameter
        param;

        % inner storage
        gc;

        % tracking input
        detection;
        nowTime;

        % tracking output
        track;


    end

    methods
        function obj = phdfClass(stateDimension)
            % constructor
            obj.param = parameterClass();
            obj.gc = gaussianComponentClass(0, stateDimension);
            obj.detection = detectionClass(0);
            obj.track = trackClass(0);
        end

        function [] = exe(obj)
            % execute GM-PHD Filter in single time frame.
            % example of use:
            % for thisTime = timeList(:)
            %     phdf.detection = detection_thisTime;
            %     phdf.exe();
            %     track_thisTime = phdf.track;
            % end
            %
            [obj.track, obj.gc] = phdf_main(obj.detection, obj.gc, obj.param, obj.nowTime);
        end
    end
end

