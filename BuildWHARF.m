% -------------------------------------------------------------------------
% Authors: Tiago P M da Silva (dept. DIBRIS, University of Genova, ITALY)
%          Divya Haresh Shah (dept. DIBRIS, University of Genova, ITALY)
%          Ernesto Denicia (dept. DIBRIS, University of Genova, ITALY)
%          Barbara Bruno (dept. DIBRIS, University of Genova, ITALY)
%
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% This code is the implementation of the algorithms described in the
% paper "Human motion modeling and recognition: a computational approach".
%
% I would be grateful if you refer to the paper in any academic
% publication that uses this code or part of it.
% Here is the BibTeX reference:
% @inproceedings{Bruno12,
% author = "B. Bruno and F. Mastrogiovanni and A. Sgorbissa and T. Vernazza and R. Zaccaria",
% title = "Human motion modeling and recognition: a computational approach",
% booktitle = "Proceedings of the 8th {IEEE} International Conference on Automation Science and Engineering ({CASE} 2012)",
% address = "Seoul, Korea",
% year = "2012",
% month = "August"
% }
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% This function is associated to the public dataset WHARF Data Set.
% (free download at: https://github.com/fulviomas/WHARF)
% The WHARF Data Set and its rationale are described in the paper "A Public
% Domain Dataset for ADL Recognition Using Wrist-placed Accelerometers".
%
% I would be grateful if you refer to the paper in any academic
% publication that uses this code or the WHARF Data Set.
% Here is the BibTeX reference:
% @inproceedings{Bruno14c,
% author = "B. Bruno and F. Mastrogiovanni and A. Sgorbissa",
% title = "A Public Domain Dataset for {ADL} Recognition Using Wrist-placed Accelerometers",
% booktitle = "Proceedings of the 23rd {IEEE} International Symposium on Robot and Human Interactive Communication ({RO-MAN} 2014)",
% address = "Edinburgh, UK",
% month = "August",
% year = "2014"
% }
% -------------------------------------------------------------------------
%
% BuildWHARF creates the single handed models (with the Gaussian Mixture 
% Modelling and Regression procedure) of the HMP of WHARF Data Set, each
% represented by a set of modelling trials stored in a specific 
% preprocessed file. This file should be generated with SyncDataWHARF and
% PreprocessDataWHARF. In addition, the function computes the
% model-specific threshold to be later used by the Classifier to 
% discriminate between known and unknown motions.

% Create the models and associated thresholds
% Constants
hand_strings = {'- Building left hand model...';
                '- Building right hand model...'};
scale = 1.5;  % experimentally set scaling factor for the threshold computation

% Models to be ran
model_names = {'OpenCloseCurtains', 'Sweeping', 'FillingCuponTap', ...
    'RemovingFromFridge', 'WardrobeOpening'};
folder = 'Data\PREPROCESSED_DATA\';

% Preallocating models array struct
models = repmat(struct('name',{''}, 'left_hand', [], 'right_hand', []), size(model_names, 2), 1 );

% Builds all specified models
for i=1:size(model_names, 2)
    fprintf('Building %s model...\n', model_names{i});
    models(i) = struct('name',{model_names{i}}, 'left_hand', [], 'right_hand', []);
    %Getting the required mat file for the model into consideration
    modelfile = strcat(folder, model_names{i}, '_PREPROCESSED.mat');
    
    % EXTRACT THE ACCELEROMETER PREPREOCESSED DATA FROM THE MAT FILES
    processed_data = GetProcessedData(modelfile);
    numSamples = processed_data.size;
    
    % Transpose processed data
    processed_data.left.x = processed_data.left.x';
    processed_data.left.y = processed_data.left.y';
    processed_data.left.z = processed_data.left.z';
    processed_data.right.x = processed_data.right.x';
    processed_data.right.y = processed_data.right.y';
    processed_data.right.z = processed_data.right.z';
    
    % Builds specified models for each hand
    for hand_index=1:2
        disp(hand_strings{hand_index});
        % Generate models and compute thresholds
        if hand_index==1
            [model_gP, model_gS, model_bP, model_bS] = GenerateModel(processed_data.left, numSamples);
        else
            [model_gP, model_gS, model_bP, model_bS] = GenerateModel(processed_data.right, numSamples);
        end
        model_threshold = ComputeThreshold(model_gP,model_gS,model_bP,model_bS,scale);
        hand_model = struct('gP',model_gP,'gS',model_gS,'bP',model_bP,'bS',model_bS,'threshold',model_threshold);
        % Save hand model data into model struct
        if hand_index==1
            models(i).left_hand = hand_model;
        else
            models(i).right_hand = hand_model;
        end

        clear model_gP model_gS model_bP model_bS model_threshold
    end
end
clear hand_strings hand_folders model_names folders

% SAVE THE MODELS IN THE CURRENT DIRECTORY
save models_and_thresholds.mat