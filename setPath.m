function setPath

base = fileparts(mfilename('fullpath'));
addpath(fullfile(base, 'spikedetection'))
addpath(fullfile(base, 'spikedetection/alignment'))
addpath(fullfile(base, 'spikedetection/detection'))
addpath(fullfile(base, 'spikedetection/threshold'))
addpath(fullfile(base, 'spikedetection/extraction'))
addpath(fullfile(base, 'spikedetection/signals'))
addpath(fullfile(base, 'lfp'))
addpath(fullfile(base, 'commonref'))
