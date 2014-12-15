function varargout = ceo_tool(varargin)
% CEO_TOOL MATLAB code for ceo_tool.fig
%      CEO_TOOL, by itself, creates a new CEO_TOOL or raises the existing
%      singleton*.
%
%      H = CEO_TOOL returns the handle to a new CEO_TOOL or the handle to
%      the existing singleton*.
%
%      CEO_TOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CEO_TOOL.M with the given input arguments.
%
%      CEO_TOOL('Property','Value',...) creates a new CEO_TOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ceo_tool_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ceo_tool_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ceo_tool
%kathryn test hi
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ceo_tool_OpeningFcn, ...
                   'gui_OutputFcn',  @ceo_tool_OutputFcn, ...
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


% --- Executes just before ceo_tool is made visible.
function ceo_tool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ceo_tool (see VARARGIN)

% Choose default command line output for ceo_tool
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%% Get target data from XML file

% Prompt user for XML file.
% prompt = {'Please choose a file to load:'};
% movegui('center')
% dlg_title = 'Select Target File';
% num_lines = 1;
% def = {''};
% answer = inputdlg(prompt,dlg_title,num_lines,def);
[filename, pathname] = uigetfile('*.xml', 'Select a file to load');
if isequal (filename, 0)
    disp('User selected Cancel')
else
    disp(['User selected ', fullfile(pathname, filename)])
end

% Get site data from file.
xmlDoc = fullfile(pathname, filename);
doc = xmlwrite(xmlDoc);
a=strsplit(doc,{'<wmc__TEOSite Category="Daily"','</wmc__TEOSite>'});
no_of_targets = (length(a)-1)/2;
handles.no_of_targets = no_of_targets
sites(no_of_targets) = struct('site_no',[], 'passover_time',[], 'target_name',[], 'lat',[], 'long', [], 'notes', [], 'lenses', [], 'closest_approach', []);

% Store each site's data in a sites struct.
for i=1:no_of_targets
    b = char(a(2*i));
    
    %site_no
    sites(i).site_no=i;
    
    %target_name
    namearr = strsplit(b,'Nomenclature="');
    name = char(namearr(2));
    namearr2 = strsplit(name,'"');
    name = char(namearr2(1));
    sites(i).target_name=name;
    
    %passover_time
    notesarr = strsplit(b, {'Notes="','>'});
    notes = char(notesarr(2));
    timearr = strsplit(notes, ';');
    sites(i).passover_time=char(timearr(1));
    
    %lenses
    lenses = char(timearr(2));
    lensarr = strsplit(lenses, ': ');
    lenses = char(lensarr(2));
    sites(i).lenses=lenses;
    
    %notes
    notes2=strsplit(char(timearr(3)),'"');
    sites(i).notes=char(notes2(1));
    
    %lat and long and closest_approach
    if(length(timearr)>3)
        latlon = char(timearr(4));
        latarr = strsplit(latlon,'lat: ');
        lati = char(latarr(2));
        lonarr = strsplit(lati,{', lon:',' '});
        lati = char(lonarr(1));
        longi = char(lonarr(2));
        close = char(lonarr(4));
        close = close(1:end-1);
        sites(i).lat=lati;
        sites(i).long=longi;
        sites(i).closest_approach=close;
    end
end

% Save sites data so it can be accessed by other functions.
handles.sites = sites;

% Populate the selection box where users pick targets to view data for.
for i=1:no_of_targets
    if i == 1
        all_targets = [];
    else
        all_targets = cellstr(get(handles.listbox3,'String'));
    end
    set(handles.listbox3, 'String', vertcat(all_targets, [num2str(i) '. ' sites(i).target_name]));
end

% Add axes and draw maps.
axes(handles.axes3); %Places map within Target View window
plot_google_map(sites(1).lat,sites(1).long)
handles.current_idx=1;
guidata(hObject, handles);


%%%%% TEST TEST
%handles.testing1 = 0;%text(0,0,'start');
%handles.testing2 = 0;

%axes('Units','Pixels','Position',[240,304,292,207], 'Visible', 'off')
axes(handles.axes5);
[handles.a handles.b handles.c] = plot_google_map(sites(1).lat, sites(1).long);
%test3 = plot_google_map('0', '0');
%handles.testing = text(0,0,'start');
guidata(hObject, handles);
handles.i = image(handles.a, handles.b, handles.c)
guidata(hObject, handles);
set(gca,'YDir','Normal')
set(handles.i,'AlphaData',1)
set(handles.i,'tag','gmap')
uistack(handles.i,'bottom')

latdbl = str2double(sites(1).lat);
longdbl = str2double(sites(1).long);



axis([longdbl-2 longdbl+2 latdbl-2 latdbl+2])


