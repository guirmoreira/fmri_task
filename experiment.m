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

handles.workDir = varargin{1};
handles.questDir = varargin{2};
handles.indNome = varargin{3};
handles.avgTime = varargin{4};
% handles.avgTime = 5;
dir = strcat(handles.workDir,'/',handles.indNome);
mkdir(dir);

handles.initialEventdata = eventdata;

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

handles.possibleKeys = ['0','1','2','3','4','5','6','7','8','9', 'numpad0', 'numpad1', 'numpad2', 'numpad3', 'numpad4', 'numpad5', 'numpad6', 'numpad7', 'numpad8', 'numpad9'];

% state 0 : initial
% state 1 : rest
% state 2 : control
% state 3 : activation

handles.stateOrder = [1 2 3 1 3 2 1 2 3 1 3 2 1 3 2 1];
handles.stateIndex = 1;

% state = handles.stateOrder(handles.stateIndex);

handles.restTime = 5;
handles.controlTime = 40;
handles.activationTime = 40;

handles.feedbackTime = 0.5;

handles.blockGui = 0;

handles.questionCounter = 1;

handles.spentTime = 0;

handles.timeWatcher = zeros(1,6);
handles.cLimitTime = handles.avgTime;
handles.cResponseTime = 0;
handles.cRestTime = 0;

guidata(hObject, handles);
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);


function varargout = experiment_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


function background_WindowKeyPressFcn(hObject, eventdata, handles)

disp(strcat('blockGui: ',num2str(handles.blockGui)));

try
   keyPressed = eventdata.Key;
catch
   keyPressed = nan;
end

% force escape
if strcmpi(keyPressed,'escape')
    pause(1);
    fclose('all');
    delete(hObject);
end

formatSpec = '%d, %d, %s, %d, %s, %d, %.3f\n'; % #, fase, questao, reposta, resposta_individuo, {0,1}, tempo
responseFile = handles.responseFile;

% rest code
if (handles.stateOrder(handles.stateIndex) == 1) & (handles.blockGui == 0)
    if strcmpi(keyPressed,'space')          % trigger esta como 'space'
        if ~handles.isRunning
            handles.blockGui = 1;
            guidata(hObject, handles);
            setVisibleRest(handles);
            pause(handles.restTime);
            handles.blockGui = 0;
            populateTimeWatcher(hObject, handles, handles.stateOrder(handles.stateIndex), 0, 0, 0, 0, handles.restTime);
            handles.stateIndex = handles.stateIndex + 1;
            guidata(hObject, handles);
            background_WindowKeyPressFcn(hObject, handles.initialEventdata, handles);
        end
    end
end

% control code
if (handles.stateOrder(handles.stateIndex) == 2) & (~isnan(keyPressed)) & (handles.blockGui == 0)
    setVisibleControl(handles);
    if ismember(keyPressed, handles.possibleKeys)    
        handleResponse(hObject, handles, responseFile, formatSpec, keyPressed);
        answer = checkAnswer(hObject, handles, keyPressed);
        setFeedback(handles, answer);
        handles.blockGui = 1;
        guidata(hObject,handles);
        pause(handles.feedbackTime);      % tempo de feedback ao usuario
        handles.blockGui = 0;
        guidata(hObject,handles);
        resetBtColors(hObject, handles);
        randomRest(hObject, handles);
        populateTimeWatcher(hObject, handles, handles.stateOrder(handles.stateIndex), handles.questionCounter, handles.cLimitTime, handles.cLimitTime, handles.feedbackTime, handles.cRestTime);
        background_WindowKeyPressFcn(hObject, handles.initialEventdata, handles);
    end
    waitResponse(hObject, handles);
    setFeedback(handles,2);
    handles.blockGui = 1;
    guidata(hObject,handles);
    pause(handles.feedbackTime);      % tempo de feedback ao usuario
    handles.blockGui = 0;
    guidata(hObject,handles);
    resetBtColors(hObject, handles);
    randomRest(hObject, handles);
    populateTimeWatcher(hObject, handles, handles.stateOrder(handles.stateIndex), handles.questionCounter, handles.cLimitTime, handles.cLimitTime, handles.feedbackTime, handles.cRestTime);
    background_WindowKeyPressFcn(hObject, handles.initialEventdata, handles);
elseif (handles.stateOrder(handles.stateIndex) == 2) & (handles.blockGui == 0)
    newQuestion(hObject, handles);
    setVisibleControl(handles);
    waitResponse(hObject, handles);
    setFeedback(handles,2);
    handles.blockGui = 1;
    guidata(hObject,handles);
    pause(handles.feedbackTime);      % tempo de feedback ao usuario
    handles.blockGui = 0;
    guidata(hObject,handles);
    resetBtColors(hObject, handles);
    randomRest(hObject, handles);
    populateTimeWatcher(hObject, handles, handles.stateOrder(handles.stateIndex), handles.questionCounter, handles.cLimitTime, handles.cLimitTime, handles.feedbackTime, handles.cRestTime);
    background_WindowKeyPressFcn(hObject, handles.initialEventdata, handles);
end

