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

# total=0
# current=1
# while [ $total -lt $num ]
# do
# 	ip="10.22.1.${current}"
# 	consensus_num=$total
# 	line=`ssh -f ${ip} "cat ${bin_path}/new_consensus_latency_${consensus_num} | wc -l"`
# 	if [ $line -gt 10000 ]; then
# 		echo "new_consensus_latency_${consensus_num}"
# 		ssh ${ip} "awk '{ sum += \$1; n++ } END { if (n > 0) print sum / n; }' ${bin_path}/new_consensus_latency_${consensus_num}"
# 		#echo $consensus_latency
# 		break
# 	fi

# 	current=`expr $current + 1`
# 	if [ $current == 10 ]
# 	then
# 		current=1
# 	fi
# 	total=`expr $total + 1`
# 	sleep 2
# done

exit
