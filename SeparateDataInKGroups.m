function [ k_sets, k_sets_indexes ] = SeparateDataInKGroups( processed_data, number_k_sets )
%%SEPARATEDATAINKGROUPS Separates the preprocessed data for a single
%%activity, into 'k' different sets for k-fold cross validation.
% 
% -------------------------------------------------------------------------
% Author: Tiago P M da Silva (dept. DIBRIS, University of Genova, ITALY)
%         Divya Haresh Shah (dept. DIBRIS, University of Genova, ITALY)
%         Ernesto Denicia (dept. DIBRIS, University of Genova, ITALY)
%
% -------------------------------------------------------------------------
% 
% SeparateDataInKGroups is used to separate the processed data into 'k'
% different sets in order to carry out the k-fold cross validation so as to
% avoid the biases during model genreation and validation.
%
% Input:
%   processed_data --> the processed_data struct for each of the activity
%   number_k_sets --> the number of sets into which the data is to be divided
%
% Output:
%   k_sets --> the struct containing the different sets into which the
%   processed data is divided.
%
% Example:
%   model_names = {'OpenCloseCurtains', 'Sweeping', 'FillingCuponTap', ...
%                   'RemovingFromFridge', 'WardrobeOpening'};
%   folder = 'Data\PREPROCESSED_DATA\';
%   modelfile = strcat(folder, model_names{i}, '_PREPROCESSED.mat');
%   processed_data = GetProcessedData(modelfile);
%    k_sets = SeparateDataInKGroups(processed_data, number_k_sets);

    %Constants declaration
    numTrials = size(processed_data.left.x,1);
    k_set_trials = floor(numTrials/number_k_sets);

    % k_sets = repmat(processed_data, k, 1);
    k_sets_indexes = zeros(number_k_sets, k_set_trials);

    %Sorting of the data into sets
    for k = 1:number_k_sets
        initial = 1 + k_set_trials*(k-1);
        final = k_set_trials*(k);
        k_sets(k).left.x = processed_data.left.x(initial:final,1:end)';
        k_sets(k).left.y = processed_data.left.y(initial:final,1:end)';
        k_sets(k).left.z = processed_data.left.z(initial:final,1:end)';
        k_sets(k).right.x = processed_data.right.x(initial:final,1:end)';
        k_sets(k).right.y = processed_data.right.y(initial:final,1:end)';
        k_sets(k).right.z = processed_data.right.z(initial:final,1:end)';

        k_sets_indexes(k,:) = initial:final;
    end

end

