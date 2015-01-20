function sdt = addStep(sdt,step,type,index)
% Add processing step.
%   sdt = addStep(sdt,@fun,'regular') adds the function fun at the end of 
%   the list of regular processing steps.
%
%   sdt = addStep(sdt,@fun,'init',1) adds the function fun as the first 
%   initialization step.
%
% AE 2009-03-27

if nargin < 4
    index = numel(sdt.steps.(type)) + 1;
end

sdt.steps.(type){index} = step;
