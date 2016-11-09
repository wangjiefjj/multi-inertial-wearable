function [ processed_data ] = GetProcessedData( modelfile )
%GETPROCESSEDDATA Get preprocessed data for a single activity
% 
% -------------------------------------------------------------------------
% Author: Tiago P M da Silva (dept. DIBRIS, University of Genova, ITALY)
%         Divya Haresh Shah (dept. DIBRIS, University of Genova, ITALY)
%         Ernesto Denicia (dept. DIBRIS, University of Genova, ITALY)
%
% -------------------------------------------------------------------------
% 
% GetProcessedData is used to extract the data in the matrix form from the
% preprocessed data mat files.
%
% Input:
%   modelfile --> the mat file containing the data of the wanted activity
%   hand_index --> parameter defining which is the hand in consideration
%                  (left==1 / right==2)
%
% Output:
%   x_set --> acceleration values measured along the x axis in each file
%             at each given time instant (each column corresponds to the
%             x axis of a file)
%   y_set --> acceleration values measured along the y axis in each file
%             at each given time instant (each column corresponds to the
%             y axis of a file)
%   z_set --> acceleration values measured along the z axis in each file
%             at each given time instant (each column corresponds to the
%             z axis of a file)
%   numSamples --> number of sample points measured by the accelerometer in
%                  each file (number of rows in the files, that must be
%                  same for ALL files)
%
% Examples:
%   file = 'Data\PREPROCESSED_DATA\OpenCloseCurtains_PREPROCESSED.mat';
%   hand_index = 1; % Left hand.
%   [ x_set, y_set, z_set, numSamples ] = GetProcessedData( file, ...
%                                                   hand_index );

    %Loading the mat  file
    prdata = matfile(modelfile);
    processed_data = prdata.processed_data;
    
%     %Extracting the data
%     numSamples = processed_data.size;
%     if(hand_index==1)
%        x_set = processed_data.left.x';
%        y_set = processed_data.left.y';
%        z_set = processed_data.left.z';
%     elseif(hand_index==2)
%        x_set = processed_data.right.x';
%        y_set = processed_data.right.y';
%        z_set = processed_data.right.z';
%     else
%        disp('Invalid Hand Index');
%     end
end