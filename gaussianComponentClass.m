classdef gaussianComponentClass < handle
%/**
%* @brief gaussian component class
%*
%* @detail
%* This class is for gaussian components' information.
%* Gaussian Component is the part of Probability Hypothesis Density
%* distribution, which is approximated as sum of weighted Gaussians.
%*
%* @see <a href='https://ieeexplore.ieee.org/document/1710358'></a>
%*
%*/
    properties
        weight; % weight of Gaussian Componens
        mean; % mean vector of Gaussian Componens in state space
        covariance; % covariance matrix of Gaussian Componens in state space
        label; % label of Gaussian Componens
        history; % history of association with observation data
    end

    methods
        function [obj] = gaussianComponentClass(dataNum, stateDimension)
            % constructor
            n = stateDimension;
            obj.weight = nan(dataNum, 1);
            obj.mean = nan(dataNum, n);
            obj.covariance = nan(dataNum, n, n);
            obj.label = nan(dataNum, 1);
            obj.history = nan(dataNum, 5);
        end

        function [x, y] = xyPos(obj)
            % output x, y Position
            x = obj.mean(:, 1);
            y = obj.mean(:, 2);
        end

        function [vx, vy] = xyVel(obj)
            % output x, y Velocity
            posDim = 0.5 * size(obj.mean, 2); % assume Constant Velocity Model
            vx = obj.mean(:, posDim+1);
            vy = obj.mean(:, posDim+2);
        end

        function [x, y, z] = xyzPos(obj)
            % output x, y, z Position
            [x, y, z] = [obj.mean(:, 1), obj.mean(:, 2), obj.mean(:, 3)];
        end

        function [vx, vy, vz] = xyzVel(obj)
            % output x, y, z Velocity
            posDim = 0.5 * size(obj.mean, 2);  % assume Constant Velocity Model
            [vx, vy, vz] = [obj.mean(:, posDim+1), obj.mean(:, posDim+2), obj.mean(:, posDim+3)];
        end

        function [numberOfData] = number(obj)
            % output number of data
            numberOfData = size(obj.weight, 1);
        end

        function [numberOfStateDimension] = stateDim(obj)
            % output number of dimension of state space
            numberOfStateDimension = size(obj.mean, 2);
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
            another_obj = gaussianComponentClass(1, obj.stateDim());
            another_obj.weight = obj.weight(index, :);
            another_obj.mean = obj.mean(index, :);
            another_obj.covariance = obj.covariance(index, :, :);
            another_obj.label = obj.label(index, :);
            another_obj.history = obj.history(index, :);
        end

        function [ ] = setOne(obj, index, another_obj)
            % set one of data
            obj.weight(index, :) = another_obj.weight;
            obj.mean(index, :) = another_obj.mean;
            obj.covariance(index, :, :) = another_obj.covariance;
            obj.label(index, :) = another_obj.label;
            obj.history(index, :) = another_obj.history;
        end

    end


end
