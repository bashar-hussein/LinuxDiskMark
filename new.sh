#!/bin/bash

# Interactive FIO Wrapper Script
# Helps users construct and run a fio command with guidance

echo "=== FIO Test Configuration ==="

read -p "Test name (e.g., bench1): " NAME
read -p "Read/write type [read/write/randread/randwrite/randrw] (e.g., randrw): " RW
read -p "Block size (e.g., 4k, 16k, 1M): " BS
read -p "File size for test (e.g., 1G, 10G): " SIZE
read -p "I/O depth (queue depth, e.g., 1, 32, 64): " IODEPTH
read -p "Number of jobs (e.g., 1, 4, 8): " NUMJOBS
read -p "Test duration in seconds (runtime): " RUNTIME
read -p "I/O engine [libaio/sync] (e.g., libaio): " IOENGINE
read -p "Use direct I/O? [1=yes, 0=no]: " DIRECT

# Validate numeric values
if ! [[ "$IODEPTH" =~ ^[0-9]+$ ]] || ! [[ "$NUMJOBS" =~ ^[0-9]+$ ]] || ! [[ "$RUNTIME" =~ ^[0-9]+$ ]]; then
    echo "Error: iodepth, numjobs, and runtime must be numbers."
    exit 1
fi

# Construct fio command
FIO_CMD="fio --name=$NAME --rw=$RW --bs=$BS --size=$SIZE --iodepth=$IODEPTH --numjobs=$NUMJOBS --runtime=$RUNTIME --time_based --ioengine=$IOENGINE --direct=$DIRECT --group_reporting"

echo
echo "=== Generated FIO Command ==="
echo "$FIO_CMD"
echo

read -p "Proceed with execution? [y/n]: " CONFIRM
if [[ "$CONFIRM" != "y" ]]; then
    echo "Aborted."
    exit 0
fi

# Run the fio command and save output
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTFILE="${NAME}_${TIMESTAMP}.txt"
echo "Running FIO... Output will be saved to $OUTFILE"
$FIO_CMD | tee "$OUTFILE"