%%% -------------------------------------------------------------------
%%% Author  : andu
%%% Description :
%%%
%%% Created : Jun 14, 2010
%%% -------------------------------------------------------------------
-module(srvchl_sup).

-behaviour(supervisor).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
%% --------------------------------------------------------------------
-export([]).

%% --------------------------------------------------------------------
%% Internal exports
%% --------------------------------------------------------------------
-export([
	start_link/1,
	 init/1
        ]).

%% --------------------------------------------------------------------
%% Macros
%% --------------------------------------------------------------------
-define(SERVER, ?MODULE).

%% --------------------------------------------------------------------
%% Records
%% --------------------------------------------------------------------

%% ====================================================================
%% External functions
%% ====================================================================



%% ====================================================================
%% Server functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Func: init/1
%% Returns: {ok,  {SupFlags,  [ChildSpec]}} |
%%          ignore                          |
%%          {error, Reason}
%% --------------------------------------------------------------------
start_link(Args) ->
    supervisor:start_link(?MODULE, Args).

init(_Args) ->
	
	
    {ok,{{one_for_all, 3, 10}, [
		
		
	]}}.

%% ====================================================================
%% Internal functions
%% ====================================================================