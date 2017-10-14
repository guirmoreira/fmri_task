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

handles.initialEventdata = eventdata;

handles.workDir = varargin{1};
handles.questDir = varargin{2};
handles.indNome = varargin{3};
handles.avgTime = varargin{4};
dir = strcat(handles.workDir,'/',handles.indNome);
mkdir(dir);

responseFile = fopen(strcat(dir,'/','experiment.csv'), 'w');
setResponseFile(responseFile);
fprintf(getResponseFile, '#,fase,question,right_answer,given_answer,hits,time\n');

[questions, responses] = csvimport(handles.questDir, 'columns', {'questions', 'response'});

setQuestions(questions);
setResponses(responses);
setQuestionIndex(1);
setCounter(1);

setPossibleKeys(['0','1','2','3','4','5','6','7','8','9', 'numpad0', 'numpad1', 'numpad2', 'numpad3', 'numpad4', 'numpad5', 'numpad6', 'numpad7', 'numpad8', 'numpad9']);

% state 0 : initial
% state 1 : rest
% state 2 : control
% state 3 : activation

setStateOrder([1 3 2 1 2 3 1 2 3 1 3 2 1 3 2 1]);
%setStateOrder([1 3 2 1]);
setStateIndex(1);

setRestTime(20);
setControlTime(40);
setActivationTime(40);

setFeedbackTime(0.5);

setBlockGui(0);

setQuestionCounter(1);

setTimeWatcher(zeros(1,7));
setcLimitTime(handles.avgTime*0.9);
setcResponseTime(0);
setcRestTime(0);

setGroupHitRate(80);

guidata(hObject, handles);
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);


function varargout = experiment_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


function background_WindowKeyPressFcn(hObject, eventdata, handles)

try
   keyPressed = eventdata.Key;
catch
   keyPressed = nan;
end

% force escape
if strcmpi(keyPressed,'escape')
    disp(getTimeWatcher);
    pause(0.3);
    fclose('all');
    delete(hObject);
end

formatSpec = '%d, %d, %s, %d, %s, %d, %.3f\n'; % #, fase, questao, reposta, resposta_individuo, {0,1}, tempo
responseFile = getResponseFile;

stateOrder = getStateOrder;
sizeStateOrder = size(stateOrder);
sizeStateOrderColumms = sizeStateOrder(2);

if (sizeStateOrderColumms >= getStateIndex)

