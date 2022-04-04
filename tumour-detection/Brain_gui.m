function varargout = Brain_gui(varargin)
% BRAIN_GUI MATLAB code for Brain_gui.fig
%      BRAIN_GUI, by itself, creates a new BRAIN_GUI or raises the existing
%      singleton*.
%
%      H = BRAIN_GUI returns the handle to a new BRAIN_GUI or the handle to
%      the existing singleton*.
%
%      BRAIN_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BRAIN_GUI.M with the given input arguments.
%
%      BRAIN_GUI('Property','Value',...) creates a new BRAIN_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Brain_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Brain_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Brain_gui

% Last Modified by GUIDE v2.5 06-Jul-2021 22:22:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Brain_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @Brain_gui_OutputFcn, ...
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


% --- Executes just before Brain_gui is made visible.
function Brain_gui_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Brain_gui (see VARARGIN)

% Choose default command line output for Brain_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Brain_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Brain_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Browse.
function Browse_Callback(hObject, eventdata, handles)
% hObject    handle to Browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[I, path] = uigetfile('*.*', 'Select a input image');
    if isequal(I,0) || isequal(path,0)
       disp('User pressed cancel')
    else
       str=strcat(path,I);
       a=imread(str);
       axes(handles.axes1);
       imshow(a);
       handles.a = a;
       guidata(hObject, handles);
    end


% --- Executes on button press in Filtering.
function Filtering_Callback(hObject, eventdata, handles)
% hObject    handle to Filtering (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s=handles.a;
f=imdiffusefilt(s);
inp = uint8(f);
    
inp=imresize(inp,[256,256]);
if size(inp,3)>1 % returns first 3 dimensions
    inp=rgb2gray(inp);% Convert image into grayscale
end
axes(handles.axes2);
imshow(inp);
handles.b = inp;
guidata(hObject, handles);



% --- Executes on button press in Tumour_alone.
function Tumour_alone_Callback(hObject, eventdata, handles)
% hObject    handle to Tumour_alone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sout=handles.b;
sout=imbinarize(sout,0.7);

%morphological operation
label=bwlabel(sout);
stats=regionprops(logical(sout),'Solidity','Area','BoundingBox');
density=[stats.Solidity];
area=[stats.Area];
high_dense_area=density>0.6; %gives area 60% soldity than brain
max_area=max(area(high_dense_area));
tumor_label=find(area==max_area);
tumor=ismember(label,tumor_label);
if max_area>100
   axes(handles.axes3);
   imshow(tumor);
   %handles.c=tumor_label;
   %guidata(hObject, handles);
   handles.d=tumor;
   guidata(hObject, handles);
   
   
else
    h = msgbox('No Tumor!!','status');
    %disp('no tumor');
    return;
end


% --- Executes on button press in Bounding_box.
function Bounding_box_Callback(hObject, eventdata, handles)
% hObject    handle to Bounding_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sout1=handles.b;
sout1=imbinarize(sout1,0.7);

%morphological operation
label=bwlabel(sout1);
stats=regionprops(logical(sout1),'Solidity','Area','BoundingBox');
density=[stats.Solidity];
area=[stats.Area];
high_dense_area=density>0.6; %gives area 60% soldity than brain
max_area=max(area(high_dense_area));
tumor_label=find(area==max_area);

boxx=tumor_label;
box = stats(boxx);
wantedBox = box.BoundingBox;
axes(handles.axes4);
imshow(handles.b);
hold on;
rectangle('Position',wantedBox,'EdgeColor','g');
hold off;


% --- Executes on button press in Tumour_outline.
function Tumour_outline_Callback(hObject, eventdata, handles)
% hObject    handle to Tumour_outline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
E=handles.d;
filledImage = imfill(E, 'holes');
se=strel('square',11);
erodedImage=imerode(filledImage,se);

tumorOutline=E;
tumorOutline(erodedImage)=0;
axes(handles.axes5);
imshow(tumorOutline);
handles.k=tumorOutline;
guidata(hObject, handles);


% --- Executes on button press in Location.
function Location_Callback(hObject, eventdata, handles)
% hObject    handle to Location (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
new=handles.b;
Ou=handles.k;
rgb = new(:,:,[1 1 1]);
red = rgb(:,:,1);
red(Ou)=255;
green = rgb(:,:,2);
green(Ou)=0;
blue = rgb(:,:,3);
blue(Ou)=0;
tumorOutlineInserted(:,:,1) = red; 
tumorOutlineInserted(:,:,2) = green; 
tumorOutlineInserted(:,:,3) = blue; 
axes(handles.axes6);
imshow(tumorOutlineInserted);
