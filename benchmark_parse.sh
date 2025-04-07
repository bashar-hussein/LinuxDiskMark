#!/bin/bash

input_file="a.txt"
output_file="benchmark_data.csv"

# Print CSV header
echo "Test Name,Block Size,Queue Depth,IOPS (Read),Bandwidth (Read),Latency Avg (Read),IOPS (Write),Bandwidth (Write),Latency Avg (Write)" > "$output_file"

awk '
/^===== / {
    # Capture header info from lines like:
    # "===== seq1mq8t1 (randrw bs=1M qd=8 jobs=1) ====="
    if (match($0, /===== ([^ ]+) \(randrw bs=([^ ]+) qd=([0-9]+)/, a)) {
         test_name = a[1]
         block_size = a[2]
         queue_depth = a[3]
    }
}
/^[[:space:]]*read:/ {
    # Capture the read metrics from lines like:
    # "  read: IOPS=1615, BW=1616MiB/s (1694MB/s)..."
    if (match($0, /IOPS=([0-9.]+[kK]?)[,] BW=([^ ]+)/, a)) {
         iops_read = a[1]
         bw_read = a[2]
    }
}
/^[[:space:]]*slat \(usec\):/ && iops_read != "" && latency_read == "" {
    # Capture the read latency from the first slat line following the read line.
    if (match($0, /avg=[[:space:]]*([0-9.]+)/, a)) {
         latency_read = a[1]
    }
}
/^[[:space:]]*write:/ {
    # Capture the write metrics from lines like:
    # "  write: IOPS=1719, BW=1720MiB/s (1803MB/s)..."
    if (match($0, /IOPS=([0-9.]+[kK]?)[,] BW=([^ ]+)/, a)) {
         iops_write = a[1]
         bw_write = a[2]
    }
}
/^[[:space:]]*slat \(usec\):/ && iops_write != "" && latency_write == "" {
    # Capture the write latency from its slat line.
    if (match($0, /avg=[[:space:]]*([0-9.]+)/, a)) {
         latency_write = a[1]
         # Once write latency is captured, print out the complete record.
         printf "%s,%s,%s,%s,%s,%s,%s,%s,%s\n", test_name, block_size, queue_depth, iops_read, bw_read, latency_read, iops_write, bw_write, latency_write
         # Reset the metric fields for the next test block.
         iops_read = latency_read = iops_write = latency_write = ""
    }
}
' "$input_file" >> "$output_file"

echo "Data has been exported to '$output_file'."