% -------------------------------------------------------------------------
% Authors: Tiago P M da Silva (dept. DIBRIS, University of Genova, ITALY)
%          Divya Haresh Shah (dept. DIBRIS, University of Genova, ITALY)
%          Ernesto Denicia (dept. DIBRIS, University of Genova, ITALY)
%          Barbara Bruno (dept. DIBRIS, University of Genova, ITALY)
%
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
%
% This code is the implementation of the algorithms described in the
% paper "Analysis of human behavior recognition algorithms based on
% acceleration data".
%
% I would be grateful if you refer to the paper in any academic
% publication that uses this code or part of it.
% Here is the BibTeX reference:
% @inproceedings{Bruno13,
% author = "B. Bruno and F. Mastrogiovanni and A. Sgorbissa and T. Vernazza and R. Zaccaria",
% title = "Analysis of human behavior recognition algorithms based on acceleration data",
% booktitle = "Proceedings of the IEEE International Conference on Robotics and Automation (ICRA 2013)",
% address = "Karlsruhe, Germany",
% month = "May",
% year = "2013"
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
% ValidateWHARF allows to test the models built by the function
% BuildWHARF with the validation trials associated to the same
% dataset. It feeds the Classifier with the samples recorded in one
% validation trial one-by-one, waiting for the completion of the previous
% classification before feeding the Classifier with a new sample.
% So as to validate two handed tasks, it assumes they are independent and
% multiplies their probabilities together to get the probability of the
% joint action.

% LOAD THE MODELS OF THE HMP IN HMPDATASET
% (models of the known activities and classification thresholds)
load models_and_thresholds.mat
models(6).gP=zeros(7,294);
models(6).bP=zeros(7,294);
models(6).gS=zeros(6,6,294);
models(6).bS=zeros(6,6,294);
models(6).threshold=0;
models(6).name='Dummy';

% DEFINE THE VALIDATION FOLDER TO BE USED AND GET DATA FROM IT
main_folder = 'Data\K-GROUPS\VALIDATION\SET_6\';
% Get list of folders with data to be validated
folders = dir(main_folder);
folders = folders(~ismember({folders.name},{'.','..'}));

% Builds all specified models
for i=1:length(folders)
    disp(['Validating folder ' num2str(i) ': ' folders(i).name ]);
    folder = [folders(i).name '\'];
    trials_data = GetTrialsData([main_folder folder]);
    % For seven dimensions data must be packed in an only structure 
    % including both hands. Notice time of left hand is imposed on both
    for packing = 1:size(trials_data,1)
        trials_dataT{packing,1}(1:7,:) = [trials_data{packing,1}(1:4,:); ...
                                          trials_data{packing,2}(2:4,:)];
    end
    clearvars trials_data
    trials_data = trials_dataT;
    clearvars trials_dataT

    
    % DEFINE THE VALIDATION PARAMETERS
    % compute the size of the sliding window
    % (size of the largest model + 64 samples)
    numModels = length(models);
    %numHands = size(model_hands, 2);
    models_size = zeros(1, numModels);
    for m=1:1:numModels
        % Left hand model should have same size as right hand, so just get one
        % of them
        models_size(m) = size(models(m).bP,2)+64;
    end
    window_size = max(models_size);
    % create an array with the models thresholds
    thresholds = zeros(1, numModels);
    for m=1:1:numModels
        %for hand_index=1:numHands
            thresholds(1, m) = models(m).threshold;
        %end
    end
    % initialize the results arrays
    dist = zeros(1, numModels);
    hand_possibilities = zeros(1, numModels, 1);
    possibilities = zeros(1, numModels);

    % ANALYZE THE VALIDATION TRIALS ONE BY ONE, SAMPLE BY SAMPLE
    files = dir([[main_folder folder], '*.mat'])';
    % Get number of data entries.
    numFiles = size(trials_data, 1);
    for k=1:1:numFiles
        disp(['-------------------Trial ' int2str(k) '/' int2str(numFiles) '-------------------']);
        % Get current trial file name
        file_name = files(k).name;
        % Get single trial's data
        single_trial_data = trials_data{k};
        % Validate trial
        %disp(['---Validating trial:' num2str(k) ': ' file_name(1:end-4) ' ']);
        ValidateTrial7d( models, single_trial_data, file_name, 1 );
        close all;
    end
end