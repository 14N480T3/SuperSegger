function [clist] = trackOptiClistNew(dirname,CONST,header)
% trackOptiClist : generates an array called the clist
% which contains non time dependent information for each cell.
% Fluorescence values contained are for at birth time.
% To see the information contained type clist.def'.
%
% INPUT :
%       dirname : seg folder eg. maindirectory/xy1/seg
%       CONST : segmentation constants
%       header : string displayed with information
% OUTPUT :
%       clist : array with the above info for each cell in the frame
%
% Copyright (C) 2016 Wiggins Lab
% Written by Paul Wiggins.
% University of Washington, 2016
% This file is part of SuperSegger.
%
% SuperSegger is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% SuperSegger is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with SuperSegger.  If not, see <http://www.gnu.org/licenses/>.

if ~exist('header','var')
    header = [];
end

if(nargin<1 || isempty(dirname))
    dirname = '.';
end
dirname = fixDir(dirname);

% Get the track file names...
contents=dir([dirname '*_err.mat']);

if isempty( contents )
    clist.data = [];
    clist.def={};
    clist.gate=[];
else
    data_c = loaderInternal([dirname,contents(end).name]);
    MAX_CELL = max(10000, max(data_c.regs.ID) + 100);
    num_im = numel(contents);
    
    if CONST.parallel.show_status
        h = waitbar( 0, 'Making Cells.');
        cleanup = onCleanup( @()( delete( h ) ) );
    else
        h = [];
    end
    
    clist = [];
    setter = clistSetter ();
    clist.def = setter(:,1)';
    tmpFields = setter(:,2)';
    death_ind = find([setter{:,3}]); % death fields : updated in every frame 
    clist_tmp = nan( MAX_CELL, numel( clist.def));
    clist_tmp(:,1) = 0;
    
    
    % calculating indexes of values used during calculations
    lengthFields = find(strcmp(tmpFields,'data_c.regs.L1'));
    index_lold = intersect(lengthFields,death_ind);
    index_lbirth = setdiff(lengthFields,death_ind);
    index_ID= find(strcmp(tmpFields,'ID'));
    index_dlmaxOld = find(strcmp(tmpFields,'dlmax'));
    index_dlminOld = find(strcmp(tmpFields,'dlmin'));
    
    % loop through all the images (*err.mat files)
    for i = 1:num_im
        
        data_c = loaderInternal([dirname,contents(i).name]);
        
        % record the number of cell neighbors
        if CONST.trackOpti.NEIGHBOR_FLAG && ...
                ~isfield( data_c.CellA{1}, 'numNeighbors' )
            for ii = 1:data_c.regs.num_regs
                nei_ = numel(trackOptiNeighbors(data_c,ii));
                data_c.CellA{ii}.numNeighbors = nei_ ;
            end
        end
        
        
        % figure out which cells are new born.
        maxID = max(clist_tmp(:,index_ID));
        ID = data_c.regs.ID;
        birthID = (ID>maxID);
        ci = and( ~birthID, logical(ID));
        
        IDnz = ID(ID>0);
        IDlog = ID>0;
   
        lold     = nan(1,numel(ID));
        lbirth   = nan(1,numel(ID));
        dlmaxOld = nan(1,numel(ID));
        dlminOld = nan(1,numel(ID));
        
        lold(IDlog) = clist_tmp(IDnz,index_lold);
        lbirth(IDlog) = clist_tmp(IDnz,index_lbirth);
        dlmaxOld(IDlog) = clist_tmp(IDnz,index_dlmaxOld);
        dlminOld(IDlog) = clist_tmp(IDnz,index_dlminOld);
        
        regnum = (1:data_c.regs.num_regs)';
        zz = zeros( data_c.regs.num_regs, 1);
        
        cell_dist = drill(data_c.CellA,'.cell_dist');
        pole_age  = drill(data_c.CellA,'.pole.op_age');
        fl1sum = drill(data_c.CellA,'.fl1.sum');
        fl2sum  = drill(data_c.CellA,'.fl2.sum');
        Area = drill(data_c.CellA,'.coord.A');
        xpos = drill(data_c.CellA,'.coord.rcm(1)');
        ypos = drill(data_c.CellA,'.coord.rcm(2)');
        numNeighbors = drill(data_c.CellA,'.numNeighbors');
        gray = drill(data_c.CellA,'.gray');
        
        locus1_L1 = drill(data_c.CellA, '.locus1(1).longaxis');
        locus1_L2 = drill(data_c.CellA, '.locus1(1).shortaxis');
        locus1_s = drill(data_c.CellA, '.locus1(1).score');
        locus1_i = drill(data_c.CellA, '.locus1(1).intensity');
        
        locus2_L1 = drill(data_c.CellA, '.locus1(2).longaxis');
        locus2_L2 = drill(data_c.CellA, '.locus1(2).shortaxis');
        locus2_s = drill(data_c.CellA, '.locus1(2).score');
        locus2_i = drill(data_c.CellA, '.locus1(2).intensity');
        
        locus3_L1 = drill(data_c.CellA, '.locus1(3).longaxis');
        locus3_L2 = drill(data_c.CellA, '.locus1(3).shortaxis');
        locus3_s = drill(data_c.CellA, '.locus1(3).score');
        locus3_i = drill(data_c.CellA, '.locus1(3).intensity');
        
        locus4_L1 = drill(data_c.CellA, '.locus1(4).longaxis');
        locus4_L2 = drill(data_c.CellA, '.locus1(4).shortaxis');
        locus4_s = drill(data_c.CellA, '.locus1(4).score');
        locus4_i = drill(data_c.CellA, '.locus1(4).intensity');
        
        locus5_L1 = drill(data_c.CellA, '.locus1(5).longaxis');
        locus5_L2 = drill(data_c.CellA, '.locus1(5).shortaxis');
        locus5_s = drill(data_c.CellA, '.locus1(5).score');
        locus5_i = drill(data_c.CellA, '.locus1(5).intensity');
        
        daughter1_id = drill(data_c.regs.daughterID,'(1)');
        daughter2_id = drill(data_c.regs.daughterID,'(2)');
        
        length1 = drill(data_c.CellA,'.length(1)');
        length2 = drill(data_c.CellA,'.length(2)');
        
        locus1_relL1 = (locus1_L1)./length1;
        locus2_relL1 = (locus2_L1)./length1;
        locus3_relL1 = (locus3_L1)./length1;
        locus4_relL1 = (locus4_L1)./length1;
        locus5_relL1 = (locus5_L1)./length1;
        
        locus1_relL2 = (locus1_L2)./length2;
        locus2_relL2 = (locus2_L2)./length2;
        locus3_relL2 = (locus3_L2)./length2;
        locus4_relL2 = (locus4_L2)./length2;
        locus5_relL2 = (locus5_L2)./length2;
        op_ori =  drill(data_c.CellA, '.pole.op_ori');
        
        locus1_PoleAlign_L1 = locus1_L1 .* op_ori;
        locus1_PoleAlign_L1 (op_ori ==0) = nan;
 
        locus1_PoleAlign_relL1 = locus1_relL1 .* op_ori;
        locus1_PoleAlign_relL1 (op_ori==0) = nan;
 
        
        locus1_fitSigma  = drill(data_c.CellA,'.locus1(1).fitSigma');
        locus2_fitSigma  = drill(data_c.CellA,'.locus1(2).fitSigma');
        locus3_fitSigma   = drill(data_c.CellA,'.locus1(3).fitSigma');
        
        if CONST.trackOpti.LYSE_FLAG
            errorColor1Cum = data_c.regs.lyse.errorColor1Cum;
            errorColor2Cum = data_c.regs.lyse.errorColor2Cum;
            errorShapeCum  = data_c.regs.lyse.errorShapeCum;
            errorColor1bCum = data_c.regs.lyse.errorColor1bCum;
            errorColor2bCum = data_c.regs.lyse.errorColor2bCum;
        else
            errorColor1Cum  = nan(size(ID));
            errorColor2Cum  = nan(size(ID));
            errorShapeCum   = nan(size(ID));
            errorColor1bCum = nan(size(ID));
            errorColor2bCum = nan(size(ID));
        end
        
        
        lnew = data_c.regs.L1;
        dl = (lnew-lold);
        dlmin = nan(size(dl));
        dlmax = nan(size(dl));
        
        indTmp = isnan(dlminOld);
        dlmin( indTmp ) = dl( indTmp);
        
        indTmp = isnan(dlmaxOld);
        dlmax( indTmp ) = dl( indTmp);
        
        indTmp = isnan(dl);
        dlmin( indTmp ) = dlminOld( indTmp);
        dlmax( indTmp ) = dlmaxOld( indTmp);
        
        indTmp = ~isnan(dl+dlminOld);
        dlmin( indTmp ) = min( [dl( indTmp);dlminOld( indTmp )]);
        
        indTmp = ~isnan(dl+dlmaxOld);
        dlmax( indTmp ) = max( [dl( indTmp);dlmaxOld( indTmp )]);
        
        lrel = lnew./lbirth;
        
        % putting all fields in tmp
        tmp = nan (numel(ID),numel(tmpFields));
        for u = 1 : numel(tmpFields)
            tmp_var =  eval(tmpFields{u});
            tmp_var = convertToColumn(tmp_var);
            tmp(:,u) = tmp_var;
        end
                  
        % keeping from tmp only the cell that were just born
        try
            clist_tmp(ID(birthID), : ) = tmp(birthID, :);
        catch ME
            printError(ME);
        end
        
        % update guys that you want to set to the death value
        clist_tmp(ID(ci), death_ind ) = tmp(ci, death_ind);
        
        if CONST.parallel.show_status
            waitbar(i/num_im,h,['Clist--Frame: ',num2str(i),'/',num2str(num_im)]);
        elseif CONST.parallel.verbose
            disp([header, 'Clist frame: ',num2str(i),' of ',num2str(num_im)]);
        end
        
        
    end
    
    if CONST.parallel.show_status
        close(h);
    end
    
    % removes cells with 0 cell id
    clist.data = clist_tmp(logical(clist_tmp(:,1)),:);
    clist.gate = CONST.trackLoci.gate;
    clist.neighbor = [];
    
    if CONST.trackOpti.NEIGHBOR_FLAG
        clist.neighbor = trackOptiListNeighbor(dirname,CONST,[]);
    end
