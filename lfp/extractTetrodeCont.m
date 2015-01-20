function extractTetrodeCont(reader, fun, cutoff, outFile)
% Extract continuous signal.
%   extractTetrodeCont(reader, fun, cutoff, outFile) extracts a continuous
%   signal from the reader and applies the function fun before appying a
%   lowpass filter with given cutoff.
%   
% AE 2011-10-15

% Load data
br = getBaseReader(reader);
assert(~isa(br, 'baseReaderHammer'), 'This function has not been tested for data recorded by Hammer. Watch out for sign flips and make sure it''s correct before removing this error!')
samplingRate = getSamplingRate(br);
factors = calcDecimationFactors(samplingRate, cutoff);

% Get channel/tetrode mapping
[tets, ~, tetIndices] = getTetrodes(br);
[refs, refIndices] = getRefs(br);
nTet = numel(tets);
nRef = numel(refs);

fp = H5Tools.createFile(outFile, 'driver', 'family');

% Limit memory usage
targetSize = 100 * 2.^20;                              % 100 MB chunks
blockSize = ceil(targetSize / 4 / getNbChannels(br));  % 4 bytes per sample
blockSize = blockSize + prod(factors) - mod(blockSize, prod(factors));

pr = packetReader(reader, 1, 'stride', blockSize);
for p = 1:length(pr)
    
    % read raw data (convert to muV)
    raw = pr(p);
    raw = toMuV(pr, raw);
    
    % average tetrode channels (refs remain unchanged)
    x = zeros(size(raw, 1), nTet + nRef);
    for i = 1:nTet
        x(:,i) = fun(raw(:,tetIndices{i}));
    end
    for i = 1:nRef
        x(:,nTet+i) = fun(raw(:,refIndices(i)));
    end
    
    % resample
    for decFactor = factors
        x = decimatePackage(x, decFactor);
    end
    
    % write data to disc
    if p == 1
        [dataSet, written] = seedDataset(fp,x);
    else
        written = written + extendDataset(dataSet, x, written);
    end
    
    progress(p, length(pr), 20);
end

H5D.close(dataSet);

% channel names
channelNames = [sprintf('t%d,', tets), sprintf('ref%d,', refs)];

% Now create/copy the remaining attributes etc.
H5Tools.writeAttribute(fp, 'Fs', samplingRate / prod(factors));
H5Tools.writeAttribute(fp, 'channelNames', channelNames(1:end-1));
H5Tools.writeAttribute(fp, 'class', 'Electrophysiology');
H5Tools.writeAttribute(fp, 'version', 1);
H5Tools.writeAttribute(fp, 'scale', 1e-6);  % data are in muV
parent = getParentReader(pr);
% Determine t0. Because of the way decimate works, when decimating by a
% factor of k, the k^th sample in the original trace is equal to the first
% sample in the decimated trace [i.e. y = decimate(x, k) --> y(1) = x(k)]
t0 = parent(prod(factors),'t'); 
H5Tools.writeAttribute(fp, 't0', t0);
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
H5D.write(dataSet, 'H5ML_DEFAULT', memSpace, fileSpace, 'H5P_DEFAULT', data);

% Clean up
H5S.close(memSpace);
H5S.close(fileSpace);
written = size(data,1);



function decFactors = calcDecimationFactors(samplingRate, cutoffFreq)

targetRate = cutoffFreq * 2 / 0.8;		% 0.8 is the cutoff of the Chebyshev filter in decimate()
coeff = samplingRate / targetRate;

if (coeff < 2)
    error('Cannot decimate by %g', coeff)
end

% Calculate a series of decimation factors
decFactors = [];
testFactors = 13:-1:2;
while (coeff > 13)
    rems = mod(coeff, testFactors);
    [~, ix] = min(rems);
    decFactors = [decFactors, testFactors(ix)]; %#ok<AGROW>
    coeff = coeff / testFactors(ix);
end

coeff = floor(coeff);
if (coeff >= 2)
    decFactors = [decFactors, coeff];
end


function out = decimatePackage(data, factor)

[m,n] = size(data);
% crop package at a multiple of decimation factor. this is important
% because otherwise decimate will cause random jitter of up to one sample
m = fix(m / factor) * factor; 
out = zeros(m/factor,n);
for col = 1:n
    out(:,col) = decimate(data(1:m,col), factor);
end
