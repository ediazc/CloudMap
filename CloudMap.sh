#!/bin/bash

set -o errexit -o nounset -o pipefail -o posix

RUNDATE=`date '+%y%0m%0d-%0H%0M%0S'`

DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ $# -lt 1 ]; then
 echo "Usage: $0 <binary> <nodecount> <experiment> <metric>"
 exit 1
fi

mkdir -p matrix

exe="$1"
numnodes="$2"
exp="$3"
var="$4"

#extract NTASKS using the standard naming of NAS benchmarks ie "bt.C.64"
NTASKS=$(basename $exe | sed 's/[^0-9]*\([0-9]*\)[^0-9]*/\1/')
benchmark=$(basename $exe | sed 's/\..*//')

#location of application' communication matrices (obtained offline using EZTrace)
commcsv=~/comm-patterns/$NTASKS/$benchmark.A.$NTASKS-num.csv

#compute mpibench performance using the number of nodes and the metric to evaluate, latency or bandwidth
/usr/bin/time -f "gen-arch: %e" ./gen-arch-csv.sh $numnodes $var


#generate communication matrix using the previous result
/usr/bin/time -f "arch-mat.R: %e" ./arch-mat.R $numnodes comm.csv arch-$benchmark-$NTASKS.csv

#archive performance results
cp arch-$benchmark-$NTASKS.csv matrix/arch-"$exp"-$benchmark-$NTASKS-$RUNDATE.csv


#calculate mapping using scotch library on the communication matrix
/usr/bin/time -f "calcmap: %e" $DIR/calcmap.sh $commcsv arch-$benchmark-$NTASKS.csv


#execute the application using the mapping stored in rankfile.txt
/usr/bin/time -f "mpirun: %e" mpirun --rankfile ~/rankfile.txt --hostfile ~/hostnames.txt -n $NTASKS -wdir ~/nas ./`basename $exe`

exit 0