axes('Units','Pixels','Position',[150,400,450,200], 'Visible', 'off')
axes(handles.axes4) %Place map within ISS location window
lat = [str2double(sites(1).lat)];
lon = [str2double(sites(1).long)];
handles.map = plot(lon,lat,'.r','MarkerSize',20);
handles.map_site_label = text(str2double(sites(1).long)+3, str2double(sites(1).lat)+3, 'Target 1');
hold;
%axes('Units','Pixels','Position',[150,400,450,200], 'Visible', 'on')
axes(handles.axes4);
iss_lat = [0];
iss_lon = [0];
handles.map_iss = plot(iss_lon,iss_lat,'+r','MarkerSize',10);
handles.map_iss_label = text(iss_lon(1)+3,iss_lat(1)+3,'ISS');

guidata(hObject, handles);
set(gca,'XTickLabel',[],...
    'YTickLabel',[])
plot_google_world

% By default, display details about the first target.
set_curr_target(1, handles, hObject);
    
% Create timer which updates ISS coordinates and display accordingly.
% The period is only 3 seconds to prevent function calls backing up.
handles.iss_timer = timer(...
    'ExecutionMode', 'fixedRate', ...       % Run timer repeatedly
    'Period', 3, ...                        
    'TimerFcn', {@iss_timer_update_callback,hObject}); 


%% Get and display ISS latitude and longitude
update_iss_coords(handles);

%% Get and display a timer to the closest target.

set_up_countdown(handles, hObject);
handles = guidata(hObject);
disp_countdown(hObject);
handles = guidata(hObject);

handles.timer = timer(...
    'ExecutionMode', 'fixedRate', ...       % Run timer repeatedly
    'Period', 1, ...                        
    'TimerFcn', {@timer_callback,hObject}); 
start(handles.timer);


function set_up_countdown(handles, hObject)
handles.closest_site = 1;
handles.closest_site_seconds_away = calculateSecondsUntilSite(1, handles);
guidata(hObject, handles);

for i=2:handles.no_of_targets
    site_seconds_away = calculateSecondsUntilSite(i, handles)
    
    if site_seconds_away < handles.closest_site_seconds_away
        handles.closest_site = i;
        handles.closest_site_seconds_away = site_seconds_away;
    end
end

set(handles.next_target, 'String', num2str(handles.closest_site));
guidata(hObject, handles);

function disp_countdown(hObject)
handles = guidata(hObject);
seconds_away = handles.closest_site_seconds_away;
h = floor(seconds_away/3600);
m = floor(seconds_away/60) - 60*h;
s = floor(seconds_away - 3600*h- 60*m);
timer_string = [sprintf('%02d',h) ':' sprintf('%02d',m) ':' sprintf('%02d',s)];
set(handles.time,'String', timer_string);
guidata(hObject, handles);

function update_iss_coords(handles)
%% Get latitude and longitude
latlong=urlread('http://api.open-notify.org/iss-now.json');

latarr = strsplit(latlong,'"latitude":');
latarr2 = strsplit(char(latarr(2)),',');
latstr = char(latarr2(1));
latitude = latstr(1:10);

longarr = strsplit(latlong,{'"longitude":','}'});
longstr = char(longarr(2));
longitude = longstr(1:10);

% Display the ISS coordinates.
if ~isempty(latitude)|| ~isempty(longitude)
    % Update the ISS coordinate strings displayed in the "Current Location"
    % box.
    set(handles.input_lat,'string',{num2str(latitude)})
    set(handles.input_long,'string',{num2str(longitude)})
    
    % Plot the current location and the selected site location on the world
    % map.
    %axes('Units','Pixels','Position',[150,400,450,200], 'Visible', 'off')
    %axes(handles.axes4) %Place map within ISS location window
    roundlat = str2double(latitude);
    roundlong = str2double(longitude);
    a = handles.current_idx 
    lat = [str2double(handles.sites(a).lat)];
    lon = [str2double(handles.sites(a).long)];
    set(handles.map, 'Xdata',lon,'Ydata',lat);
    set(handles.map_site_label, 'Position', [lon(1)+3 lat(1)+3]);
    set(handles.map_site_label, 'String', ['Target ' num2str(a)]);
    %hold;
    iss_lat = [str2double(strtrim(latitude))];
    iss_lon = [str2double(strtrim(longitude))];
    
    
    %axes
    f = figure('Visible','off')
    ax = axes('Visible','off')
    [d e f] = plot_google_map(strtrim(latitude), strtrim(longitude));
    axes(handles.axes5);
    set(gca,'YDir','Normal')
    set(handles.i, 'Xdata', d)
    set(handles.i, 'Ydata', e)
    set(handles.i, 'Cdata', f)
    te = get(handles.i)
    uistack(handles.i,'bottom')
    set(handles.axes5, 'XLim', [iss_lon(1)-2 iss_lon(1)+2], 'YLim', [iss_lat(1)-2 iss_lat(1)+2]);
    %axis([iss_lat(1)-2 iss_lat(1)+2 iss_lon(1)-2 iss_lon(1)+2])
    
    axes(handles.axes4);
    set(handles.map_iss, 'Xdata', iss_lon, 'Ydata', iss_lat);
    set(handles.map_iss_label, 'Position', [iss_lon(1)+3 iss_lat(1)+3]);
