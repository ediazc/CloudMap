#!/bin/bash

set -o errexit -o nounset -o pipefail

shopt -s lastpipe

# directory of this script
DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ $# -ne 2 ] ; then
 echo "usage: $0 task.csv arch.csv"
 exit
fi

task="$1"
arch="$2"
ppn="8" #defined manually

$DIR/csv2scotch.sh $task
$DIR/csv2scotch.sh $arch

amk_grf $arch.grf $arch.tgt

coreids=(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)

nodenum=$(wc -l $arch | cut -f 1 -d ' ')

scotch_gmap $task.grf $arch.tgt | tail -n +2 | while read line
 do
  rank=$(echo $line | cut -f 1 -d ' ')
  node=$(echo $line | cut -f 2 -d ' ')
  core=$((coreids[node]%ppn))
  coreids[node]=$((coreids[node]+1))
  nodename=CCGRID-$(printf "%02d" $((node+1)))

  if [ -z $core ]; then
      core="0"
  fi

#mapping assignment
  echo rank $rank=$nodename slot=$core

 done > ~/rankfile.txt

exit 0

#usage example
./calcmap.sh ../comm-patterns/64/bt.A.64-num.csv arch-bt-64.csv