end
end


function setter = clistSetter ()
% clistSetter : use this function to add new values to the clist
% the first variable is the description, the second is the variabel to
% which it will be set (needs to be calculated in the first function, and
% the third is 0 if it is set at birth and 1 if it is set at death.

setter = [{'Cell ID'},{'ID'},0;
    {'Region Num Birth'},{'regnum'},0;
    {'Region Num Death'},{'regnum'},1;
    {'Cell Birth Time'},{'i + zz'},0;
    {'Cell Division Time'},{'i + zz'},1;
    {'Cell Age'},{'i - data_c.regs.birth'},1;
    {'Cell Dist to edge'},{'cell_dist'},0;
    {'Old Pole Age'},{'pole_age'},0;
    {'stat0'},{'data_c.regs.stat0'},1;
    {'Long Axis Birth'},{'data_c.regs.L1'},0;
    {'Long Axis Death'},{'data_c.regs.L1'},1;
    {'Short Axis Birth'},{'data_c.regs.L2'},0;
    {'Short Axis Death'},{'data_c.regs.L2'},1;
    {'Area Birth'},{'Area'},0;
    {'Area Death'},{'Area'},1;
    {'Region Score birth'},{'data_c.regs.scoreRaw'},0;
    {'Region Score death'},{'data_c.regs.scoreRaw'},1;
    {'x position birth'},{'xpos'},0;
    {'y position birth'},{'ypos'},0;
    {'fluor1 sum'},{'fl1sum'},0;
    {'fluor1 mean'},{'fl2sum./Area'},0;
    {'fluor2 sum'},{'fl2sum'},0;
    {'fluor2 mean'},{'fl2sum./Area'},0;
    {'Number of neighbors'},{'numNeighbors'},0;
    {'Region gray val'},{'gray'},0;
    {'locus1_1 longaxis'},{'locus1_L1'},0;
    {'locus1_1 shortaxis'},{'locus1_L2'},0;
    {'locus1_1 score'},{'locus1_s'},0;
    {'locus1_1 Intensity'},{'locus1_i'},0;
    {'locus1_2 longaxis'},{'locus2_L1'},0;
    {'locus1_2 shortaxis'},{'locus2_L2'},0;
    {'locus1_2 score'},{'locus2_s'},0;
    {'locus1_2 Intensity'},{'locus2_i'},0;
    {'locus1_2 longaxis'},{'locus3_L1'},0;
    {'locus1_3 shortaxis'},{'locus3_L2'},0;
    {'locus1_3 score'},{'locus3_s'},0;
    {'locus1_3 Intensity'},{'locus3_i'},0;
    {'locus1_4 longaxis'},{'locus4_L1'},0;
    {'locus1_4 shortaxis'},{'locus4_L2'},0;
    {'locus1_4 score'},{'locus4_s'},0;
    {'locus1_4 Intensity'},{'locus4_i'},0;
    {'locus1_5 longaxis'},{'locus5_L1'},0;
    {'locus1_5 shortaxis'},{'locus5_L2'},0;
    {'locus1_5 score'},{'locus5_s'},0;
    {'locus1_5 Intensity'},{'locus5_i'},0;
    {'locus_1_1_longaxis pole_align'},{'locus1_PoleAlign_L1'},0;
    {'locus_1_1_longaxis normalized pole_align'},{'locus1_PoleAlign_relL1'},0;
    {'locus1_1_longaxis normalized'},{'locus1_relL1'},0;
    {'locus1_2_longaxis normalized'},{'locus2_relL1'},0;
    {'locus1_3_longaxis normalized'},{'locus3_relL1'},0;
    {'locus1_4_longaxis normalized'},{'locus4_relL1'},0;
    {'locus1_5_longaxis normalized'},{'locus5_relL1'},0;
    {'locus1_1_shortaxis normalized'},{'locus1_relL2'},0;
    {'locus1_2_shortaxis normalized'},{'locus2_relL2'},0;
    {'locus1_3_shortaxis normalized'},{'locus3_relL2'},0;
    {'locus1_4_shortaxis normalized'},{'locus4_relL2'},0;
    {'locus1_5_shortaxis normalized'},{'locus5_relL2'},0;
    {'locus1_1_gaussianFitWidth'},{'locus1_fitSigma'},0;
    {'locus1_2_gaussianFitWidth'},{'locus2_fitSigma'},0;
    {'locus1_3_gaussianFitWidth'},{'locus3_fitSigma'},0;
    {'mother ID'},{'data_c.regs.motherID'},0;
    {'daughter1 ID'},{'daughter1_id'},1;
    {'daughter2 ID'},{'daughter2_id'},1;
    {'dl max'},{'dlmax'},1;
    {'dl min'},{'dlmin'},1;
    {'l/l_birth'},{'lrel'},1
    ];

% used to add numbers in front of the description
for i = 1 : size(setter,1)
    field_name = setter(i,1);
    nameWithNum = [num2str(i), ' : ', field_name{1}];
    setter(i,1) = {nameWithNum};
end

end


function vector = convertToColumn (vector)
% convertToColumn : converts vector to column vector if row vector
    if size(vector,1) == 1
        vector = vector';
    end
end

function data = loaderInternal( filename )
data = load(filename);
end