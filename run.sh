#!/bin/bash
#parameters:
#$1: the number of servers
set -x

num=$1
current=2
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

ssh -f 10.22.1.1 "cd ${bin_path}; ulimit -c unlimited; ./srv_test -m ${dgid} -s ${num} -i 0"

#start the servers
total=1
current=2
while [ $total -lt $num ]
do
	ip="10.22.1.${current}"
	ssh -f ${ip} "cd ${bin_path}; ulimit -c unlimited; ./srv_test -m ${dgid} -s ${num} -i ${total}"
	current=`expr $current + 1`
	if [ $current == 10 ]
	then
		current=2
	fi
	total=`expr $total + 1`
	sleep 2
done

sleep 60
#start the clients.
total=1
client_num=$2
client_current=9
while [ $total -le $client_num ]
do
	ip="10.22.1.${client_current}"
	ssh -f ${ip} "cd ${bin_path}; ./clt_test -m ${dgid} --loop -p 50 -t ${kvsfile} -o ${client_output} -i ${total}"
	client_current=`expr $client_current - 1`
	if [ $client_current == 0 ]
	then
		client_current=9
	fi
	total=`expr $total + 1`
	#sleep 2
done

sleep 10

#kill all the clients
current=1
while [ $current -lt 10 ]
do
	ip="10.22.1.${current}"
	ssh ${ip} "killall -2 clt_test"
	current=`expr $current + 1`
done

#kill all the servers
current=1
while [ $current -lt 10 ]
do
	ip="10.22.1.${current}"
	ssh ${ip} "killall -2 srv_test"
	current=`expr $current + 1`
done

#ssh 10.22.1.1 "awk '{ sum += \$1; n++ } END { if (n > 0) print sum / n; }' ${bin_path}/new_consensus_latency_0"

exit
