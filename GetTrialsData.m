function [ trials_data ] = GetTrialsData( folder )
%GETTRIALSDATA Get synced data from all trials for a single activity
% 
% -------------------------------------------------------------------------
% Author: Tiago P M da Silva (dept. DIBRIS, University of Genova, ITALY)
%         Divya Haresh Shah (dept. DIBRIS, University of Genova, ITALY)
%         Ernesto Denicia (dept. DIBRIS, University of Genova, ITALY)
%
% -------------------------------------------------------------------------
%
% GetTrialsData, loads the synchronized data from all trials for a single 
% activity.
%
% Input:
%   folder --> name of folder where synced data is.
%
% Output:
%   trials_data --> dataset containing a Nx2x4xM cell array.
%                - N : Number of trials;
%                - 2 : Left and Right hands;
%                - 4 : acceleration components data with its timestamp 
%     (row1 -> timestamp, row2 -> x_axis, row3 -> y_axis, row4 -> z_axis);
%                - M : Data points in each trial.
%
% Examples:
%   SyncDataWHARF;
%   folder = 'Data\MODELS\Open_Close_Curtains_MODEL\';
%   trials_data = GetTrialsData(folder);
%

    % Get all mat files in specified folder and number of trial entries.
    files = dir([folder,'*.mat']);
    num_files = size(files, 1);
    
    % Load data and save it in trials_data
    trials_data = cell(num_files, 2);
    for i=1:num_files
        load([folder files(i).name]);
        trials_data{i,1} = single_trial_data{1,1}; %#ok<*USENS> Remove warning
        trials_data{i,2} = single_trial_data{1,2};
    end
end

