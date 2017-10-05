function varargout = experiment(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @experiment_OpeningFcn, ...
                   'gui_OutputFcn',  @experiment_OutputFcn, ...
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


function experiment_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
clc

handles.workDir=varargin{1};
handles.questDir=varargin{2};
handles.indNome=varargin{3};
dir = strcat(handles.workDir,'/',handles.indNome);
mkdir(dir);

responseFile = fopen(strcat(dir,'/','experiment.csv'), 'w');
handles.responseFile = responseFile;
fprintf(responseFile, '#,fase,question,right_answer,given_answer,hits,time\n');

[questions, responses] = csvimport(handles.questDir, 'columns', {'questions', 'response'});

handles.questions = questions;
handles.responses = responses;
handles.questionIndex = 1;
handles.counter = 1;

handles.escStatus = false;
handles.isRunning = false;

handles.workDir = '';

guidata(hObject, handles);
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);


function varargout = experiment_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;




function background_WindowKeyPressFcn(hObject, eventdata, handles)
data = guidata(hObject);
formatSpec = '%d, %s, %d, %s, %d, %.3f\n'; % # ,questao, reposta, resposta_individuo, {0,1}, tempo
responseFile = handles.responseFile;
keyPressed = eventdata.Key;
if strcmpi(keyPressed,'escape')
    fclose('all');
    delete(hObject);
end

if strcmpi(keyPressed,'space')
    if ~handles.isRunning
        setVisible(handles)
        newQuestion(hObject, data);
    end
else
    if ismember(keyPressed, ['0','1','2','3','4','5','6','7','8','9'])
        handleResponse(hObject, data, responseFile, formatSpec, eventdata.Key);
    end
end

function handleResponse(hObject, data, responseFile, formatSpec, key)
resetBtColors(hObject, data);
bt = choosenBt(data, key);
bt.BackgroundColor = [1 0 0];
bt.ForegroundColor = [1 1 1];
guidata(hObject,data);
pause(0.3);
if strcmpi(num2str(data.responses(data.questionIndex)),key)
    answer = 1;
else
    answer = 0;
end
fprintf(responseFile,formatSpec,data.counter,data.equation.String{1},data.responses(data.questionIndex),key,answer,toc);
data.counter=data.counter+1;
guidata(hObject,data);
newQuestion(hObject, data);

function newQuestion(hObject, data)
questions = data.questions;
questions_size = size(questions);
questions_size = questions_size(1);
choosen_equation_index = fix(rand()*questions_size);
data.questionIndex = choosen_equation_index;
data.equation.String = strcat(data.questions(choosen_equation_index), ' ?');
guidata(hObject,data);
resetBtColors(hObject, data);
tic;

function bt = choosenBt(data, key)
switch key
    case '0'
        bt = data.bt0;
    case '1'
        bt = data.bt1;
    case '2'
        bt = data.bt2;
    case '3'
        bt = data.bt3;
    case '4'
        bt = data.bt4;
    case '5'
        bt = data.bt5;
    case '6'
        bt = data.bt6;
    case '7'
        bt = data.bt7;
    case '8'
        bt = data.bt8;
    case '9'
        bt = data.bt9;
end

function resetBtColors(hObject, data)
data.bt0.BackgroundColor = [1 1 1];
data.bt0.ForegroundColor = [0 0 0];
data.bt1.BackgroundColor = [1 1 1];
data.bt1.ForegroundColor = [0 0 0];
data.bt2.BackgroundColor = [1 1 1];
data.bt2.ForegroundColor = [0 0 0];
data.bt3.BackgroundColor = [1 1 1];
data.bt3.ForegroundColor = [0 0 0];
data.bt4.BackgroundColor = [1 1 1];
data.bt4.ForegroundColor = [0 0 0];
data.bt5.BackgroundColor = [1 1 1];
data.bt5.ForegroundColor = [0 0 0];
data.bt6.BackgroundColor = [1 1 1];
data.bt6.ForegroundColor = [0 0 0];
data.bt7.BackgroundColor = [1 1 1];
data.bt7.ForegroundColor = [0 0 0];
data.bt8.BackgroundColor = [1 1 1];
data.bt8.ForegroundColor = [0 0 0];
data.bt9.BackgroundColor = [1 1 1];
data.bt9.ForegroundColor = [0 0 0];
guidata(hObject,data);

function setVisible(handles)
set(handles.trigger,'visible','off')
set(handles.equation,'visible','on')
set(handles.bt0,'visible','on')
set(handles.bt1,'visible','on')
set(handles.bt2,'visible','on')
set(handles.bt3,'visible','on')
set(handles.bt4,'visible','on')
set(handles.bt5,'visible','on')
set(handles.bt6,'visible','on')
set(handles.bt7,'visible','on')
set(handles.bt8,'visible','on')
set(handles.bt9,'visible','on')
