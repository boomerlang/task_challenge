%% This is the application resource file (.app file) for the 'srvchl'
%% application.
{application,srvchl,
 [{description, "CraftingSoftware coding challenge for Erlang Engineer" },
  {vsn, "1.0" },
  {modules, [gen_module mochijson2 mochinum]},
  {registered,[]},
  {mod,{srvchl_app,[
  			[]
  		]}
  },
  {env, [
         % {debug, false},                % true | false
         % {trace, false},                % http | traffic | false
         % {traceoutput, false},          % true | false
         % {conf, "/etc/yaws.conf"},      % string()
         % {runmod, mymodule},            % atom()
         % {embedded, false},             % true | false
         % {id, "default"},               % string()
         % {pam_service, "system-auth"},  % string()
         % {pam_use_acct, true},          % true | false
         % {pam_use_sess, true}           % true | false
        ]},
  {applications, [kernel,stdlib]}
  
  %%%{included_applications, [log4erl]}
 ]}.
