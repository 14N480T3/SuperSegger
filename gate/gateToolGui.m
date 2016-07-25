function varargout = gateToolGui(varargin)
% GATETOOLGUI MATLAB code for gateToolGui.fig
%      GATETOOLGUI, by itself, creates a new GATETOOLGUI or raises the existing
%      singleton*.
%
%      H = GATETOOLGUI returns the handle to a new GATETOOLGUI or the handle to
%      the existing singleton*.
%
%      GATETOOLGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GATETOOLGUI.M with the given input arguments.
%
%      GATETOOLGUI('Property','Value',...) creates a new GATETOOLGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gateToolGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gateToolGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gateToolGui

% Last Modified by GUIDE v2.5 22-Jul-2016 16:48:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @gateToolGui_OpeningFcn, ...
    'gui_OutputFcn',  @gateToolGui_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before gateToolGui is made visible.
function gateToolGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gateToolGui (see VARARGIN)

% Choose default command line output for gateToolGui
handles.output = hObject;
handles.dirname.String = pwd;
handles.clist_found = 0;
handles.multi_clist = [];
updateGui(hObject,handles)
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gateToolGui wait for user response (see UIRESUME)
% uiwait(handles.figure1);





% --- Outputs from this function are returned to the command line.
function varargout = gateToolGui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.multi_clist;


function updateGui(hObject,handles)

if isfield(handles,'multi_clist') && ~isempty(handles.multi_clist) &&  isfield(handles.multi_clist{1},'def')
    handles.clist_found = 1;
else
    handles.clist_found = 0;
end


