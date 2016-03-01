function trackOptiViewNew(dirname,file_filter)
% trackOptiView provides visulization of the segmented data.
%
% It has a lot of options such as :
% f : Toggle between phase and fluorescence view
% x# :  Switch xy dir #
% t  : Show Cell Numbers
% r  : Show/Hide Region Outlines
% o  : Show Consensus
% K  : Kymograph Mosaic
% h# : Tower for Cell #
% g  : Make Gate
% Clear : Clear all Gates
% c  : Reset Plot to Default View'
% s  : Show Fluor Foci
% #  : Go to Frame Number #
% CC : Use Complete Cell Cycles
% F : Find Cell Number #
% p  : Show/Hide Cell Poles
% H# : Show Kymograph for Cell #
% Z  : Cell Towers Mosaic
% G  : Gate All Cell Files
% Movie : Export Movie Frames
%
% important notes :
% - it saves a file in the directory named .trackOptiView.mat where it
% saves the flags from the previous launch
%
%   FLAGS :
%         FLAGS.P_val = 0.2;
%         P_Flag : shows regions (default 1)
%         ID_flag : shows the cell numbers (default 0)
%         lyse_flag : outlines cell that lysed
%         m_flag : shows mask (default 0)
%         c_flag : ? reserts to default view
%         v_flag : shows cells outlines (default 1)
%         f_flag : shows flurescence image
%         s_flag : shows the foci and their score
%         T_flag : ? something related to regions (default 0)
%         p_flag : shows pole positions and connects daughter cells to each other
%         e_flag : 0, errors displayed for this frame
%         f_flag : 0
%         err_flag = false; // getting rid of it
%         D_FLAG = SD_FLAG, AD_FLAG, ND_FLAG

% INPUT :
%       dirname : main directory that contains files segemented by supeSegger
%       it must be the directory that has raw_im and xy1 etc folders.
%       file_filter : used to obtain the contents (deafult .err file)
%       err_flag : if 1, displays errors found in frame, default 0
%
% Copyright (C) 2016 Wiggins Lab
% University of Washington, 2016
% This file is part of SuperSeggerOpti.

%% Load Constants and Initialize Flags

hf = figure(1);
clf;
mov = struct;
CONST = [];
touch_list = [];
setHeader =[];

if nargin<2 || isempty(file_filter);
    file_filter = '*err.mat';
end

% Add slash to the file name if it doesn't exist
if(nargin<1 || isempty(dirname))
    dirname=uigetdir()
end

dirname = fixDir(dirname);
dirname0 = dirname;

% load flags if they already exist to maintain state between launches
filename_flags = [dirname0,'.trackOptiView.mat'];
if exist( filename_flags, 'file' )
    %load(filename_flags);
    FLAGS = intSetDefaultFlags();
        error_list = [];
    nn = 1;
    dirnum = 1;
else
    FLAGS = intSetDefaultFlags();
    error_list = [];
    nn = 1;
    dirnum = 1;
end

% Load info from one of the xy directories. dirnum tells you which one. If
% you quit the program in an xy dir, it goes to that xy dir.

clist = [];
contents_xy =dir([dirname, 'xy*']);
num_xy = numel(contents_xy);

if ~num_xy
    disp('There are no xy dirs. Choose a different directory.');
    return;
else
    dirname_seg = [dirname0,contents_xy(dirnum).name,filesep,'seg',filesep];
    dirname_cell = [dirname0,contents_xy(dirnum).name,filesep,'cell',filesep];
    dirname_xy = [dirname0,contents_xy(dirnum).name,filesep];
    
    % Open clist if it exists
    clist_name = [dirname0,contents_xy(dirnum).name,filesep,'clist.mat'];
    if exist( clist_name, 'file' )
        clist = load([dirname0,contents_xy(dirnum).name,filesep,'clist.mat']);
    else
        clist = [];
    end
    
    ixy = intGetNum( contents_xy(dirnum).name );
    header = ['xy',num2str(ixy),': '];
end


contents=dir([dirname_seg, file_filter]);
num_im = length(contents);


if exist([dirname0,'CONST.mat'],'file')
    CONST = load([dirname0,'CONST.mat']);
    if isfield( CONST, 'CONST' )
        CONST = CONST.CONST;
    end
