function [clist, out] = gateTool(varargin)
% gateTool : tool for gating and plotting functionality of clists.
%
% GATETOOL( [clist,clist cell array], [command string], [argument], ... ) 
% 
% clist must be (i) a clist struct or (ii) a cell array of clists or (iii)
% a data directory, xy1 directory or a clist file name. 
%
%  If there are no arguments specified, the 'strip' command is run
%
%Clist modification commands:
%
% 'merge'      : Merge all clist input into a single output clist (no
%                arguments accepted)
%
% 'name', str  : Add name in str to all input clists as a label                 
%
% 'color', cc  : Set color cc for all clists
%
% 'strip'      : Remove all un-gated cells (no arguments)           
%
% 'make', ind  : Gate on indices in ind. Specify either 1 or 2 as a vector 
%                index names are stored in def and can be view by running 
%                the def command. If the ind is a structure it assumes it 
%                is a preformed gate and adds it to the gate array in all 
%                clists. Any gating is performed on all clists input.  
%
% 'squeeze'     : make a clist vertical so all entries are treated as
%                 identifcal conditions.
%
% 'expand'      : make a clist horizontal so all entries are treated as
%                 different conditions
%
% 'add', data, name : add a field (name) to the clist data with values
%                 (data)
%
% 'add3d' data, name : add a field (name) to the clist data with values
%                 (data)
%
% 'get', index  : gets data from data column index  
%%
% 'getgate', index : gets the indexed gate.
%
%Visualization commands:
%
% 'show', ind   : This command will make a figure for viewing without 
%                 modifying the clist. ind is either and index or pair of 
%                 indices specifying what is to be visualized. If no ind is 
%                 passed then all gates are displayed on a single clist 
%                 input         
%
% 'kde'         : Make either a 1 or 2D KDE (depending on dimension of ind)
%                 'show' must be called as well.
%
% 'time'        : Make a temporal plot of single cell dynamics for one index
%                 'show' must be called as well.
%
% 'hist'        : Make a 1 or 2D histogram (depending on dimension of ind)
%                 'show' must be called as well.   
%           
% 'dot'         : Make a dot plot. Dim of ind must equal 2.
%                 'show' must be called as well.   
%
% 'log', axes   : Set of axes to set with log scales. axes = [1,2,3] will 
%                 set x, y and color axis to have log scale.
%
% 'den'         : Normalize KDE and hist like a probability density
%
% 'cond'        : Normalize like a conditional probability density
%
% 'no clear'    : Do not run clear figure (clf) before drawing.
%
% 'rk', rk      : radius of the gaussian kernel for KDE
%
% 'rm', rm      : radius of the point mask for KDE              
%
% 'inv'         : invert 2D hist/KDE image for printing 
%
% 'mult', mult   : set the resolution for the KDE. Increase res by a factor
%                 of mult.
%
% 'bin', bin    : set the binning for the hist and KDE. In 1D, if bin is a
%                 scalar it is interpretted as the number of bins. If it is
%                 a vector it is assumed to be the bin centers. In 2D, if
%                 bun is a vector, it is interpretted to be a vector of bin
%                 numbers for the two dimensions. If it is a cell array, it
%                 is assumed to be two vectors of centers.
%
%
% 'err'         : show error in 1D histograms and kde's
%
% 'stat'        : show statistics for a show command. Only one index.
%
% 'newfig'      : draws new figures for each clist
%
%Other commands:
%
% 'def'         : Show all the channel definitions at the command line
%
% 'def3D'       : Show all the temporal channel definitions at the command
%                 line
%
% 'xls', filename : export an excel doc with the clist data. Need to have
%                   excel installed to export. (Not my fault.)
%
% 'csv', filename : export a csv doc with the clist data.
%
% 'save', filename : Save .mat file.
%
% 'units', units : set the multiplier for the data to set the desired units
%
% 'drill'       : Use recursive loading trhough a directory tree to any
%                 level.
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
%

%% process the input arguments
data = intProcessInput( varargin );


%% make a new gate if required
if data.merge_flag
    data.clist = intDoMerge( data.clist, [], ~data.time_flag );
end


%% make a new gate if required
if data.make_flag
    data = intMakeGate( data, data.ind );
end

%% Show the gates if the show flag is true
if data.show_all_flag
    data.clist = intShowAll( data.clist, 1 );
elseif data.show_flag
    data = intShow( data );
end

%% strip out data that was gated out if the strip flag is set;
if data.strip_flag
    data = intDoStrip( data );
end


%% Do export
if data.export_flag
    intcsv( data.clist, data );
end

%% make the output

if data.get_flag
    if data.time_flag
        out = squeeze(intGet3D( data.clist, data.g_ind ));
    else
        out = intGet( data.clist, data.g_ind );
    end
elseif data.stat_flag
    %out = intGetCellNum( data.clist );
    %disp( ['Gated cells: ',num2str(out(1))] );
    %disp( ['Total cells:  ',num2str(out(2))] );
    %disp( [num2str(100*out(1)/out(2)),' %'] );
elseif data.get_gate_flag
    
    if ~data.time_flag
        if data.which_gate <= numel( data.clist.gate )
            out = data.clist.gate(data.which_gate);
        else
            error( ['There are only ', num2str( numel( data.clist.gate ) ), ' gates.'] );
        end
    else
        if ~isfield( data.clist, 'gate3D' )
            error( 'There is not gate3D field.' );
        else
            if data.which_gate <= numel( data.clist.gate3D )
                out = data.clist.gate3D(data.which_gate);
            else
                error( ['There are only ', num2str( numel( data.clist.gate3D ) ), ' gates.'] );
            end
        end
        
    end
end


clist = data.clist;



end

%% internal funciton that processes that input arguments
function data = intProcessInput( varargin )

varargin = varargin{1};
nargin   = numel( varargin );

data.make_flag      = false;

data.strip_flag     = false;
data.log_flag       = false([1,3]);
data.merge_flag     = false;
data.bin_flag       = false;
data.hist_flag      = false;
data.kde_flag       = false;
data.time_flag      = false;
data.dot_flag       = false;
data.dothist_flag   = false;
data.inv_flag       = false;
data.get_flag       = false;
data.stat_flag      = false;
data.skip3D_flag    = false;
data.export_flag    = false;
data.drill_flag     = false;
data.error_flag     = false;
data.newfig_flag    = false;

data.trace_flag     = false;

data.get_gate_flag  = false;
data.name_flag      = false;
data.den_flag       = false;
data.noclear_flag   = false;

data.show_flag      = false;
data.show_all_flag  = false;
data.array_flag     = false;

data.clist      = [];
data.h          = [];
data.legend     = {};

data.ind        = [];
data.bin        = [];
data.color      = [];
data.rk         = [];
data.rm         = [];
data.g_ind      = [];

data.units      = [1,1];
data.fig_ptr    = [];
data.minBinNum  = 5;
data.multi      = 500;

data.im = {};


data.cond_flag  = false;

load_flag = false;

if nargin == 0
    error( 'gate must have at least one argument (a clist)' );
else
    next_arg = varargin{1};
        
    if ischar( next_arg )
        
        if any(strcmp( 'drill',varargin ))
            data.drill_flag = true;
        end
        
        next_arg = intLoadClist( next_arg, data );
        load_flag = true;
    end
    
    if (~iscell( next_arg )) && (~isstruct( next_arg ))
        error( 'First argument must be a clist' );
    end
    
    data.clist = next_arg;
    
    if iscell( next_arg );
        data.array_flag  = true;
    end
    
    counter = 1;
    
    % set the strip if no arguments are specified
    if  nargin == 1 && ~load_flag
        data.strip_flag = true;
    end
    
    while counter < nargin
        
        counter = counter + 1;
        next_arg = varargin{counter};
        
        if ~ischar( next_arg )
            disp( next_arg );
            error( 'is not a command string' );
        end
        
        switcher = lower(next_arg);
        switch switcher
            case 'log' % set the lag flag for log display
                
                counter = counter + 1;
                
                if counter > nargin
                    error( 'You need to specify which axes to log scale' );
                end
                next_arg = varargin{counter};
                
                if isnumeric( next_arg ) % if numeic set the ind's to log
                    ind = next_arg;
                    data.log_flag( ind ) = true;
                else % if there is no numeric ind's turn all to log
                    data.log_flag( [1,2] ) = true;
                    counter = counter-1;
                end
            case 'skip3d'
                data.skip3D_flag = true;
                
            case 'drill'
                data.drill_flag = true;
                
            case 'err'
                data.error_flag = true;
                
            case 'mult'
                counter = counter + 1;
                if counter > nargin
                    error( 'Not enough arguments for MULT.' )
                end
                next_arg = varargin{counter};
                
                if isnumeric( next_arg )
                    data.mult = next_arg; 
                end
                
            