state = stateOrder(getStateIndex);

    % rest code
    if (state == 1) & (getBlockGui == 0)
        if strcmpi(keyPressed,'space')          % trigger esta como 'space'
            setTimeCounter;      % conta o tempo total do experimento
            background_WindowKeyPressFcn(hObject, handles.initialEventdata, handles);
        else
            setBlockGui(1);
            setVisibleRest(handles);
            pause(getRestTime);
            setBlockGui(0);
            populateTimeWatcher(hObject, handles, state, 0, 0, 0, 0, getRestTime, nan);
            setStateIndex(getStateIndex + 1);
            guidata(hObject, handles);
            background_WindowKeyPressFcn(hObject, handles.initialEventdata, handles);
        end
    end
    
    % control code
    if (state == 2) & (~isnan(keyPressed)) & (getBlockGui == 0)
        setVisibleControl(handles);
        if ismember(keyPressed, getPossibleKeys)
            handleResponse(hObject, handles, responseFile, formatSpec, keyPressed);
            answer = checkAnswer(hObject, handles, keyPressed);
            setFeedback(handles, answer);
            setBlockGui(1);
            pause(getFeedbackTime);      % tempo de feedback ao usuario
            setBlockGui(0);
            resetBtColors(hObject, handles);
            randomRest(hObject, handles);
            % resposta adquirida
            populateTimeWatcher(hObject, handles, state, getQuestionCounter, getcLimitTime, getcResponseTime, getFeedbackTime, getcRestTime, answer);
            remainingTime = getControlTime-getTotalStateTime;
            if (remainingTime > getcLimitTime)
                setQuestionCounter(getQuestionCounter+1);
            else
                setBlockGui(1);
                setVisibleRest(handles);
                pause(remainingTime);
                setStateIndex(getStateIndex+1);
                if remainingTime > 0
                    populateTimeWatcher(hObject, handles, state, 0, 0, 0, 0, remainingTime, nan);
                end
                setcLimitTime(getControlAvgTime*0.9);
                setQuestionCounter(1);
                setBlockGui(0);
            end
            background_WindowKeyPressFcn(hObject, handles.initialEventdata, handles);
        end
        waitResponse(hObject, handles);
        setFeedback(handles,2);
        setBlockGui(1);
        pause(getFeedbackTime);      % tempo de feedback ao usuario
        setBlockGui(0);
        resetBtColors(hObject, handles);
        randomRest(hObject, handles);
        background_WindowKeyPressFcn(hObject, handles.initialEventdata, handles);
    elseif (state == 2) & (getBlockGui == 0)
        newQuestion(hObject, handles);
        setVisibleControl(handles);
        waitResponse(hObject, handles);
        setFeedback(handles,2);
        setBlockGui(1);
        pause(getFeedbackTime);      % tempo de feedback ao usuario
        setBlockGui(0);
        resetBtColors(hObject, handles);
        randomRest(hObject, handles);
        % resposta adquirida
        populateTimeWatcher(hObject, handles, state, getQuestionCounter, getcLimitTime, getcLimitTime, getFeedbackTime, getcRestTime, 2);
        remainingTime = getControlTime-getTotalStateTime;
        if (remainingTime > getcLimitTime)
            setQuestionCounter(getQuestionCounter+1);
        else
            setBlockGui(1);
            setVisibleRest(handles);
            pause(remainingTime);
            setStateIndex(getStateIndex+1);
            if remainingTime > 0
                    populateTimeWatcher(hObject, handles, state, 0, 0, 0, 0, remainingTime, nan);
            end
            setcLimitTime(getControlAvgTime*0.9);
            setQuestionCounter(1);
            setBlockGui(0);
        end
        background_WindowKeyPressFcn(hObject, handles.initialEventdata, handles);
    end
    
    % activation code
    if (state == 3) & (~isnan(keyPressed)) & (getBlockGui == 0)
        %setVisibleActivation(handles);
        if ismember(keyPressed, getPossibleKeys)
            handleResponse(hObject, handles, responseFile, formatSpec, keyPressed);
            answer = checkAnswer(hObject, handles, keyPressed);
            setFeedback(handles, answer);
            setBlockGui(1);
            pause(getFeedbackTime);      % tempo de feedback ao usuario
            setBlockGui(0);
            resetBtColors(hObject, handles);
            randomRest(hObject, handles);
            % resposta adquirida
            populateTimeWatcher(hObject, handles, state, getQuestionCounter, getcLimitTime, getcResponseTime, getFeedbackTime, getcRestTime, answer);
            remainingTime = getControlTime-getTotalStateTime;
            if (remainingTime > getcLimitTime)
                setQuestionCounter(getQuestionCounter+1);
            else
                setBlockGui(1);
                setVisibleRest(handles);
                pause(remainingTime);
                setStateIndex(getStateIndex+1);
                if remainingTime > 0
                    populateTimeWatcher(hObject, handles, state, 0, 0, 0, 0, remainingTime, nan);
                end
                setQuestionCounter(1);
                setBlockGui(0);
            end
            background_WindowKeyPressFcn(hObject, handles.initialEventdata, handles);
        end
        waitResponse(hObject, handles);
        setFeedback(handles,2);
        setBlockGui(1);
        pause(getFeedbackTime);      % tempo de feedback ao usuario
        setBlockGui(0);
        resetBtColors(hObject, handles);
        randomRest(hObject, handles);
        background_WindowKeyPressFcn(hObject, handles.initialEventdata, handles);
    elseif (state == 3) & (getBlockGui == 0)
        newQuestion(hObject, handles);
        setVisibleActivation(handles);
        updateAxisActivation(hObject,handles);
        waitResponse(hObject, handles);
        setFeedback(handles,2);
        setBlockGui(1);
        pause(getFeedbackTime);      % tempo de feedback ao usuario
        setBlockGui(0);
        resetBtColors(hObject, handles);
        randomRest(hObject, handles);
        % resposta adquirida
        populateTimeWatcher(hObject, handles, state, getQuestionCounter, getcLimitTime, getcLimitTime, getFeedbackTime, getcRestTime, 2);
        remainingTime = getControlTime-getTotalStateTime;
        if (remainingTime > getcLimitTime)
            setQuestionCounter(getQuestionCounter+1);
        else
            setBlockGui(1);
            setVisibleRest(handles);
            pause(remainingTime);
            setStateIndex(getStateIndex+1);
            if remainingTime > 0
                populateTimeWatcher(hObject, handles, state, 0, 0, 0, 0, remainingTime, nan);
            end
            setQuestionCounter(1);
            setBlockGui(0);
        end
        background_WindowKeyPressFcn(hObject, handles.initialEventdata, handles);
    end
    
