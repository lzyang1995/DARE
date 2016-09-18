#!/bin/bash

cd bin

num_line="$(cat ackinfo | wc -l)"
echo "${num_line}"

fist_part=$(( $num_line / 3 ))

second_part=$(( $num_line * 2 / 3 ))

echo $fist_part
echo $second_part

sed -n $fist_part,"$second_part"p ackinfo > newfile

awk '{sum+=$2} END {print "Average = ", sum/NR}' newfile

exit