%             case 'e'
%                 
%                 counter = counter + 1;
%                 if counter > nargin
%                     error( 'Not enough arguments for target error.' )
%                 end
%                 next_arg = varargin{counter};
%                 
%                 if isnumeric( next_arg )
%                     data.err = next_arg; 
%                 else
%                     error( 'Estimated error must be a double.' );
%                 end
                
            case 'newfig'
                data.newfig_flag = true;
                
            case 'getgate'
                
                
                counter = counter + 1;                
                if counter > nargin
                    error( 'Need to specify which clist.' );
                end
                
                next_arg = varargin{counter};
                if isnumeric( next_arg ) % if numeic set the ind's to log
                    data.which_gate = next_arg;
                     
                     if numel(data.clist) ~= 1 || ~isstruct(data.clist)
                        error('Get gate only works with a single clist');
                     end
                         
                     data.get_gate_flag = true;
                else
                     error( 'getGate needs a numeric argument .' );
                end
                        
                
            case 'clear'

                counter = counter + 1;                
                if counter > nargin
                    cind = [];
                else
                    cind = [];
                    next_arg = varargin{counter};
                     if isnumeric( next_arg ) % if numeic set the ind's to log
                        cind = next_arg;
                        
                    else % if there is no numeric ind's t
                        counter = counter - 1;      
                    end
                end
                
                data.clist = intClear( data.clist, cind );

            case {'xls','csv'}
                counter = counter + 1;
                if counter > nargin
                    error( 'Not enough arguments for xls/csv. Must provide filename.' )
                end
                next_arg = varargin{counter};
                if ~ischar( next_arg )
                    error( 'You must include a filename.' );
                end
                data.export_filename = next_arg;
                
                data.export_index = [];
                
                counter = counter + 1;
                if counter > nargin || ischar( varargin{counter} )
                    counter = counter - 1;
                else
                    data.export_index = varargin{counter};
                end
                
                switch switcher
                    case 'xls'
                        data.which_export_flag = 2;
                    case 'csv'
                        data.which_export_flag = 1;
                end
                        
                data.export_flag = true;
                
            case 'save'
                counter = counter + 1;
                if counter > nargin
                    error( 'Not enough arguments for save. Must provide filename.' )
                end
                next_arg = varargin{counter};
                if ~ischar( next_arg )
                    error( 'You must include a filename.' );
                end
                filename = next_arg;
                
                clist = data.clist;
                
                if isstruct( data.clist )
                    save( filename,'-struct','clist' );
                else
                    save( filename,'-v7.3','clist' );
                end
        
           
                
            
            case 'units'
                counter = counter + 1;
                if counter > nargin
                    error( 'Not enough arguments for units. Must provide a scalar or vector.' )
                end
                next_arg = varargin{counter};
                if ~isnumeric( next_arg )
                    error( 'units must be scalar or vector.' );
                else
                    data.units =  next_arg;   
                end
                
                
            case 'add'
                
                if numel( data.clist ) ~= 1
                    error( 'You can only add a field to a clist structure, not a cell array' );     
                end
               
                counter = counter + 1;
                if counter > nargin
                    error( 'Not enough arguments for add' )
                end
                next_arg = varargin{counter};
                if ~isnumeric( next_arg )
                    error( '1st argument of add must be the data' );
                end
                
                if numel( next_arg ) ~= size( data.clist.data, 1)
                    error( 'added data size must match the clist data dimension' );
                end
                
                ss = size(data.clist.data);
                
                tmp_data = next_arg;
                tmp_data = reshape( tmp_data, [numel(tmp_data),1]);
                
                counter = counter + 1;
                if counter > nargin
                    error( 'Not enough arguments for add' )
                end
                next_arg = varargin{counter};
                if ~ischar( next_arg )
                    error( '2nd argument of add must be a str name for the field' );
                end
                field_name = next_arg;
                
                data.clist.data = [data.clist.data,tmp_data];
                
                field_name = [num2str( size(data.clist.data,2) ),': ',field_name];
                
                data.clist.def{ss(2)+1} = field_name;
                
                disp( ['Adding field ',field_name] );
                
                
            case 'add3d'
                
                         
                if numel( data.clist ) ~= 1
                    error( 'You can only add a field to a clist structure, not a cell array' );     
                end
               
                counter = counter + 1;
                if counter > nargin
                    error( 'Not enough arguments for add' )
                end
                next_arg = squeeze(varargin{counter});
                if ~isnumeric( next_arg )
                    error( '1st argument of add must be the data' );
                end
                
                if ~all(size( next_arg ) == [size( data.clist.data3D,1),size( data.clist.data3D,3)] )
                    error( 'added data size must match the clist data3D dimension' );
                end
                
                tmp_data = next_arg;
                
                ss = size(data.clist.data3D);
                 
                counter = counter + 1;
                if counter > nargin
                    error( 'Not enough arguments for add' )
                end
                next_arg = varargin{counter};
                if ~ischar( next_arg )
                    error( '2nd argument of add must be a str name for the field' );
                end
                field_name = next_arg;
                
                data.clist.data3D = cat(2,data.clist.data3D,reshape(tmp_data,[ss(1),1,ss(3)]));
                
                field_name = [num2str( ss(2)+1 ),': ',field_name];
                
                data.clist.def3d{ss(2)+1} = field_name;
                
                disp( ['Adding field ',field_name] );
                

            case 'add3dt'               
                data.clist = intDoAddT( data.clist );
            case 'trace'
                data.trace_flag = true;
                
            case 'get'
                data.get_flag = true;
                
                counter = counter + 1;
                if counter > nargin
                    error( 'Not enough arguments for get' )
                end
                next_arg = varargin{counter};
                if ~isnumeric( next_arg )
                    error( 'indices must be numeric' );
                end
                
                data.g_ind = next_arg;
    
                
            case 'def'
                disp( intGetDef( data.clist )' );
            case 'def3d'
                disp( intGetDef3D( data.clist )' );
            case 'merge' % set merge flag
                data.merge_flag = true;
            case 'den' % set density flag
                data.den_flag = true;
            case 'no clear' % set the names
                data.noclear_flag = true;
            case 'kde'
                data.kde_flag = true; 
                
            case 'rk' % kernal radius
                counter = counter + 1;
                next_arg = varargin{counter};
                
                if isnumeric( next_arg ) % if numeic set the ind's to log
                    data.rk = next_arg;                
                else % if there is no numeric ind's turn all to log
                    error( 'KDE kernal radius must be a double' );
                end
            case 'rm'              
                counter = counter + 1;
                next_arg = varargin{counter};
                
                if isnumeric( next_arg ) % if numeic set the ind's to log
                    data.rm = next_arg;
                else % if there is no numeric ind's turn all to log
                    error( 'KDE kernal radius must be a double' );
                end
            case 'cond'
                data.cond_flag = true;
            case 'inv'
                data.inv_flag = true;
            case 'res'
                 counter = counter + 1;
                next_arg = varargin{counter};
                
                 if isnumeric( next_arg ) % if numeic set the ind's to log
                    data.mult = next_arg;

                 else % if there is no numeric ind's turn all to log
                    error( 'Resolution must be a double.' );
                 end
                
            case 'squeeze'
                
                data.clist = intSqueeze( data.clist );
                
            case 'expand'
                
                data.clist = intExpand( data.clist );
                
            case 'name' % set the names
                
                
                counter = counter + 1;
                next_arg = varargin{counter};
                
                if ~isstr( next_arg )
                    error( 'name is not a string' );
                else
                    name = next_arg;
                    if ~data.array_flag
                        data.clist.name = name;
                    else
                        data.clist = intDoAll( data.clist, 'name', name);
                    end
                end
                
            case 'bin'
                data.bin_flag = true;
                
                counter = counter + 1;
                bin     = varargin{counter};
                
                if iscell( bin ) || isnumeric( bin )
                    data.bin = bin;
                else
                    error( 'Bin must be numeric ar a cell.' );
                end
                
            case {'make','gate'}
                counter  = counter + 1;
                if counter > nargin
                    error( 'Not enough arguments for add' )
                end
                next_arg = varargin{counter};
                
                if isnumeric( next_arg )
                    
                    data.ind = next_arg;
                    
                    counter  = counter + 1;
                    if ~(counter > nargin)
                        next_arg = varargin{counter};
                        if isnumeric( next_arg )
                            
                            tmp_gate.ind = data.ind;
                            
                            if numel( data.ind ) == 1
                                tmp_gate.x =  next_arg;
                            elseif  numel( data.ind ) == 2
                                tmp_gate.xx =  next_arg;
                            end
                            
                            data = intMakeGate( data, tmp_gate );
                            
                        else
                            data.make_flag = true;
                            counter  = counter - 1;
                        end
                    else
                        data.make_flag = true;
                    end
                elseif isstruct( next_arg )
                    data = intMakeGate( data, next_arg );
                else
                    error( 'gate must be numeric ind list or struct' );
                end
                
            case {'make3d','gate3d'}
                
                counter  = counter + 1;
                next_arg = varargin{counter};
                
                data.time_flag = true;
                
                if isnumeric( next_arg )
                    data.make_flag = true;
                    data.ind = next_arg;
                    
                elseif isstruct( next_arg )
                    data = intMakeGate( data, next_arg );
                else
                    error( 'gate must be numeric ind list or struct' );
                end
                
            case {'time','3d' }
                
                data.time_flag = true;
                
            case 'show'
                data.show_flag = true;
                
                counter  = counter + 1;
                
                if (counter <= nargin) && isnumeric( varargin{counter} )
                    data.ind =  varargin{counter};
                else
                    data.show_all_flag = true;
                    counter  = counter - 1;
                end
                
            case 'hist'
                
                data.hist_flag = true;
                
            case 'stat'
                data.stat_flag = true;
                
             case 'dothist'
                
                data.dothist_flag = true;
                    
            case 'dot'
                
                data.dot_flag = true;
                
            case 'strip'
                
                data.strip_flag = true;
                
            case 'color'
                
                counter  = counter + 1;
                color = varargin{counter};
                
                if ~data.array_flag
                    data.clist.color = color;
                else
                    data.clist = intDoAll( data.clist, 'color', color);
                end
            case ''
                % this is just an empty
            otherwise
                disp( [next_arg, ' is not a command'] );
                
        end
        
    end
    
  
end

if ~data.hist_flag && ~data.kde_flag && ~data.dot_flag
    
    if (numel( data.ind ) == 2)
        if data.time_flag
            data.kde_flag = true;
        else
            data.dot_flag = true;
        end
        if numel( data.ind ) == 1
            data.hist_flag = true;
        end
        
    end
    
    
end

if numel( data.bin ) == 1 && numel( data.ind ) == 2
    error( 'Dimension of bin must match ind.' );
end

end

%% run gate too  on all clists in a clist
function clist = intDoAll( clist, comm_, arg_ )

if ~exist( 'arg_', 'var' )
    arg_ = '';
end

nc = numel( clist );
for ii = 1:nc
    clist{ii} = gateTool( clist{ii}, comm_, arg_ );
end
end



%% Strip out data not used.
function data = intDoStrip( data )

if data.array_flag
    data.clist = intDoAll( data.clist, 'strip' );
else
    clist  = data.clist;
    clist0 = clist;
    
    % strip out stuff we don't need
    if isfield( clist0, 'gate' );
        clist0 = rmfield( clist0, {'gate'} );
    end
    if isfield( clist0, 'idExclude' );
        clist0 = rmfield( clist0, {'idExclude'} );
    end
    if isfield( clist0, 'idExclude' );
        clist0 = rmfield( clist0, {'idExclude'} );
    end
    
    
    ss = size(clist.data);
    inflag = true(ss(1),1);
    
    if isfield( clist, 'idExclude' ) && ~isempty(clist.idExclude)
        inflag = ~ismember(clist.data(:,1), clist.idExclude);
    end
    
    if isfield( clist, 'idInclude' ) && ~isempty(clist.idInclude)
        inflag = ismember(clist.data(:,1), clist.idInclude);
    end
    
    if isfield( clist, 'gate' ) && ~isempty ('gate.clist')
        for ii = 1:numel(clist.gate)
            if numel(clist.gate(ii).ind) == 2
                inflag = and(inflag, inpolygon( clist.data(:,clist.gate(ii).ind(1)), ...
                    clist.data(:,clist.gate(ii).ind(2)), ...
                    clist.gate(ii).xx(:,1), clist.gate(ii).xx(:,2) ));
            else
                x = clist.data(:,clist.gate(ii).ind);
                inflag = and( inflag, and( x > min(clist.gate(ii).x), x < max(clist.gate(ii).x)));
            end
        end
    end
    
    
    clist0.data = clist.data(inflag,:);
    if isfield(clist,'data3D') && isfield(clist,'def3d') && ~data.skip3D_flag
        clist0.def3d = clist.def3d;
        clist0.data3D = clist.data3D(inflag,:,:);
    end
    
    data.clist = clist0;
    
    if numel(clist0.data) == 0
       disp( 'Warning: At least one clist is empty after gating.' ); 
    end
end

end

%% Add another gate. Interactive if info is not specified at the command line
function data = intMakeGate( data, arg_ )

% if you pass the gate structure whole just put it in the field
if isstruct(arg_)
    if iscell( data.clist )
        data.clist = intDoAll( data.clist, 'make', arg_ );
    else
        if ~data.time_flag
            if isfield( data.clist, 'gate' ) && ~isempty( data.clist.gate )
                data.clist.gate = intMergeStruct(data.clist.gate,arg_);
            else
                data.clist.gate = arg_;
            end
        else
            if isfield( data.clist, 'gate3D' ) && ~isempty( data.clist.gate3D )
                data.clist.gate3D = intMergeStruct(data.clist.gate3D,arg_);
            else
                data.clist.gate3D = arg_;
            end
        end
    end 
elseif isnumeric( arg_ ) % fire up the gui and do it by hand
    intShow( data );
    hold on;
    
    ylim_ = ylim;
    
    % 1D get choose min and max
    if numel( data.ind ) == 1
        disp( 'Click on the max and min value to make a gate.');
        for i = 1:2
            try
                tmp = ginput(1);
            catch
                % if window was closed - does not make any clist
                return;
            end
            if ~isempty(tmp)
                gxx(i,:) = tmp;
                plot( gxx(i,1)+[0,0], ylim_, 'r--' );
            end
        end
        
        tmp_gate.x    = gxx(:,1);
        tmp_gate.ind  = data.ind;
        tmp_gate.xx   = [];
        
        % print the gate info to the command window.
        if data.time_flag
            def = intGetDef3D( data.clist );
            disp( ['Gate selected for ', def{data.ind}] );
        else
            def = intGetDef( data.clist );
            disp( ['Gate selected for ', def{data.ind}] );
        end
        
        disp(tmp_gate.x);
        
        hold on;
        plot( gxx(1)+[0,0], ylim_, 'r--' );
        hold on;
        plot( gxx(2)+[0,0], ylim_, 'r--' );
        % Do 2 D gating
    elseif numel( data.ind ) == 2
        
        % do polygon gate
        c_flag = 1;
        disp('Draw polygon. Finish by pressing return' );
        i = 0;
        xx = zeros( 100, 2 );
        
        while c_flag;
            dvar = 0;
            
            i = i+1;
            tmp = ginput(1);
            if isempty(tmp)
                if i ~= 1
                    plot( xx([i-1,1],1), xx([i-1,1],2), 'r-' );
                end
                
                c_flag = false;
                numvert = i-1;
            else
                dr = (xx(1,:)-tmp );
                if (i>1) && (sum((dr.^2)) < dvar*0.001 )
                    numvert = i-1;
                    c_flag = false;
                    plot( xx([1,numvert],1), xx([1,numvert],2), 'r-' );
                else
                    xx(i,:) = tmp;
                    
                    if i == 1
                        plot( xx(1,1), xx(1,2), 'r-' );
                    else
                        plot( xx([i,i-1],1), xx([i,i-1],2), 'r-' );
                    end
                end
            end
        end
        
        xx = xx(1:numvert,:);
        
        tmp_gate.ind = data.ind;
        tmp_gate.xx  = xx;
        tmp_gate.x   = [];
        
        % print the gate info to the command window.
        if data.time_flag
            def = intGetDef3D( data.clist );
            disp( ['Gate selected for ', def{data.ind(1)},', ',def{data.ind(2)}] );
        else
            def = intGetDef( data.clist );
            disp( ['Gate selected for ', def{data.ind(1)},', ',def{data.ind(2)}] );
        end
        disp( tmp_gate.xx );
        
    else
        error( 'Too many ind to gate. Must be either 1 or 2.' );
    end
   
    % copy the gate in
    if ~data.time_flag
        data.clist = gateTool( data.clist, 'make', tmp_gate );
        % Show the gate
        figure
        gateTool( data.clist, 'show', data.ind);  
    else 
        data.clist = gateTool( data.clist, 'make3D', tmp_gate );
        % Show the gate
        figure
        gateTool( data.clist, 'show', data.ind, 'time' );
    end
    
    
else
    error( 'Make gate in must be gate structure of indices' );
end

end

%% Show the gates if the show flag is true
function [clist, fignum] = intShowAll( clist, fignum )

if ~exist( 'fignum', 'var' )
    fignum = 1;
end

if iscell( clist )
    nc = numel( clist )
    for ii = 1:nc
        [clist{ii},fignum] =  intShowAll( clist{ii}, fignum );
    end
elseif isstruct( clist )

    if isfield( clist, 'gate' )
        ng = numel( clist.gate );
    else
        ng = 0;
    end
        
    clist0 = clist;
    
    for ii = 1:ng
        
        fignum = fignum + 1;
        
        figure(fignum);
        clf;
        
        clist0 = clist;
        clist0.gate = clist.gate(1:ii-1);
        
        [N,N0] = intShowGate( clist0, clist.gate(ii), ii );
        
        clist.gate(ii).N = N;
        clist.gate(ii).N0 = N0;
    end
else
    error( 'internal non clist error');
end
end

%% get the number of gate and ungated cells...not used.
function [out] = intGetCellNum( clist )
clist = gateTool( clist, 'merge', 'skip3d' );

num = size( clist.data, 1 );

clist = gateTool( clist, 'strip', 'skip3d' );

numG = size( clist.data, 1 );

out = [numG,num];
end


%% Show the gate info on the plot
function [N,N0] = intShowGate( clist, gate_var, gate_num )

if ~exist( 'gate_num', 'var' )
    gate_num = 0;
end


tmp = gateTool( clist );
N0  = size( tmp.data, 1);
tmp = gateTool( tmp, 'gate',gate_var  );
tmp = gateTool( tmp );
N   = size( tmp.data, 1);



gateTool( clist, 'show', gate_var.ind );

        
hold on;
if numel(gate_var.ind)==1
    ylim_ = ylim;
    
    plot( gate_var.x(1)+0*ylim_,ylim_, '.--', 'color','r' );
    plot( gate_var.x(2)+0*ylim_,ylim_, '.--', 'color','r' );
else
    plot( gate_var.xx([1:end,1],1), gate_var.xx([1:end,1],2), '.--', 'color', 'r' );
end

name = '';

if isfield( clist, 'name' )
    name = clist.name;
end

title( [name,' Gate: ',num2str(gate_num), ' Cell count: ',num2str(N), ' / ', num2str( N0 )] ); 


end

%% function that handles the data display
function  data0 = intShow( data0 )

if ~data0.noclear_flag
    clf;
end

data = data0;

if data.time_flag
    data.clist = gateTool( data.clist, 'strip', 'time' );
else
    data.clist = gateTool( data.clist, 'strip', 'skip3d' );
end


% make bins
if data0.hist_flag || (numel( data0.ind )==1) || data0.kde_flag
    data1 = data;
    data1.clist = intDoMerge( data1.clist, [], ~data.time_flag );
    
    data = intMakeBins( data1.clist, data1  );
end

% Int show function: Take care of all top level operations
data = intIntShow( data.clist, data );

nf = max( [1, numel( data.fig_ptr )] );

for jj = 1:nf
    
    if ~isempty( data.fig_ptr )
        figure( data.fig_ptr(jj) );
    end
    
    if (numel( data.ind ) == 2) && ...
            (~data.dot_flag)
        
        
        xx1 = data.xx{1};
        xx2 = data.xx{2};
        
        if data.log_flag(2)
            xx1 = exp(xx1);
        end
        if data.log_flag(1)
            xx2 = exp(xx2);
        end
        
        if numel(data.clist)>1 && ~data.newfig_flag
            if ~data.log_flag(3)
                data.im = data.im/max(data.im(:));
            end
            if data.inv_flag
                data.im = 1-data.im;
            end
        end
        
        if data.log_flag(1) 
            xx2 = log10(xx2);
        end
        
        if data.log_flag(2) 
            xx1 = log10(xx1);
        end
        
        if iscell( data.im )
            im = data.im{jj};
        else
            im = data.im;
        end
        
         imagesc( xx2, xx1, im );
        
        
        
        hold on;
        
        if size(data.clist,2)==1 || data.newfig_flag
            colorbar
            
            cc = colormap;
            cc(1,:) = [0.5,0.5,0.5];
            colormap(cc);
            
            tmp = im;
            tmp(tmp==0) = nan;
            min_caxis = min(tmp(:));
            max_caxis = max(tmp(:));
            
            N = size(cc,1);
            c = (N*min_caxis-max_caxis)/(N-1);
            if ~isnan( max_caxis )
                caxis( [c,max_caxis] );
            end
        end
        
        
        axis( [xx2(1),xx2(end),xx1(1),xx1(end)] );
        set(gca,'layer','top')
    end
    
    
    % set the scale on the axes
    if data.log_flag(1)
         if (numel(data.ind)==1) || ~( data.kde_flag || data.hist_flag )
            set(gca,'XScale','log' );
         end
    end
    
    if data.log_flag(2)
        if (numel(data.ind)==1) || ~( data.kde_flag || data.hist_flag )
            set(gca,'YScale','log' );
        end
    end
    
    % set the labels on the axis.
    def = intGetDef( data.clist );
    def3d = intGetDef3D( data.clist );
    
    if data.time_flag
        labs = def3d(data.ind);
    else
        labs = def(data.ind);
    end
    
    
    if (numel(data.ind)==2) && ( data.kde_flag || data.hist_flag )
       if data.log_flag(1)
           labs{1} = [labs{1},' (log10)']; 
       end
       
       if data.log_flag(2)
           labs{2} = [labs{2},' (log10)']; 
       end
        
    end
    
    
    if data.trace_flag
        xlabel( 'Time (Frames)', 'Interpreter','none' );
        
        
        ylabel(  labs{1}, 'Interpreter','none' );
    else
        if numel( data.ind )
            xlabel( labs{1}, 'Interpreter','none'  );
        end
        
        if numel( data.ind ) == 2
            ylabel(  labs{2} , 'Interpreter','none');
        elseif data.den_flag
            ylabel( 'Density', 'Interpreter','none' );
        else
            ylabel( 'Number' , 'Interpreter','none');
        end
    end
    
    set( gca, 'Box', 'on' );
    
    if ~data.newfig_flag
        legend( data.h, data.legend );
    end
    
    set( gca, 'YDir', 'normal' );
    
end

if data.dot_flag || (numel(data.ind)==1)
    xlim_ = xlim;
    XM = mean(xlim_);
    xlim( XM+1.05*(xlim_-XM) );
end

end

%% internal show data fuction 
function data = intIntShow( clist, data )


if iscell(clist)
    
    nc = size( clist,2 );
    nr = size( clist,1 );
    
    if (nr~=1) && (nc~=1)
        error( 'At least one dimension of the clist cell array should be unitary' );
    else
        if nr > 1
            if data.time_flag
                clist = gateTool( clist, 'merge', 'time' );
            else
                clist = gateTool( clist, 'merge', 'skip3d' );
            end
            data = intIntShow( clist, data );
        else
            for ii = 1:nc
                data = intIntShow( clist{ii}, data );
            end
        end
    end
    
else
    
    data = intIntIntShow( clist, data );
    hold on;
end

end


%% internal show data fuction 
function data = intIntIntShow( clist, data )

if isfield( clist, 'name' );
    name = clist.name;
else
    name = ['data ', num2str(numel( data.h )) ];
end

if data.newfig_flag
    data.fig_ptr = [data.fig_ptr, figure()];
end

switch numel( data.ind )
    
    case 0
        error( 'No indices to show' );
    case 1 % 1D
        if data.kde_flag
            [data,h] = intShowKDE1D(  clist, data, name );
        %elseif data.time_flag
        %    [data,h] = intTime( clist, data );
        else
            [data,h] = intShowHist1D( clist, data, name );
        end
    case 2 % 2D
        if data.hist_flag
            [data,h] = intShowHist2D( clist, data, name );
        elseif data.dot_flag
            [data,h] = intShowDot(    clist, data, name );
        elseif data.kde_flag
            [data,h] = intShowKDE2D(  clist, data, name );
        else %default
            [data,h] = intShowDot(    clist, data, name );
        end
end

data.h = [data.h,h];



nc = size( clist.data, 1 );

if data.time_flag
    name = [name,' (',num2str( data.n, '%1.2g' ),' points)'];
else
    name = [name,' (',num2str( nc ),' cells)'];
end
   
if data.newfig_flag
    legend( h, name );
else
    data.legend = {data.legend{:},name};
end

end

%% Show 1D histogram
function [data,h] = intShowHist1D( clist, data, name )

[x1,x0,flagger,n] = intGetDataC( clist, data,1 );
data.n = n;

[y,x] = hist( x1, data.binS.xx );
dy    = intDoError(y); 

if data.den_flag
    dx = diff(x(1:2));
    %dx = ([dx(1),dx]+[dx,dx(end)])/2;
    
    normer = 1./(dx*sum(y(:)));
    y = y*normer;
    dy = dy*normer;
end


if data.log_flag(1)
    x_plot = exp(x);
else
     x_plot = x;
end

if isfield( clist, 'color' )
    cc = clist.color;
    h = plot( x_plot,y, '.-', 'color', cc );
else
    h = plot( x_plot,y, '.-' );
    cc = h.Color;
end

if data.error_flag
    hold on;
    plot( x_plot,intFixError(y-dy), ':', 'color', cc );
    plot( x_plot,intFixError(y+dy), ':', 'color', cc );
end


if ~data.bin_flag
    data.bin = x;
end

if data.stat_flag
    intDoStatAn( x10, x_plot, y, n, data, cc, name );
end

end

%% Do statistical analysis.
function intDoStatAn( x1, x, y, n, data, cc, name )

   hold on;
   
      styl = '%1.3e';

      
   x1_mean = mean( x1 );
   x1_std  = std(  x1 );
   x1_max  = max(  x1 );
   x1_min  = min(  x1 );
   x1_p1   = x1_mean+x1_std;
   x1_p1m  = x1_mean+x1_std/sqrt(n);
   x1_m1   = x1_mean-x1_std;
   x1_m1m  = x1_mean-x1_std/sqrt(n);
   
   all_out_text = [name,' -- stats: n = ',num2str( n, styl ),', '];
   
   y1_mean = interp1( x,y, x1_mean );
   y1_p1   = interp1( x,y, x1_p1 );
   y1_p1m  = interp1( x,y, x1_p1m );
   y1_m1   = interp1( x,y, x1_m1 );
   y1_m1m  = interp1( x,y, x1_m1m );
   y1_max  = interp1( x,y, x1_max ,'linear','extrap');
   y1_min  = interp1( x,y, x1_min,'linear','extrap' );
   
   
   if data.log_flag(2)
       del = [1e-1,1];
   else
       del = [0,1];
   end
   
   
   plot( x1_mean+[0,0], del*y1_mean, 'x:', 'color', cc, 'MarkerSize', 10 );
   
   out_text = [' mean: ',num2str( x1_mean, styl )];
   text( x1_mean, y1_mean/2, out_text, 'color', cc );
   all_out_text = [ all_out_text, out_text,','];
   
   plot( x1_p1+[0,0], del*y1_p1, 'x:', 'color', cc, 'MarkerSize', 10 );
   
   out_text = [' std: ',num2str( x1_std, styl )];
   text( x1_p1, y1_p1*.75, out_text, 'color', cc );
   all_out_text = [ all_out_text, out_text,','];
   
   plot( x1_m1+[0,0], del*y1_m1, 'x:', 'color', cc, 'MarkerSize', 10 );
   
   %out_text = [' std: ',num2str( x1_std, styl )];
   %text( x1_p1, y1_p1*.75, out_text, 'color', cc );
   %all_out_text = [ all_out_text, out_text,','];
   
   plot( x1_p1m+[0,0], del*y1_p1m, 'x:', 'color', cc, 'MarkerSize', 10 );
   plot( x1_m1m+[0,0], del*y1_m1m, 'x:', 'color', cc, 'MarkerSize', 10 );
  % plot( x1_max+[0,0], del*y1_max, 'x:', 'color', cc, 'MarkerSize', 10 );
  % plot( x1_min+[0,0], del*y1_min, 'x:', 'color', cc, 'MarkerSize', 10 );
   
   out_text = [' error: ',num2str( x1_std/sqrt(n), styl )];
   text( x1_p1m, y1_p1m*.25, out_text, 'color', cc );
   all_out_text = [ all_out_text, out_text,','];
   
   out_text = [' max: ',num2str( x1_std/sqrt(n), styl )];
   %text( x1_max, y1_max, out_text, 'color', cc,...
   %    'VerticalAlignment', 'baseline');
   all_out_text = [ all_out_text, out_text,','];
   
   out_text = [' min: ',num2str( x1_std/sqrt(n), styl )];
   %text( x1_min, y1_min, out_text, 'color', cc,...
   %    'HorizontalAlignment', 'right', 'VerticalAlignment', 'baseline');
   all_out_text = [ all_out_text, out_text,'.'];
   
   disp( all_out_text );
end


function dy = intDoError( y )

dy = sqrt( y );
dy(dy<1) = 1;

end

function y = intFixError( y )

y(y<0) = 0;

end

%% show 1D kde
function [data,h] = intShowKDE1D( clist, data, name )

[x1,x0,flagger,n] = intGetDataC( clist, data, 1 );
data.n = n;

bin = data.binS(1).xx;
dx  = data.binS(1).dx;
rk  = data.binS(1).rk_pix;

[y,x] = hist( x1, bin );


if data.log_flag(1)
    x_plot = exp(x);
else
    x_plot = x;
end


%[yf,dyf] = intConv1D( y, data, dx );
[yf,dyf] = intConv1Dint( y, rk );

%dyf =  intDoError( yf );

if data.den_flag
    normer = 1./( sum(y(:))*dx );
    yf = yf*normer;
    dyf = dyf*normer;
end

if isfield( clist, 'color' )
    cc = clist.color;
    h = plot( x_plot,yf, '-', 'color', cc );
else
    h = plot( x_plot,yf, '-' );
    cc = h.Color;
end

if data.error_flag
    hold on;
    plot( x_plot,intFixError(yf-dyf), ':', 'color', cc );
    plot( x_plot,intFixError(yf+dyf), ':', 'color', cc );
end


if ~data.bin_flag
    data.bin = x;
end


if data.stat_flag
    intDoStatAn( x10, x_plot, yf, n, data, cc, name);
end


end

%% Make the bin sizes if they aren't specified
function data = intMakeBins( clist, data )

for ii = 1:numel( data.ind )
    if data.kde_flag
           num = data.multi;
    else
       if isfield( data, 'bin' ) && ~isempty( data.bin ) 
           num = data.bin(ind);
       else
           num = intChooseBin(clist, data, ii);
       end
    end

   binS = intMakeDX( clist, data, num, ii );
    
    if ~data.kde_flag
        binS.rk_pix = [];
        binS.rm_pix = [];
    else
        if isfield( data, 'rk' ) && ~isempty( data.rk )
            binS.rk_pix = data.rk(ind)/binS.dx;
        else
            binS.rk_pix = intChooseRK(clist, data, ii);
        end
        
        if isfield( data, 'rm' ) && ~isempty( data.rm )
            binS.rm_pix = data.rm(ind)/binS.dx;
        else
            binS.rm_pix = binS.rk_pix;
        end
    end
    
    data.binS(ii) = binS;
end
end

% Make structures for binning the data or determining the kernel radius
function binS = intMakeDX( clist, data, num, ind )
x = intGetData( clist, data, data.ind(ind), data.units(ind) );
if data.log_flag(ind)
    x = log(x);
end
x = fixVals( x );

x_max = max( x(:) );
x_min = min( x(:) );

if x_max == x_min
    tmp = x_max;
    x_max = tmp+1;
    x_min = tmp-1;
end

    DX = x_max - x_min;
    xx = DX*(0:(num-1))/(num-1)+x_min;
    dx = xx(2)-xx(1);
    
    binS.xx    = xx;
    binS.dx    = dx;
    binS.DX    = DX;
    binS.x_max = x_max;
    binS.x_min = x_min;
    binS.x     = x;
end


% find the fundamental resolution of the data.
function dx_min = intFindSmallest( x )

dx_min = min(diff(sort(unique(x(:)))));

if isempty( dx_min )
    dx_min = 1;
end


end

%% Make automatic choice of bin size.
function num_ = intChooseBin(clist, data, ind)

del = 2;

binS = intMakeDX( clist, data, 2, ind );
x    = intGetDataC( clist, data, ind );

dx_min = intFindSmallest( x );
maxBinNum = min( [floor(binS.DX/dx_min),data.multi]);

ln_vec = log(data.minBinNum):log(del):log(maxBinNum);
n_vec  = round( exp(ln_vec) );

num_n = numel(n_vec);

if num_n == 0
    num_ = data.multi;
else
    switcher = nan( [1,num_n] );
    
    for ii = 1:num_n
        num  = n_vec(ii);
        binS = intMakeDX( clist, data, num, ind );
        
        y = hist( x, binS.xx );
        
        if false
            delta_y = abs(diff(y));
            dy      = sqrt( (y(2:end)+y(1:end-1))/2 );
        else
            tmp = diff(y);
            tmp = tmp([1,1:end,end]);
            delta_y = abs(tmp(2:end)+tmp(1:end-1))/2;
            dy      = sqrt( y );
        end
        
        %switcher(ii) = mean( delta_y > 2*dy );
        switcher(ii) = sum( y.*(delta_y > 2*dy))/sum(y);
    end
    
    
    cutt = 0.5;
    
    ind_n = find( switcher < cutt, 1, 'first' ) - 1;
    
    if isempty( ind_n ) || ind_n < 1 || ind_n > num_n
        if switcher(1) < cutt
            ind_n = 1;
            num_ = n_vec(ind_n);
        else switcher(end) > cutt
            num_ = maxBinNum;
            ind_n = num_n;
        end
    end
    
    num_ = n_vec(ind_n);
end
end

%% Make automatic selection of kernel radius for kde
function rk_pix = intChooseRK(clist, data, ind)

binS = intMakeDX( clist, data, data.multi, ind );
x    = intGetDataC( clist, data, ind );

dx_min = intFindSmallest( x );
maxBinNum = min( [(binS.DX/dx_min),data.multi]);


ln_vec = log(data.minBinNum):log(1.5):log(maxBinNum);
n_vec  = round( exp(ln_vec) );
rk_vec = data.multi./n_vec;

num_n = numel(n_vec);

if num_n == 0
    rk_pix = 1;
else
    switcher = nan( [1,num_n] );
    
    for ii = 1:num_n
        num  = n_vec(ii);
        
        y = hist( x, binS.xx );
        [y,dy] = intConv1Dint( y, rk_vec(ii) );
        
        delta_y = rk_vec(ii)*abs(diff(y));
        dy      = (dy(1:end-1)+dy(2:end))/2;
        y_      = (y(2:end)+y(1:end-1))/2; 
        
        switcher(ii) =sum( y_.*(delta_y > 2*dy))/sum(y_);
    end
    
    cutt = .5;
    
    ind_n = find( switcher < cutt, 1, 'first' ) - 1;
    
    if isempty( ind_n ) || ind_n < 1 || ind_n > num_n
        if switcher(1) < cutt
            ind_n = 1;
        else switcher(end) > cutt
            ind_n = num_n;
        end
    end
    
    rk_pix = rk_vec(ind_n);
end
end

%% Strip out imaginary, nan and inf values
function [x,flagger] = fixVals( x )

flagger = ~( isinf( x ) + isnan( x) + imag( x ) );
x = x(flagger);

end

%% Make 2D Hist
function [data,h] = intShowHist2D( clist, data, name )

[x_vec,x0,flagger,n] = intGetDataC( clist, data, [1,2] );
data.n = n;
x1 = x_vec(:,1);
x2 = x_vec(:,2);

[y,xx] = hist3( [x2,x1], {data.binS(2).xx,data.binS(1).xx} );

if data.log_flag(3)
    y = log(y);
    y(isinf(y)) = nan;
    y(isnan(y)) = min(y(:));
end


hold on;
if isfield( clist, 'color' )
    cc = clist.color;
    h = plot( nan, nan, '.', 'color', cc);

else
    h = plot( nan, nan, '.');
end

cc = h.Color;

if ischar( cc )
    cc = convert_color( cc)
end



if (size( data.clist,2 ) > 1) && ~data.newfig_flag    
    dd = y/max(y(:));
    
    im = cat(3, dd*cc(1), dd*cc(2), dd*cc(3) );
    
    
    if isfield( data, 'im' ) && ~isempty( data.im )
        data.im = data.im + im;
    else
        data.im = im;
    end
    
else
    data.im = {data.im{:},y};
end

data.xx = xx;


end

%% Make 2D KDE
function [data,h] = intShowKDE2D( clist, data, name )

[x_vec,x0,flagger,n] = intGetDataC( clist, data, [1,2] );
data.n = n;
x1 = x_vec(:,1);
x2 = x_vec(:,2);

bin = {data.binS(2).xx,data.binS(1).xx};
dx  = [data.binS(2).dx,data.binS(1).dx];

[y,xx] = hist3( [x2,x1], bin );


if data.cond_flag
   ys = sum( y, 1 );
   
   ys(ys==0) = 1;
   
   y = y./(ones([size(y,1),1])*ys);
 %  cutt = 1/(2*data.mult);
 %  y(y>cutt) = cutt;
   
end

%y = intConv2Dadd( y, data, dx );
y = intConv2D( y, data );

if data.den_flag
    y = y./sum(y(:));
end

y = y/prod(dx);

if data.log_flag(3)
    y = log(y);
    y(isinf(y)) = nan;
    y(isnan(y)) = min(y(:));
end


hold on;

if isfield( clist, 'color' )
    cc = clist.color;
    h = plot( nan, nan, '.', 'color', cc);

else
    h = plot( nan, nan, '.');
end


cc = h.Color;

if ischar( cc )
    cc = convert_color( cc)
end

if data.inv_flag
   cc = 1-cc; 
end

if size( data.clist, 2 ) > 1 && ~data.newfig_flag 

    
    dd = y/max(y(:));
    
    im = cat(3, dd*cc(1), dd*cc(2), dd*cc(3) );
    
    
    if isfield( data, 'im' ) && ~isempty( data.im )
        data.im = data.im + im;
    else
        data.im = im;
    end
    
else
    data.im = {data.im{:},y};
end

data.xx = xx;
data.bin = bin;


end

%% Do gaussian convolution in 2D for KDE
function [yf] = intConv2D( y, data )

rk = [data.binS(1).rk_pix,data.binS(2).rk_pix];
rm = [data.binS(1).rm_pix,data.binS(2).rm_pix];



xx = -ceil(1.1*rm(1)):ceil(1.1*rm(1));
yy = -ceil(1.1*rm(2)):ceil(1.1*rm(2));
[X,Y] = meshgrid( xx,yy);
R = sqrt((X./rm(1)).^2+(Y./rm(2)).^2);
fdisk = double( R<=1 );

%fdisk = fspecial( 'disk', rm  );

xx = -ceil(7*rk(1)):ceil(7*rk(1));
yy = -ceil(7*rk(2)):ceil(7*rk(2));
[X,Y] = meshgrid( xx,yy);
R = sqrt((X./rk(1)).^2+(Y./rk(2)).^2);

fgaus = exp( -R.^2/2 )/(2*pi*rk(1)*rk(2));

minner = imfilter( y, fdisk, 0 );

yf      = imfilter( y, fgaus, 0 );

%yf = max( yf, minner );

yf( minner==0) = 0;
yf = yf;

end

%% Internal KDE convolution function
function [yf,dyf] = intConv1Dint( y, rk )

xx = -ceil(7*rk(1)):ceil(7*rk(1));
R = sqrt((xx./rk(1)).^2);

fgaus = exp( -R.^2/2 )/sqrt(2*pi*rk(1)^2);

yf      = imfilter( y, fgaus, 0 );
dyf     = sqrt(imfilter( y, fgaus.^2, 0 ));

end

function [yf,dyf] = intConv1D( y, data, dx )

if isempty( data.rk )
    [yf,dyf,rk] = intConv1Dadd( y, data, dx );
else
    rk = data.rk./dx;
    
    
    
    xx = -ceil(7*rk(1)):ceil(7*rk(1));
    R = sqrt((xx./rk(1)).^2);
    
    fgaus = exp( -R.^2/2 )/sqrt(2*pi*rk(1)^2);
    
    yf      = imfilter( y, fgaus, 0 );
    dyf     = sqrt(imfilter( y, fgaus.^2, 0 ));
    
    %yf = max( yf, minner );
    
end

end

%% Show do plot in 2D
function [data,h] = intShowDot( clist, data, name )

    hold on;

    
if ~data.time_flag
    x1 = intGetData( clist, data, data.ind(1), data.units(1) );
    x2 = intGetData( clist, data, data.ind(2), data.units(2) );

    
    if isfield( clist, 'color' )
        h = scatter( x1, x2, [], clist.color, '.' );
    else
        h = scatter( x1, x2, '.' );
    end
else
    x1 = squeeze(clist.data3D(:,data.ind(1),:));
    x2 = squeeze(clist.data3D(:,data.ind(2),:));
    
    [~,flagger] = fixVals( x1 + x2 );
    data.n = sum( flagger(:) );
    n   = data.n;
    
    if isfield( clist, 'color' )
        cc = clist.color;
        h = plot( nan,nan, '.', 'color', cc );
    else
        h = plot( nan,nan, '.' );
        cc = h.Color;
    end
   
    if ischar( cc )
        cc = convert_color(cc);
    end
    
    nc = size( x1, 1 );
    
    for ii = 1:nc
        
        hh = plot( nan, nan, '.' );
        cc_ii = hh.Color;
        cc_ii = (cc_ii+cc)/2;
        
        plot( x1(ii,:), x2(ii,:), 'color', cc_ii );
        
        start_ind = find( ~isnan( x1(ii,:) ), 1, 'first' );
        end_ind   = find( ~isnan( x1(ii,:) ), 1, 'last' );
        
        plot( x1(ii,start_ind), x2(ii,start_ind), '.','MarkerSize', 10, 'color', cc_ii );
        plot( x1(ii,start_ind), x2(ii,end_ind  ), 'x','MarkerSize', 10, 'color', cc_ii );
    end
    
end


end

%% Get field definition from the structure
function def = intGetDef( clist );

if isstruct( clist )
    def = clist.def;
elseif iscell( clist )
    def = intGetDef( clist{1} );
else
    error( 'empty clist in intGetDef' );
end


end

%% Get 3d field definition from the structure
function def = intGetDef3D( clist );

if isstruct( clist )
    if isfield( clist, 'def3d' )
        def = clist.def3d;
    else
        def = {};
    end
elseif iscell( clist )
    def = intGetDef3D( clist{1} );
else
    error( 'empty clist in intGetDef' );
end


end

%% Fix colors. From internet.
function outColor = convert_color(inColor)

charValues = 'rgbcmywk'.';  %#'
rgbValues = [eye(3); 1-eye(3); 1 1 1; 0 0 0];
assert(~isempty(inColor),'convert_color:badInputSize',...
    'Input argument must not be empty.');

if ischar(inColor)  %# Input is a character string
    
    [isColor,colorIndex] = ismember(inColor(:),charValues);
    assert(all(isColor),'convert_color:badInputContents',...
        'String input can only contain the characters ''rgbcmywk''.');
    outColor = rgbValues(colorIndex,:);
    
elseif isnumeric(inColor) || islogical(inColor)  %# Input is a numeric or
    %#   logical array
    assert(size(inColor,2) == 3,'convert_color:badInputSize',...
        'Numeric input must be an N-by-3 matrix');
    inColor = double(inColor);           %# Convert input to type double
    scaleIndex = max(inColor,[],2) > 1;  %# Find rows with values > 1
    inColor(scaleIndex,:) = inColor(scaleIndex,:)./255;  %# Scale by 255
    [isColor,colorIndex] = ismember(inColor,rgbValues,'rows');
    assert(all(isColor),'convert_color:badInputContents',...
        'RGB input must define one of the colors ''rgbcmywk''.');
    outColor = charValues(colorIndex(:));
    
else  %# Input is an invalid type
    
    error('convert_color:badInputType',...
        'Input must be a character or numeric array.');
    
end
end


%% intDoMerge merges clists into a single list
function clistM = intDoMerge( clist, ID_ind, skip3D )

if ~exist( 'skip3D', 'var' )
    skip3D = false;
end

if ~exist( 'ID_ind', 'var' )
    def = intGetDef( clist );
    ID_ind = find(cellfun(@(IDX) ~isempty(IDX), strfind(def, 'ID')));
end


if isstruct( clist )
    clistM = clist;
else
    nc = numel( clist );
    
    data = [];
    clistM = [];
    
    
    for ii = 1:nc
        if iscell( clist{ii} )
            clist_ = intDoMerge( clist{ii}, [], skip3D );
        else
            clist_ = clist{ii};
        end
        
        if isempty( clistM )
            clistM = clist_;
        else
            % regular clist
            maxID = max( clistM.data(:,1) );
            
            tmp = clist_.data(:,ID_ind);
            tmp = tmp + maxID;
            tmp(tmp==maxID) = 0;
            
            clist_.data(:,ID_ind) = tmp;
             
            clistM.data = [clistM.data;...
                clist_.data];
            
            %clist 3D
            
            if isfield( clist_, 'data3D' ) && ~skip3D
                clist_.data3D(:,1,:) = clist_.data3D(:,1,:) +maxID;
                
                ss = size(clistM.data3D);
                               clistM.data3D = [clistM.data3D;...
                    clist_.data3D(:,1:ss(2),:)];
            end
        end
    end
    
end
end


%% Merge structure with different fields
function g12 = intMergeStruct( g1, g2)

ng1 = numel(g1);
ng2 = numel(g2);

tmp1 = fieldnames( g1 );
tmp2 = fieldnames( g2 );

names = unique({tmp1{:},tmp2{:}});
nnames = numel(names);

for ii = (ng1+ng2):-1:1

    tmp_gate = [];
    
    for jj = 1:nnames
        
        if ii <= ng1
            tmps = g1(ii);
        else
            tmps = g2(ii-ng1);
        end
        
        if isfield( tmps, names{jj} )
            tmp = getfield( tmps, names{jj} );
        else
           tmp = []; 
        end
        
        tmp_gate = setfield( tmp_gate,  names{jj}, tmp );
    end
    
    g12(ii) = tmp_gate;
    
end
end

%% Load clist from file
function clist = intLoadClist( dirname, data )

drill_flag = data.drill_flag;

clist = {};


if exist( dirname, 'file' ) == 2
    
    tmp = load( dirname );
    
    if isstruct( tmp ) && isfield( tmp, 'clist' );
        clist = tmp.clist;
    else
        clist = tmp;
    end
    
    
else
    dirname = fixDir( dirname );

    if ~exist( dirname, 'dir' )
        error( ['Directory ', dirname, 'does not exist.' ] );
    else
        if drill_flag
            clist = intRecLoad( {}, dirname, 0 );
        else
            contentsD = dir(  [dirname, 'xy*'] );
            
            nc = numel( contentsD );
            
            if nc == 0
                
                filename = [dirname,'clist.mat'];
                if exist( filename, 'file' );
                    clist = load( filename );
                    clist.filename = [fixDir(pwd),filename];
                else
                    error([ 'Can''t find file ', filename] );
                end
                
            else
                
                counter = 0;
                for ii = 1:nc
                    dirname_xy = fixDir( [dirname,contentsD(ii).name] );
                    
                    filename = [dirname_xy,'clist.mat' ];
                    
                    if exist( filename, 'file' )
                        counter = counter+1;
                        tmp = load( filename );
                        tmp.filename = [fixDir(pwd),filename];
                        
                        clist{counter} = tmp;
                    end
                end
            end
        end
    end
end
end

% recursive loading of clist from directory.
function [clist,count] = intRecLoad( clist, dirname, count )

dirname = fixDir( dirname );

contents = dir( dirname );

nc = numel( contents );

for ii = 1:nc
    
    if contents( ii).isdir && contents(ii).name(1) ~= '.'
        dirname_ii = [dirname,contents(ii).name];
        %disp( ['Checking directory ',dirname_ii] );
        [clist,count] = intRecLoad( clist, dirname_ii, count );
    elseif strcmp( contents(ii).name, 'clist.mat' )
        count = count+1;
        name = [dirname,'clist.mat'];
        disp( ['Loading ',name] );
        tmp = load( name );
        
        if isstruct( tmp ) && isfield( tmp, 'clist' );
            clist{1,count} = tmp.clist;
        else
            clist{1,count} = tmp;
        end
        
        end
end


end

%% squeeze all clists into a single column
function clistS = intSqueeze( varargin )

if nargin == 1
    clistS = {};    
    clistS = intSqueeze( clistS, varargin{1} );
elseif nargin == 2
    clistS = varargin{1};
    clist  = varargin{2};
    
    nc  = numel( clist );
    
    for ii = 1:nc
       
        if iscell( clist{ii} )
            clistS = intSqueeze( clistS, clist{ii} );
        elseif isstruct( clist{ii} )
            clistS = { clistS{:}, clist{ii} }';
        else
            error( 'Not a clist' );
        end
    end
end
end

%% expand all clists into a row.
function clistS = intExpand( varargin )

if nargin == 1
    clistS = {};    
    clistS = intExpand( clistS, varargin{1} );
elseif nargin == 2
    clistS = varargin{1};
    clist  = varargin{2};
    
    nc  = numel( clist );
    
    for ii = 1:nc
       
        if iscell( clist{ii} )
            clistS = intExpand( clistS, clist{ii} );
        elseif isstruct( clist{ii} )
            clistS = { clistS{:}, clist{ii} };
        else
            error( 'Not a clist' );
        end
    end
end
end

%% Get data to return at the command line
function output = intGet( clist, g_ind )

output = [];
if iscell( clist )
    nc = numel(clist);
    
    for ii = 1:nc
        output = [output;  intGet( clist{ii}, g_ind )];
    end
else
    output = clist.data(:,g_ind);
end

end

%% get 3d data out of the structure to return at the command line
function output = intGet3D( clist, g3d_ind )

output = [];
if iscell( clist )
    nc = numel(clist);
    
    for ii = 1:nc
        output = cat(1, output, intGet3D( clist{ii}, g3d_ind ));
    end
else
    output = clist.data3D(:,g3d_ind,:);
end

end

%% Get data out of the structures
function x = intGetData( clist, data, ind, units )

if ~exist( 'units', 'var' )
    units = 1;
end

if data.time_flag
    x = clist.data3D(:,ind,:);
    x = x(:);
    
    x = intApplyGate3d( x, clist );
else
    x = clist.data(:,ind);
end

x = units*x;

end

%% Get data out of the structures
function [x,x0,flagger,n] = intGetDataC( clist, data, wind )

tmp = intGetData( clist, data, data.ind(wind(1)), data.units(wind(1)) );

n_ind = numel( wind );

x  = nan( [numel(tmp),n_ind] );
x0 = nan( [numel(tmp),n_ind] );

for ii = 1:n_ind
    tmp = intGetData( clist, data, data.ind(wind(ii)), data.units(wind(ii)) );
    
    x0(:,ii) = tmp;

    if data.log_flag(wind(ii))
        tmp = log(tmp);
    end
    
    x(:,ii) = tmp;
end

[~,flagger] = fixVals( sum(x,2) );

x  = x(flagger,:);
x0 = x0(flagger,:);

n= sum(flagger);
end


%% Gate the 3d data
function x = intApplyGate3d( x, clist )

ss     = size(clist.data3D);
inflag = true(ss(1)*ss(3),1);

if isfield( clist, 'gate3D' ) && ~isempty ('gate3D.clist')
    for ii = 1:numel(clist.gate3D)
        if numel(clist.gate3D(ii).ind) == 2
            
            tmp1 = clist.data3D(:,clist.gate3D(ii).ind(1),:);
            tmp2 = clist.data3D(:,clist.gate3D(ii).ind(2),:);
            
            inflag = and(inflag, inpolygon( tmp1(:), tmp2(:), ...
                clist.gate3D(ii).xx(:,1), clist.gate3D(ii).xx(:,2) ));
        else
            tmp = clist.data3D(:,clist.gate3D(ii).ind,:);
            inflag = and( inflag, and( tmp(:) > min(clist.gate3D(ii).x), tmp(:) < max(clist.gate3D(ii).x)));
        end
    end
end

x = x(inflag);

end

%% Add time fields to 3d data structure 
function clist = intDoAddT( clist )

if iscell( clist )
    nc = numel(clist);
    
    for ii = 1:nc
        clist{ii} = intDoAddT( clist{ii} );
    end
elseif isstruct( clist )
    ss = size( clist.data3D );
    
    [~,tmp] = gateTool( clist, 'get', 2, 'time' );
    
    len  = reshape( ~isnan(squeeze(tmp)),[ss(1),ss(3)]);
    age = cumsum( len, 2 );
    age(~len) = nan;
    
    age_rel = age;
    age_rel = age./(max(age,[],2)*ones([1,size(age,2)]));
    
    time = ones([ss(1),1])*(1:ss(3)); 
    
    clist = gateTool( clist, 'add3D', time, 'Time (Frames)' );
    clist = gateTool( clist, 'add3D', age, 'Age (Frames)' );
    clist = gateTool( clist, 'add3D', age_rel, 'Relative Age' );
else
    error( 'Internal error. not clist' );
end

end

%% Clear gates
function clist = intClear( clist, ind )

if iscell( clist )
    nc = numel(clist);
    
    for ii = 1:nc
        clist{ii} = intClear( clist{ii}, ind );
    end
elseif isstruct( clist )
    clist = gateStrip( clist, ind );
end

end

%% output csv and xls files
function intcsv( clist, data );


filename = data.export_filename;

disp( 'Warning: All lists contained in clist will be stripped (ungated data removed) and merged (multiple lists combined) before xls export.');


if ~data.time_flag
    clist = gateTool( clist, 'strip', 'skip3d' );
    clist = gateTool( clist, 'merge', 'skip3d' );
    
    tmp1 = num2cell( clist.data );
    tmp2 = reshape( clist.def, [1,numel(clist.def)] );
    
    tmp = cat(1,tmp2,tmp1);
else
    clist = gateTool( clist, 'strip');
    clist = gateTool( clist, 'merge');
    
    if isfield( clist, 'data3D' )
        if ~isfield( data, 'export_index' ) || isempty( clist.data3D ) || isempty( data.export_index )
            error( 'Need an export index to export data3D' );
        elseif  ~(0<data.export_index) && data.export_index<=size(clist.data3D,2)
            error( 'Index outside the range of allowed indices for data3D' );
        else
            tmp = squeeze( clist.data3D(:,data.export_index,:) );
        end
    else
        error( 'No data3D field.' );
    end
end

if data.which_export_flag == 1
    csvwrite2( filename, tmp );
else
    disp( 'Warning: This function only works if excel is installed. Complain to matlab (ie mathworks) not me.' );
    
    xlswrite( filename, tmp );
end

end

%% crappy csv output written due to problems with matlabs implementation
function csvwrite2( filename, data )


cellflag = iscell( data );

nn = size( data )

fid = fopen(filename, 'w') ;

if fid
    for ii = 1:nn(1)
        for jj = 1:nn(2)
            
            if cellflag
                tmp = data{ii,jj};
            else
                tmp = data(ii,jj);
            end
            
            if ischar( tmp )
                fprintf(fid, '%s', tmp);
            elseif isnumeric( tmp )
                if numel( tmp ) == 1
                    fprintf(fid, '%e', tmp);
                else
                    error( 'No nonscalar allowed in csv.' );
                end
            else
                error( 'un recognized type in csv.' );
            end
            
            if jj ~= nn(2);
                fprintf(fid, '%c', ',' );
            end
        end
        fprintf(fid, '\n');
    end
    fclose(fid) ;
end
end
