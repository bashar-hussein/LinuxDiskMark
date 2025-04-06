#!/bin/bash

# ====== CONFIG ======
POOL="SMB-Pool"
CONTEXT="data"
OUTPUT="raw_${POOL}_${CONTEXT}.txt"
TESTFILE="./fio_testfile.tmp"
SIZE="1G"
RUNTIME=5

# ====== TEST MATRIX ======
declare -a tests=(
  "seq1mq8t1 randrw 1M 8 1"
  "seq1mq1t1 randrw 1M 1 1"
  "rnd4kq32t1 randrw 4k 32 1"
  "rnd4kq1t1 randrw 4k 1 1"
)

# ====== RUN TESTS ======
echo "Running benchmarks..." > "$OUTPUT"

for test in "${tests[@]}"; do
  set -- $test
  NAME=$1
  RW=$2
  BS=$3
  QD=$4
  JOBS=$5

  echo -e "\n===== $NAME ($RW bs=$BS qd=$QD jobs=$JOBS) =====" >> "$OUTPUT"

  fio --name="$NAME" --rw="$RW" --rwmixread=50 --bs="$BS" --ioengine=libaio \
      --iodepth="$QD" --numjobs="$JOBS" --size="$SIZE" --runtime="$RUNTIME" \
      --group_reporting --filename="$TESTFILE" >> "$OUTPUT"
done

# ====== CLEANUP ======
rm -f "$TESTFILE"

echo "Raw benchmark saved to $OUTPUT"
