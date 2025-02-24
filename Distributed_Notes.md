# Erlang Port Mapper Daemon

## Making an erlang process available

When we start an erlang process as a node^1 it sends an 
ALIVE2_REQ to epmd and epmd sends ALIVE2_RESP back. 

This is a log of epmd after starting an erlang shell with `erl -name dilbert`
```sh
~ % epmd -debug
epmd: Thu Feb 20 18:45:00 2025: epmd running - daemon = 0
epmd: Thu Feb 20 18:49:14 2025: ** got ALIVE2_REQ
epmd: Thu Feb 20 18:49:14 2025: registering 'dilbert:1740106155', port 62105
epmd: Thu Feb 20 18:49:14 2025: type 77 proto 0 highvsn 6 lowvsn 5
epmd: Thu Feb 20 18:49:14 2025: ** sent ALIVE2_RESP for "dilbert"
```

epmd assigns a random high port number for the first node and 
increments the port number from there. If we need to
manually specify the port number (for ex: firewall reasons)
then we can with: 
`erl -kernel inet_dist_listen_min 8001 -kernel inet_dist_listen_max 8100 -name bilbert`

epmd output after creating a process with the above command:
```sh
epmd: Thu Feb 20 18:57:50 2025: registering 'bilbert:1740106671', port 8001
epmd: Thu Feb 20 18:57:50 2025: type 77 proto 0 highvsn 6 lowvsn 5
epmd: Thu Feb 20 18:57:50 2025: ** sent ALIVE2_RESP for "bilbert"
```

1. I believe this means running an erlang process with the `-name <name>` flag

## Connecting two nodes

We can connect to a node on the same computer with only a hostname.
No setup required. The ping command will establish a two way 
connection between the processes. (pong means message received :p)
```sh
(zilbert@Armans-MacBook-Pro.local)2> net_adm:ping('bilbert@Armans-MacBook-Pro.local').
pong
```

We can see all the nodes we have a connection with using nodes/0
```sh
(bilbert@Armans-MacBook-Pro.local)2> nodes().
['zilbert@Armans-MacBook-Pro.local']
```

## Testing in docker

For some reason setting a long-name for a node fails inside
erlang alpine docker image.
```sh
/ # erl -name one
=INFO REPORT==== 24-Feb-2025::19:18:06.085830 ===
Can't set long node name!
Please check your configuration
... stack trace
```
But its ok because it seems you only need the long-name if you want to 
communicate across domains [(from a thread made in 2008)](https://erlang.org/pipermail/erlang-questions/2008-June/036024.html), which I do
not need to do. So -sname is good enough :)

Computers running erlang on the same network can communicate by default. 
In our docker environment we can setup a connected set of nodes!

To do this you need to run these commands on each machine in the network.
(You will replace node_name with whatever you want to name the node)
```sh
$ hostname
<hostname>
$ erl -sname <node_name> -setcookie secret
```

Then to connect the nodes to eachother you will use
net_adm:ping('<node_name>@<hostname>') from within the erlang shell.
```erl
(node@<my_node_hostname>)4>net:adm:ping('local_node@other_machine').
pong
```

If the pong was not verification enough, we can check that we are
connected to other nodes using the nodes() function.
```erl
nodes().
[local_node@other_machine, ...]
```
