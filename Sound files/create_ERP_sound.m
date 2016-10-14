function create_ERP_sound(subid, audiogram)

% This function receives audiogram information and outputs appropriate
% sound files for the SNR-ERP study, Project AE. Sound intensity is
% calculated based on 30 db above PTA db HL converted to db SPL
% 
% Inputs:
%  1. subid = 4-digit Subject ID for SNR and SNR-ERP study. UW site
%             subjects begin with 1
%  2. audiogram = 2x3 array 
%                     ex. [10,20,30;10,20,30]

% Table of Contents:
% 1. Import sound files
% 2. Calculate PTA

% 1. Import sound files

noise65db=audioread('Noise65.wav')
stim65db=audioread('stim65.wav')

% 2. Calculate pure tone average (PTA)

PTA=mean(mean(audiogram,2))
