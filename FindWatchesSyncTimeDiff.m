function [delta_time] = FindWatchesSyncTimeDiff(subfolder)
% function [delta_time] = FindWatchesSyncTimeDiff(subfolder)
%
% -------------------------------------------------------------------------
% Author: Tiago Pimentel (dept. DIBRIS, University of Genova, ITALY)
%         Divya Haresh Shah (dept. DIBRIS, University of Genova, ITALY)
%         Ernesto Denicia (dept. DIBRIS, University of Genova, ITALY)
%
% -------------------------------------------------------------------------
%
% FindWatchesSyncTimeDiff finds the time difference between two smart
% watches timestamp by using reference synchronous data. This data should
% be taken by starting both watches at, as preciselly as possible, the same
% time, and this time difference is used as reference to synchronize both
% watches in BuildWHARF and ValidateWHARF. This data should be placed in
% a subfolder inside DATA/SYNCHRONOUS/.
% Inside each subfolder there should be a equal number of files named:
%   - '*_Right.txt'
%   - '*_Left.txt'
% Relative to the data taken from the left hand watch and the right hand
% one. Related files should have identical names, which means, file 
% DEADBEEF_Left.txt should be relative to file DEADBEEF_Right.txt.
%
% Input:
%   subfolder --> directory inside 'Data\SYNCHRONOUS\' folder containing
%               the reference files to be used as truth values for
%               sinchronization. This subfolder should be named 
%               SYNC_yy.mm.dd, with the acquisition date in its name.
%
% Output:
%   delta_time --> reference delta_time between the two watches to be used
%               for data synchronization
%
% Examples:
%   subfolder = 'SYNC_15.12.12\';
%   delta_time = FindWatchesSyncTimeDiff(subfolder);

    % Get files in SYNCHRONIZATION data folder
    sync_folder = 'Data\SYNCHRONIZATION\';
    folder = [sync_folder subfolder];
    files = [dir([folder,'*_Left.txt'])';
             dir([folder,'*_Right.txt'])'];
    % Get number of data entries. Number of left and right files is assumed to
    % be the same
    num_files = size(files, 2);
    left_watch = 1;
    right_watch = 2;

    % Initialize delta time
    delta_time = 0;
    % Calculate delta time
    for i=1:1:num_files
        for watch_index=1:1:2
            % Get timestamp data
            trial_file = fopen([folder files(watch_index, i).name],'r');
            trial_data = fscanf(trial_file,'a;%ld;%f;%f;%f\n',[4,inf]);
            trial_time(watch_index) = trial_data(1,1);
        end
        delta_time = delta_time + (trial_time(left_watch) - trial_time(right_watch))/num_files;
    end
end