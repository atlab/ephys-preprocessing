function extractMuaTetrodes(sourceFile, outFile, varargin)
% Extract analog MUA signal.
%   extractMuaTetrodes(sourceFile, outFile)
%
%   We take the mean square of all four channels for each tetrode before
%   applying lowpass filter with 200 Hz cutoff. Further lowpass filtering
%   and taking the square root is done post-hoc depending on the timescale
%   that one wants to consider. References are treated individually.
%   
% AE 2011-10-15

params.freqBand = [480 600 5800 6000];
params.cutoffFreq = 200;
params = parseVarArgs(params, varargin{:});

% setup filtering
br = baseReader(sourceFile);
freqBand = num2cell(params.freqBand);
filter = filterFactory.createBandPass(freqBand{:}, getSamplingRate(br));
fr = filteredReader(br, filter);

% do mua extraction
extractTetrodeCont(fr, @(x) mean(x.^2, 2), params.cutoffFreq, outFile);
