function wave = getCurrentWaveform(sdt)
% Returns waveform for current chunk of data.
%   wave = getCurrentWaveform(sdt)
%
% AE 2009-03-27

wave = sdt.current.waveform;
