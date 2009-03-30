function ndx = getStartIndex(sdt)
% Get index of first sample.
%   ndx = getStartIndex(sdt)
%
% AE 2009-02-25

ndx = getParams(sdt,'istart');
if isempty(ndx)
    t = getParams(sdt,'tstart');
    if ~isempty(t)
        ndx = getSampleIndex(sdt.filtered,t);
    else
        ndx = 1;
    end
end
