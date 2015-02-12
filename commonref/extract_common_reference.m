function extract_common_reference(inPath, varargin)
% extract common reference value from
% inPath - file pattern for raw data e.g. 'Electrophysiology%d.h5'
% Hammer handling has not been validated with this code

for i=1:2:length(varargin)
    params.(varargin{i}) = varargin{i+1};
end

% Load data: behavior depends on the type of source file (namely those from
% Hammer without any file extension and those from newer system ending in
% .h5
if ~isempty(strfind(inPath, '%u.h5')) || ~isempty(strfind(inPath, '%d.h5'))
    sourceFilename = getLocalPath(inPath);
    br = baseReader(sourceFilename);
else
    % handling for Hammer
    
    error('extract_common_reference:hammer','Hammer has not been validated since updating this method. Check scales');
    sourceFilename = fullfile(getLocalPath(inPath), 'neuro%d');
    
    % Get params from file
    fpSource = H5Tools.openFamily(sourceFilename);
    rootSource = H5G.open(fpSource, '/');
    H5G.close(rootSource);
    H5F.close(fpSource);

    br = baseReader(sourceFilename); % this will create baseReaderHammer 
    tets = getRecordedTetrodes(br);

end

samplingRate = getSamplingRate(br);

outFile = fullfile(getLocalPath(fileparts(inPath)), 'ref%d.h5');
fp = H5Tools.createFile(outFile, 'driver', 'family');

% Limit memory usage
targetSize = 100 * 2.^20;       % 100 MB chunks
blockSize = ceil(targetSize / 10 / length(params.channels));

% this constant is expected by our data standard
dataset_name = '/data';

pr = packetReader(br, 1, 'stride', blockSize);
for p=1:length(pr)

    prpack = pr(p);
    packet = mean(prpack(:,params.channels),2);
    
    if (p==1)
        % both axes are set to unlimited because if they are singleton
        % the writeDataset method strips out that dimension to "maintain
        % backward compatibility"
        H5Tools.writeDataset(fp, dataset_name, packet, [100000,1], {'H5S_UNLIMITED','H5S_UNLIMITED'});
    else
        H5Tools.appendDataset(fp, dataset_name, packet, 1);
    end
    
    fprintf('.');
    if  mod(p,round((length(pr) / 20))) == 0
        disp([' Common reference Extraction: ' num2str(round(p * 100 / length(pr))) '%']);
    end
end

% Now create/copy the remaining attributes etc.
H5Tools.writeAttribute(fp, 'Fs', samplingRate);
H5Tools.writeAttribute(fp, 'channelNames', 'common_ref');
H5Tools.writeAttribute(fp, 'class', 'Electrophysiology');
H5Tools.writeAttribute(fp, 'version', 1);
H5Tools.writeAttribute(fp, 'scale', 1.0);  % data are in muV from previous read
H5Tools.writeAttribute(fp, 't0', br(1,'t'));
H5F.close(fp);

close(br)

