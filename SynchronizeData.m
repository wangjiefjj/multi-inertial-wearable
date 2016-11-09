function [ trials_data ] = SynchronizeData( subfolder )
%SYNCHRONIZEDATA Synchronizes data from two smart watches
% 
% -------------------------------------------------------------------------
% Author: Tiago P M da Silva (dept. DIBRIS, University of Genova, ITALY)
%         Divya Haresh Shah (dept. DIBRIS, University of Genova, ITALY)
%         Ernesto Denicia (dept. DIBRIS, University of Genova, ITALY)
%
% -------------------------------------------------------------------------
%
% SynchronizeData, using raw acceleration data from two smart watches,
% generates time synced data with respect to the timestamps on both 
% datasets. It goes through all the files inside the given subfolder.
% There should be an equal number of files named:
%   - '*_Right.txt'
%   - '*_Left.txt'
% Relative to the data taken from the left hand watch and the right hand
% one. Related files should have identical names, which means, file 
% DEADBEEF_Left.txt should be relative to file DEADBEEF_Right.txt.
%
% Input:
%   subfolder --> name of folder where unsynchronized data is. This
%                 subfolder should be named: 
%       - '(\d{2}\.\d{2}\.\d{2})_(\w+)_(MODEL|VALIDATION)\\'
%           . The date the data was taken (as yy.mm.dd)
%           . The name of the activity
%           . If this is a MODEL or VALIDATION data
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
%   subfolder = '15.12.12_Open_Close_Curtains_MODEL_TIMEDIFF\';
%   trials_data = SynchronizeData(subfolder);
%

    % Constants declaration
    UNSYNCED_DATA_FOLDER = 'Data\UNSYNCED_DATA\';
    MODELS_FOLDER        = 'Data\MODELS\';
    VALIDATION_FOLDER    = 'Data\VALIDATION\';
    
    % Hands indices
    left_watch = 1;
    right_watch = 2;
    
    % Folder name regex
    folder_pattern = '(\d{2}\.\d{2}\.\d{2})_(\w+)_(MODEL|VALIDATION)\\';
    tokens = regexp(subfolder, folder_pattern, 'tokens');
    % Folder name parsing
    sync_subfolder = [tokens{1}{1} '\'];
    data_name = tokens{1}{2};
    data_type = tokens{1}{3};

    % Get delta_time for synchronization
    delta_time = FindWatchesSyncTimeDiff(['SYNC_' sync_subfolder]);
    
    % Get all trials data
    [trials_data, trials_names] = ReadFiles([UNSYNCED_DATA_FOLDER subfolder]);
    num_trials = size(trials_data, 1);
    
    % Synchronize data using timestamps
    for i=1:1:num_trials
        % Get initial time diff
        old_time_diff = trials_data{i, left_watch}(1,1) - trials_data{i,right_watch}(1,1);
        old_time_diff = old_time_diff - delta_time;
        % Get sample that has smallest time diff
        for j=2:min(size(trials_data{i, left_watch}, 2), size(trials_data{i, right_watch}, 2))
            % Get timestamp diff between two watches samples
            time_diffs(1) = trials_data{i, left_watch}(1,j) - trials_data{i,right_watch}(1,1);
            time_diffs(2) = trials_data{i, left_watch}(1,1) - trials_data{i,right_watch}(1,j);
            real_time_diffs = time_diffs - delta_time;
            [~, index] = min(abs(real_time_diffs));
            current_time_diff = real_time_diffs(index);
            % If time diff crossed zero, means it's close to zero
            if abs(current_time_diff) > abs(old_time_diff)
                break;
            end
            old_time_diff = current_time_diff;
        end
        
        % Trim data based on delta time of reference synchronous data
        if abs(real_time_diffs(1)) < abs(real_time_diffs(2))
            trials_data{i, left_watch} = trials_data{i, left_watch}(:,j-1:end);
        else
            trials_data{i, right_watch} = trials_data{i, right_watch}(:,j-1:end);
        end
        
        % Trim data to make two hands vectors same size
        data_size = min(size(trials_data{i, left_watch}, 2), size(trials_data{i, right_watch}, 2));
        trials_data{i, left_watch} = trials_data{i, left_watch}(:,1:data_size);
        trials_data{i, right_watch} = trials_data{i, right_watch}(:,1:data_size);
    end
    
    % Save data in its respective folders
    switch data_type
        case 'MODEL'
            trials_data = FilterModelData(trials_data);
            trials_folder = [MODELS_FOLDER data_name '_' data_type '\'];
            % Create folder if it doesn't exist
            if ~isdir(trials_folder)
                mkdir(trials_folder);
            end
            for i=1:1:num_trials
                clear single_trial_data;
                single_trial_data{left_watch} = trials_data{i,left_watch};
                single_trial_data{right_watch} = trials_data{i,right_watch};
                save([trials_folder trials_names{i} '.mat'], 'single_trial_data');
            end
        case 'VALIDATION'
            trials_folder = [VALIDATION_FOLDER data_name '_' data_type '\'];
            % Create folder if it doesn't exist
            if ~isdir(trials_folder)
                mkdir(trials_folder);
            end
            for i=1:1:num_trials
                clear single_trial_data;
                single_trial_data{left_watch} = trials_data{i,left_watch};
                single_trial_data{right_watch} = trials_data{i,right_watch};
                save([trials_folder trials_names{i} '.mat'], 'single_trial_data');
            end
        otherwise
            disp(['Invalid data type in folder ' subfolder]);
    end
end

function [filtered_data] = FilterModelData( trials_data )
    % median filter parameters
    n = 3;      % order of the median filter
    left_watch = 1;
    right_watch = 2;
    % Filter data for all trials and all axis (x, y, z)
    filtered_data = cell(size(trials_data));
    num_trials = size(trials_data, 1);
    for i=1:1:num_trials
        for j=2:size(trials_data{i, left_watch}, 1)
            filtered_data{i, left_watch}(j,:) = medfilt1(trials_data{i, left_watch}(j,:),n);
            filtered_data{i, right_watch}(j,:) = medfilt1(trials_data{i, right_watch}(j,:),n);
        end
    end
end
