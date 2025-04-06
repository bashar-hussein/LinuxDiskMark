#!/bin/bash

# ====== DETECT POOL NAME FROM PATH ======
CURRENT_PATH=$(pwd)
POOL=$(echo "$CURRENT_PATH" | cut -d'/' -f3)

# ====== USER INPUT ======
read -p "Enter context label (e.g. data, backup, vm): " CONTEXT
read -p "Enter test file size (e.g. 1G, 500M): " SIZE
read -p "Enter runtime in seconds (e.g. 5, 10): " RUNTIME

# ====== FILE PATHS ======
OUTPUT="raw_${POOL}_${CONTEXT}.txt"
TESTFILE="./fio_testfile.tmp"

# ====== PREVIEW SUMMARY ======
echo
echo "Ready to run benchmark with the following settings:"
echo "--------------------------------------------------"
echo "POOL        : $POOL"
echo "CONTEXT     : $CONTEXT"
echo "FILE SIZE   : $SIZE"
echo "RUNTIME     : $RUNTIME seconds"
echo "TEST FILE   : $TESTFILE"
echo "OUTPUT FILE : $(realpath "$OUTPUT")"
echo

read -p "Proceed with test? (y/n): " confirm
[[ "$confirm" != "y" && "$confirm" != "Y" ]] && echo "Aborted." && exit 1

# ====== TEST MATRIX ======
declare -a tests=(
  "seq1mq8t1 randrw 1M 8 1"
  "seq1mq1t1 randrw 1M 1 1"
  "rnd4kq32t1 randrw 4k 32 1"
  "rnd4kq1t1 randrw 4k 1 1"
)

# ====== RUN TESTS ======
echo "Running benchmarks on pool [$POOL]..." > "$OUTPUT"

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

echo
echo "✅ Benchmark complete!"
echo "Results saved to: $(realpath "$OUTPUT")"
