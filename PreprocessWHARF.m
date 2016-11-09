% -------------------------------------------------------------------------
% Authors: Tiago P M da Silva (dept. DIBRIS, University of Genova, ITALY)
%          Divya Haresh Shah (dept. DIBRIS, University of Genova, ITALY)
%          Ernesto Denicia (dept. DIBRIS, University of Genova, ITALY)
%
% 
% -------------------------------------------------------------------------
% This function is associated to the public dataset WHARF Data Set.
% (free download at: https://github.com/tiagopms/WHARF)
% 
% -------------------------------------------------------------------------
%
% PreprocessWHARF executes the pre-processing of the data. It loads the
% time synced sensory data files present in the MODEL folder. This data is
% shown, as graphs, so the user can sync one trial start time with respect
% to the others and cut all trials data so they all have the same size.

% Constants declaration.
SAVE_FOLDER = 'Data\PREPROCESSED_DATA\';

% Models folders and names.
model_names = {'OpenCloseCurtains', 'Sweeping', 'FillingCuponTap', ...
    'RemovingFromFridge', 'WardrobeOpening'};
folders = {'Open_Close_Curtains_MODEL\'; 'Sweeping_MODEL\'; ...
    'Filling_Cup_on_Tap_MODEL\'; 'Removing_from_Fridge_MODEL\'; ...
    'Wardrobe_Opening_MODEL\'};

% Preprocess each model
for i=1:size(model_names, 2)
    folder = strcat('Data\MODELS\', folders{i});
    [processed_data] = PreprocessData( folder );
    save([SAVE_FOLDER model_names{i} '_PREPROCESSED.mat'], 'processed_data', '-v7.3');
end