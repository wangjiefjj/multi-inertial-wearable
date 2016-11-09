function [ processed_data ] = PreprocessData( folder )
%PREPROCESSDATA Preprocess data to synchronize between trials
% 
% -------------------------------------------------------------------------
% Author: Tiago P M da Silva (dept. DIBRIS, University of Genova, ITALY)
%         Divya Haresh Shah (dept. DIBRIS, University of Genova, ITALY)
%         Ernesto Denicia (dept. DIBRIS, University of Genova, ITALY)
%
% -------------------------------------------------------------------------
%
% PreprocessData, loads the synchronized data created by SyncDataWHARF and
% allows a user to synchronize one trial with the other. It plots trials'
% data one by one in a graph and allows panning them with respect to the
% first trial. After all trial have been panned the user can trim the data
% at the start and end to make all trials the same size.
%
% Input:
%   folder --> name of folder where unprocessed model data is. This
%              folder should be named: 
%                 - '(\w+)_MODEL\\'
%              being w+ the name of the modeled activity.
%
% Output:
%   processed_data --> dataset containing a struct with six acceleration
%                      arrays (left.x, left.y, left.z, right.x, right.y,
%                      right.z) and the size of the model (size).
%
% Examples:
%   SyncDataWHARF;
%   folder = 'Data\MODELS\Open_Close_Curtains_MODEL\';
%   trials_data = PreprocessData(folder);
%
    % Constants declaration.
    left_index = 1;
    right_index = 2;

    % Read the accelerometers data files and get longest trial size
    raw_data = GetTrialsData(folder);
    num_files = length(raw_data);
    [max_size, max_index] = max(cellfun('size', raw_data, 2));
    max_trial_size = max_size(1);

    % Get first data trial
    data1_left = raw_data{1, left_index};
    data1_right = raw_data{1, right_index};
    
    % Plot data from first trial
    close all
    x = 1:size(data1_left, 2);
    ax(1) = subplot(3,1,1); plot(x,data1_left(2,:), x, data1_right(2,:)); hold on;
    title('Check if this is your desired data');
    ax(2) = subplot(3,1,2); plot(x,data1_left(3,:), x, data1_right(3,:));
    ax(3) = subplot(3,1,3); plot(x,data1_left(4,:), x, data1_right(4,:));
    linkaxes(ax,'x');
    pause;
    close all;

    % Initialize sets that will hold data from all trials
    left_x_set = [data1_left(2,1:end), ones(1,max_trial_size - size(data1_left,2))*data1_left(2,end)];
    right_x_set = [data1_right(2,1:end), ones(1,max_trial_size - size(data1_right,2))*data1_right(2,end)];
    left_y_set = [data1_left(3,1:end), ones(1,max_trial_size - size(data1_left,2))*data1_left(3,end)];
    right_y_set = [data1_right(3,1:end), ones(1,max_trial_size - size(data1_right,2))*data1_right(3,end)];
    left_z_set = [data1_left(4,1:end), ones(1,max_trial_size - size(data1_left,2))*data1_left(4,end)];
    right_z_set = [data1_right(4,1:end), ones(1,max_trial_size - size(data1_right,2))*data1_right(4,end)];
    
    % Loop through each trial
    for i = 2:1:num_files
        % Get next data trial
        data_left = raw_data{i,left_index};
        data_right = raw_data{i,right_index};
        
        % Plot initial trial data, other trials will be compared to this
        % one
        figure(2) = gcf;
        clf(figure(2))
        plot(left_x_set(1,:));
        hold on;
        plot(right_x_set(1,:));
        axis1 = figure(2).CurrentAxes;
        
        % Plot data of current trial with the initial
        axis_pos = axis1.Position; % position of first axes
        axis2 = axes('Position',axis_pos,...
        'XAxisLocation','top',...
        'YAxisLocation','right',...
        'Color','none');
        hold on;
        plot(axis2, data_left(2,:), 'g');
        plot(axis2, data_right(2,:), 'k');
        % Allow axes panning and wait for user to synchronize data between
        % different trials
        title('Pan until desired overlapping and pres ENTER')
        xlim([0 max_trial_size])
        h=pan;
        h.ActionPreCallback = @myprecallback;
        h.ActionPostCallback = @mypostcallback;
        h.Motion = 'horizontal';
        h.Enable = 'on';
        pause;
        
        % Get data panning info
        x_limits = xlim;

        % Pan new data according to x_limits
        if x_limits(1) < 0
            x_limits(1) = abs(floor(x_limits(1)));
            % Shif data_left and data_right with pan information while
            % filling start with continuous data equals to its first value
            temp_left = [ones(1,x_limits(1))*data_left(1,1); ...
                    ones(1,x_limits(1))*data_left(2,1); ...
                    ones(1,x_limits(1))*data_left(3,1); ...
                    ones(1,x_limits(1))*data_left(4,1)];
            temp_right = [ones(1,x_limits(1))*data_right(1,1); ...
                    ones(1,x_limits(1))*data_right(2,1); ...
                    ones(1,x_limits(1))*data_right(3,1); ...
                    ones(1,x_limits(1))*data_right(4,1)];
            data_left = [temp_left data_left(1:end,1:end)];
            data_right = [temp_right data_right(1:end,1:end)];
        elseif x_limits(1) == 0
            x_limits(1) = 1;
            data_left = data_left(1:end, ceil(x_limits(1)):end);
            data_right = data_right(1:end, ceil(x_limits(1)):end);
        else
            data_left = data_left(1:end,ceil(x_limits(1)):end);
            data_right = data_right(1:end,ceil(x_limits(1)):end);
        end
        
        % Complete data_left and data_right to max_trial size by copying
        % its last data value and add new trial panned data to set
        left_x_set = [left_x_set; [data_left(2,1:end), ones(1,max_trial_size-size(data_left,2))*data_left(2,end)]];
        left_y_set = [left_y_set; [data_left(3,1:end), ones(1,max_trial_size-size(data_left,2))*data_left(3,end)]];
        left_z_set = [left_z_set; [data_left(4,1:end), ones(1,max_trial_size-size(data_left,2))*data_left(4,end)]];
        right_x_set = [right_x_set; [data_right(2,1:end), ones(1,max_trial_size-size(data_right,2))*data_right(2,end)]];
        right_y_set = [right_y_set; [data_right(3,1:end), ones(1,max_trial_size-size(data_right,2))*data_right(3,end)]];
        right_z_set = [right_z_set; [data_right(4,1:end), ones(1,max_trial_size-size(data_right,2))*data_right(4,end)]];
    end
    
    % Plot all panned trials' data together
    for i=1:size(left_x_set,1)
        subplot(3,1,1); hold on;
        plot(left_x_set(i,:));
        plot(right_x_set(i,:));
        subplot(3,1,2); hold on;
        plot(left_y_set(i,:));
        plot(right_y_set(i,:));
        subplot(3,1,3); hold on;
        plot(left_z_set(i,:));
        plot(right_z_set(i,:));
    end
    % Cut data on the left and right based on user input
    title('Choose cutting LEFT and RIGHT edges')
    [cutx,~] = ginput(2);
    left_x_set = left_x_set(1:end,ceil(cutx(1)):ceil(cutx(2)));
    left_y_set = left_y_set(1:end,ceil(cutx(1)):ceil(cutx(2)));
    left_z_set = left_z_set(1:end,ceil(cutx(1)):ceil(cutx(2)));
    right_x_set = right_x_set(1:end,ceil(cutx(1)):ceil(cutx(2)));
    right_y_set = right_y_set(1:end,ceil(cutx(1)):ceil(cutx(2)));
    right_z_set = right_z_set(1:end,ceil(cutx(1)):ceil(cutx(2)));
  
    % Return cut data
    processed_data.left.x = left_x_set;
    processed_data.right.x = right_x_set;
    processed_data.left.y = left_y_set;
    processed_data.right.y = right_y_set;
    processed_data.left.z = left_z_set;
    processed_data.right.z = right_z_set;
    processed_data.size = length(left_x_set(1,:)); 

% Announce that pan is in progress
function myprecallback(obj,evd)
    disp('A pan is about to occur.');

% Save new limit after pan
function mypostcallback(obj,evd)
    newLim = xlim
    disp('callback')
%msgbox(sprintf('The new X-Limits are [%.2f,%.2f].',newLim));
%assignin('base', 'x_limits', newLim);
