function varargout = intro(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @intro_OpeningFcn, ...
                   'gui_OutputFcn',  @intro_OutputFcn, ...
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


% --- Executes just before intro is made visible.
function intro_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);

function varargout = intro_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function work_dir_Callback(hObject, eventdata, handles)

function work_dir_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function work_dir_bt_Callback(hObject, eventdata, handles)
dname = uigetdir('C:\');
set(handles.work_dir, 'String', dname);
set(handles.quest_dir, 'String', strcat(dname,'/questoes.csv'));

function nome_individuo_Callback(hObject, eventdata, handles)

function nome_individuo_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function quest_dir_Callback(hObject, eventdata, handles)

function quest_dir_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function quest_dir_bt_Callback(hObject, eventdata, handles)
[FileName,PathName] = uigetfile(strcat(handles.work_dir.String,'/*.csv'),'Selecione um arquivo de questoes formato CSV');
set(handles.quest_dir, 'String', strcat(PathName,FileName));

function treinamento_bt_Callback(hObject, eventdata, handles)
if isempty(handles.work_dir.String)
    errordlg('Coloque um nome de individuo para iniciar o treinamento', 'Erro');
else
    treinamento(handles.work_dir.String, handles.quest_dir.String,get(handles.nome_individuo,'string'));
end

function experiment_bt_Callback(hObject, eventdata, handles)
if isempty(handles.work_dir.String)
    errordlg('Coloque um nome de individuo para iniciar o experimento', 'Erro');
else
    experiment(handles.work_dir.String, handles.quest_dir.String,get(handles.nome_individuo,'string'));
end

function dados_treinamento_Callback(hObject, eventdata, handles)


function dados_treinamento_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function dados_treinamento_bt_Callback(hObject, eventdata, handles)
[FileName,PathName] = uigetfile(strcat(handles.work_dir.String,'/',get(handles.nome_individuo,'string'),'/*.csv'),'Selecione um arquivo de dados no formato CSV');
set(handles.dados_treinamento, 'String', strcat(PathName,FileName));

function calcular_parametros_Callback(hObject, eventdata, handles)
[time,hit_rate,answers] = get_trainning_results(handles.dados_treinamento.String);
set(handles.tempo_medio, 'String', strcat(sprintf('%0.2f',time),' s'));
set(handles.acertos, 'String', strcat(sprintf('%0.1f',hit_rate*100),' %'));
set(handles.respostas, 'String', num2str(answers));
handles.avg_time = time;
handles.hit_rate = hit_rate;
handles.answers = answers;
guidata(hObject, handles);








