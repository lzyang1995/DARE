#!/bin/sh

#parameters:
#$1: the number of servers

num=$1
current=1
total=0
dgid="ff0e::ffff:e101:101" 
kvsfile="throughput"
bin_path="~/DARE/bin"
client_output="output"

#start the servers
while [ $total -lt num ]
do
	ip = "10.22.1.${current}"
	ssh -t -f ${ip} "cd ${bin_path};./srv_test -m ${dgid} -s ${num} -i ${total}"
	current='expr $current + 1'
	if [ $current == 10 ]
	then
		current=1
	fi
	total='expr $total + 1'
done

#start the client on the nineth machine. 
ssh -t -f 10.22.1.9 "cd ${bin_path};./clt_test -m ${dgid} --loop -t ${kvsfile} -o ${client_output}"

sleep 2

#kill the client process
ssh -t -f 10.22.1.9 "killall -9 clt_test"

#kill all the servers
current=1
while [ $current -lt 10 ]
do
	ip = "10.22.1.${current}"
	ssh -t -f ${ip} "killall -9 srv_test"
	current='expr $current + 1'
done