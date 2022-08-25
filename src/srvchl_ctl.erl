-module(srvchl_ctl).
-compile(export_all).


start([Node]) ->
 		% error_logger:logfile({open, "/var/srvchl/logs/error_log"}),
		inets:start(),
		{ok, Pid} = inets:start(httpd, [{port, 8080}, {server_name,"httpd_chall"}, {server_root,"/tmp"}, 
							{document_root,"/tmp/htdocs"}, {bind_address, "10.0.0.232"}, {modules, [gen_module]}]),
		io:format("Starting INETS server with pid:~p~n", [Pid]),
		application:start(srvchl).

debug([Node])->
		inets:start(),
		{ok, Pid} = inets:start(httpd, [{port, 8080}, {server_name,"httpd_chall"}, {server_root,"/tmp"}, 
							{document_root,"/tmp/htdocs"}, {bind_address, "10.0.0.232"}, {modules, [gen_module]}]),
		io:format("Starting INETS server with pid:~p~n", [Pid]),
		application:start(srvchl).

stop([Node])->
	case net_adm:ping(Node) of
        pong ->
			inets:stop(httpd, {{10,10,11,66}, 8080}),
			application:stop(srvchl),
			ok;
        pang ->
            io:format("~p *NOT STARTED* ~n", [Node]),
			fail
    end,
	init:stop().
	
status([Node])->
	case os:cmd("epmd -names|grep " ++ atom_to_list(Node)) of
		[] -> 
			io:format("~p not running ~n", [Node]);
		Running ->
			io:format("up and running : ~p~n", [lists:flatten(string:tokens(Running, "\n"))])
	end,
	init:stop().

reload_module(Module) ->
	{_Module, Binary, Filename} = code:get_object_code(Module),
	code:load_binary(Module, Filename, Binary).
