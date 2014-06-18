function varargout = extractPath

p = { ...
    getLocalPath('/lab/libraries/matlab'), ...
    getLocalPath('/lab/users/alex/projects/lfp'), ...
    getLocalPath('/lab/users/alex/projects/hdf5matlab'), ...
    getLocalPath('/lab/users/alex/projects/hdf5matlab/raw'), ...
    getLocalPath('/lab/users/alex/projects/acqusition'), ...
    getLocalPath('/lab/users/alex/projects/acqusition/processing'), ...
    getLocalPath('/lab/users/alex/projects/acqusition/processing/sync'), ...
    getLocalPath('/lab/users/alex/projects/acqusition/processing/utils'), ...
    getLocalPath('/lab/users/alex/projects/acqusition/schemas'), ...
    getLocalPath('/lab/libraries/mym'), ...
};

if nargout
    varargout{1} = p;
else
    for folder = p
        addpath(folder)
    end
end
