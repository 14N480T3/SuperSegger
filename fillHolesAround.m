function bw_filled = fillHolesAround(magicPhase)
% fillHolesAround : creates an image of the regions that have halos.
% It blurs the image, then takes things above the cut off intensity, and
% fills the holes in the middle and edges.
% INPUT : 
%       magicPhase : phase image after magic contrast is applied
% OUTPUT : 
%       bw_filled : image with halo-regions filled.
%
% Copyright (C) 2016 Wiggins Lab
% University of Washington, 2016
% This file is part of SuperSeggerOpti.


blurFilter = fspecial( 'gaussian',15, 1 );
phaseFilt = imfilter(magicPhase,blurFilter, 'replicate');

CUT_INT_LOW = 45;
halos = (phaseFilt>CUT_INT_LOW);
halos_filled = imfill(halos,'holes');

bw_a = padarray(halos_filled,[1 1],1,'pre');
bw_a_filled = imfill(bw_a,'holes');
bw_a_filled = bw_a_filled(2:end,2:end);

bw_b = padarray(padarray(halos_filled,[1 0],1,'pre'),[0 1],1,'post');
bw_b_filled = imfill(bw_b,'holes');
bw_b_filled = bw_b_filled(2:end,1:end-1);

bw_c = padarray(halos_filled,[1 1],1,'post');
bw_c_filled = imfill(bw_c,'holes');
bw_c_filled = bw_c_filled(1:end-1,1:end-1);

bw_d = padarray(padarray(halos_filled,[1 0],1,'post'),[0 1],1,'pre');
bw_d_filled = imfill(bw_d,'holes');
bw_d_filled = bw_d_filled(1:end-1,2:end);

bw_filled = bw_a_filled | bw_b_filled | bw_c_filled | bw_d_filled;

end
