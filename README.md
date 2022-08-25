Minimalist and self-contained service that implements the challenge.

Requirements:
-------------


In this coding challenge we kindly ask you to implement a rather contrived HTTP job processing
service.

A job is a collection of tasks, where each task has a name and a shell command.Tasks may
depend on other tasks and require that those are executed beforehand.The service takes care
of sorting the tasks to create a proper execution order.

An example request body: 
{
    "tasks": [{
            "name": "task-1",
            "command": "touch /tmp/file1"
        },
        {
            "name": "task-2",
            "command": "cat /tmp/file1",
            "requires": [
                "task-3"
            ]
        },
        {
            "name": "task-3",
            "command": "echo 'Hello World!' > /tmp/file1",
            "requires": [
                "task-1"
            ]
        },
        {
            "name": "task-4",
            "command": "rm /tmp/file1",
            "requires": [
                "task-2",
                "task-3"
            ]
        }
    ]
}

For which an example response might look like the following: 
{
    "tasks": [{
            "name": "task-1",
            "command": "touch /tmp/file1"
        },
        {
            "name": "task-3",
            "command": "echo 'Hello World!' > /tmp/file1"
        },
        {
            "name": "task-2",
            "command": "cat /tmp/file1"
        },
        {
            "name": "task-4",
            "command": "rm /tmp/file1"
        }
    ]
}

Additionally, the service should be able to
return a bash script representation directly: #!/usr/bin / env bash
touch / tmp / file1
echo "Hello World!" > /tmp/file
1
cat / tmp / file1
rm / tmp / file1

Please include any instructions you deem necessary to be able to test the execution of the
solution.CraftingSoftware coding challenge for Erlang Engineer!


Intructions
-----------

Files that need to be modified:
1. src/srvchl_ctl.erl
   set bind_address to your IP address;
   and then:
   $ make
2. In script srvchld:
    set the envvar ERL_CALL to your real erl_call location



1. Start the server:
$ sh srvchld start

2. Stop the server:
$ sh srvchld stop

3. Query the status of the server:
$ sh srvchld status


Endopints:

curl  -XPOST http://boomerlang.eu:8080/tasks --data @tasks.json

curl  -XPOST http://boomerlang.eu:8080/shellscript --data @tasks.json


