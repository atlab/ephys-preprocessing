function ndx = getEndIndex(sdt)
% Get index of last sample.
%   ndx = getEndIndex(sdt)
%
% AE 2009-02-25

ndx = getParams(sdt,'iend');
if isempty(ndx)
    t = getParams(sdt,'tend');
    if ~isempty(t)
        ndx = getSampleIndex(sdt.filtered,t);
    else
        ndx = length(sdt.filtered);
    end
end
