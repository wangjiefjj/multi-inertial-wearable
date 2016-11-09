function [window, numWritten] = CreateWindow(data_sample,window,window_size,numWritten)
% function [window numWritten] = CreateWindow(data_sample,window,window_size,numWritten)
%
% -------------------------------------------------------------------------
% Author: Barbara Bruno (dept. DIBRIS, University of Genova, ITALY)
%         Tiago P M da Silva (dept. DIBRIS, University of Genova, ITALY)
%         Divya Haresh Shah (dept. DIBRIS, University of Genova, ITALY)
%         Ernesto Denicia (dept. DIBRIS, University of Genova, ITALY)
%
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
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
%
% CreateWindow adds the accelerometer values of the [data_sample] in the
% sliding [window] of samples and updates the value of the counter
% [numWritten]. Once the window is full, and at each new sample from then
% onwards, the classifier analyzes its content to check whether it
% represents a known HMP.
%
% Input:
%   data_sample --> one sample (tri-axial acceleration) read from the
%                     validation trial
%   window --> sliding window over the validation trial
%   window_size --> size of the window
%   numWritten --> number of sample points in the window
%
% Output:
%   window --> sliding window over the validation trial (UPDATED)
%   numWritten --> number of sample points in the window (UPDATED)
%
% Example:
%   ** this function is part of the code of ValidateWHARF:
%   ** do NOT call it directly!

    % COMPUTE THE ACTUAL WINDOW
    if(numWritten < window_size)
        % window(numWritten+1,:) = data_sample(:);
        numWritten = numWritten+1;
    end
    window = circshift(window,[-1 0]);
    window(window_size,:) = data_sample;
