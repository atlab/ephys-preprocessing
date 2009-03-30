function sdt = setFilter(sdt,filter)
% Add filter to process raw broadband voltage signal.
%   sdt = setFilter(sdt,filter) where filter is either a filter object of 
%   type waveFilter or a vector containing the impulse response.
%
% Ae 2009-02-24

if ~(isa(filter,'waveFilter') || isnumeric(filter) && isvector(filter))
    error('Filter needs to be of type waveFilter or a vector containing the impulse response!')
end

sdt.filter = filter;
