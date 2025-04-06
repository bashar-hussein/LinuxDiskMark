#!/bin/bash

# ====== CONFIG ======
POOL_NAME="SMB-Pool"
CONTEXT="data"
TESTFILE="./fio_testfile.tmp"
TEMP_FILE="raw_${POOL_NAME}_${CONTEXT}.txt"
FINAL_FILE="result_${POOL_NAME}_${CONTEXT}.txt"
SIZE=1G
RUNTIME=5

# ====== HEADER ======
{
  echo "------------------------------------------------------------------------------"
  echo "LinuxDiskMark 1.0 (fio-based)"
  echo "Inspired by CrystalDiskMark output style"
  echo "------------------------------------------------------------------------------"
  echo "* MB/s = 1,000,000 bytes/s | MiB/s = 1,048,576 bytes/s"
  echo "* KB = 1000 bytes | KiB = 1024 bytes"
  echo
} > "$FINAL_FILE"

# ====== FIO RUNNER FUNCTION ======
run_fio() {
  local NAME=$1
  local RW=$2
  local BS=$3
  local QD=$4
  local NUMJOBS=$5
  local DESC=$6

  # Run fio and write raw output
  fio --name=$NAME --rw=$RW --rwmixread=50 --bs=$BS --ioengine=libaio \
      --iodepth=$QD --numjobs=$NUMJOBS --size=$SIZE --runtime=$RUNTIME \
      --group_reporting --filename=$TESTFILE > "$TEMP_FILE"

  # Extract READ and WRITE blocks from final summary
  local R_LINE=$(grep "READ:" "$TEMP_FILE")
  local W_LINE=$(grep "WRITE:" "$TEMP_FILE")

  local R_BW=$(echo "$R_LINE" | awk -F'[,=()]+' '{for(i=1;i<=NF;i++) if($i=="bw") print $(i+1)}')
  local R_IOPS=$(echo "$R_LINE" | awk -F'[,=()]+' '{for(i=1;i<=NF;i++) if($i=="iops") print $(i+1)}')

  local W_BW=$(echo "$W_LINE" | awk -F'[,=()]+' '{for(i=1;i<=NF;i++) if($i=="bw") print $(i+1)}')
  local W_IOPS=$(echo "$W_LINE" | awk -F'[,=()]+' '{for(i=1;i<=NF;i++) if($i=="iops") print $(i+1)}')

  [[ -z "$R_BW" ]] && R_BW="n/a"
  [[ -z "$R_IOPS" ]] && R_IOPS="n/a"
  [[ -z "$W_BW" ]] && W_BW="n/a"
  [[ -z "$W_IOPS" ]] && W_IOPS="n/a"

  {
    printf "%-40s\n" "[$DESC]"
    printf "  READ : %-10s [%8s IOPS]\n" "$R_BW" "$R_IOPS"
    printf "  WRITE: %-10s [%8s IOPS]\n\n" "$W_BW" "$W_IOPS"
  } >> "$FINAL_FILE"
}

# ====== RUN TESTS ======
run_fio seq1mq8t1   randrw 1M 8 1 "SEQ    1MiB (Q=  8, T= 1)"
run_fio seq1mq1t1   randrw 1M 1 1 "SEQ    1MiB (Q=  1, T= 1)"
run_fio rnd4kq32t1  randrw 4k 32 1 "RND    4KiB (Q= 32, T= 1)"
run_fio rnd4kq1t1   randrw 4k 1 1  "RND    4KiB (Q=  1, T= 1)"

# ====== CLEANUP ======
rm -f "$TESTFILE" "$TEMP_FILE"
