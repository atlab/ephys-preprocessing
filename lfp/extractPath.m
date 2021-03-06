function varargout = extractPath

p = { ...
    getLocalPath('/lab/libraries/matlab'), ...
    getLocalPath('/lab/users/alex/projects/lfp'), ...
    getLocalPath('/lab/users/alex/projects/hdf5matlab'), ...
    getLocalPath('/lab/users/alex/projects/hdf5matlab/raw'), ...
};

if nargout
    varargout{1} = p;
else
    for folder = p
        addpath(folder)
    end
end
