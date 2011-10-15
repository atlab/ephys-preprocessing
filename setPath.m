if ~exist('baseReaderElectrophysiology', 'file')
    run(getLocalPath('/lab/libraries/hdf5matlab/setPath'))
end

base = fileparts(mfilename('fullpath'));
addpath(fullfile(base,''))
addpath(fullfile(base,'alignment'))
addpath(fullfile(base,'detection'))
addpath(fullfile(base,'threshold'))
addpath(fullfile(base,'extraction'))
addpath(fullfile(base,'signals'))
clear base
