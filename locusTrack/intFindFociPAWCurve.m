function [ data ] = intFindFociPAWCurve( data, CONST, numc )
% intFindFociPAWCurve: finds the foci and assigns them to the cells.
% It fits the cytoplasmic fluorescence to cell by cell.
% The result of the global cytofluorescence model is added to the field
% cyto[numc] in data, where [numc] is number of the channel. 
%
% INPUT : 
%       data : cell/regions file (err file)
%       CONST : segmentation constants
%       numc : channel number
% OUTPUT : 
%       data : updated data with cytoplasmic fluorescence model
%
% Copyright (C) 2016 Wiggins Lab
% University of Washington, 2016
% This file is part of SuperSeggerOpti.

debug_flag = false;
fieldname = ['locus',num2str(numc)];

% Get images out of the structures.
image0 = double(data.(['fluor',num2str(numc)]));

% Subtract the background 
hg = fspecial( 'gaussian' ,210,30 );
image = image0 - imfilter( image0, hg, 'replicate' );
image_ = image;

istd = std(double(image(:)));
dI0 = std( double(image(data.mask_bg)) ); 
image_med = medfilt2( image, [3,3], 'symmetric' );

if debug_flag
    figure(1);
    clf;
    imshow( image_med, [] );
    hold on;
end


[~,~,images] = curveFilter( image0 );
data.(['flour',num2str(numc),'_filtered']) = images;
im_rel = images/dI0;

rad = 3;
A   = pi*rad^2;
hd = fspecial( 'disk' , rad)*A;
imaged = imfilter( image, hd, 'replicate' );

mask_mod = bwmorph( data.mask_bg, 'dilate', 1 );

tmp = im_rel-1;
tmp( tmp<0 ) = 0;
L = watershed( -tmp );
Lp = logical(double(L).*double(mask_mod));

fr_label = bwlabel( Lp );
props    = regionprops( fr_label, {'BoundingBox'} );
num_regs = numel( props );
imsize = size( image );

focus0.r               = [nan,nan];
focus0.score           = nan;
focus0.intensity_score = nan;
focus0.intensity       = nan;
focus0.b               = 1;
focus0.error           = nan;
focus0.shortaxis       = nan;
focus0.longaxis        = nan;

% Loop through the regions and fit loci in each one
max_med_ii  = nan( [1,num_regs] );
max_disk_ii = nan( [1,num_regs] );
x_ii        = nan( [1,num_regs] );
y_ii        = nan( [1,num_regs] );
cell_ii     = nan( [1,num_regs] );

for ii = 1:num_regs

    [xx,yy] = getBBpad( props(ii).BoundingBox, imsize, 3 );
    [XX_ii,YY_ii] = meshgrid(xx,yy);
    
    ims_ii  = images(yy,xx);
    imd_ii  = imaged(yy,xx);
    
    mask_ii = (fr_label(yy,xx)==ii);
    
    [max_med_ii(ii), ind] = max(  ims_ii(mask_ii) );
    
    tmp = ims_ii(mask_ii);
    max_disk_ii(ii) = tmp(ind);
   
    tmp = XX_ii(mask_ii);
    x_ii(ii) = tmp(ind);
   
    tmp = YY_ii(mask_ii);
    y_ii(ii) = tmp(ind);
   
    x_ = x_ii(ii);
    y_ = y_ii(ii);

    % figure out which cell the foci belongs to
    ss_dist = [numel(yy),numel(xx)];

    cells_label = data.regs.regs_label(yy,xx);
    cells_mask = logical(cells_label);
    mask_tmp = zeros( ss_dist );
    
    mask_tmp( y_-yy(1)+1, x_-xx(1)+1 ) = 1;
    dist_tmp = bwdist( mask_tmp );

    list = cells_label(cells_mask);
    [~,ind_min] = min( dist_tmp(cells_mask) );
    cell_num = list(ind_min);

    % Add the focus to the right cell
    if ~isempty( cell_num )
        cell_ii(ii) = cell_num;
        
        if debug_flag
           plot( x_, y_, '.r' );
           text( x_, y_, num2str( max_disk_ii(ii), '%1.2g' ));
        end
    end
        
end


% assign to cells
for ii = 1:data.regs.num_regs

    list_ind = find(cell_ii == ii);
    
    max_med_ii_  = max_med_ii(list_ind);
    max_disk_ii_ = max_disk_ii(list_ind);
    x_ii_        = x_ii(list_ind);
    y_ii_        = y_ii(list_ind);
    cell_ii_     = cell_ii(list_ind);
    
    [max_disk_ii__,ord] = sort( max_disk_ii_, 'descend' );
    max_med_ii__        = max_med_ii_(ord);
    x_ii__              = x_ii_(ord);
    y_ii__              = y_ii_(ord);
    
    ind = find(max_disk_ii__ > 0.333*max_disk_ii__);
    if numel(ind) > CONST.trackLoci.numSpots(numc)
        ind = ind(1:CONST.trackLoci.numSpots(numc));
    end
    
    nfocus = numel(ind);
    max_disk_ii__ = max_disk_ii__(ind);
    max_med_ii__  = max_med_ii__(ind);
    x_ii__        = x_ii__(ind);
    y_ii__        = y_ii__(ind);
    
    % make the mask with subtracted fluorecence
    mask = data.CellA{ii}.mask;
    xx   = data.CellA{ii}.xx; 
    yy   = data.CellA{ii}.yy; 

    mask_mod = zeros( size( mask) );

    for jj = 1:nfocus        
        yp = y_ii__(jj)+1-yy(1);
        xp = x_ii__(jj)+1-xx(1);

        if (xp>0) && (xp<numel(xx)+1) && (yp>0) && (yp<numel(yy)+1)
            mask_mod(yp, xp) = 1;
        end
    end
    
    mask_mod = imfilter( mask_mod, hd, 'replicate' );
    mask_mod = (mask_mod>0.5);
    
    mask_ii = and(mask,~mask_mod);
    im_ii = image_(yy,xx);
    
    Imean   = mean(im_ii(mask_ii));
    Istd    = std(im_ii(mask_ii));
    Istd_B  = std(im_ii(mask));
   
    focus = focus0;

    for jj = 1:nfocus
        Iten = max_disk_ii__(jj);

        score = Iten/(Istd_B);
        focus(jj).r               = [x_ii__(jj),y_ii__(jj)];
        focus(jj).score           = score;
        focus(jj).intensity_score = Iten;
        focus(jj).intensity       = Iten;
        focus(jj).b               = 1;
        focus(jj).error           = nan;
        
        focus(jj).shortaxis = ...
            (focus(jj).r-data.CellA{ii}.coord.rcm)*data.CellA{ii}.coord.e2;
        focus(jj).longaxis = ...
            (focus(jj).r-data.CellA{ii}.coord.rcm)*data.CellA{ii}.coord.e1;
    end

    sc = [focus(:).score];
    focus = focus( ~isnan(sc) );   
    data.CellA{ii}.fieldname = focus;
    xx = data.CellA{ii}.xx;
    yy = data.CellA{ii}.yy;
    data.CellA{ii}.(['fluor',num2str(numc),'_filtered'])=images( yy, xx );
end


end