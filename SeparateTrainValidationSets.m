function [ train_processed_data, val_processed_data ] = SeparateTrainValidationSets( k_sets, validation_set_index )

%%SEPARATETRAINVALIDATIONSETS forms the training and the validation sets
%%from the given data set.
% 
% -------------------------------------------------------------------------
% Author: Tiago P M da Silva (dept. DIBRIS, University of Genova, ITALY)
%         Divya Haresh Shah (dept. DIBRIS, University of Genova, ITALY)
%         Ernesto Denicia (dept. DIBRIS, University of Genova, ITALY)
%
% -------------------------------------------------------------------------
% 
% SeparateTrainValidationSets is used to separate out and form the training and the
% validation sets from the obtained k sets of the processed data. The
% training and validation sets formed are different for different
% validation set index so as to avoid the biases.
%
% Input:
%   k_sets --> the struct containing the different sets into which the
%   processed data is divided.
%   validation_set_index --> the index specifying which 'k' set would be
%   the validation set.
%
% Output:
%   train_processed_data --> struct containing the k sets to be used for
%   training of the model.
%   val_processed_data --> struct containing the k sets to be used for
%   validation of the model.
%
% Example:
%   model_names = {'OpenCloseCurtains', 'Sweeping', 'FillingCuponTap', ...
%                   'RemovingFromFridge', 'WardrobeOpening'};
%   folder = 'Data\PREPROCESSED_DATA\';
%   modelfile = strcat(folder, model_names{i}, '_PREPROCESSED.mat');
%   processed_data = GetProcessedData(modelfile);
%   k_sets = SeparateDataInKGroups(processed_data, number_k_sets);
%   for validation_set_index = 1:number_k_sets
%   [train_processed_data, val_processed_data] = SeparateTrainValidationSets(k_sets, validation_set_index);
%   end

%Forming the validation data
val_processed_data.left.x = k_sets(validation_set_index).left.x;
val_processed_data.left.y = k_sets(validation_set_index).left.y;
val_processed_data.left.z = k_sets(validation_set_index).left.z;
val_processed_data.right.x = k_sets(validation_set_index).right.x;
val_processed_data.right.y = k_sets(validation_set_index).right.y;
val_processed_data.right.z = k_sets(validation_set_index).right.z;

%Forming the training data
train_processed_data.left.x = [];
train_processed_data.left.y = [];
train_processed_data.left.z = [];
train_processed_data.right.x = [];
train_processed_data.right.y = [];
train_processed_data.right.z = [];
for i = 1:size(k_sets,2)
    if(i ~= validation_set_index)
        train_processed_data.left.x = vertcat(train_processed_data.left.x,k_sets(i).left.x);
        train_processed_data.left.y = vertcat(train_processed_data.left.y,k_sets(i).left.y);
        train_processed_data.left.z = vertcat(train_processed_data.left.z,k_sets(i).left.z);
        train_processed_data.right.x = vertcat(train_processed_data.right.x,k_sets(i).right.x);
        train_processed_data.right.y = vertcat(train_processed_data.right.y,k_sets(i).right.y);
        train_processed_data.right.z = vertcat(train_processed_data.right.z,k_sets(i).right.z);
    end
end

end