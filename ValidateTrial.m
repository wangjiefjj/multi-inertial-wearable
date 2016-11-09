function [  ] = ValidateTrial( models, trial_data, file_name, debug_mode )
%VALIDATETRIAL Summary of this function goes here
%   Detailed explanation goes here

    % Define default value for flag debugMode as false
    if nargin < 4 || isempty(debug_mode)
        debug_mode = 0;
    end
    
    % Define constants
    res_folder = 'Data\K-GROUPS\RESULTS\4X4_SET_6\';
    model_hands = {'left_hand', 'right_hand'};
    
    % Set result file names
    result_file_name = [res_folder 'RES_' file_name(1:end-4)];
    graph_file_name = [res_folder 'GRAPH_POSS_NORM__' file_name(1:end-4)];
    graph_file_name_DTW = [res_folder 'GRAPH_POSS_DTW__' file_name(1:end-4)];
    graph_file_name_prob = [res_folder 'GRAPH_PROB__' file_name(1:end-4)];
    
    % transform the trial into a stream of samples
   % current_data = [trial_data(2:4,1:end),zeros(3,300)];   % remove timestamp data
    %numSamples = size(current_data, 2);
    % DEFINE THE VALIDATION PARAMETERS
    % compute the size of the sliding window
    % (size of the largest model + 64 samples)
    numModels = length(models);
    numHands = size(model_hands, 2);
    models_size = zeros(1, numModels);
    for m=1:1:numModels
        % Left hand model should have same size as hight hand, so just get one
        % of them
        models_size(m) = size(models(m).left_hand.bP,2)+64;
    end
    min_window_size = min(models_size);
    window_size = max(models_size);
    % create an array with the models thresholds
    thresholds = zeros(numHands, numModels);
    for m=1:1:numModels
        for hand_index=1:numHands
            thresholds(hand_index, m) = models(m).(model_hands{hand_index}).threshold;
        end
    end
    
    % Since two hands have same number of samples for a specific trial, get
    % number of samples from left hand.
    trial_data{1} = [trial_data{1},zeros(4,300)];
    trial_data{2} = [trial_data{2},zeros(4,300)];
    num_samples = size(trial_data{1}, 2);
    % If number of samples in trial is smaller than window size, ignore
    % trial
    if num_samples < min_window_size
        disp(['Trial ' file_name(1:end-4) ' data is smaller than one of the models, so we cant run it. Will skip it!']);
        return;
    end
    
    % initialize the results arrays
    hand_dist = zeros(numHands, numModels);
%     hand_dist_DTW = zeros(numHands, numModels);
    temp_probabilities = zeros(1, numModels);
    hand_possibilities = zeros(num_samples, numModels, numHands);
%     hand_possibilities_DTW = zeros(num_samples, numModels, numHands);
    hand_probabilities = zeros(num_samples, numModels, numHands);
    
    for hand_index=1:1:numHands
        % transform the trial into a stream of samples
        current_data = trial_data{hand_index}(2:4,1:end);   % remove timestamp data
        % initialize the window of data to be used by the classifier
        window = zeros(window_size,3);
        numWritten = 0;
        for j=1:1:num_samples
            current_sample = current_data(:,j);
            % update the sliding window with the current sample
            [window, numWritten] = CreateWindow(current_sample,window,window_size,numWritten);
            % analysis is meaningful only when we have enough samples
            if (numWritten >= min_window_size)
                % compute the acceleration components of the current window of samples
                [gravity, body] = AnalyzeActualWindow(window,window_size);
                % compute the difference between the actual data and each model
                for m=1:1:numModels
                    model = models(m).(model_hands{hand_index});
                    % If current window size is bigger than model compute
                    % distance, else set distance to infinite so prob is 0
                    if numWritten > models_size(m)
                        difference = size(gravity,1)-models_size(m);
                    if difference<0
                        gravity = [zeros(-difference,3);gravity];
                        body = [zeros(-difference,3);body];
                    end
                        [hand_dist(hand_index, m), temp_probabilities(m)] = ...
                                    CompareWithModels( ...
                                        gravity(end-models_size(m)+1:end-64,:), ...
                                        body(end-models_size(m)+1:end-64,:), ...
                                        model.gP, model.gS, ...
                                        model.bP, model.bS);
%                         hand_dist_DTW(hand_index, m) = CompareWithModels_DTW( ...
%                                         gravity(end-models_size(m)+1:end-64,:), ...
%                                         body(end-models_size(m)+1:end-64,:), ...
%                                         model.gP, model.gS, ...
%                                         model.bP, model.bS);
                    else
                        hand_dist(hand_index, m) = inf;
%                         hand_dist_DTW(hand_index, m) = inf;
                        temp_probabilities(m) = inf;
                    end
                end
                % Classify the current data
                hand_possibilities(j,:, hand_index) = Classify(hand_dist(hand_index, :),thresholds(hand_index, :));
%                 hand_possibilities_DTW(j,:, hand_index) = Classify(hand_dist_DTW(hand_index, :),thresholds(hand_index, :));
                hand_probabilities(j,:, hand_index) = temp_probabilities;
            else
                hand_possibilities(j,:, hand_index) = zeros(1,numModels);
%                 hand_possibilities_DTW(j,:, hand_index) = zeros(1,numModels);
                hand_probabilities(j,:, hand_index) = zeros(1,numModels);
            end
            
            if mod(j, 20) == 0
                disp(['Trial ' file_name(1:end-4) ': Running hand ' int2str(hand_index) ' trial number ' int2str(j) ' of ' int2str(num_samples)]);
            end
        end
    end

    % Get the full probability for both hands uncorrelated model
    possibilities = hand_possibilities(:,:, 1) .* hand_possibilities(:,:, 2);
%     possibilities_DTW = hand_possibilities_DTW(:,:, 1) .* hand_possibilities_DTW(:,:, 2);
    probabilities = hand_probabilities(:,:, 1) .* hand_probabilities(:,:, 2);
    
    % Save the validation data
    save(result_file_name, ...
        'possibilities', ...
        'hand_possibilities', ...
        'probabilities', ...
        'hand_probabilities', ...
        '-v7.3');
%         'hand_possibilities_DTW', ...

    % Plot the possibilities and probabilities curves for the models
    PlotAndPrint(graph_file_name, models, possibilities, ...
        min_window_size, num_samples, numModels, debug_mode);
%     PlotAndPrint(graph_file_name_DTW, models, possibilities_DTW, ...
%         min_window_size, num_samples, numModels, debug_mode);
    PlotAndPrint(graph_file_name_prob, models, probabilities, ...
        min_window_size, num_samples, numModels, debug_mode);

    clear possibilities hand_possibilities hand_dist;
end

function [] = PlotAndPrint(graph_file_name, models, plotted_values, min_window_size, num_samples, numModels, debug_mode)
    % plot the possibilities curves for the models
    x = min_window_size:1:num_samples;
    
    fig = figure; 
    if debug_mode
        set(fig,'Visible', 'on');
    else
        set(fig,'Visible', 'off');
    end
    
    plot(x, plotted_values(min_window_size:end,:));
    title(graph_file_name)
    % title()
    h = legend(models(:).name, numModels);
    set(h,'Interpreter','none');
    print(fig, graph_file_name, '-deps');
    print(fig, graph_file_name, '-dpng');
end
