% -------------------------------------------------------------------------
% Authors: Tiago P M da Silva (dept. DIBRIS, University of Genova, ITALY)
%          Divya Haresh Shah (dept. DIBRIS, University of Genova, ITALY)
%          Ernesto Denicia (dept. DIBRIS, University of Genova, ITALY)
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% This function is associated to the public dataset Bimanual Data Set.
% -------------------------------------------------------------------------
%
% SyncDataBimanual, using raw acceleration data from two smart watches,
% generates time synced data with respect to the timestamps on both 
% datasets. It goes through all the subfolders inside the 
% UNSYNCED_DATA_FOLDER, these subfolders should be named:
%   - '(\d{2}\.\d{2}\.\d{2})_(\w+)_(MODEL|VALIDATION)\\'
%     . The date the data was taken (as yy.mm.dd)
%     . The name of the activity
%     . If this is a MODEL or VALIDATION data
% Inside each subfolder there should be a equal number of files named:
%   - '*_Right.txt'
%   - '*_Left.txt'
% Relative to the data taken from the left hand watch and the right hand
% one. Related files should have identical names, which means, file 
% DEADBEEF_Left.txt should be relative to file DEADBEEF_Right.txt.

% Constants declaration
UNSYNCED_DATA_FOLDER = 'Data\UNSYNCED_DATA\';

% Get list of data to be synced
subfolders = dir(UNSYNCED_DATA_FOLDER);
subfolders = subfolders(~ismember({subfolders.name},{'.','..'}));

% Builds all specified models
for i=1:length(subfolders)
    % Close open files to prevent MatLab instability
    fclose all;
    % Synchronizes and saves data in specified folder
    subfolder = [subfolders(i).name '\'];
    fprintf('Syncing %s folder...\n', subfolder);
    SynchronizeData(subfolder);
end

fclose all;