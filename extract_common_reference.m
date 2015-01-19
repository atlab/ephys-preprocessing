function extract_common_reference(inPath, varargin)
% extract common reference value from
% inPath - file pattern for raw data e.g. 'Electrophysiology%d.h5'

params.channels = 1:96;
for i=1:2:length(varargin)
    params.(varargin{i}) = varargin{i+1};
end

% Load data: behavior depends on the type of source file (namely those from
% Hammer without any file extension and those from newer system ending in
% .h5
if ~isempty(strfind(inPath, '%u.h5')) || ~isempty(strfind(inPath, '%d.h5'))
    sourceFilename = getLocalPath(inPath);
    br = baseReader(sourceFilename);
    tetNames = getfield(struct(br),'chNames');
    gain = getfield(struct(br),'scale');
    ver = 1;
else % handling for Hammer
    sourceFilename = fullfile(getLocalPath(inPath), 'neuro%d');
    
    % Get params from file
    fpSource = H5Tools.openFamily(sourceFilename);
    rootSource = H5G.open(fpSource, '/');
    ver = H5Tools.readAttribute(rootSource, 'version');
    gain = H5Tools.readAttribute(rootSource, 'gain');
    H5G.close(rootSource);
    H5F.close(fpSource);

    br = baseReader(sourceFilename); % this will create baseReaderHammer
    
    tets = getRecordedTetrodes(br);
    tetNames = cell(length(tets), 1);
    for t=1:length(tets)
        tetNames{t} = sprintf('t%uc1', tets(t));
    end
end


samplingRate = getSamplingRate(br);

fp = H5Tools.createFile( fullfile(getLocalPath(fileparts(inPath)), 'ref%d'), 'driver', 'family' );

% Limit memory usage
targetSize = 100 * 2.^20;       % 100 MB chunks
blockSize = ceil(targetSize / 10 / length(params.channels));

pr = packetReader(br, 1, 'stride', blockSize);
for p=1:length(pr)

    prpack = pr(p);
    packet = mean(prpack(:,params.channels),2);

    if (p==1)
        [dataSet, written] = seedDataset(fp, packet); % 'written' keeps track of size of written data
    else
        written = written + extendDataset(dataSet, packet, written);
    end
    
    fprintf('.');
    if  mod(p,round((length(pr) / 20))) == 0
        disp([' Common reference Extraction: ' num2str(round(p * 100 / length(pr))) '%']);
    end
end

H5D.close(dataSet);
close(br)

% Now create/copy the remaining attributes etc.
rootDest = H5G.open(fp, '/');
H5Tools.writeAttribute(rootDest, 'version', ver);
H5Tools.writeAttribute(rootDest, 'actual sample rate', samplingRate);
H5Tools.writeAttribute(rootDest, 'sample rate', samplingRate);
H5Tools.writeAttribute(rootDest, 'gain', gain);

H5G.close(rootDest);

tetNames = char(tetNames);
tempNames = zeros(81, size(tetNames,1), 'uint16');
tempNames(1:size(tetNames, 2), :) = uint16(tetNames');
tempNames(tempNames == ' ') = 0;
tempNames = char(tempNames);
H5Tools.writeDataset(fp, '/channel names', tempNames);

H5F.close(fp);

function [dataSet, written] = seedDataset(fp, data)

nbDims = 2;
dataDims = size(data);
dataDims(1:2) = dataDims([2 1]);
dataType = H5Tools.getHDF5Type(data);
dataSpace = H5S.create_simple(nbDims, dataDims, [dataDims(1) -1]);

setProps = H5P.create('H5P_DATASET_CREATE'); % create property list
chunkSize = [4, 100000]; 		% define chunk size
chunkSize = min(chunkSize, dataDims);
H5P.set_chunk(setProps, chunkSize); % set chunk size in property list

dataSet = H5D.create(fp, '/data', dataType, dataSpace, setProps);
H5D.write(dataSet, 'H5ML_DEFAULT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', data);

H5P.close(setProps);
H5T.close(dataType);
H5S.close(dataSpace);
written = size(data, 1);


function written = extendDataset(dataSet, data, written)

% Extend dataset
H5D.extend(dataSet, [size(data,2), written+size(data,1)])

% Select appended part of the dataset
fileSpace = H5D.get_space(dataSet);
H5S.select_hyperslab(fileSpace, 'H5S_SELECT_SET', [0, written], [], fliplr(size(data)), []);

% Create a memory dataspace of equal size.
memSpace = H5S.create_simple(2, fliplr(size(data)), []);

% And write the data
% [s f] = H5S.get_select_bounds(fileSpace);
%disp(s), disp(f)
% [s f] = H5S.get_select_bounds(memSpace);
%disp(s), disp(f)
H5D.write(dataSet, 'H5ML_DEFAULT', memSpace, fileSpace, 'H5P_DEFAULT', data);

% Clean up
H5S.close(memSpace);
H5S.close(fileSpace);
written = size(data,1);

