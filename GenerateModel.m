function [gr_points, gr_sigma, b_points, b_sigma] = GenerateModel( training_data, numSamples )
%GENERATEMODEL Generate gravity and body model for a activity
%
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
%
% GenerateModel assumes the trials provided in [x_set, y_set, z_set,
% numSamples] to be the modelling dataset of a Human Motion Primitive (HMP)
% and returns the model of the HMP computed by executing Gaussian Mixture
% Modelling (GMM) and Gaussian Mixture Regression (GMR) over the modelling
% dataset. The model is defined by the expected curve and associated set of
% covariance matrices of the features extracted from the trials.
%
% Actually considered features are:
% - 4D gravity (time (as a step index), gravity components on the 3 axes)
% - 4D body acceleration (time (as a step index), body acc. components on
%                           the 3 axes)
%
% Input:
%   training_data -->  the training data set for the respective hand
%   numSamples --> size of acceleration vectors
% 
% Output:
%   gr_points --> expected curve of the gravity feature
%   gr_sigma --> associated covariance matrices
%   b_points --> expected curve of the body acc. feature
%   b_sigma --> associated covariance matrices
%
% Example:
% validation_set_index = 1;
% [train_processed_data, val_processed_data] = SeparateTrainValidationSets(k_sets, validation_set_index);
% hand_index=1;
% [model_gP, model_gS, model_bP, model_bS] = GenerateModel(train_processed_data.left, numSamples);

%Extracting accelerations in respective co-ordinate axes
x_set = training_data.x;
y_set = training_data.y;
z_set = training_data.z;

% SEPARATE THE GRAVITY AND BODY-MOTION ACCELERATION COMPONENTS...
% ... AND CREATE THE DATASETS FOR GM-MODELING
[gravity, body] = CreateDatasets(numSamples,x_set,y_set,z_set,0);

% COMPUTE THE EXPECTED CURVE FOR EACH DATASET (GMM+GMR)
% 1) determine the number of Gaussians to be used in the GMM
K_gravity = TuneK(gravity);
K_body = TuneK(body);
% 2) define the number of points to be used in GMR
%    (current settings allow for CONSTANT SPACING only)
numPoints = max(gravity(1,:));
scaling_factor = 10/10;
numGMRPoints = ceil(numPoints*scaling_factor);
% 3) perform Gaussian Mixture Modelling and Regression to retrieve the
%    expected curve and associated covariance matrices for each feature
[gr_points, gr_sigma] = GetExpected(gravity, K_gravity, numGMRPoints,0);
[b_points, b_sigma] = GetExpected(body, K_body, numGMRPoints,0);

% DISPLAY THE RESULTS
% display the GMR results for the GRAVITY and BODY ACC. features projected
% over 3 2D domains (time + mono-axial acceleration)
darkcolor = [0.8 0 0];
lightcolor = [1 0.7 0.7];
figure,
    % gravity
    % time and gravity acceleration along x
    subplot(3,2,1);
    for i=1:1:numGMRPoints
        sigma = sqrtm(3.*gr_sigma(:,:,i));
        maximum(i) = gr_points(2,i) + sigma(1,1);
        minimum(i) = gr_points(2,i) - sigma(1,1);
    end
    patch([gr_points(1,1:end) gr_points(1,end:-1:1)], [maximum(1:end) minimum(end:-1:1)], lightcolor);
    hold on;
    plot(gr_points(1,:),gr_points(2,:),'-','linewidth',3,'color',darkcolor);
    axis([min(gravity(1,:)) max(gravity(1,:)) min(gravity(2,:)) max(gravity(2,:))]);
    title ('gravity - x axis');
    % time and gravity acceleration along y
    subplot(3,2,3);
    for i=1:1:numGMRPoints
        sigma = sqrtm(3.*gr_sigma(:,:,i));
        maximum(i) = gr_points(3,i) + sigma(2,2);
        minimum(i) = gr_points(3,i) - sigma(2,2);
    end
    patch([gr_points(1,1:end) gr_points(1,end:-1:1)], [maximum(1:end) minimum(end:-1:1)], lightcolor);
    hold on;
    plot(gr_points(1,:),gr_points(3,:),'-','linewidth',3,'color',darkcolor);
    axis([min(gravity(1,:)) max(gravity(1,:)) min(gravity(3,:)) max(gravity(3,:))]);
    title ('gravity - y axis');
    ylabel('acceleration [m/s^2]');
    % time and gravity acceleration along z
    subplot(3,2,5);
    for i=1:1:numGMRPoints
        sigma = sqrtm(3.*gr_sigma(:,:,i));
        maximum(i) = gr_points(4,i) + sigma(3,3);
        minimum(i) = gr_points(4,i) - sigma(3,3);
    end
    patch([gr_points(1,1:end) gr_points(1,end:-1:1)], [maximum(1:end) minimum(end:-1:1)], lightcolor);
    hold on;
    plot(gr_points(1,:),gr_points(4,:),'-','linewidth',3,'color',darkcolor);
    axis([min(gravity(1,:)) max(gravity(1,:)) min(gravity(4,:)) max(gravity(4,:))]);
    title ('gravity - z axis');
    xlabel('time [samples]');
    % body
    % time and body acc. acceleration along x
    subplot(3,2,2);
    for i=1:1:numGMRPoints
        sigma = sqrtm(3.*b_sigma(:,:,i));
        maximum(i) = b_points(2,i) + sigma(1,1);
        minimum(i) = b_points(2,i) - sigma(1,1);
    end
    patch([b_points(1,1:end) b_points(1,end:-1:1)], [maximum(1:end) minimum(end:-1:1)], lightcolor);
    hold on;
    plot(b_points(1,:),b_points(2,:),'-','linewidth',3,'color',darkcolor);
    axis([min(body(1,:)) max(body(1,:)) min(body(2,:)) max(body(2,:))]);
    title ('body - x axis');
    % time and body acc. acceleration along y
    subplot(3,2,4);
    for i=1:1:numGMRPoints
        sigma = sqrtm(3.*b_sigma(:,:,i));
        maximum(i) = b_points(3,i) + sigma(2,2);
        minimum(i) = b_points(3,i) - sigma(2,2);
    end
    patch([b_points(1,1:end) b_points(1,end:-1:1)], [maximum(1:end) minimum(end:-1:1)], lightcolor);
    hold on;
    plot(b_points(1,:),b_points(3,:),'-','linewidth',3,'color',darkcolor);
    axis([min(body(1,:)) max(body(1,:)) min(body(3,:)) max(body(3,:))]);
    title ('body - y axis');
    % time and body acc. acceleration along z
    subplot(3,2,6);
    for i=1:1:numGMRPoints
        sigma = sqrtm(3.*b_sigma(:,:,i));
        maximum(i) = b_points(4,i) + sigma(3,3);
        minimum(i) = b_points(4,i) - sigma(3,3);
    end
    patch([b_points(1,1:end) b_points(1,end:-1:1)], [maximum(1:end) minimum(end:-1:1)], lightcolor);
    hold on;
    plot(b_points(1,:),b_points(4,:),'-','linewidth',3,'color',darkcolor);
    axis([min(body(1,:)) max(body(1,:)) min(body(4,:)) max(body(4,:))]);
    title ('body - z axis');
    xlabel('time [samples]');