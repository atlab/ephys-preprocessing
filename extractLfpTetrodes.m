function extractLfpTetrodes(sourceFile, outFile, varargin)
% Extract LFP for tetrodes.
%   extractLfpTetrodes(sourceFile, outFile) extracts the LFP by taking
%   channel averages for tetrodes and treating references individually. A
%   lowpass filter with a 200 Hz cutoff is applied before downsampling.
%   
% AE 2011-10-15

params.cutoffFreq = 200;
params = parseVarArgs(params, varargin{:});
extractTetrodeCont(baseReader(sourceFile), @(x) mean(x, 2), params.cutoffFreq, outFile);
