#!/bin/bash

mkdir -p comm
rm -f comm/*

mpibenchloc="/home/benchsmpi/mpbench"
mpibenchexec="mpi_bench_v2"

if [ $# -lt 2 ] ; then
	echo "usage: $0 ./gen-arch-csv.sh <node_count> <metric> [message_size]"
	exit
fi

nodes="$1"
test="$2"
size="$3"

#if message size is not defined then default is 1K
if [[ $size ]]; then
 size="M$size"
 else
 size="M1K"
fi

#define the fixed part used in naming the deployment processing nodes
basehost="CCGRID-"

for node in $(eval echo {01.."$nodes"})
 do
  myid=$node

  block=`echo "(($nodes/2)-1)" | bc`
  start=`echo "$myid" | bc`

  for i in $(eval echo {00.."$block"})
   do
    pair=`echo "(1+($i+$myid)%($nodes))" | bc | awk '{printf "%02d",$0}'`
    if [ $i -eq $block -a $node -eq $nodes ]; then
      echo "mpirun -bynode -host "$basehost""$myid","$basehost""$pair" -wdir $mpibenchloc ./$mpibenchexec -i 1000 -"$test" -"$size" | cut -f 2 -d ' ' | xargs echo -e "$myid"-"$pair""\t" > comm/"$myid"-"$pair".csv"
    else
      echo "mpirun -bynode -host "$basehost""$myid","$basehost""$pair" -wdir $mpibenchloc ./$mpibenchexec -i 1000 -"$test" -"$size" | cut -f 2 -d ' ' | xargs echo -e "$myid"-"$pair""\t" > comm/"$myid"-"$pair".csv &"
      sleep 0.035
    fi
   done
 done

cat comm/*.csv > comm.csv

exit 0

#usage example
#./gen-arch-csv.sh 8 l [4K]
