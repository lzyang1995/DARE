#!/bin/bash
#parameters:
#$1: the number of servers
set -x

num=$1
current=1
total=0
dgid="ff0e::ffff:e101:101" 
kvsfile="throughput"
bin_path="~/DARE/bin"
client_output="output"

#compile
while [ $current -lt 10 ]
do
	ip="10.22.1.${current}"
	ssh ${ip} "cd ${bin_path};cd ..;git pull;make"
	current=`expr $current + 1`
done

#start the servers
total=0
current=1
while [ $total -lt $num ]
do
	ip="10.22.1.${current}"
	ssh -f ${ip} "cd ${bin_path};./srv_test -m ${dgid} -s ${num} -i ${total}"
	current=`expr $current + 1`
	if [ $current == 10 ]
	then
		current=1
	fi
	total=`expr $total + 1`
	sleep 10
done

sleep 60
#start the client on the nineth machine. 
ssh -f 10.22.1.9 "cd ${bin_path};./clt_test -m ${dgid} --loop -t ${kvsfile} -o ${client_output}"

sleep 5

#kill the client process
ssh 10.22.1.9 "killall -2 clt_test"

#kill all the servers
current=1
while [ $current -lt 10 ]
do
	ip="10.22.1.${current}"
	ssh ${ip} "killall -2 srv_test"
	current=`expr $current + 1`
done

exit