function varargout = volume(varargin)
% VOLUME MATLAB code for volume.fig
%      VOLUME, by itself, creates a new VOLUME or raises the existing
%      singleton*.
%
%      H = VOLUME returns the handle to a new VOLUME or the handle to
%      the existing singleton*.
%
%      VOLUME('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VOLUME.M with the given input arguments.
%
%      VOLUME('Property','Value',...) creates a new VOLUME or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before volume_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to volume_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help volume

% Last Modified by GUIDE v2.5 21-Oct-2016 13:27:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @volume_OpeningFcn, ...
                   'gui_OutputFcn',  @volume_OutputFcn, ...
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


% --- Executes just before volume is made visible.
function volume_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to volume (see VARARGIN)

% Choose default command line output for volume
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes volume wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = volume_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function volume_Callback(hObject, eventdata, handles)
% hObject    handle to volume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of volume as text
%        str2double(get(hObject,'String')) returns contents of volume as a double


% --- Executes during object creation, after setting all properties.
function volume_CreateFcn(hObject, eventdata, handles)
% hObject    handle to volume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in volumeup.
function volumeup_Callback(hObject, eventdata, handles)
% hObject    handle to volumeup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
volumechange=get(handles.volume, 'String');
handles.sound=handles.sound*(db2amp(volumechange));
guidata(hObject, handles);
msgbox('Volume Up')

% --- Executes on button press in volumedown.
function volumedown_Callback(hObject, eventdata, handles)
% hObject    handle to volumedown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
volumechange=get(handles.volume, 'String');
handles.sound=handles.sound*(db2amp(-volumechange));
guidata(hObject, handles);
msgbox('Volume Down')

% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SoundFile.
function SoundFile_Callback(hObject, eventdata, handles)
% hObject    handle to SoundFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SoundFile contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SoundFile


% --- Executes during object creation, after setting all properties.
function SoundFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SoundFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function targetspl_Callback(hObject, eventdata, handles)
% hObject    handle to targetspl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of targetspl as text
%        str2double(get(hObject,'String')) returns contents of targetspl as a double


% --- Executes during object creation, after setting all properties.
function targetspl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to targetspl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2

handles.popupmenu2
get(handles.popupmenu2, 'String');
% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in stimulus.
function stimulus_Callback(hObject, eventdata, handles)
% hObject    handle to stimulus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of stimulus
handles.subjectid
% subjectid=get(handles.subjectid, 'String')
% get(handles.SPL, 'String')
strcat(handles.subjectid,'stim.wav')
handles.sound=audioread(strcat(handles.subjectid,'stim.wav'));
handles.filename=strcat(handles.subjectid,'stim.wav')
handles.hz=10000
guidata(hObject, handles);
set(handles.targetspl, 'String', handles.SPL);

% --- Executes on button press in SNR_5.
function SNR_5_Callback(hObject, eventdata, handles)
% hObject    handle to SNR_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SNR_5
handles.sound=audioread(strcat(handles.subjectid,'SNRnoise_5.wav'));
handles.filename=strcat(handles.subjectid,'SNRnoise_5.wav')
handles.hz=44100
guidata(hObject, handles);
set(handles.targetspl, 'String', handles.SPL+5);

% --- Executes on button press in SNR0.
function SNR0_Callback(hObject, eventdata, handles)
% hObject    handle to SNR0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SNR0
handles.sound=audioread(strcat(handles.subjectid,'SNRnoise0.wav'));
handles.filename=strcat(handles.subjectid,'SNRnoise0.wav')
handles.hz=44100
guidata(hObject, handles);

set(handles.targetspl, 'String', handles.SPL);

% --- Executes on button press in SNR5.
function SNR5_Callback(hObject, eventdata, handles)
% hObject    handle to SNR5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SNR5
handles.sound=audioread(strcat(handles.subjectid,'SNRnoise5.wav'));
handles.filename=strcat(handles.subjectid,'SNRnoise5.wav')
handles.hz=44100
guidata(hObject, handles);
set(handles.targetspl, 'String', handles.SPL-5);

% --- Executes on button press in SNR10.
function SNR10_Callback(hObject, eventdata, handles)
% hObject    handle to SNR10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SNR10
handles.sound=audioread(strcat(handles.subjectid,'SNRnoise10.wav'));
handles.filename=strcat(handles.subjectid,'SNRnoise10.wav')
handles.hz=44100
guidata(hObject, handles);
set(handles.targetspl, 'String', handles.SPL-10);
% --- Executes on button press in SNR15.

function SNR15_Callback(hObject, eventdata, handles)
% hObject    handle to SNR15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SNR15
handles.sound=audioread(strcat(handles.subjectid,'SNRnoise15.wav'));
handles.filename=strcat(handles.subjectid,'SNRnoise15.wav')
handles.hz=44100
guidata(hObject, handles);
set(handles.targetspl, 'String', handles.SPL-15);


% --- Executes on button press in start.
function start_Callback(hObject, eventdata, handles)
% hObject    handle to start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
subjectid=get(handles.subjectid, 'String')
[SPL30,subjectid]=create_ERP_sound(str2num(subjectid));
handles.subjectid=subjectid
handles.SPL=SPL30
% saves handles data into temporary storage
guidata(hObject, handles);

% Places SPL30 value into PTA30 textbox
  set(handles.PTA30, 'String', SPL30);
  
function subjectid_Callback(hObject, eventdata, handles)
% hObject    handle to subjectid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of subjectid as text
%        str2double(get(hObject,'String')) returns contents of subjectid as a double


% --- Executes during object creation, after setting all properties.
function subjectid_CreateFcn(hObject, eventdata, handles)
% hObject    handle to subjectid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PTA30_Callback(hObject, eventdata, handles)
% hObject    handle to PTA30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PTA30 as text
%        str2double(get(hObject,'String')) returns contents of PTA30 as a double


% --- Executes during object creation, after setting all properties.
function PTA30_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PTA30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in savefile.
function savefile_Callback(hObject, eventdata, handles)
% hObject    handle to savefile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.filename
audiowrite(handles.filename,handles.sound,handles.hz)