else
    disp(['Exiting. Can''t load CONST file. Make sure there is a CONST.mat file at the root', ...
        'level of the data directory.']);
end

if nn > num_im % nn : current frame
    nn = num_im;
end


runFlag = (nn<=num_im);
first_flag = 1;

% This flag controls whether you reload from file
resetFlag = true;
FLAGS.e_flag = 0 ;

%% Run the main loop... and run it while the runFlag is true.
while runFlag
    
    % load current frame
    if resetFlag
        resetFlag = false;
        [data_r, data_c, data_f] = intLoadData( dirname_seg, ...
            contents, nn, num_im, [], clist, dirnum);
    end
    
    if first_flag
        imshow( data_c.phase );
    else
        tmp_axis = axis; % sets scaling for the image
    end
    
    showSeggerImage( data_c, data_r, data_f, FLAGS, clist, CONST);
       
    if ~first_flag
        axis( tmp_axis );
    end
    first_flag = false;
    
    
    flagsStates = intSetStateStrings(FLAGS);
    
    % Main Menu
    disp('-----------------------------------------------------------');
    disp('SuperSegger Data Viewer');
    disp(' ');
    disp ('Current State :');
    disp ([flagsStates.fState, ('(f : toogle between phase/fluor)')]);
    disp ([flagsStates.tState, ('(t to toggle)')]);
    disp ([flagsStates.vState, ('(v to toggle)')]);
    disp ([flagsStates.mState, ('(m to toggle)')]);
    disp ([flagsStates.TState, ('(T to toggle)')]);
    disp ([flagsStates.eState, ('(e to hide/show)')]);
    disp ([flagsStates.sState, ('(s to hide/show)')]);
    disp('');
    disp('q  : To quit                      ');
    disp('f  : Toggle Phase/Fluor           s  : Show Fluor Foci           ');
    disp('x# : Switch xy dir #              #  : Go to Frame Number #      ');
    disp('t  : Show Cell Numbers            CC : Use Complete Cell Cycles ');
    disp('r  : Show/Hide Region Outlines    F# : Find Cell Number #       ');
    disp('o  : Show Consensus               p  : Show/Hide Cell Poles      ');
    disp('K  : Kymograph Mosaic             H# : Show Kymograph for Cell #');
    disp('h# : Tower for Cell #             Z  : Cell Towers Mosaic        ');
    disp('g  : Make Gate                    G  : Gate All Cell Files       ');
    disp('MoveG  : Move gated cells         reset : Reset Plot to Default View');   
    disp('Clear : Clear all Gates           Movie : Export Movie Frames   ');
    disp ('Current State :')    
    disp(' ');
    disp('              k : Enter debugging mode                      ');
    disp('-----------------------------------------------------------')
    disp(' ');
    
    % if you loaded segmented data
    
    if ~isempty( touch_list );
        disp('Warning! Frames touched. Run re-link.');
        touch_list
    end
    
    
    disp([header, 'Frame num [1...',num2str(num_im),']: ',num2str(nn)]);
    
    c = input(':','s')
    
    % LIST OF COMMANDS
    if isempty(c)
        % do nothing
    elseif c(1) == 'j' % false color
        if ~isfield( CONST,'view') || ...
                ~isfield( CONST.view,'falseColorFlag')|| isempty( CONST.view.falseColorFlag )
            CONST.view.falseColorFlag = true;
        else
            CONST.view.falseColorFlag = ~CONST.view.falseColorFlag;
        end
        
    elseif c(1) == 'J' % log view
        if ~isfield( CONST, 'view' ) || ~isfield( CONST.view, 'LogView' ) || ...
                isempty( CONST.view.LogView )
            CONST.view.LogView = true;
        else
            CONST.view.LogView = ~CONST.view.LogView;
        end
    elseif (c(1) == 'Q' || c(1) == 'q' ) % Quit Command
        try
            save( [dirname0,contents_xy(dirnum).name,filesep,'clist.mat'],'-STRUCT','clist');
        catch ME
            printError(ME);
            disp('Error saving clist file.');
        end
        runFlag = 0  ;
    elseif strcmp(c,'CC') % Toggle Between Full Cell Cycles
        CONST.view.showFullCellCycleOnly = ~CONST.view.showFullCellCycleOnly ;
        if CONST.view.showFullCellCycleOnly
            disp('Only showing complete Cell Cycles (press any key)')
            pause
        else
            disp('Showing incomplete Cell Cycles (press any key)')
            pause
        end
        
    elseif c(1) == 'F' % Find Single Cells as F(number)
        if numel(c) > 1
            find_num = floor(str2num(c(2:end)));
            if FLAGS.v_flag
                regnum = find( data_c.regs.ID == find_num);
                
                if ~isempty( regnum )
                    plot(data_c.CellA{regnum}.coord.r_center(1),...
                        data_c.CellA{regnum}.coord.r_center(2), ...
                        'yx','MarkerSize',100);
                else
                    disp('couldn''t find that cell');
                end
                
            else
                if (find_num <= data_c.regs.num_regs) && (find_num >0)
                    plot(data_c.CellA{find_num}.coord.r_center(1),...
                        data_c.CellA{find_num}.coord.r_center(2), ...
                        'yx','MarkerSize',100);
                else
                    disp( 'Out of range' );
                end
            end            
            input('Press any key','s');            
        end        
    elseif c(1) == 'x' % Change xy positions
        
        if numel(c)>1
            c = c(2:end);
        else
            for ll = 1:num_xy                
                disp( [num2str(ll),': xy',num2str(nameInfo.nxy(ll))] );                
            end
            c = input(':','s')
        end
        ll_ = floor(str2num(c));
        
        if ~isempty(ll_) && (ll_>=1) && (ll_<=num_xy)
            
            try
                save( [dirname0,contents_xy(dirnum).name,filesep,'clist.mat'],'-STRUCT','clist');
            catch ME
                printError(ME);
                disp( 'Error writing clist file.');
            end
            
            dirnum = ll_;          
            dirname_seg = [dirname0,contents_xy(ll_).name,filesep,'seg',filesep];            
            dirname_cell = [dirname0,contents_xy(ll_).name,filesep,'cell',filesep];
            dirname_xy = [dirname0,contents_xy(ll_).name,filesep];
            
            ixy = intGetNum( contents_xy(dirnum).name );
            header = ['xy',num2str(ixy),': '];            
            contents=dir([dirname_seg, file_filter]);
            error_list = [];
            
            clist = load([dirname0,contents_xy(ll_).name,filesep,'clist.mat']);            
        end
        resetFlag = true;
      
    elseif c(1) == 'r' % Show/Hide Region Outlines
        FLAGS.P_flag = ~FLAGS.P_flag;
        
    elseif strcmp(c,'Reset') % Reset Plot to Default View
        %FLAGS.c_flag = ~FLAGS.c_flag;
        clf;
        first_flag = 1;
        
    elseif numel(c) == 2 && c(1) == 'f' && isnum(c(2)) % Toggle Between Fluorescence and Phase Images
        disp('toggling between phase and fluorescence');
        FLAGS.f_flag = str2num(c(2));
  
    elseif strcmp(c, 'ffilter') % Toggle Between filtered and unfiltered
        disp('filtering'); 
        FLAGS.filt = ~ FLAGS.filt;
        
    elseif c(1) == 'g' % choose characteristics and values to gate cells
        disp('Choose gating characteristic')
        disp(clist.def')
        cc = input('Gate Number(s) [ ] :','s') ;
        tmp_clist = gateMake(clist,str2num(cc)) ;       
        clist = tmp_clist ;
        clf;
        first_flag = 1;
        
    elseif strcmp(c,'Clear')  % Clear All Gates
        clist.gate = [] ;
        clf;
        first_flag = 1;
        
    elseif strcmp(c,'MoveG')   % moves gated cell Files to a different directory
        header = 'trackOptiView: ';
        trackOptiGateCellFiles( dirname_cell, clist);
        
    elseif c(1) == 'G' % Gate All XY Positions
        if ~isfield( clist, 'gate' );
            clist.gate = [];
        end
        
        for ll_ = 1:num_xy
            filename = [dirname0,contents_xy(ll_).name,filesep,'clist.mat'];          
            clist_tmp = gate(load( filename ));
            if  ll_ == 1
                clist_comp =clist_tmp;
            else
                clist_comp.data = [clist_comp.data; clist_tmp.data];
            end
        end
        
        save( [dirname0,'clist_comp.mat'], '-STRUCT', 'clist_comp' );
        
        
    elseif c(1) == 't' % Show Cell Numbers
        FLAGS.ID_flag = ~FLAGS.ID_flag;
        
    elseif strcmp(c,'s') % Show Fluorescent Foci score values
        FLAGS.s_flag = ~FLAGS.s_flag;
    elseif numel(c) > 1 && c(1) == 's' && all(isnum(c(2:end))) % Toggle Between Fluorescence and Phase Images
        disp(['showing foci with scores higher than  ', c(2:end)]);
        FLAGS.s_flag = 1;
        CONST.getLocusTracks.FLUOR1_MIN_SCORE = str2double(c(2:end));
        
    elseif c(1) == 'p'  % Show Cell Poles
        FLAGS.p_flag = ~FLAGS.p_flag;
        
    elseif c(1) == 'k' % Enter Debugging Mode
        tmp_axis = axis;
        disp('Type "return" to exit debugging mode')
        keyboard
        resetFlag = true;
        clf;
        axis( tmp_axis );
        
    elseif c(1) == 'K' % Make Kymograph Mosaic for All Cells
        tmp_axis = axis;
        clf;
        makeKymoMosaic( dirname_cell, CONST );
        disp('press enter to continue.');
        pause;
        axis(tmp_axis);
        
    elseif c(1) == 'Z' %  Show Cell Towers for All Cells
        tmp_axis = axis;
        clf;
        
        if numel(c) > 1
            ll_ = floor(str2num(c(2:end)));
        else
            ll_ = [];
        end
        
        makeFrameStripeMosaic([dirname_cell], CONST, ll_,true );
        axis equal
        
        disp('press enter to continue.');
        pause;
        axis(tmp_axis);
        
    elseif c(1) == 'o' % Show existant consensus for this XY or calculate new one
        intCons(dirname0, contents_xy(ixy), [], CONST)%
        
    elseif c(1) == 'h' % Cell Tower for Single Cell
        
        if numel(c) > 1
            comma_pos = findstr(c,',');
            
            if isempty(comma_pos)
                ll_ = floor(str2num(c(2:end)));
                xdim__ = [];
            else
                ll_ = floor(str2num(c(2:comma_pos(1))));
                xdim__ = floor(str2num(c(comma_pos(1):end)));
            end
            
            padStr = getPadSize( dirname_cell );
            
            if ~isempty( padStr )
                data_cell = [];
                filename_cell_C = [dirname_cell,'Cell',num2str(ll_,padStr),'.mat'];
                filename_cell_c = [dirname_cell,'cell',num2str(ll_,padStr),'.mat'];
                
                if exist(filename_cell_C, 'file' )
                    filename_cell = filename_cell_C;
                elseif exist(filename_cell_c, 'file' )
                    filename_cell = filename_cell_c;
                else
                    filename_cell = [];
                end
                
                if isempty( filename_cell )
                    disp( ['Files: ',filename_cell_C,' and ',filename_cell_c,' do not exist.']);
                else
                    try
                        data_cell = load( filename_cell );
                    catch
                        disp(['Error loading: ', filename_cell] );
                    end
                    
                    if ~isempty( data_cell )
                        tmp_axis = axis;
                        clf;
                        im_tmp = makeFrameMosaic(data_cell, CONST, xdim__);
                        disp('Press enter to continue');
                        pause;
                        axis(tmp_axis);
                    end
                    
                end
            end
        else
            disp ('Please enter a number next to h');
        end
        
        
        
    elseif c(1) == 'H' % Show Kymograph for Single Cell
        
        if numel(c) > 1
            ll_ = floor(str2num(c(2:end)));
            padStr = getPadSize( dirname_cell );
            
            if ~isempty( padStr )
                data_cell = [];
                filename_cell_C = [dirname_cell,'Cell',num2str(ll_,padStr),'.mat']
                filename_cell_c = [dirname_cell,'cell',num2str(ll_,padStr),'.mat']
                
                if exist(filename_cell_C, 'file' )
                    filename_cell = filename_cell_C;
                elseif exist(filename_cell_c, 'file' )
                    filename_cell = filename_cell_c;
                else
                    filename_cell = [];
                end
                
                if isempty( filename_cell )
                    disp( ['Files: ',filename_cell_C,' and ',filename_cell_c,' do not exist.']);
                else
                    try
                        data_cell = load( filename_cell );
                    catch
                        disp(['Error loading: ', filename_cell] );
                    end
                    
                    if ~isempty( data_cell )
                        tmp_axis = axis;
                        clf;
                        makeKymographC(data_cell, 1, CONST );
                        ylabel('Long Axis (pixels)');
                        xlabel('Time (frames)' );
                        disp('Press enter to continue');
                        pause;
                        axis(tmp_axis);
                    end
                    
                end
            end
        end
        
    elseif strcmp(c,'Movie')  % Make Time-Lapse Images for Movies
        setAxis = axis;
        nn_old = nn;
        z_pad = ceil(log(num_im)/log(10));
        
        movdir = 'mov';
        if ~exist( movdir, 'dir' )
            mkdir( movdir );
        end
        file_tmp = ['%0',num2str(z_pad),'d'];
        
        for nn = 1:num_im
            
            [data_r, data_c, data_f] = intLoadData( dirname, ...
                contents, nn, num_im, nameInfo, clist, dirnum);
            
            tmp_im = showDA4new( data_c,data_r, data_f, FLAGS, clist, CONST);
            
            drawnow;
            disp( ['Frame number: ', num2str(nn)] );
            
            imwrite( tmp_im, [movdir,filesep,'mov',sprintf(file_tmp,nn),'.tif'], 'TIFF', 'Compression', 'none' );
            
        end
        nn = nn_old;
        resetFlag = true;
        
    elseif c(1) == 'e'
        % Show Error List
        FLAGS.e_flag = ~FLAGS.e_flag;
        
    elseif c(1) == 'v'  % Toggle between cell view and region view
        FLAGS.v_flag = ~FLAGS.v_flag;
        
        
    elseif strcmp(c,'editSegs')  % Edit Segments : Use at your own risk
        disp('Are you sure you want to edit the segments?')
        d = input('[y/n]:','s');
        if strcmp(d,'y')
            segsTLEdit( dirname, nn);
        end
        
    elseif strcmp(c, 'relink') % Re-Link : Use at your own risk
        disp('Are you sure you want to relink the cells?')
        d = input('[y/n]:','s');
        if strcmp(d,'y')
            
            delete([dirname_cell,'*.mat']);
            delete([dirname,'*trk.mat*']);
            delete([dirname,'*err.mat*']);
            delete([dirname,'.trackOpti*']);
            delete([dirname_xy,'clist.mat']);
            % Re-Run trackOpti
            skip = 1;
            CLEAN_FLAG = false;
            header = 'trackOptiView: ';
            trackOpti(dirname_xy,skip,CONST, CLEAN_FLAG, header);
        end
    elseif c(1) == 'n'; % pick region and ignore error
        if FLAGS.T_flag
            disp( 'Tight flag must be off');
        else
            x = floor(ginput(1));
            
            if ~isempty(x)
                ii = data_c.regs.regs_label(x(2),x(1));
                tmp_axis = axis();
                
                if ~ii
                    disp('missed region');
                else
                    
                    if isfield( data_c.regs, 'ignoreError' )
                        disp(['Picked region ',num2str(ii)]);
                        data_c.regs.ignoreError(ii) = 1;
                        save([dirname,contents(nn  ).name],'-STRUCT','data_c');
                    else
                        disp( 'Ignore error not implemented for your version of trackOpti.');
                    end
                end
            end
        end
        
    elseif strcmp(c,'link'); % Reset Linking in Current Frame
        if FLAGS.T_flag
            disp( 'Tight flag must be off');
        else
            disp('pick region to reset linking in the current frame');
            x = floor(ginput(1));
            
            if ~isempty(x)
                ii = data_c.regs.regs_label(x(2),x(1));
                tmp_axis = axis();
                
                
                if ~ii
                    disp('missed region');
                else
                    disp(['Picked region ',num2str(ii)]);
                    showDA4new( data_f,data_c, data_f, FLAGS, clist, CONST);
                    axis( tmp_axis );
                    
                    disp( 'Click on linked cell(s). press enter to return');
                    x = floor(ginput());
                    
                    ss = size(x);
                    
                    list_of_regs = [];
                    
                    for hh = 1:ss(1);
                        
                        jj = data_f.regs.regs_label(x(hh,2),x(hh,1));
                        if jj
                            list_of_regs = [list_of_regs, jj];
                        end
                    end
                    
                    if ~isempty(list_of_regs)
                        
                        %list_of_regs
                        data_c.regs.ol.f{ii}    = zeros(2, 5);
                        
                        nnn = min([5,numel(list_of_regs)]);
                        
                        data_c.regs.ol.f{ii}(1,1:nnn) = 1;
                        data_c.regs.ol.f{ii}(2,1:nnn) = list_of_regs(1:nnn);
                        data_c.regs.map.f{ii}   = list_of_regs;
                        data_c.regs.error.f(ii) = double(numel(list_of_regs)>1);
                        data_c.regs.ignoreError(ii) = 1;
                        
                        for kk = list_of_regs
                            
                            data_f.regs.ol.r{kk}     = zeros(2,5);
                            
                            data_f.regs.ol.r{kk}(1,1)= 1/numel(list_of_regs);
                            data_f.regs.ol.r{kk}(2,1)= ii;
                            
                            data_f.regs.dA.r(kk)     = 1/numel(list_of_regs);
                            data_f.regs.map.r{kk}    = ii;
                            data_f.regs.error.r(kk)  = double(numel(list_of_regs)>1);
                            data_f.regs.ignoreError(kk) = 1;
                        end
                        
                        % Save files....
                        
                        save([dirname,contents(nn  ).name],'-STRUCT','data_c');
                        save([dirname,contents(nn+1).name],'-STRUCT','data_f');
                        
                    end
                end
            end
        end
        
    elseif strcmp(c,'errRez'); % ReRun Error Resolution and  linking code trackOpti
        ctmp = input('Are you sure you want to re-run error resolution? (y/n): ','s');
        
        if ismember(ctmp(1),'yY')
            % Erase all stamp files after .trackOptiSetEr.mat
            contents_stamp = dir( [dirname,filesep,'.trackOpti*'] );
            num_stamp = numel( contents_stamp );
            
            for iii = 1:num_stamp
                if isempty( strfind( contents_stamp(iii).name,...
                        '.trackOptiLink.mat'  ) ) && ...
                        isempty( strfind( contents_stamp(iii).name,...
                        '.trackOptiErRes1.mat') ) && ...
                        isempty( strfind( contents_stamp(iii).name,...
                        '.trackOptiSetEr.mat' ) )
                    delete ([dirname,filesep,contents_stamp(iii).name]);
                end
            end
            
            
            delete ([dirname_cell,'*.mat']);
            delete ([dirname_cell,'clist.mat']);
            
            % Re-Run trackOpti
            skip = 1;
            CLEAN_FLAG = false;
            header = 'trackOptiView: ';
            trackOpti(dirname_xy,skip,CONST, CLEAN_FLAG, header);
            
        end
        
    else % we assume that it is a number for a frame change.
        tmp_nn = str2num(c);
        if ~isempty(tmp_nn)
            nn = tmp_nn;
            if nn > num_im;
                nn = num_im;
            elseif nn< 1
                nn = 1;
            end
        else % not a number - command not found
            disp ('Command not found');
        end
        resetFlag = true;
    end
    
end

try
    save(filename_flags, 'FLAGS', 'nn', 'dirnum', 'error_list' );
catch
    disp('Error saving flag preferences.');
end

end


% END OF MAIN FUNCTION (trackOptiView)

% INTERNAL FUNCTIONS
function data = loaderInternal( filename, clist )
% loaderInternal : loads the cell outlines for cells in clist
% % Load Date and put in outline fields.

data = load( filename );
ss = size( data.phase );

if isfield( data, 'mask_cell' )
    data.outline =  xor(bwmorph( data.mask_cell,'dilate'), data.mask_cell);
end

if isempty( clist )
    disp (' Clist is empty, can not load any files');
else
    clist = gate(clist);
    data.cell_outline = false(ss);
    if isfield( data, 'regs' ) && isfield( data.regs, 'ID' )
        ind = find(ismember(data.regs.ID,clist.data(:,1))); % get ids of cells in clist
        mask_tmp = ismember( data.regs.regs_label, ind ); % get the masks of cells in clist
        data.cell_outline = xor(bwmorph( mask_tmp, 'dilate' ), mask_tmp);
        
    end
end

end

function [nameInfo] = getDirStruct( dirname )

contents = dir( [dirname,filesep,'*.tif'] );

nt  = [];
nc  = [];
nxy = [];
nz  = [];

num_im = numel(contents);

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

xyPadSize = floor(log(max(nxy))/log(10))+1;
padString = ['%0',num2str(xyPadSize),'d'];

num_xy = numel(nxy);
num_c  = numel(nc);
num_z  = numel(nz);
num_t  = numel(nt);

nameInfo.nt  = nt;
nameInfo.nc  = nc;
nameInfo.nxy = nxy;
nameInfo.nz  = nz;
end

function padStr = getPadSize( dirname )
% getPadSize : returns number of numbers in cell id's.
contents = dir([dirname,'*ell*.mat']);

if numel(contents) == 0
    disp('No cell files' );
    padStr = []
else
    num_num = sum(ismember(contents(1).name,'1234567890'));
    padStr = ['%0',num2str(num_num),'d'];
end

end


function ixy = intGetNum( str_xy )
ixy = str2num(str_xy(ismember(str_xy, '0123456789' )));
end


function [data_r, data_c, data_f] = intLoadData( dirname, contents, nn, num_im, nameInfo, clist, ixy)
% intLoadData : loads current, reverse and forward data.
% INPUT :
%       dirname : seg directory

%       contents : filenames to be loaded
%       nn : frame number to be loaded
%       num_im : total number of images
%       nameInfo : not used
%       clist : list of cells
%       ixy : not used



if (nn ==1) && (1 == num_im) % 1 frame only
    data_r = [];
    data_c = loaderInternal([dirname,contents(nn).name], clist);
    data_f = [];
elseif nn == 1;  % first frame
    data_r = [];
    data_c = loaderInternal([dirname,contents(nn).name], clist);
    data_f = [];
elseif nn == num_im ||  nn == num_im-1 % last or before last frame
    data_r = [];
    data_c = loaderInternal([dirname,contents(nn).name], clist);
    data_f = [];
else
    data_r = loaderInternal([dirname,contents(nn-1).name], clist);
    data_f = loaderInternal([dirname,contents(nn+1).name], clist);
    data_c = loaderInternal([dirname,contents(nn).name], clist);
end


end


function intDispError( data_c, FLAGS )
% intDispError
for kk = 1:data_c.regs.num_regs
    if isfield(data_c,'regs') &&...
            isfield(data_c.regs, 'error') && ...
            isfield(data_c.regs.error,'label') && ...
            ~isempty( data_c.regs.error.label{kk} )
        if FLAGS.v_flag && isfield( data_c.regs, 'ID' )
            disp(  ['Cell: ', num2str(data_c.regs.ID(kk)), ', ', ...
                data_c.regs.error.label{kk}] );
        else
            disp(  [ data_c.regs.error.label{kk}] );
        end
    end
end
end


function flagsStates = intSetStateStrings(FLAGS)
% intSetStateStrings : sets default flags for when the program begins
flagsStates.vState = '';
flagsStates.mState = 'Mask';
flagsStates.tState = 'Cell numbers not shown';
flagsStates.TState = 'Tight : on';
flagsStates.PState ='';
flagsStates.eState = 'Error : on';
flagsStates.fState = 'Fluorescence';
flagsStates.cState ='';
flagsStates.PValState = '';
flagsStates.lyseState = '';
flagsStates.sState = 'Scores shown';

if ~FLAGS.v_flag
    flagsStates.vState = 'Regions Outlined';
end

if ~FLAGS.m_flag
    flagsStates.mState = '';
end

if ~FLAGS.ID_flag
    flagsStates.tState = 'Cell numbers shown';
end

if ~FLAGS.T_flag
    flagsStates.TState = 'Tight : off';
end

if ~FLAGS.P_flag
    flagsStates.eState = 'P flag off';
end
if ~FLAGS.e_flag
    flagsStates.eState = 'Errors off';
end

if ~FLAGS.f_flag
    flagsStates.fState = 'Phase';
end

if ~FLAGS.s_flag
    flagsStates.sState = 'No scores shown';
end
if ~FLAGS.p_flag
    flagsStates.pState = '';
end
if ~FLAGS.c_flag
    flagsStates.cState= '';
end
if ~FLAGS.lyse_flag
    flagsStateslyseState = 'Lyse';
end




end

function FLAGS = intSetDefaultFlags()
% intSetDefaultFlags : sets default flags for when the program begins
FLAGS.v_flag  = 1;
FLAGS.m_flag  = 0;
FLAGS.ID_flag  = 0;
FLAGS.T_flag  = 0;
FLAGS.P_flag  = 1;
FLAGS.e_flag  = 0;
FLAGS.f_flag  = 0;
FLAGS.s_flag  = 1;
FLAGS.p_flag  = 0;
FLAGS.c_flag  = 1;
FLAGS.P_val = 0.2;
FLAGS.lyse_flag = false;
FLAGS.filt = false;
end

function intCons(dirname0, contents_xy, setHeader, CONST)
xyDir = [dirname0,contents_xy.name,filesep];
dircons = [xyDir,'/consensus/']

if ~exist(dircons,'dir')
    mkdir(dircons);
end

ixy = intGetNum( contents_xy.name );
header = ['xy',num2str(ixy),': '];

if exist([dircons, 'consColor_', setHeader, '_', num2str(ixy,'%02d'), '.tif'],'file')
    disp('Consensus Already Calculated')
    imColor = imread([dircons, 'consColor_', setHeader, '_', num2str(ixy,'%02d'), '.tif']);
    figure(1)
    clf
    imshow(imColor);
    disp('Press any key to continue')
    pause;
else
    
    disp('No Images Found.')
    disp('Calculate New Consensus?')
    d = input('[y/n]:','s');
    
    if strcmp(d,'y')
        if isdir([dirname0,contents_xy.name,filesep,'seg_full'])
            dirname = [dirname0,contents_xy.name,filesep,'seg_full',filesep];
        end
        
        dirname_cell = [dirname0,contents_xy.name,filesep,'cell',filesep];
        disp( ['Doing ',num2str(ixy)] );
        skip = 1;
        mag = 4;
        [dataImArray] = makeConsensusArray( [dirname_cell], CONST, skip, mag, [] );
        [imMosaic, imColor, imBW, imInv, imMosaic10 ] = makeConsensusImage( dataImArray,CONST,skip,mag,0);
        
        figure(1)
        clf
        imshow(imColor)
        
        if ~isempty( imMosaic10 )
            disp('Save consensus images?')
            d = input('[y/n]:','s');
            % this just saves the consensus images.
            if strcmp(d,'y')
                save([dircons,'consensus'],'imMosaic', 'imColor', 'imBW', 'imInv', 'imMosaic10');
                imwrite( imBW,    [dircons, 'consBW_',    setHeader, '_', num2str(ixy,'%02d'), '.tif'], 'tif' );
                imwrite( imColor, [dircons, 'consColor_', setHeader, '_', num2str(ixy,'%02d'), '.tif'], 'tif' );
                imwrite( imInv,   [dircons, 'consInv_',   setHeader, '_', num2str(ixy,'%02d'), '.tif'], 'tif' );
                imwrite( imMosaic10,   [dircons, 'typical_',   setHeader, '_', num2str(ixy,'%02d'), '.tif'], 'tif' );
            end
        else
            disp( ['Found no cells in ', dirname_cell, '.'] );
        end
        
    else
        
        return
        
    end
end
end