if handles.clist_found
    handles.def1.String = ['None';handles.multi_clist{1}.def'];
    handles.def2.String = ['None';handles.multi_clist{1}.def'];
    handles.def3d.String = ['None';handles.multi_clist{1}.def3d'];
    num_clist = numel(handles.multi_clist);
    names = {};
    for i = 1 : num_clist
        if isfield(handles.multi_clist{i},'name')
            names {end+1} = handles.multi_clist{i}.name;
        else
            names {end+1} = ['data',num2str(i)];
        end
    end
    handles.clist_choice.String = ['All';names'];
    handles.msgbox.String = ['Clists : ', num2str(num_clist)];
    set(findall(handles.action_panel, '-property', 'enable'), 'enable', 'on')
    set(findall(handles.show_panel, '-property', 'enable'), 'enable', 'on')
    set(findall(handles.save_panel, '-property', 'enable'), 'enable', 'on')
    set(findall(handles.def_panel, '-property', 'enable'), 'enable', 'on')
else
    set(findall(handles.action_panel, '-property', 'enable'), 'enable', 'off')
    set(findall(handles.show_panel, '-property', 'enable'), 'enable', 'off')
    set(findall(handles.save_panel, '-property', 'enable'), 'enable', 'off')
    set(findall(handles.def_panel, '-property', 'enable'), 'enable', 'off')
    
end


guidata(hObject,handles);


% --- Executes on button press in xls.
function xls_Callback(hObject, eventdata, handles)
% hObject    handle to xls (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathName] = uiputfile('data.csv', 'Save xls file',  handles.dirname.String);
if handles.clist_choice.Value == 1
    which_clist = handles.multi_clist;
else
    which_clist = handles.multi_clist{handles.clist_choice.Value-1};
end
gateTool(which_clist,'xls',[pathName,filesep,filename]);


% --- Executes on button press in csv.
function csv_Callback(hObject, eventdata, handles)
% hObject    handle to csv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathName] = uiputfile('data.csv', 'Save csv file',  handles.dirname.String);
if handles.clist_choice.Value == 1
    which_clist = handles.multi_clist;
else
    which_clist = handles.multi_clist{handles.clist_choice.Value-1};
end
gateTool(which_clist,'csv',[pathName,filesep,filename]);

% --- Executes on button press in save_mat_file.
function save_mat_file_Callback(hObject, eventdata, handles)
% hObject    handle to save_mat_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathName] = uiputfile('clist.mat', 'Save clist file',  handles.dirname.String);
if handles.clist_choice.Value == 1
    which_clist = handles.multi_clist;
else
    which_clist = handles.multi_clist{handles.clist_choice.Value-1};
end
gateTool(which_clist,'save',[pathName,filesep,filename]);

function [tmp_clist] = loadClistFromDir()
folderOrClist = uigetdir;
tmp_clist = gateTool(folderOrClist);

% --- Executes on button press in load_clist.
function load_clist_Callback(hObject, eventdata, handles)
% hObject    handle to load_clist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[tmp_clist] = loadClistFromDir()
updateGui(handles)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes on button press in drill.
function drill_Callback(hObject, eventdata, handles)
% hObject    handle to drill (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.multi_clist = gateTool(handles.dirname,'drill' );
guidata(hObject,handles);

% --- Executes on button press in merge.
function merge_Callback(hObject, eventdata, handles)
% hObject    handle to merge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of merge



% --- Executes on button press in dash.
function dash_Callback(hObject, eventdata, handles)
% hObject    handle to dash (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dash
handles.multi_clist = handles.multi_clist';
guidata(hObject,handles);

% --- Executes on button press in strip.
function strip_Callback(hObject, eventdata, handles)
% hObject    handle to strip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.multi_clist = gateTool(handles.multi_clist,'strip');
guidata(hObject,handles);


% --- Executes on button press in squeeze.
function squeeze_Callback(hObject, eventdata, handles)
% hObject    handle to squeeze (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.multi_clist = gateTool(handles.multi_clist,'squeeze');
guidata(hObject,handles);

% --- Executes on button press in expand.
function expand_Callback(hObject, eventdata, handles)
% hObject    handle to expand (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.multi_clist = gateTool(handles.multi_clist,'expand');
guidata(hObject,handles);

% --- Executes on button press in kde.
function kde_Callback(hObject, eventdata, handles)
% hObject    handle to kde (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of kde


% --- Executes on button press in stats.
function stats_Callback(hObject, eventdata, handles)
% hObject    handle to stats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of stats


% --- Executes on button press in time.
function time_Callback(hObject, eventdata, handles)
% hObject    handle to time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of time


% --- Executes on selection change in def1.
function def1_Callback(hObject, eventdata, handles)
% hObject    handle to def1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns def1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from def1


% --- Executes during object creation, after setting all properties.
function def1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to def1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in def2.
function def2_Callback(hObject, eventdata, handles)
% hObject    handle to def2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns def2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from def2


% --- Executes during object creation, after setting all properties.
function def2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to def2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hist_tool.
function hist_Callback(hObject, eventdata, handles)
% hObject    handle to hist_tool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hist_tool


% --- Executes on button press in dot.
function dot_Callback(hObject, eventdata, handles)
% hObject    handle to dot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dot


% --- Executes on button press in log.
function log_Callback(hObject, eventdata, handles)
% hObject    handle to log (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of log


% --- Executes on button press in cond.
function cond_Callback(hObject, eventdata, handles)
% hObject    handle to cond (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cond


% --- Executes on button press in show_gates.
function show_gates_Callback(hObject, eventdata, handles)
% hObject    handle to show_gates (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

index1 = handles.def1.Value - 1;
index2 = handles.def2.Value - 1;

varg = {'show'};

if ~handles.time.Value
    if ~index1 && ~index2
        %nothing
    elseif index1~=0 && index2 == 0
        varg{end+1} = index1;
    elseif index1==0 && index2 ~= 0
        varg{end+1} = index2;
    elseif index1~=0 && index2 ~= 0
        varg{end+1} = index1;
        varg{end+1} = index2;
    end
else
    if (handles.def3d.Value - 1) ~= 0
        varg{end+1} =  handles.def3d.Value - 1;
        varg{end+1} = 'time';
    else
        msgbox ('choose time index')
    end
end


if handles.stats.Value
    varg{end+1} = 'stat';
end

if handles.kde.Value
    varg{end+1} = 'kde';
end

if handles.hist.Value
    varg{end+1} = 'hist';
end
if handles.dot.Value
    varg{end+1} = 'dot';
end

if handles.log.Value
    varg{end+1} = 'log';
end
if handles.cond.Value
    varg{end+1} = 'cond';
end
if handles.err.Value
    varg{end+1} = 'err';
end

if handles.merge.Value
    varg{end+1} = 'merge';
end


if handles.clist_choice.Value == 1
    which_clist = handles.multi_clist;
else
    which_clist = handles.multi_clist{handles.clist_choice.Value-1};
end

gateTool(which_clist,varg{:},'no clear','newfig' );

% --- Executes on button press in err.
function err_Callback(hObject, eventdata, handles)
% hObject    handle to err (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of err


% --- Executes on button press in load.
function load_Callback(hObject, eventdata, handles)
% hObject    handle to load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(handles.dirname.String)
    handles.multi_clist = gateTool(handles.dirname.String);
    updateGui(hObject,handles)
end

% --- Executes on button press in add.
function add_Callback(hObject, eventdata, handles)
% hObject    handle to add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[tmp_clist] = loadClistFromDir();
handles.multi_clist = [handles.multi_clist,tmp_clist];
updateGui(hObject,handles)

% --- Executes on button press in delete.
function delete_Callback(hObject, eventdata, handles)
% hObject    handle to delete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.multi_clist = [];
updateGui(hObject,handles)

% --- Executes on selection change in def3d.
function def3d_Callback(hObject, eventdata, handles)
% hObject    handle to def3d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns def3d contents as cell array
%        contents{get(hObject,'Value')} returns selected item from def3d


% --- Executes during object creation, after setting all properties.
function def3d_CreateFcn(hObject, eventdata, handles)
% hObject    handle to def3d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in make_gate.
function make_gate_Callback(hObject, eventdata, handles)
% hObject    handle to make_gate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

index1 = handles.def1.Value - 1;
index2 = handles.def2.Value - 1;



varg = {'make'};

if ~index1 && ~index2
    msgbox ('choose an index')
elseif index1~=0 && index2 == 0
    varg{end+1} = index1;
elseif index1==0 && index2 ~= 0
    varg{end+1} = index2;
elseif index1~=0 && index2 ~= 0
    varg{end+1} = index1;
    varg{end+1} = index2;
end

if handles.merge.Value
    varg{end+1} = 'merge';
end

if index1 || index2
    if handles.clist_choice.Value == 1
        handles.multi_clist = gateTool(handles.multi_clist,varg{:},'no clear','newfig');
    else
        handles.multi_clist{handles.clist_choice.Value-1} = gateTool(handles.multi_clist{handles.clist_choice.Value-1},varg{:},'no clear','newfig');
    end
    
end
guidata(hObject,handles);



function dirname_Callback(hObject, eventdata, handles)
% hObject    handle to dirname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dirname as text
%        str2double(get(hObject,'String')) returns contents of dirname as a double


% --- Executes during object creation, after setting all properties.
function dirname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dirname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function uipushtool1_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.dirname.String = uigetdir;
guidata(hObject,handles);

% --------------------------------------------------------------------
function hist_tool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to hist_tool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function contour_tool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to contour_tool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function scatter_tool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to scatter_tool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function debug_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to debug (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
keyboard;


% --- Executes on button press in close_figs.
function close_figs_Callback(hObject, eventdata, handles)
% hObject    handle to close_figs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(gateToolGui, 'HandleVisibility', 'off');
close all;
set(gateToolGui, 'HandleVisibility', 'on');


% --- Executes on button press in clear_gate.
function clear_gate_Callback(hObject, eventdata, handles)
% hObject    handle to clear_gate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.multi_clist = gateTool(handles.multi_clist,'clear');
guidata(hObject,handles);

% --- Executes on button press in name.
function name_Callback(hObject, eventdata, handles)
% hObject    handle to name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


name = getString ('Clist name', 'Type clist name');
if handles.clist_choice.Value == 1
    handles.multi_clist = gateTool(handles.multi_clist,'name',name);
else
    handles.multi_clist{handles.clist_choice.Value-1} = gateTool(handles.multi_clist{handles.clist_choice.Value-1},'name',name);
end
updateGui(hObject,handles)

function num_return = getNumber (dlg_title, prompt)

num_lines = 1;
a = inputdlg(prompt,dlg_title,num_lines);

if ~isempty(a) % did not press cancel
    num_return = str2double(a(1));
else
    num_return = [];
end


function str_return = getString (dlg_title, prompt)

num_lines = 1;
a = inputdlg(prompt,dlg_title,num_lines);
if ~isempty(a) % did not press cancel
    str_return = a{1};
else
    str_return = [];
end


% --- Executes on selection change in clist_choice.
function clist_choice_Callback(hObject, eventdata, handles)
% hObject    handle to clist_choice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns clist_choice contents as cell array
%        contents{get(hObject,'Value')} returns selected item from clist_choice


% --- Executes during object creation, after setting all properties.
function clist_choice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to clist_choice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