else
    % finaliza a tarefa
    disp(getTimeWatcher);
    disp(getTimeCounter);
    disp(getHitRate);
    pause(0.3);
    fclose('all');
    delete(hObject);
end

guidata(hObject, handles);


function handleResponse(hObject, handles, responseFile, formatSpec, key)
bt = choosenBt(handles, key);
bt.BackgroundColor = [1 0 0];
bt.ForegroundColor = [1 1 1];
answer = checkAnswer(hObject, handles, key);
responses = getResponses;
expectedResponse = responses(getQuestionIndex);
stateOrder = getStateOrder;
state = stateOrder(getStateIndex);
fprintf(responseFile,formatSpec,getCounter,state,handles.equation.String{1},expectedResponse,key,answer,'tempo');
setCounter(getCounter + 1);
setcResponseTime(getTimeSaved);
guidata(hObject,handles);

function newQuestion(hObject, handles)
setBlockGui(0);
resetBtColors(hObject, handles);
questions = getQuestions;
questions_size = size(questions);
questions_size = questions_size(1);
choosen_equation_index = fix(rand()*questions_size);
setQuestionIndex(choosen_equation_index);
handles.equation.String = strcat(questions(choosen_equation_index), ' ?');
setTimeSaved;
guidata(hObject,handles);

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
set(handles.axis,'visible','off')
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
set(handles.axis,'visible','on')
set(handles.axisGroupLabel,'visible','on')
set(handles.axisGroupValue,'visible','on')
set(handles.axisYouLabel,'visible','on')
set(handles.axisYouValue,'visible','on')
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
set(handles.axis,'visible','off')
cla;
set(handles.axisGroupLabel,'visible','off')
set(handles.axisGroupValue,'visible','off')
set(handles.axisYouLabel,'visible','off')
set(handles.axisYouValue,'visible','off')
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


function updateAxisActivation(hObject,handles)
axes(handles.axis);
hitRate = getHitRate;
set(handles.axisYouValue,'String', strcat((sprintf('%0.0f', hitRate*100)),'%'));
y = [hitRate*100, getGroupHitRate];
barh(y, 'white');
xlim([0 100])
ax = gca;
ax.XColor = 'black';
ax.YColor = 'black';
ax.ZColor = 'black';
guidata(hObject, handles);


function answer = checkAnswer(hObject, handles, key)
responses = getResponses;
if strcmpi(num2str(responses(getQuestionIndex)), key)
    answer = 1;
else
    answer = 0;
end

function randomRest(hObject, handles)
setBlockGui(1);
guidata(hObject, handles);
setVisibleRest(handles);
i = random('normal', 3, 0.5);
pause(i);
setBlockGui(0);
setcRestTime(i);
guidata(hObject, handles);

function waitResponse(hObject, handles)
setCountdown(hObject, handles);

function setCountdown(hObject, handles)
set(handles.timer,'visible','on');
t = timer('TimerFcn', 'stat=false; counter=0;', 'StartDelay', handles.avgTime);
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

