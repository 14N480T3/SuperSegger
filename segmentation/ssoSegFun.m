function [data, err_flag] = ssoSegFun( phase, CONST, header, dataname, crop_box, verbose)
% ssoSegFun : starts segmentation of phase image and sets error flags
% It creates the first set of good, bad and permanent segments and if
% CONST.seg.OPTI_FLAG is set to true it optimizes the region sizes.
% 
% INPUT :
%       phase_ : phase image
%       CONST : segmentation constants
%       header : string displayed with infromation
%       dataname : 
%       crop_box : information about alignement of the image
% 
%  OUTPUT :
%       data : contains information about the segments and mask, for more
%       information look at superSeggerOpti.
%       err_flag : set to true if there are more segments than max
%       
% Written by Paul Wiggins and Keith Cheveralls
% Copyright (C) 2016 Wiggins Lab
% University of Washington, 2016
% This file is part of SuperSeggerOpti.

% create the masks and segments
%data = superSeggerOpti( phase ,[], ~CONST.seg.OPTI_FLAG ,CONST, 1, header, crop_box);

if ~exist( 'verbose', 'var' ) || isempty( verbose )
    verbose = 1;
end

data = superSeggerOpti( phase ,[], 1 ,CONST, 1, header, crop_box, verbose);

if numel(data.segs.score) > CONST.superSeggerOpti.MAX_SEG_NUM;
    err_flag = true;
    save([dataname,'_too_many_segs'],'-STRUCT','data');
    disp( [header,'BSSO ',dataname,'_too_many_segs'] );
    return
else
    err_flag = false;    
end

% optimize the regions 
if CONST.seg.OPTI_FLAG
    data = regionOpti( data, 1, CONST,header, verbose);
    drawnow;
end

end

