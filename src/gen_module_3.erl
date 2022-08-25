%%
%% Author: Bogdan Peta PFA
%%

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

'task-3'(Acc) -> 'task-1'(["task-3","task-8","task-9","task-10"|Acc]).
% 'task-3'(Acc) -> 'task-1'(["task-3"|'task-10'(Acc)]).
% 'task-3'(Acc) -> 'task-1'('task-9'(["task-3"|Acc])).
% 'task-3'(Acc) -> 'task-1'(["task-3"|Acc]).

'task-2'(Acc) -> 'task-3'(["task-2" |Acc]).
% 'task-2'(Acc) -> 'task-3'(["task-8", "task-9", "task-2" |Acc]).

'task-1'(Acc) -> ["task-1"|Acc].

'task-8'(Acc) -> ["task-8"|Acc].

'task-9'(Acc) -> 'task-8'(["task-9"|Acc]).

'task-10'(Acc) -> 'task-9'(["task-10"|Acc]).



test_input(File) ->
    {ok, Json} = file:read_file("/home/andu/web/chall_craft/" ++ File),
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

maybe_set_task(Task, Acc) ->
    Is = lists:member(Task, Acc),
    if  Is == false ->
        
        [Task|Acc];
    true ->
        Acc
    end.

%%
%% Treat case when last task empty
%%
%% To DO:
%% handle intermediary empty tasks (alhough does not make sense)
%%

gen_tasks_module([], Acc, Acc2, EntryPoint) -> 
    ModuleName = "fsdfsdfsdkf_" ++ pid_str(),
    {ok, MTs, _} = erl_scan:string("-module(" ++ ModuleName ++ ")."),
    {ok, ETs, _} = erl_scan:string("-export([sort_tasks/0])."),
    Fun = "sort_tasks() -> '" ++ binary_to_list(EntryPoint) ++ "'([]).",
    {ok, FTs, _} = erl_scan:string(Fun),
    
    {ok, MF} = erl_parse:parse_form(MTs),
    {ok, EF} = erl_parse:parse_form(ETs),
    {ok, FF} = erl_parse:parse_form(FTs),
    
    {ModuleName, [MF, EF, FF | Acc], Acc2};

gen_tasks_module([{struct, L} | T], Acc, Acc2, EntryPoint) -> 
    {_, TaskName0} = lists:keyfind(<<"name">>, 1, L),
    Req = lists:keyfind(<<"requires">>, 1, L),
    Lent = length(T),
    {Fun, EntryPoint0} = 
    if Req == false ->
        {iolist_to_binary(["'", TaskName0, "'(Acc) -> ", "[<<\"", TaskName0, "\">>|Acc]."]),
            EntryPoint
        };
    true ->
        {_, [TaskName1|_]} = Req,
        {LastTask, EntryPoint1} = 
        if Lent == 1 -> 
            % check for last emtpy task
            % we look-ahead in last task:
            [{struct, L0}] = T,
            {_, TaskName0_l} = lists:keyfind(<<"name">>, 1, L0),
            Req_l = lists:keyfind(<<"requires">>, 1, L0),

            if Req_l == false ->
                {["[<<\"", TaskName0_l, "\">>]"], TaskName0};
            true -> {["[]"], TaskName0_l}
            end;
        true -> {["[]"], EntryPoint}
        end,
        {iolist_to_binary(["'", TaskName0, "'(Acc) -> '", TaskName1, "'([<<\"", TaskName0, "\">>|Acc]++", LastTask, ")."]),
        EntryPoint1}
    end,

    io:format("FUNCTION=~p~n", [Fun]),
    {ok, Tokens, _EndLocation} = erl_scan:string(binary_to_list(Fun)),
    {ok, Form} = erl_parse:parse_form(Tokens),
    L1 = lists:keydelete(<<"requires">>, 1, L),
    gen_tasks_module(T, [Form|Acc], [{TaskName0, L1}|Acc2], EntryPoint0).
    

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
    Rez.

sort_input([], _L, Acc, Acc2) -> {lists:reverse(Acc), lists:join("\n", lists:reverse(Acc2))};

sort_input([Key|T1], L, Acc, Acc2) ->
    {value, {_, Tuple}, L1} = lists:keytake(Key, 1, L),
    {_, Cmd} = lists:keyfind(<<"command">>, 1, Tuple),
    sort_input(T1, L1, [{struct, Tuple}|Acc], [Cmd|Acc2]).

handle_input(Input) ->
    case parse_input(Input) of
    {ok, Tasks} ->
        {Filename, Forms, TaskMap} = 
            gen_tasks_module(Tasks, [], [], []),
        
        Ordered = inject_module(Filename, Forms),
        
        {OrderedTasks, Cmds} = sort_input(Ordered, TaskMap, [], []),
        ShellScript = iolist_to_binary(["#!/usr/bin/env bash\n", Cmds, "\n"]),
        Json = {struct, [{<<"tasks">>, OrderedTasks}]},
        {iolist_to_binary(mochijson2:encode(Json)), ShellScript};
    _ ->
        {<<"{\"error\":\"Invalid input\"}">>, ""}
    end.

do(ModData) ->
    do1(ModData).

do1(ModData) when ModData#mod.method == "POST" ->
    Input = ModData#mod.entity_body,
    io:format("POST-DATA = ~p~n", [ModData#mod.entity_body]),

    Head = [{content_type, "application/json"}],
    Uri = ModData#mod.request_uri,
    {RespBody, ShellScript} = handle_input(Input),

    io:format("Uri = ~p~n", [Uri]),

    NewData = case Uri of
        "/tasks" ->
            [{response, {200, binary_to_list(RespBody)}}];
        "/shellscript"   -> 
            [{response, {200, binary_to_list(ShellScript)} }];
        _ ->
            [{response, {404, "Not Found!"} }]
    end,
    
    {proceed, NewData};

do1(ModData) ->
    {proceed, [{response, {405, "Method not allowed"} }] }.