function populateTimeWatcher(hObject, handles, state, questionCounter, limitTime, responseTime, feedbackTime, restTime, hit)
timeWatcher = getTimeWatcher;
s = size(timeWatcher);
s_rows = s(1);
index = s_rows + 1;
timeWatcher(index, :) = [state questionCounter limitTime responseTime feedbackTime restTime hit];
setTimeWatcher(timeWatcher)

function r = getTotalStateTime
r = 0;
timeWatcher = getTimeWatcher;
s = size(timeWatcher);
s_rows = s(1);
for n = 0:getQuestionCounter-1
   r = r + timeWatcher(s_rows-n,4) + timeWatcher(s_rows-n,5) + timeWatcher (s_rows-n,6);
end

function r = getControlAvgTime
r = 0;
sum = 0;
timeWatcher = getTimeWatcher;
s = size(timeWatcher);
s_rows = s(1);
for n = 0:getQuestionCounter-1
   sum = sum + timeWatcher(s_rows-n,4);
end
r = sum/getQuestionCounter;


% GETTERS AND SETTERS FOR GLOBAL VARIABLES

function setResponseFile(val)
global responseFile
responseFile = val;

function r = getResponseFile
global responseFile
r = responseFile;

function setQuestions(val)
global questions
questions = val;

function r = getQuestions
global questions
r = questions;

function setResponses(val)
global responses
responses = val;

function r = getResponses
global responses
r = responses;

function setQuestionIndex(val)
global questionIndex
questionIndex = val;

function r = getQuestionIndex
global questionIndex
r = questionIndex;

function setCounter(val)
global counter
counter = val;

function r = getCounter
global counter
r = counter;

function setPossibleKeys(val)
global possibleKeys
possibleKeys = val;

function r = getPossibleKeys
global possibleKeys
r = possibleKeys;

function setStateOrder(val)
global stateOrder
stateOrder = val;

function r = getStateOrder
global stateOrder
r = stateOrder;

function setStateIndex(val)
global stateIndex
stateIndex = val;

function r = getStateIndex
global stateIndex
r = stateIndex;

function setRestTime(val)
global restTime
restTime = val;

function r = getRestTime
global restTime
r = restTime;

function setControlTime(val)
global controlTime
controlTime = val;

function r = getControlTime
global controlTime
r = controlTime;

function setActivationTime(val)
global activationTime
activationTime = val;

function r = getActivationTime
global activationTime
r = activationTime;

function setFeedbackTime(val)
global feedbackTime
feedbackTime = val;

function r = getFeedbackTime
global feedbackTime
r = feedbackTime;

function setBlockGui(val)
global blockGui
blockGui = val;

function r = getBlockGui
global blockGui
r = blockGui;

function setQuestionCounter(val)
global questionCounter
questionCounter = val;

function r = getQuestionCounter
global questionCounter
r = questionCounter;

function setTimeWatcher(val)
global timeWatcher
timeWatcher = val;

function r = getTimeWatcher
global timeWatcher
r = timeWatcher;

function setcLimitTime(val)
global cLimitTime
cLimitTime = val;

function r = getcLimitTime
global cLimitTime
r = cLimitTime;

function setcResponseTime(val)
global cResponseTime
cResponseTime = val;

function r = getcResponseTime
global cResponseTime
r = cResponseTime;

function setcRestTime(val)
global cRestTime
cRestTime = val;

function r = getcRestTime
global cRestTime
r = cRestTime;

function setGroupHitRate(val)
global groupHitRate
groupHitRate = val;

function r = getGroupHitRate
global groupHitRate
r = groupHitRate;

function r = getHitRate
global hitRate
m = getTimeWatcher;
activationHits = sum([m(:,1)==3 & m(:,7)==1]);
activationResponses = sum([m(:,1)==3 & ~isnan(m(:,7))]);
if activationResponses > 0
    hitRate = activationHits/activationResponses;
else
    hitRate = 0;
end
r = hitRate;

function setTimeSaved
global timeSaved
timeSaved = tic;

function r = getTimeSaved
global timeSaved
r = toc(timeSaved);

function setTimeCounter
global timeCounter
timeCounter = tic;

function r = getTimeCounter
global timeCounter
r = toc(timeCounter);


function background_SizeChangedFcn(hObject, eventdata, handles)
