%%
%% Author: Bogdan Peta PFA
%%

%% f(Pid),{ok, Pid}=inets:start(httpd, [{port, 8081}, {server_name,"httpd_test"}, {server_root,"/tmp"}, {document_root,"/tmp/htdocs"}, {bind_address, "localhost"}, {modules, [gen_module]}]).

%% inets:stop(httpd, {{127,0,0,1}, 8081}).


-module(gen_module).

-include_lib("inets/include/httpd.hrl").

%%
%% Include files
%%

%%
%% Exported Functions
%%
%% -export([]).
-compile(export_all).

sort_t() -> 'task-4'([]).
'task-4'(Acc) -> 'task-2'(["task-4"|Acc]).

% 'task-3'(Acc) -> 'task-1'(["task-3","task-8","task-9","task-10"|Acc]).
% 'task-3'(Acc) -> 'task-1'(["task-3"|'task-10'(Acc)]).
% 'task-3'(Acc) -> 'task-1'('task-9'(["task-3"|Acc])).
'task-3'(Acc) -> 'task-1'(["task-3"|Acc]).

% 'task-2'(Acc) -> 'task-3'(["task-2" |Acc]).
'task-2'(Acc) -> 'task-3'(["task-2", "task-8", "task-9" |Acc]).

'task-1'(Acc) -> ["task-1"|Acc].

'task-8'(Acc) -> ["task-8"|Acc].

'task-9'(Acc) -> 'task-8'(["task-9"|Acc]).

'task-10'(Acc) -> 'task-9'(["task-10"|Acc]).


test_input(File) ->
    {ok, Json} = file:read_file("/home/andu/web/mweb_lib/" ++ File),
    handle_input(Json).
  

parse_input(Input) ->
    
    try mochijson2:decode(Input) of
        {struct, [{<<"tasks">>, Tasks}]} -> 
            io:format("Tasks = ~p~n", [Tasks]),
            {ok, Tasks}
    catch
        _Error:ErrorReason -> 
            {error, ErrorReason}
    end.
    
make_fun_form(Fun) ->
    {ok, Tokens, _EndLocation} = erl_scan:string(binary_to_list(Fun)),
    {ok, Form} = erl_parse:parse_form(Tokens),
    Form.
%%
%% CASES"
%%
%% 1. no emtpy intermediate tasks with/without last emtpy task
%% 2. there are emtpy intermediate tasks with/without last emtpy task
%% 3. all tasks are emtpy

gen_tasks_module([], Acc, Acc2, EmptyTasks, EntryPoint, TrackEmpties) -> 
    ModuleName = "fsdfsdfsdkf_" ++ pid_str(),
    {ok, MTs, _} = erl_scan:string("-module(" ++ ModuleName ++ ")."),
    {ok, ETs, _} = erl_scan:string("-export([sort_tasks/0])."),
    Fun = "sort_tasks() -> '" ++ binary_to_list(EntryPoint) ++ "'([]).",
    io:format("ENTRY-POINT-CALL=~p~n", [Fun]),
    {ok, FTs, _} = erl_scan:string(Fun),
    
    {ok, MF} = erl_parse:parse_form(MTs),
    {ok, EF} = erl_parse:parse_form(ETs),
    {ok, FF} = erl_parse:parse_form(FTs),
    
    %% Final Empty tasks
    Acc3 = if EmptyTasks == [] ->
        % iolist_to_binary(["'", TaskName0, "'(Acc) -> '", TaskName1, "'([<<\"", TaskName0, "\">>|Acc]++", LastTask, ")."]);
        % iolist_to_binary(["'", TaskName0, "'(Acc) -> '", TaskName1, "'([<<\"", TaskName0, "\">>|Acc])."]);
        
        % iolist_to_binary(["'", TaskName0, "'(Acc) -> '", TaskName0, "'([", "<<\"", TaskName1, "\">>,", "<<\"", TaskName0, "\">>|Acc]++", LastTask, ")."]);
        Acc;
    true ->

        ET = iolist_to_binary(lists:join(",", [["<<\"", TaskName2, "\">>"] || TaskName2 <- lists:reverse(EmptyTasks)])),
        io:format("EMPTY-TASKS=~p~n", [ET]),
        
        {Task, Fun0} = lists:keyfind(EntryPoint, 1, Acc),

        % io:format("ENTRY-POINT-FORM=~p~n", [erl_parse:normalise(Form0)]),
        io:format("ENTRY-POINT-FORM=~p~n", [Fun0]),

        % iolist_to_binary(["'", TaskName0, "'(Acc) -> '", TaskName1, "'([", ET, ",<<\"", TaskName0, "\">>|Acc]++", LastTask, ")."])

        % iolist_to_binary(["'", TaskName0, "'(Acc) -> '", TaskName1, "'([<<\"", TaskName0, "\">>,", ET, "|Acc]++", LastTask, ")."])
        % Fun = iolist_to_binary(["'", TaskName0, "'(Acc) -> '", TaskName1, "'([<<\"", TaskName0, "\">>,", ET, "|Acc])."]),

        % Form = make_fun_form(Fun),
        % iolist_to_binary(["'", TaskName0, "'(Acc) -> '", TaskName0, "'([", "<<\"", TaskName1, "\">>,", ET, ",<<\"", TaskName0, "\">>|Acc]++", LastTask, ")."])

        {L3, L4} = lists:split(size(Fun0)-2, binary_to_list(Fun0)),
        Fun1 = iolist_to_binary([L3, "++[", ET, "])." ]),
        io:format("F1=~p~n", [Fun1]),
        lists:keyreplace(EntryPoint, 1, Acc, {EntryPoint, Fun1})
    end,
    
    
    {_Tasks, Funs} = lists:unzip(Acc3),

    Forms = [make_fun_form(Fun) || Fun <- Funs],

    {ModuleName, [MF, EF, FF | Forms], Acc2};

