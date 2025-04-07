#!/bin/bash

# Input and output file names
input_file="a.txt"
output_file="benchmark_data.csv"

# Write CSV header
echo "Test Name,Block Size,Queue Depth,IOPS (Read),Bandwidth (Read),Latency Avg (Read),IOPS (Write),Bandwidth (Write),Latency Avg (Write)" > "$output_file"

# Initialize variables to hold block data
test_name=""
block_size=""
queue_depth=""
iops_read=""
bw_read=""
latency_read=""
iops_write=""
bw_write=""
latency_write=""

# Variable to track the current section (read or write)
current_section="none"

# Function to output the current test block (if any)
output_block() {
  if [ -n "$test_name" ]; then
    echo "$test_name,$block_size,$queue_depth,$iops_read,$bw_read,$latency_read,$iops_write,$bw_write,$latency_write" >> "$output_file"
  fi
}

# Read the input file line by line
while IFS= read -r line
do
  # Detect header lines that start a new test block
  if [[ "$line" =~ ^=====\  ]]; then
    # If we already captured a block, output it first
    output_block

    # Reset all captured fields for the new block
    test_name=""
    block_size=""
    queue_depth=""
    iops_read=""
    bw_read=""
    latency_read=""
    iops_write=""
    bw_write=""
    latency_write=""
    current_section="none"

    # Expected header format, e.g.:
    # "===== seq1mq8t1 (randrw bs=1M qd=8 jobs=1) ====="
    if [[ "$line" =~ ^=====\ ([^[:space:]]+)\ \(randrw\ bs=([^[:space:]]+)\ qd=([0-9]+) ]]; then
      test_name="${BASH_REMATCH[1]}"
      block_size="${BASH_REMATCH[2]}"
      queue_depth="${BASH_REMATCH[3]}"
    fi
    continue
  fi

  # Capture read block
  if [[ "$line" =~ ^[[:space:]]*read:\ IOPS=([0-9]+),\ BW=([0-9]+MiB/s) ]]; then
    iops_read="${BASH_REMATCH[1]}"
    bw_read="${BASH_REMATCH[2]}"
    current_section="read"
    continue
  fi

  # Capture write block
  if [[ "$line" =~ ^[[:space:]]*write:\ IOPS=([0-9]+),\ BW=([0-9]+MiB/s) ]]; then
    iops_write="${BASH_REMATCH[1]}"
    bw_write="${BASH_REMATCH[2]}"
    current_section="write"
    continue
  fi

  # Capture the overall latency from the "lat (usec):" line
  if [[ "$line" =~ lat\ \(usec\):.*avg=([0-9.]+) ]]; then
    if [ "$current_section" = "read" ] && [ -z "$latency_read" ]; then
      latency_read="${BASH_REMATCH[1]}"
    elif [ "$current_section" = "write" ] && [ -z "$latency_write" ]; then
      latency_write="${BASH_REMATCH[1]}"
    fi
    continue
  fi
done < "$input_file"

# Output the final block if present
output_block

echo "Data has been exported to '$output_file'."