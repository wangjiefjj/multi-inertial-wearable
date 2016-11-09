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
models(6).left_hand.gP=zeros(4,294);
models(6).left_hand.bP=zeros(4,294);
models(6).left_hand.gS=zeros(3,3,294);
models(6).left_hand.bS=zeros(3,3,294);
models(6).left_hand.threshold=0;
models(6).right_hand.gP=zeros(4,294);
models(6).right_hand.bP=zeros(4,294);
models(6).right_hand.gS=zeros(3,3,294);
models(6).right_hand.bS=zeros(3,3,294);
models(6).right_hand.threshold=0;
models(6).name='Dummy';

% DEFINE THE VALIDATION FOLDER TO BE USED AND GET DATA FROM IT
main_folder = 'Data\K-GROUPS\VALIDATION\SET_6\';
% Get list of folders with data to be validated
folders = dir(main_folder);
folders = folders(~ismember({folders.name},{'.','..'}));

% Builds all specified models
for i=1:length(folders)
    folder = [folders(i).name '\'];
    trials_data = GetTrialsData([main_folder folder]);

    % ANALYZE THE VALIDATION TRIALS ONE BY ONE, SAMPLE BY SAMPLE
    files = dir([[main_folder folder], '*.mat'])';
    % Get number of data entries.
    numFiles = size(trials_data, 1);
    for file_index=1:1:13
        % Get current trial file name
        file_name = files(file_index).name;
        % Get single trial's data
        single_trial_data = {trials_data{file_index,1}; trials_data{file_index,2}};
        % Validate trial
        ValidateTrial( models, single_trial_data, file_name, 1 );
    end
end