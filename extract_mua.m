function extract_mua(sourceFile, outFile, varargin)
% here we extract analog MUA (see e.g. kayser et al. 2008)
%   1) filter signal between 1k and 6k
%   2) take absolute value of the signal
%   3) take average value on the four channels
%
% 2010-09-17 PHB

params.lowerFreq = [1000 1050];
params.upperFreq = [6000 6050];	
params.cutoffFreq = 200;
for i=1:2:length(varargin)
    params.(varargin{i}) = varargin{i+1};
end

% Load data
br = baseReader(sourceFile);
samplingRate = getSamplingRate(br);

% Get channel/tetrode mapping
[tets, channels] = getRecordedTetrodes(br);
channels = channels(tets);

% create bandpass filter for filtering data
wf = filterFactory.createBandPass(params.lowerFreq(1),params.lowerFreq(2),...
                    params.upperFreq(1),params.upperFreq(2),samplingRate);

% replace base reader with filtered reader
fr = filteredReader(br,wf);

factors = calcDecimationFactors(samplingRate, params.cutoffFreq);

fp = H5Tools.createFile(outFile, 'driver', 'family');

% Limit memory usage
targetSize = 100 * 2.^20;       % 100 MB chunks
blockSize = ceil( targetSize / 4 / getNbChannels(br) );
blockSize = blockSize + prod(factors) -  mod(blockSize, prod(factors));

pr = packetReader(fr, 1, 'stride', blockSize);
for p=1:length(pr)
    
    % this is not exaclty the most efficient code...
    % packet = pr(p) * avMatrix;

    chansPerTet = cellfun('length', channels);
    cumChans = [0 cumsum(chansPerTet)];
    prpack = pr(p);
    packet = zeros(size(prpack,1), numel(channels));
    
    % when we extract AMUA, we want to take the average of the
    % absolute value of the signal here
    for i = 1:numel(chansPerTet)
        packet(:,i) = mean(abs(prpack(:,cumChans(i)+(1:chansPerTet(i)))),2);
    end

    for decFactor=factors
        packet = decimatePackage(packet, decFactor);
    end
    if (p==1)
        [dataSet, written] = seedDataset(fp, int32(packet));
    else
        written = written + extendDataset(dataSet, int32(packet), written);
    end
    fprintf('.')
end

H5D.close(dataSet);
close(br)

% Now create/copy the remaining attributes etc.
fpSource = H5Tools.openFamily(sourceFile);
rootSource = H5G.open(fpSource, '/');
rootDest = H5G.open(fp, '/');

ver = H5Tools.readAttribute(rootSource, 'version');
H5Tools.writeAttribute(rootDest, 'version', ver);

H5Tools.writeAttribute(rootDest, 'actual sample rate', samplingRate / prod(factors));
H5Tools.writeAttribute(rootDest, 'sample rate', samplingRate / prod(factors));

gain = H5Tools.readAttribute(rootSource, 'gain');
H5Tools.writeAttribute(rootDest, 'gain', gain);

H5G.close(rootDest);
H5G.close(rootSource);

tetNames = cell(length(tets), 1);
for t=1:length(tets)
    tetNames{t} = sprintf('t%uc1', tets(t));
end
tetNames = char(tetNames);
tempNames = zeros(81, size(tetNames,1), 'uint16');
tempNames(1:size(tetNames, 2), :) = uint16(tetNames');
tempNames(tempNames == ' ') = 0;
tempNames = char(tempNames);
H5Tools.writeDataset(fp, '/channel names', tempNames);

H5F.close(fpSource);
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
H5D.write(dataSet, 'H5ML_DEFAULT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', -data);

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
H5D.write(dataSet, 'H5ML_DEFAULT', memSpace, fileSpace, 'H5P_DEFAULT', -data);

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
    [foo ix] = min(rems);
    decFactors = [decFactors, testFactors(ix)]; %#ok<AGROW>
    coeff = coeff / testFactors(ix);
end

coeff = floor(coeff);
if (coeff >= 2)
    decFactors = [decFactors, coeff];
end


function out = decimatePackage(data, factor)


[m,n] = size(data);
m = fix(m / factor) * factor;
if m<size(data,1), disp('last package'),end
out = zeros(m/factor,n);
for col = 1:n
    out(:,col) = decimate(data(1:m,col), factor);
end


% temp = decimate(data(:,1), factor);
% out = zeros(length(temp), size(data,2));
% out(:,1) = temp;
% clear temp
% 
% for col=2:size(data,2)
%     out(:,col) = decimate(data(:,col), factor);
% end


% function avMatrix = createAveragingMatrix(channels)
%
% chansPerTet = cellfun('length', channels);
% cumChans = [0 cumsum(chansPerTet)];
%
% avMatrix = zeros(sum(chansPerTet), length(channels));
% for t=1:length(channels)
%     avMatrix(cumChans(t) + (1:chansPerTet(t)), t) = 1 / chansPerTet(t);
% end
