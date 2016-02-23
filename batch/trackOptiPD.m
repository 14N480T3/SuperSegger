function trackOptiPD(dirname, CONST)
% trackOptiPD Sets up directory structure for cell segmentation
% analysis for the SuperSeggerOpti package and moves
% aligned images to their respective folders.
%
% Copyright (C) 2016 Wiggins Lab
% University of Washington, 2016
% This file is part of SuperSeggerOpti.

file_filter = '*.tif';



dirseperator = filesep;


if(nargin<1 || isempty(dirname))
    
    dirname=uigetdir()
    dirname=[dirname,dirseperator];
else
    if dirname(length(dirname))~=dirseperator
        dirname=[dirname,dirseperator];
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make and move subdirs
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
contents=dir([dirname file_filter]);


if ~isempty(contents);
    
    num_im = numel(contents);
    
    
    nt  = [];
    nc  = [];
    nxy = [];
    nz  = [];
    
    
    for i = 1:num_im;
        nameInfo = ReadFileName( contents(i).name );
        
        nt  = [nt,  nameInfo.npos(1,1)];
        nc  = [nc,  nameInfo.npos(2,1)];
        nxy = [nxy, nameInfo.npos(3,1)];
        nz  = [nz,  nameInfo.npos(4,1)];
    end
    
    nt  = sort(unique(nt));
    nc  = sort(unique(nc));
    nxy = sort(unique(nxy));
    nz  = sort(unique(nz));
    
    %xyPadSize = floor(log(max(nxy))/log(10))+1;
    %padString = ['%0',num2str(xyPadSize),'d'];
    
    num_xy = numel(nxy);
    num_c  = numel(nc);
    num_z  = numel(nz);
    num_t  = numel(nt);
    
    dirname_list = cell(1,num_xy);
    
    if nxy(1)==-1
        nxy = 1;
    end
    
    if nxy == 0
        xyPadSize = 1;
    else
        xyPadSize = floor(log(max(nxy))/log(10))+1;
    end
    
    padString = ['%0',num2str(xyPadSize),'d'];
    
    for i = 1:num_xy
        
        dirname_list{i} = [dirname,'xy',num2str(nxy(i), padString),dirseperator];
        mkdir( dirname_list{i} );
        mkdir( [dirname_list{i},'phase', dirseperator] );
        mkdir( [dirname_list{i},'seg',   dirseperator] );
        mkdir( [dirname_list{i},'cell',  dirseperator] );
        for j = 2:num_c
            mkdir( [dirname_list{i},'fluor',num2str(j-1),dirseperator] );
        end
    end
    
    if CONST.show_status
        h = waitbar(0, 'Moving Files');
    else
        h = [];
    end
    for i = 1:num_im;
        if CONST.show_status
            waitbar(i/num_im,h);
        end
        nameInfo = ReadFileName( contents(i).name );
        
        it  = nameInfo.npos(1,1);
        ic  = nameInfo.npos(2,1);
        ixy = nameInfo.npos(3,1);
        iz  = nameInfo.npos(4,1);
        
        
        if ixy==-1
            ii = 1;
        else
            ii = find(ixy==nxy);
        end
        
        if ic ==-1
            ic  = 1;
        end
        
        
        if ic == 1
            tmp_target =  [dirname_list{ii},'phase', dirseperator];
        else
            tmp_target =  [dirname_list{ii},'fluor',num2str(ic-1),dirseperator];
        end
        
        tmp_source =   [dirname,contents(i).name];
        
        if ispc
            move_cmd = '!move ';
            tmp_target = [ tmp_target ];
            tmp_source = [ tmp_source ];
            
            try
                movefile( tmp_source, tmp_target ,'f');
            catch
                
                keyboard
                
            end
        else
            move_cmd = '!mv ';
            move_cmd = [move_cmd,tmp_source,' ',tmp_target];
            eval(move_cmd);
        end
        
        
        
    end
    if CONST.show_status
        close(h);
    end
    
end
end