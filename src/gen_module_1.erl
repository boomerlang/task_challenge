%% Author: andu
%% Created: Jan 19, 2012
%% Description: TODO: Add description to rkv_test
-module(gen_module_1).

%%
%% Include files
%%

%%
%% Exported Functions
%%
%% -export([]).
-compile(export_all).

gen_module_text() ->
    "
-module(nonexistent).

-compile(export_all).

func4() -> func2(), io:format(\"~p~n\", [4]).

func3() -> func1(), io:format(\"~p~n\", [3]).

func2() -> func3(), io:format(\"~p~n\", [2]).

func1() -> io:format(\"~p~n\", [1]).

sort() -> func4([]).

func4(Acc) -> func2([4|Acc]).

func3(Acc) -> func1([3|Acc]).

func2(Acc) -> func3([2|Acc]).

func1(Acc) -> [1|Acc].
".

handle_input1() ->
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
} ".

% {struct, [{<<"tasks">>, Tasks}]} = mochijson2:decode(Json),
% io:format("Tasks = ~p~n", [Tasks]),
% % Tasks.
%     try mochijson2:decode(Json) of
%         {struct, [{<<"tasks">>, Tasks}]} -> 
%             {ok, Tasks}
%     catch
%         _Error:ErrorReason -> 
%             {error, ErrorReason}
%     end.
    
% func4(Acc) -> func1(func3(func2([4|Acc]))).

% % func3(Acc) -> func1([3|Acc]).
% func3(Acc) -> [3|Acc].

% func2(Acc) -> [2|Acc].

% func1(Acc) -> [1|Acc].

% 'task-1'()-> func4([]).

% func4(Acc) -> func2([4|Acc]).

% func3(Acc) -> func1([3|Acc]).

% func2(Acc) -> func3([2|Acc]).

% func1(Acc) -> [1|Acc].

% maybe_set_task(Task, Acc) ->
%     if lists:member(Task, Acc) ->
%         Acc;
%     true ->
%         [Task|Acc]
%     end
    
% 'task-1'(Acc) -> [<<"task-1">>|Acc].
% 'task-2'(Acc) -> 'task-3'([<<"task-1">>,<<"task-2">>|Acc]++[]).
% 'task-3'(Acc) -> 'task-1'([<<"task-3">>|Acc]++[]).
% 'task-4'(Acc) -> 'task-2'([<<"task-4">>|Acc]++[]).

% func() ->
%     Acc = [], 
%     % func1(func3(func2([4|Acc]))).
%     func1(func3(func2(func4(Acc)))).

% func1() ->
%     Acc = [], 
%     % [func4(func2(Acc)), func3(func1(Acc)), func2(func3(Acc)), func1(Acc)].
%     % lists:uni
%     % lists:flatten([  func1(Acc), func3(func2(Acc)), func1(func3(Acc)), func2(func4(Acc))]).
%     % lists:flatten([  func1(Acc), func2(Acc), func3(Acc), func4(Acc)]).
%     % lists:flatten(
%         [  func1([]), func2([]), func3([]), func4([])].
%     % ).
%     % func1(func3(func2([4|Acc]))).

% % func3(Acc) -> func1([3|Acc]).
% func4(Acc) -> [4|Acc].

% func3(Acc) -> [3|Acc].

% func2(Acc) -> [2|Acc].

% func1(Acc) -> [1|Acc].

% sort() ->
%     [].

% func() -> func5([]).


% func5(Acc) -> func4([5|Acc]).

% func4(Acc) -> func2([4|Acc]).

% func3(Acc) -> func1([3|Acc]).

% func2(Acc) -> func3([2|Acc]).

% func1(Acc) -> [1|Acc].


bin2atom(X) ->
    try erlang:binary_to_existing_atom(X) of
        Atom -> Atom
    catch
        _Error:_ErrorReason -> 
            erlang:binary_to_atom(X)
    end.

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
}",

{struct, [{<<"tasks">>, Tasks}]} = mochijson2:decode(Json),
Tasks.
% lists:keysearch("name", 0, Tasks).


gen_tasks_module([], Acc) -> 
    ModuleName = "nonexistent_" ++ pid_str(),
    {ok, MTs, _} = erl_scan:string("-module(" ++ ModuleName ++ ")."),
    % {ok, ETs, _} = erl_scan:string("-export([sort_tasks/0])."),

    {ok, ETs, _} = erl_scan:string("-compile(export_all)."),

    {ok, MF} = erl_parse:parse_form(MTs),
    {ok, EF} = erl_parse:parse_form(ETs),
    % {ok, FTs, _} = erl_scan:string("sort_tasks."),
    {ModuleName, [MF, EF | Acc]};

gen_tasks_module([{struct, L} | T], Acc) -> 
    % TaskName0 = bin2atom(lists:keysearch(<<"name">>, 0, L)),
    {_, TaskName0} = lists:keyfind(<<"name">>, 1, L),
    Req = lists:keyfind(<<"requires">>, 1, L),
    Fun = if 
    Req =/= false ->
        {_, [TaskName1|_]} = Req,
        % TaskName1 = bin2atom(H1);
        iolist_to_binary(["'", TaskName0, "'(Acc) -> '", TaskName1, "'([\"", TaskName0, "\"|Acc])."]);
    true ->
        
        iolist_to_binary(["'", TaskName0, "'(Acc) -> ", "[\"", TaskName0, "\"|Acc]."])
    end,

    % if T == [] ->
    %     {ok, FTs, _} = erl_scan:string("sort_tasks() ->'", binary_to_list(TaskName0), "'([]).")
    % end,
    % Fun = iolist_to_binary(["'", TaskName0, "'() -> ", BodyFun]),
    {ok, Tokens, _EndLocation} = erl_scan:string(binary_to_list(Fun)),
    {ok, Form} = erl_parse:parse_form(Tokens),
    gen_tasks_module(T, [Form|Acc]).

pid_str() ->
	Pid1 = re:replace(pid_to_list(self()),"<(.*)>","\\1", [{return, list}]),
	re:replace(Pid1,"\\.","\\_", [{return, list}, global]).

handle_tokens() ->
    Tokens = [{'-',2},
          {atom,2,module},
          {'(',2},
          {atom,2,nonexistent},
          {')',2},
          {dot,2},
          {'-',4},
          {atom,4,compile},
          {'(',4},
          {atom,4,export_all},
          {')',4},
          {dot,4},
          {atom,6,func4},
          {'(',6},
          {')',6},
          {'->',6},
          {atom,6,func2},
          {'(',6},
          {')',6},
          {',',6},
          {integer,6,4},
          {dot,6},
          {atom,8,func3},
          {'(',8},
          {')',8},
          {'->',8},
          {atom,8,func1},
          {'(',8},
          {')',8},
          {',',8},
          {integer,8,3},
          {dot,8},
          {atom,10,func2},
          {'(',10},
          {')',10},
          {'->',10},
          {atom,10,func3},
          {'(',10},
          {')',10},
          {',',10},
          {integer,10,2},
          {dot,10},
          {atom,12,func2},
          {'(',12},
          {')',12},
          {'->',12},
          {integer,12,1},
          {dot,12}],

handle_tokens(Tokens, [], []).

handle_tokens(Tokens) ->
    handle_tokens(Tokens, [], []).

handle_tokens([], _Acc1, Acc2) -> lists:reverse(Acc2);

handle_tokens([{dot, Int}|T], Acc1, Acc2) ->
    Tok = lists:reverse([{dot, Int}|Acc1]),
    io:format("T = ~p~n", [Tok]),
    {ok, F} = erl_parse:parse_form(Tok),
    handle_tokens(T, [], [F|Acc2]);

handle_tokens([H|T], Acc1, Acc2) ->
    handle_tokens(T, [H|Acc1], Acc2).

inject_module(Filename, Forms) ->
    % ModuleText = gen_module_text(),
    % {ok, Tokens, _EndLocation} = erl_scan:string(ModuleText),
    % io:format("TOKENS = ~p~n", [Tokens]),
    % Forms = handle_tokens(Tokens),
    % {Filename, Forms} = parse_input(),
    % AF = erl_parse:abstract(Tokens),
    % AF = cerl:abstract(ModuleText),
    % AF = erl_parse:parse_form(Tokens),
    % io:format("Forms = ~p~n", [Forms]),
    {ok, ModuleName, BinaryOrCode} = compile:forms(Forms),
	% {_Module, Binary, Filename} = code:get_object_code(ModuleName),
%% 	io:format("NODE=~p~n", [Node]),
%% 	rpc:call(Node, code, load_binary, [Module, Filename, Binary]).
    % Filename = ModuleName0,
	code:load_binary(ModuleName, Filename, BinaryOrCode),
    % apply(ModuleName, 'task-4', [[]]).
     ModuleName:'task-4'([]).

handle_input() ->
    Tasks = parse_input(),
    {Filename, Forms} = gen_tasks_module(Tasks, []),
    Tasks1 = inject_module(Filename, Forms),
    Tasks1.

% reload_module(Module) ->
%     compile:file(Module),
% 	{_Module, Binary, Filename} = code:get_object_code(Module),
% %% 	io:format("NODE=~p~n", [Node]),
% %% 	rpc:call(Node, code, load_binary, [Module, Filename, Binary]).
% 	code:load_binary(Module, Filename, Binary).

% sort_input([Key|T1], [{_, L} | T2], Acc) ->
%     sort_input([Key|T1], T2, Acc).

% sort_input([[Key|T1], T2, Acc) ->
%     sort_input(T1, T2, Acc);

% lookup(Key, [{Key, Val}|_]) -> Val;
% lookup(Key, [_|T]) -> lookup(Key, T);
% lookup(_, []) -> [].

% sort_input([Key|T1], [{struct, L} | T2], Acc) ->
%     case lists:keyfind(Key, 1, L) of
%     {_, TaskName0} -> 
%         sort_input(T1, T2, [{struct, L}|Acc]);
%     _ ->
%         sort_input([Key|T1], T2, Acc);
%     end
