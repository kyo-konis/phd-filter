classdef detectionClass < handle
%/**
%* @brief detection data class
%*
%* @detail
%* This class is for detection data.
%* Detection data is sensor's signal detected by thresholding.
%*
%*/
    properties
        time; % detected time, unit [sec]
        x; % x position, unit [m]
        y; % y position, unit [m]
        z; % z position, unit [m]
        id; % identity number
    end

    methods
        function [obj] = detectionClass(dataNum)
            % constructor
            obj.time = nan(dataNum, 1);
            obj.x = nan(dataNum, 1);
            obj.y = nan(dataNum, 1);
            obj.z = nan(dataNum, 1);
            obj.id = nan(dataNum, 1);
        end

        function [numberOfData] = number(obj)
            % output number of data
            numberOfData = size(obj.time, 1);
        end

        function [x, y] = xyPos(obj)
            % output x, y Position
            if obj.number() > 0
                x = obj.x(:, 1);
                y = obj.y(:, 1);
            else
                x = [];
                y = [];
            end
        end

        function [x, y, z] = xyzPos(obj)
            % output x, y, z Position
            if obj.number() > 0
                x = obj.x(:, 1);
                y = obj.y(:, 1);
                z = obj.z(:, 1);
            else
                x = [];
                y = [];
                z = [];
            end
        end

        function [] = append(obj, another_obj)
            % vertically append same class objects
            fieldList = fieldnames(obj);
            nField = length(fieldList);
            for iField = 1:nField
                thisField = fieldList{iField};
                obj.(thisField) = [obj.(thisField); another_obj.(thisField)];
            end
        end

        function [ another_obj ] = getOne(obj, index)
            % get one of data
            another_obj = detectionClass(1);
            another_obj.time = obj.time(index, :);
            another_obj.x = obj.x(index, :);
            another_obj.y = obj.y(index, :);
            another_obj.z = obj.z(index, :);
            another_obj.id = obj.id(index, :);
        end

        function [array] = all(obj)
            % output all properties in data array
            array = [
                obj.time, ...
                obj.x, ...
                obj.y, ...
                obj.z, ...
                obj.id];
        end
    end

end
