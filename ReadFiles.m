function [ files_data, trial_names ] = ReadFiles( folder )
%READFILES Reads text files with trial data
% 
% -------------------------------------------------------------------------
% Author: Tiago P M da Silva (dept. DIBRIS, University of Genova, ITALY)
%         Divya Haresh Shah (dept. DIBRIS, University of Genova, ITALY)
%         Ernesto Denicia (dept. DIBRIS, University of Genova, ITALY)
%
% -------------------------------------------------------------------------
%
% ReadFiles, reads *.txt files with in each line: 'a;%ld;%f;%f;%f\n'.
%           - timestamp;
%           - x_axis acceleration;
%           - y_axis acceleration;
%           - z_axis acceleration.
%
% Input:
%   folder --> name of folder where data is.
%
% Output:
%   files_data --> dataset containing a 2x4xN cell array.
%                - 2 : Left and Right hands;
%                - 4 : acceleration components data with its timestamp 
%     (row1 -> timestamp, row2 -> x_axis, row3 -> y_axis, row4 -> z_axis);
%                - N : Data points in each file.
%
%   trial_names --> vector containing the name of each trial.
%
% Examples:
%   UNSYNCED_DATA_FOLDER = 'Data\UNSYNCED_DATA\';
%   subfolder = '15.12.12_Open_Close_Curtains_MODEL_TIMEDIFF\';
%   [trials_data, trials_names] = ReadFiles([UNSYNCED_DATA_FOLDER subfolder]);

    % Get name of data files for left and right hand
    files = [dir([folder,'*_Left.txt'])';
             dir([folder,'*_Right.txt'])'];
    
    % Get number of data entries. Number of left and right files should be the
    % same
    num_files = size(files, 2);
    files_data = cell(num_files, 2);
    % Get files contents for both right and left hands in a cell array
    for i=1:1:num_files
        for hand_index=1:1:2
            current_file = fopen([folder files(hand_index, i).name],'r');
            files_data{i, hand_index} = fscanf(current_file,'a;%ld;%f;%f;%f\n',[4,inf]);
        end
    end
    
    trial_names = cell(num_files,1);
    for i = 1:num_files
        trial_names{i} = files(1,i).name(1:end-9);
    end
end