gen_tasks_module([{struct, L} | T], Acc, Acc2, EmptyTasks, EntryPoint, TrackEmpties) -> 
    % io:format("ENTRY-POINT=~p~n", [EntryPoint]),
    io:format("TRACK-EMPTIES=~p~n", [TrackEmpties]),
    {_, TaskName0} = lists:keyfind(<<"name">>, 1, L),
    Req = lists:keyfind(<<"requires">>, 1, L),
    Lent = length(T),
    if 
    Req == false ->
        
        gen_tasks_module(T, Acc, Acc2, [TaskName0|EmptyTasks], EntryPoint, [TaskName0|TrackEmpties]);
        % gen_tasks_module(T, Acc, Acc2, [TaskName0|EmptyTasks], EntryPoint)
        
        % iolist_to_binary(["'", TaskName0, "'(Acc) -> ", "[<<\"", TaskName0, "\">>|Acc]."]);
    true ->
        {_, [TaskName1|_]} = Req,

        % EntryPoint1 = if EntryPoint == <<>> ->
        %     TaskName0;
        % true ->
        %     EntryPoint
        % end,
        % LastTask = 
        % if Lent == 1 -> 
        %     % check for last emtpy task
        %     % extract next which is last and
        %     % insert next in back of this
        %     % we look-ahead in last task:
        %     [{struct, L0}] = T,
        %     {_, TaskName0_l} = lists:keyfind(<<"name">>, 1, L0),
        %     Req_l = lists:keyfind(<<"requires">>, 1, L0),

        %     if Req_l == false ->
        %         ["[<<\"", TaskName0_l, "\">>]"];
        %     true -> ["[]"]
        %     end;
        % true -> ["[]"]
        % end,
        % {LastTask, EntryPoint1} = 
        % if Lent == 1 -> 
        %     % check for last emtpy task
        %     % we look-ahead in last task:
        %     [{struct, L0}] = T,
        %     {_, TaskName0_l} = lists:keyfind(<<"name">>, 1, L0),
        %     Req_l = lists:keyfind(<<"requires">>, 1, L0),

        %     if Req_l == false ->
        %         {["[<<\"", TaskName0_l, "\">>]"], TaskName0};
        %     true -> 
        %         {["[]"], TaskName0_l}
        %     end;
        % true -> {["[]"], EntryPoint}
        % end,
        % {iolist_to_binary(["'", TaskName0, "'(Acc) -> '", TaskName1, "'([<<\"", TaskName0, "\">>|Acc]++", LastTask, ")."]),
        % EntryPoint1}
        Fun = if EmptyTasks == [] ->
            % iolist_to_binary(["'", TaskName0, "'(Acc) -> '", TaskName1, "'([<<\"", TaskName0, "\">>|Acc]++", LastTask, ")."]);
            iolist_to_binary(["'", TaskName0, "'(Acc) -> '", TaskName1, "'([<<\"", TaskName0, "\">>|Acc])."]);
            
            % iolist_to_binary(["'", TaskName0, "'(Acc) -> '", TaskName0, "'([", "<<\"", TaskName1, "\">>,", "<<\"", TaskName0, "\">>|Acc]++", LastTask, ")."]);
        true ->
            io:format("TASK-NAME-1=~p~n", [TaskName1]),
            IsMember = lists:member(TaskName1, TrackEmpties),
            EmptyTasks1 = if IsMember == true ->
                lists:delete(TaskName1, EmptyTasks);
            true ->
                EmptyTasks
            end,
            ET = iolist_to_binary(lists:join(",", [["<<\"", TaskName2, "\">>"] || TaskName2 <- lists:reverse(EmptyTasks1)])),
            io:format("EMPTY-TASKS=~p~n", [ET]),
            

            % iolist_to_binary(["'", TaskName0, "'(Acc) -> '", TaskName1, "'([", ET, ",<<\"", TaskName0, "\">>|Acc]++", LastTask, ")."])

            % iolist_to_binary(["'", TaskName0, "'(Acc) -> '", TaskName1, "'([<<\"", TaskName0, "\">>,", ET, "|Acc]++", LastTask, ")."])
            iolist_to_binary(["'", TaskName0, "'(Acc) -> '", TaskName1, "'([<<\"", TaskName0, "\">>,", ET, "|Acc])."])

            % iolist_to_binary(["'", TaskName0, "'(Acc) -> '", TaskName0, "'([", "<<\"", TaskName1, "\">>,", ET, ",<<\"", TaskName0, "\">>|Acc]++", LastTask, ")."])
        end,
        
        Fun2 = fun(TaskName1) -> iolist_to_binary(["'", TaskName1, "'(Acc) -> ", "[<<\"", TaskName1, "\">>|Acc]."]) end,
        
        % Forms2 = [{TaskName1, make_fun_form(Fun2(TaskName2)) } || TaskName2 <- lists:reverse(EmptyTasks)],

        Funs = [{TaskName1, Fun2(TaskName2) } || TaskName2 <- lists:reverse(EmptyTasks)],

        io:format("FUNCTION=~p:~p~n", [Fun, EmptyTasks]),
        % io:format("FUNCTION-2=~p~n", [Fun2]),
        % Form = make_fun_form(Fun),
        % Form2 = make_fun_form(Fun2),
        
        L1 = lists:keydelete(<<"requires">>, 1, L),
        gen_tasks_module(T, [{TaskName0, Fun} | Funs ++ Acc], [{TaskName0, L1}|Acc2], [], TaskName0, TrackEmpties)
        % gen_tasks_module(T, [Form|Acc], [{TaskName0, L1}|Acc2], [], EntryPoint1)
    end.
    

