addpath(getLocalPath('/lab/libraries/detection'))
addpath(getLocalPath('/lab/libraries/clustering_lib'))

base = fileparts(mfilename('fullpath'));
addpath(fullfile(base,''))
addpath(fullfile(base,'alignment'))
addpath(fullfile(base,'detection'))
addpath(fullfile(base,'threshold'))
addpath(fullfile(base,'extraction'))
addpath(fullfile(base,'signals'))
clear base
