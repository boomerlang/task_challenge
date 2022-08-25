%%
%% Author: Bogdan Peta PFA
%%

%% f(Pid),{ok, Pid}=inets:start(httpd, [{port, 8081}, {server_name,"httpd_test"}, {server_root,"/tmp"}, {document_root,"/tmp/htdocs"}, {bind_address, "localhost"}, {modules, [gen_module]}]).

%% inets:stop(httpd, {{127,0,0,1}, 8081}).


-module(gen_module_2).

-include_lib("inets/include/httpd.hrl").

%%
%% Include files
%%

%%
%% Exported Functions
%%
%% -export([]).
-compile(export_all).


parse_input() ->
    Json = "{
\"tasks\": [
{
\"name\": \"task-1\",
\"command\": \"touch /tmp/file1\"
},
{
\"name\": \"task-2\",
\"command\":\"cat /tmp/file1\",
\"requires\":[
\"task-3\"
]
},
{
\"name\": \"task-3\",
\"command\": \"echo 'Hello World!' > /tmp/file1\",
\"requires\":[
\"task-1\"
]
},
{
\"name\": \"task-4\",
\"command\": \"rm /tmp/file1\",
\"requires\":[
\"task-2\",
\"task-3\"
]
}
]
} }",

% {struct, [{<<"tasks">>, Tasks}]} = mochijson2:decode(Json),
% io:format("Tasks = ~p~n", [Tasks]),
% Tasks.
    try mochijson2:decode(Json) of
        {struct, [{<<"tasks">>, Tasks}]} -> 
            {ok, Tasks}
    catch
        _Error:ErrorReason -> 
            {error, ErrorReason}
    end.
  
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
    

gen_tasks_module([], Acc, Acc2, EntryPoint) -> 
    ModuleName = "fsdfsdfsdkf_" ++ pid_str(),
    {ok, MTs, _} = erl_scan:string("-module(" ++ ModuleName ++ ")."),
    {ok, ETs, _} = erl_scan:string("-export([sort_tasks/0])."),
    Fun = "sort_tasks() -> '" ++ binary_to_list(EntryPoint) ++ "'([]).",
    io:format("FUNCTION-ENTRYPOINT=~p~n", [Fun]),
    {ok, FTs, _} = erl_scan:string(Fun),
    % {ok, ETs, _} = erl_scan:string("-compile(export_all)."),

    {ok, MF} = erl_parse:parse_form(MTs),
    {ok, EF} = erl_parse:parse_form(ETs),
    {ok, FF} = erl_parse:parse_form(FTs),
    
    {ModuleName, [MF, EF, FF | Acc], Acc2};

gen_tasks_module([{struct, L} | T], Acc, Acc2, EntryPoint) -> 
    % TaskName0 = bin2atom(lists:keysearch(<<"name">>, 0, L)),
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
            % extract next which is last and
            % insert next in back of this
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
        % iolist_to_binary(["'", TaskName0, "'(Acc) -> '", TaskName1, "'([<<\"", TaskName0, "\">>|Acc])."]);
        {iolist_to_binary(["'", TaskName0, "'(Acc) -> '", TaskName1, "'([<<\"", TaskName0, "\">>|Acc]++", LastTask, ")."]),
        EntryPoint1}
    end,

    % if T == [] ->
    %     {ok, FTs, _} = erl_scan:string("sort_tasks() ->'", binary_to_list(TaskName0), "'([]).")
    % end,
    % Fun = iolist_to_binary(["'", TaskName0, "'() -> ", BodyFun]),
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
        {Filename, Forms, TaskMap} = gen_tasks_module(Tasks, [], [], 'None'),
        Ordered = inject_module(Filename, Forms),
        % Ordered.
        % TaskMap,
        {OrderedTasks, Cmds} = sort_input(Ordered, TaskMap, [], []),
        ShellScript = iolist_to_binary(["#!/usr/bin/env bash\n", Cmds, "\n"]),
        Json = {struct, [{<<"tasks">>, OrderedTasks}]},
        {iolist_to_binary(mochijson2:encode(Json)), ShellScript};
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