pid_str() ->
	Pid1 = re:replace(pid_to_list(self()),"<(.*)>","\\1", [{return, list}]),
	re:replace(Pid1,"\\.","\\_", [{return, list}, global]).

inject_module(Filename, Forms) ->
    {ok, ModuleName, BinaryOrCode} = compile:forms(Forms),
    
	code:load_binary(ModuleName, Filename, BinaryOrCode),
    Rez = ModuleName:sort_tasks(),
    CheckResult = check_process_code(self(), ModuleName, []),
    io:format("CheckResult = ~p~n", [CheckResult]),
    code:purge(ModuleName),
    code:delete(ModuleName),
    % ModuleName:'task-4'([]),
    Rez.

sort_input([], _L, Acc, Acc2) -> {lists:reverse(Acc), lists:join("\n", lists:reverse(Acc2))};

sort_input([Key|T1], L, Acc, Acc2) ->
    {value, {_, Tuple}, L1} = lists:keytake(Key, 1, L),
    % io:format("Tuple = ~p~n", [Tuple]),
    {_, Cmd} = lists:keyfind(<<"command">>, 1, Tuple),
    sort_input(T1, L1, [{struct, Tuple}|Acc], [Cmd|Acc2]).

handle_input(Input) ->
    case parse_input(Input) of
    {ok, Tasks} ->
        {Filename, Forms, TaskMap} = 
            % gen_tasks_module(lists:reverse(Tasks), [], [], [], <<>>),
            gen_tasks_module(Tasks, [], [], [], <<>>, []),
        
         Ordered = inject_module(Filename, Forms),
         Ordered;
        % % TaskMap,
        % {OrderedTasks, Cmds} = sort_input(Ordered, TaskMap, [], []),
        % ShellScript = iolist_to_binary(["#!/usr/bin/env bash\n", Cmds, "\n"]),
        % Json = {struct, [{<<"tasks">>, OrderedTasks}]},
        % {iolist_to_binary(mochijson2:encode(Json)), ShellScript};
    _ ->
        {<<"{\"error\":\"Invalid input\"}">>, ""}
    end.

% do(ModData) ->
%     do1(ModData).

do(ModData) when ModData#mod.method == "POST" ->
% do(ModData#mod{method=Met}) when Met == "GET" ->
    io:format("ModData = ~p~n", [ModData]),
    % NewData = [{response, {200, "ShellScript"} }],

    Input = ModData#mod.entity_body,
    io:format("POST-DATA = ~p~n", [ModData#mod.entity_body]),


% do(ModData#mod{method=Met}) when Met == "GET" ->
    io:format("ModData = ~p~n", [ModData]),
    Head = [{content_type, <<"application/json">>}],
    Uri = ModData#mod.request_uri,
    {RespBody, ShellScript} = handle_input(Input),
    % RespBody1 = iolist_to_binary(RespBody),
    io:format("Uri = ~p~n", [Uri]),
    io:format("RespBody1 = ~p~n", [RespBody]),
    NewData = case Uri of
        "/tasks" ->
            [{response, {response, Head, binary_to_list(RespBody)}}];
        _   -> 
            [{response, {200, binary_to_list(ShellScript)} }]
    end,
    % Body = 
    % Response = [{response, {response, Head, Body}}],
    {proceed, NewData};

do(ModData) ->
    [{response, {200, "Method not allowed"} }].

