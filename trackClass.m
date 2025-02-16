classdef trackClass < handle
%/**
%* @brief track data class
%*
%* @detail
%* This class is for track data.
%* Track data is result of tracking algorithm.
%*
%*/
    properties
        time; % detected time, unit [sec]
        x; % x position, unit [m]
        y; % y position, unit [m]
        z; % z position, unit [m]
        vx; % x velocity, unit [m/s]
        vy; % y velocity, unit [m/s]
        vz; % z velocity, unit [m/s]
        label; % track label
    end

    methods
        function [obj] = trackClass(dataNum)
            % constructor
            obj.time = nan(dataNum, 1);
            obj.x = nan(dataNum, 1);
            obj.y = nan(dataNum, 1);
            obj.z = nan(dataNum, 1);
            obj.vx = nan(dataNum, 1);
            obj.vy = nan(dataNum, 1);
            obj.vz = nan(dataNum, 1);
            obj.label = nan(dataNum, 1);
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

        function [vx, vy] = xyVel(obj)
            % output x, y Velocity
            if obj.number() > 0
                vx = obj.vx(:, 1);
                vy = obj.vy(:, 1);
            else
                vx = [];
                vy = [];
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

        function [vx, vy, vz] = xyzVel(obj)
            % output x, y Velocity
            if obj.number() > 0
                vx = obj.vx(:, 1);
                vy = obj.vy(:, 1);
                vz = obj.vz(:, 1);
            else
                vx = [];
                vy = [];
                vz = [];
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

        function [array] = all(obj)
            % output all properties in data array
            array = [
                obj.time, ...
                obj.x, ...
                obj.y, ...
                obj.z, ...
                obj.vx, ...
                obj.vy, ...
                obj.vz, ...
                obj.label];
        end

        function [ another_obj ] = getOne(obj, index)
            % get one of data
            another_obj = trackClass(1);
            another_obj.time = obj.time(index, :);
            another_obj.x = obj.x(index, :);
            another_obj.y = obj.y(index, :);
            another_obj.z = obj.z(index, :);
            another_obj.vx = obj.vx(index, :);
            another_obj.vy = obj.vy(index, :);
            another_obj.vz = obj.vz(index, :);
            another_obj.label = obj.label(index, :);
        end
    end

end