% activation code
if handles.stateOrder(handles.stateIndex) == 3
    % TODO
end
guidata(hObject, handles);


function handleResponse(hObject, handles, responseFile, formatSpec, key)
bt = choosenBt(handles, key);
bt.BackgroundColor = [1 0 0];
bt.ForegroundColor = [1 1 1];
answer = checkAnswer(hObject, handles, key);
fprintf(responseFile,formatSpec,handles.counter,handles.stateOrder(handles.stateIndex),handles.equation.String{1},handles.responses(handles.questionIndex),key,answer,toc);
handles.counter=handles.counter+1;
handles.cResponseTime = getTimeSaved;
populateTimeWatcher(hObject, handles, handles.stateOrder(handles.stateIndex), handles.questionCounter, handles.cLimitTime, handles.cResponseTime, handles.feedbackTime, handles.cRestTime);
guidata(hObject,handles);

function newQuestion(hObject, handles)
handles.blockGui = 0;
resetBtColors(hObject, handles);
questions = handles.questions;
questions_size = size(questions);
questions_size = questions_size(1);
choosen_equation_index = fix(rand()*questions_size);
handles.questionIndex = choosen_equation_index;
handles.equation.String = strcat(handles.questions(choosen_equation_index), ' ?');
setTimeSaved;
guidata(hObject,handles);
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
    case 'numpad0'
        bt = data.bt0;
    case 'numpad1'
        bt = data.bt1;
    case 'numpad2'
        bt = data.bt2;
    case 'numpad3'
        bt = data.bt3;
    case 'numpad4'
        bt = data.bt4;
    case 'numpad5'
        bt = data.bt5;
    case 'numpad6'
        bt = data.bt6;
    case 'numpad7'
        bt = data.bt7;
    case 'numpad8'
        bt = data.bt8;
    case 'numpad9'
        bt = data.bt9;
end

function resetBtColors(hObject, data)
set(data.feedback,'visible','off')
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

function setVisibleControl(handles)
setAllInvisible(handles)
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

function setVisibleActivation(handles)
setAllInvisible(handles)
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

function setVisibleRest(handles)
setAllInvisible(handles)
set(handles.cross,'visible','on')

function setAllInvisible(handles)
set(handles.feedback,'visible','off')
set(handles.trigger,'visible','off')
set(handles.equation,'visible','off')
set(handles.timer,'visible','off')
set(handles.cross,'visible','off')
set(handles.bt0,'visible','off')
set(handles.bt1,'visible','off')
set(handles.bt2,'visible','off')
set(handles.bt3,'visible','off')
set(handles.bt4,'visible','off')
set(handles.bt5,'visible','off')
set(handles.bt6,'visible','off')
set(handles.bt7,'visible','off')
set(handles.bt8,'visible','off')
set(handles.bt9,'visible','off')


function setFeedback(handles, type)
set(handles.feedback,'visible','on')
switch type
    case 0
        handles.feedback.ForegroundColor = [1 0 0];
        handles.feedback.String = 'Incorreto!';
    case 1
        handles.feedback.ForegroundColor = [0 1 0];
        handles.feedback.String = 'Correto!';
    case 2
        handles.feedback.ForegroundColor = [1 1 0];
        handles.feedback.String = 'Tempo esgotado!';
end


function answer = checkAnswer(hObject, handles, key)
handles = guidata(hObject);
if strcmpi(num2str(handles.responses(handles.questionIndex)), key)
    answer = 1;
else
    answer = 0;
end
disp(strcat('answer: ', num2str(answer), ' response: ', num2str(handles.responses(handles.questionIndex)), ' index: ', num2str(handles.questionIndex), ' key: ', key));

function randomRest(hObject, handles)
handles.blockGui = 1;
guidata(hObject, handles);
setVisibleRest(handles);
i = random('normal', 3, 0.5);
pause(i);
handles.blockGui = 0;
handles.cRestTime = i;
guidata(hObject, handles);

function waitResponse(hObject, handles)
setCountdown(hObject, handles);

function setCountdown(hObject, handles)
set(handles.timer,'visible','on');
t = timer('TimerFcn', 'stat=false; counter=0; disp(''Acabou o timer!'')', 'StartDelay', handles.avgTime);
start(t)
stat=true;
counter = 0;
while(stat==true)
  pause(0.01)
  set(handles.timer,'String', sprintf('%0.2f', abs(handles.avgTime-counter*0.01)));
  guidata(hObject, handles);
  counter = counter+1;
  if handles.avgTime-counter*0.01 <= -0.005
      break
  end
end
delete(t)

function populateTimeWatcher(hObject, handles, state, questionCounter, limitTime, responseTime, feedbackTime, restTime)
s = size(handles.timeWatcher);
s_rows = s(1);
index = s_rows + 1;
handles.timeWatcher(index, :) = [state questionCounter limitTime responseTime feedbackTime restTime];
guidata(hObject, handles);
disp(handles.timeWatcher);

function setTimeSaved
global timeSaved
timeSaved = tic;

function r = getTimeSaved
global timeSaved
r = toc(timeSaved);


function background_SizeChangedFcn(hObject, eventdata, handles)
