#!/bin/bash

# ====== CONFIG ======
POOL_NAME="SMB-Pool"            # <-- Set your actual pool name
CONTEXT="data"                  # <-- Set any context (e.g., 'boot', 'vm', etc.)
TESTFILE="./fio_benchmark.test"
TEMP_FILE="raw_${POOL_NAME}_${CONTEXT}.txt"
FINAL_FILE="result_${POOL_NAME}_${CONTEXT}.txt"
SIZE=1G
RUNTIME=5

# ====== HEADER ======
echo "------------------------------------------------------------------------------" > "$FINAL_FILE"
echo "LinuxDiskMark 1.0 (fio-based)" >> "$FINAL_FILE"
echo "Inspired by CrystalDiskMark output style" >> "$FINAL_FILE"
echo "------------------------------------------------------------------------------" >> "$FINAL_FILE"
echo "* MB/s = 1,000,000 bytes/s | MiB/s = 1,048,576 bytes/s" >> "$FINAL_FILE"
echo "* KB = 1000 bytes | KiB = 1024 bytes" >> "$FINAL_FILE"
echo "" >> "$FINAL_FILE"

# ====== FIO RUNNER FUNCTION ======
run_fio() {
  local NAME=$1
  local RW=$2
  local BS=$3
  local QD=$4
  local NUMJOBS=$5
  local DESC=$6

  fio --name=$NAME --rw=$RW --rwmixread=50 --bs=$BS --ioengine=libaio \
      --iodepth=$QD --numjobs=$NUMJOBS --size=$SIZE --runtime=$RUNTIME \
      --group_reporting --filename=$TESTFILE >> "$TEMP_FILE"

  local R_LINE=$(grep -A1 "Run status group 0" "$TEMP_FILE" | grep "READ:" | tail -1)
  local W_LINE=$(grep -A1 "Run status group 0" "$TEMP_FILE" | grep "WRITE:" | tail -1)

  local R_BW=$(echo "$R_LINE" | awk -F'[,= ]+' '{print $(NF-6)}')
  local R_IOPS=$(echo "$R_LINE" | awk -F'[,= ]+' '{print $(NF-3)}')
  local W_BW=$(echo "$W_LINE" | awk -F'[,= ]+' '{print $(NF-6)}')
  local W_IOPS=$(echo "$W_LINE" | awk -F'[,= ]+' '{print $(NF-3)}')

  [[ -z $R_BW ]] && R_BW="n/a"
  [[ -z $R_IOPS ]] && R_IOPS="n/a"
  [[ -z $W_BW ]] && W_BW="n/a"
  [[ -z $W_IOPS ]] && W_IOPS="n/a"

  printf "%-40s\n" "[$DESC]" >> "$FINAL_FILE"
  printf "  READ : %8sB/s [%8s IOPS] <approx>\n" "$R_BW" "$R_IOPS" >> "$FINAL_FILE"
  printf "  WRITE: %8sB/s [%8s IOPS] <approx>\n\n" "$W_BW" "$W_IOPS" >> "$FINAL_FILE"
}

# ====== RUN TESTS ======
run_fio seq1mq8t1   randrw 1M 8 1 "SEQ    1MiB (Q=  8, T= 1)"
run_fio seq1mq1t1   randrw 1M 1 1 "SEQ    1MiB (Q=  1, T= 1)"
run_fio rnd4kq32t1  randrw 4k 32 1 "RND    4KiB (Q= 32, T= 1)"
run_fio rnd4kq1t1   randrw 4k 1 1  "RND    4KiB (Q=  1, T= 1)"

# ====== CLEANUP ======
rm -f "$TESTFILE" "$TEMP_FILE"
