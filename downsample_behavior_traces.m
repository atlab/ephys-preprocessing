function downsample_behavior_traces(inFile, outFile, varargin)
% Downsample a behavioral data set
%
% JC 2011-08-14

params.channels = ':';
params.outputRate = 200;
params.stopBand = [130 160];
params.Fs = 400;
for i=1:2:length(varargin)
    params.(varargin{i}) = varargin{i+1};
end

assert(length(params.stopBand) == 2, 'Bad filter settings');
assert(params.Fs > 2 * params.stopBand(2), 'Not storing at nyquist');

% Load data
sourceFilename = getLocalPath(inFile);
if iscell(params.channels)
	br = baseReader(sourceFilename,params.channels);
else
	br = baseReader(sourceFilename);
end

samplingRate = getSamplingRate(br);
assert(samplingRate > params.Fs, 'Sampling rate of file should be faster than output rate');

if ischar(params.channels) && params.channels == ':'
	params.channels = 1:size(br,2);
end

% Build up filtered reader
wf = filterFactory.createLowpass(params.stopBand(1),params.stopBand(2),samplingRate);
fr = filteredReader(br, wf);

outPath = fileParts(outFile);
assert(exist(getLocalPath(outPath),'dir') ~= 0, 'The output directory should exist since it is a stimulation directory');

fp = H5Tools.createFile(getLocalPath(outFile), 'driver', 'family');

% Limit memory usage
downsampling = round(samplingRate / params.Fs);
targetSize = 100 * 2.^20;       % 100 MB chunks
blockSize = ceil(targetSize / 10 / length(params.channels));
blockSize = blockSize - mod(blockSize,downsampling);

pr = packetReader(fr, 1, 'stride', blockSize);
for p=1:length(pr)

    prpack = pr(p);
    packet = prpack(1:downsampling:end,params.channels);

    if (p==1)
        [dataSet, written] = seedDataset(fp, packet);
    else
        written = written + extendDataset(dataSet, packet, written);
    end
    fprintf('.')
end
H5D.close(dataSet);

chNames = getfield(struct(br),'chNames');
close(br);


chNames = cellfun(@(x) [x ','], chNames, 'UniformOutput', false);
chNames = cat(2,chNames{:})'; chNames(end) = [];

% Determine attributes to write
inFp = H5Tools.openFamily(getLocalPath(inFile));
scale = H5Tools.readAttribute(inFp,'scale');
class = char('BehaviorData')'; % hard code because this is the format we are writing
Version = 1;
t0 = fr(1,'t');
Fs = samplingRate / downsampling;
H5F.close(inFp)

% Now create/copy the remaining attributes etc.
rootDest = H5G.open(fp, '/');
H5Tools.writeAttribute(rootDest, 'Fs', Fs);
H5Tools.writeAttribute(rootDest, 'Version', Version);
H5Tools.writeAttribute(rootDest, 'class', class);
H5Tools.writeAttribute(rootDest, 'channelNames', chNames);
H5Tools.writeAttribute(rootDest, 'scale', scale);
H5Tools.writeAttribute(rootDest, 't0', t0);
H5G.close(rootDest);

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

