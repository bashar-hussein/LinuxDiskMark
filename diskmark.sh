#!/bin/bash

echo "------------------------------------------------------------------------------"
echo "LinuxDiskMark 1.0 (fio-based)"
echo "Inspired by CrystalDiskMark output style"
echo "------------------------------------------------------------------------------"
echo "* MB/s = 1,000,000 bytes/s | MiB/s = 1,048,576 bytes/s"
echo "* KB = 1000 bytes | KiB = 1024 bytes"
echo

TESTFILE="./fio_benchmark.test"
SIZE=1G
RUNTIME=5

function run_fio() {
  local NAME=$1
  local RW=$2
  local BS=$3
  local QD=$4
  local NUMJOBS=$5
  local DESC=$6

  fio --name=$NAME --rw=$RW --rwmixread=50 --bs=$BS --ioengine=libaio --iodepth=$QD --numjobs=$NUMJOBS \
      --size=$SIZE --runtime=$RUNTIME --group_reporting --filename=$TESTFILE > tmp_result.txt

  # Use the Run Status summary which is consistent
  local R_LINE=$(grep -A1 "Run status group 0" tmp_result.txt | grep "READ:")
  local W_LINE=$(grep -A1 "Run status group 0" tmp_result.txt | grep "WRITE:")

  local R_BW=$(echo "$R_LINE" | awk -F'[,= ]+' '{print $(NF-6)}')
  local R_IOPS=$(echo "$R_LINE" | awk -F'[,= ]+' '{print $(NF-3)}')
  local W_BW=$(echo "$W_LINE" | awk -F'[,= ]+' '{print $(NF-6)}')
  local W_IOPS=$(echo "$W_LINE" | awk -F'[,= ]+' '{print $(NF-3)}')

  # Fallback if missing
  [[ -z $R_BW ]] && R_BW="n/a"
  [[ -z $R_IOPS ]] && R_IOPS="n/a"
  [[ -z $W_BW ]] && W_BW="n/a"
  [[ -z $W_IOPS ]] && W_IOPS="n/a"

  printf "%-40s\n" "[$DESC]"
  printf "  READ : %8sB/s [%8s IOPS] <approx>\n" "$R_BW" "$R_IOPS"
  printf "  WRITE: %8sB/s [%8s IOPS] <approx>\n\n" "$W_BW" "$W_IOPS"
}

# Run tests similar to CrystalDiskMark
run_fio seq1mq8t1   randrw 1M 8 1 "SEQ    1MiB (Q=  8, T= 1)"
run_fio seq1mq1t1   randrw 1M 1 1 "SEQ    1MiB (Q=  1, T= 1)"
run_fio rnd4kq32t1  randrw 4k 32 1 "RND    4KiB (Q= 32, T= 1)"
run_fio rnd4kq1t1   randrw 4k 1 1  "RND    4KiB (Q=  1, T= 1)"

# Clean up
rm -f "$TESTFILE" tmp_result.txt
