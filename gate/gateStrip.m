function [clist] = gateStrip( clist, ind )
% gate : removes the gate field from clist, or the gate for index ind.
%
% INPUT :
%       clist : table of cells with time-independent variables
%       ind : index to be removed from gate, if none given strips the whole gate
%
% OUTPUT :
%       clist : updated clist with stripped gate
%
% Copyright (C) 2016 Wiggins Lab
% University of Washington, 2016
% This file is part of SuperSeggerOpti.

if ~exist('ind','var') || isempty(ind)
    clist.gate = [];
else
   loc = find( cellfun(@(x)isequal(x,ind),{clist.gate.ind}) ); 
   if isempty (loc)
       disp (['index : ', num2str(ind), ' not found in the gate']);
   else
        disp (['removing : ', num2str(ind), ' from gate']);
        clist.gate(loc) = [];
   end
end

end