end

%obj = gcf;
%handles = guidata(obj);
%axes(handles.axes5);
%axes('Units','Pixels','Position',[240,304,292,207], 'Visible', 'off')
%plot_google_map(latitude, longitude)
%plot(0,0,'.r','MarkerSize',20);
%set(handles.testing, 'String', latitude);


%axes('Units','Pixels','Position',[240,304,292,207], 'Visible', 'off')
%plot_google_map(latitude, longitude)

% --- Updates the ISS information.
function iss_timer_update_callback(hObject,eventdata,hfigure)
% hfigure   handle to the main figure object
%handles = guidata(hfigure);
handles = guidata(hfigure);
update_iss_coords(handles);



% --- Updates the ISS information.
function timer_callback(hObject,eventdata,hfigure)
% hfigure   handle to the main figure object
handles = guidata(hfigure);
handles.closest_site_seconds_away = handles.closest_site_seconds_away-1;
if handles.closest_site_seconds_away <= 0
    set_up_countdown(handles, hfigure);
    handles = guidata(hfigure);
end
guidata(hfigure, handles);
disp_countdown(hfigure);

% --- Updates the information in the information box given the target
% number requested by the user.
function set_curr_target(target_num, handles, obj)
% target_num the index of the target the user selected
% handles    structure with handles and user data (see GUIDATA)
% obj        handle to the main figure object
sites = handles.sites;
handles.current_idx = target_num; 

set(handles.selected_name, 'string', sites(target_num).target_name)
set(handles.selected_lat, 'string', sites(target_num).lat)
set(handles.selected_long, 'string', sites(target_num).long)
set(handles.selected_passtime, 'string', sites(target_num).passover_time)
set(handles.selected_lens, 'string', sites(target_num).lenses)
set(handles.selected_notes, 'string', strtrim(sites(target_num).notes))
set(handles.curr_target_str, 'string', [num2str(target_num) ' of ' num2str(length(sites))])
set(handles.map_site_label, 'Position', [str2double(handles.selected_long)+3 str2double(handles.selected_lat)+3]);

guidata(obj, handles);

update_iss_coords(handles);

% --- Outputs from this function are returned to the command line.
function varargout = ceo_tool_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on selection change in listbox3.
function listbox3_Callback(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
obj = gcbf

% Get data from listbox3, including the selected item.
contents = cellstr(get(hObject,'String')); 
val = contents{get(hObject,'Value')}; 
curr_target_index = val(1);

% Update selected item, and the GUI to reflect this.
set_curr_target(str2num(curr_target_index), handles, obj);
handles = guidata(obj);
index = str2num(curr_target_index);
target_lat = (handles.sites(1, index).lat);
target_long = (handles.sites(1, index).long);
%axes('Units','Pixels','Position',[300,80,320,200], 'Visible', 'off')
axes(handles.axes3);

% this line caused a crash with object 6
plot_google_map(target_lat, target_long);

% --- Executes during object creation, after setting all properties.
function listbox3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in update_iss_button.
function update_iss_button_Callback(hObject, eventdata, handles)
% hObject    handle to update_iss_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Update coordinates continuously.
if strcmp(get(handles.iss_timer, 'Running'), 'off')
    start(handles.iss_timer);
end

% --- Executes during object deletion, before destroying properties.
function listbox3_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over input_long.
function input_long_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to input_long (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in stop_iss_update_button.
function stop_iss_update_button_Callback(hObject, eventdata, handles)
% hObject    handle to stop_iss_update_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(handles.iss_timer, 'Running'), 'on')
    stop(handles.iss_timer);
end


function x = calculateSecondsUntilSite(sitenum, handles)
current_date_time = clock;
current_date_time_in_gmt = addtodate(datenum(current_date_time),4,'hour');
current_date_time_in_gmt_vector = datevec(current_date_time_in_gmt);
current_date = datestr(current_date_time_in_gmt_vector,'dd-mmm-yyyy');
passover_time = handles.sites(sitenum).passover_time(5:end);
passover_date_time_str = [current_date ' ' passover_time];
passover_date_time_vector = datevec(passover_date_time_str, 'dd-mmm-yyyy HH:MM:SS');
seconds_until_passover = etime(passover_date_time_vector, current_date_time_in_gmt_vector);
if seconds_until_passover < 0
    passover_date_time_num = addtodate(datenum(passover_date_time_vector), 1, 'day');
    passover_date_time_vector = datevec(passover_date_time_num);
    seconds_until_passover = etime(passover_date_time_vector, current_date_time_in_gmt_vector);
end
x = seconds_until_passover;
