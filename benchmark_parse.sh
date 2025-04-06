#!/bin/bash

# ====== INPUT FILE ======
read -p "Enter the raw input filename (e.g. raw_SMB-Pool_data.txt): " INPUT
[[ ! -f "$INPUT" ]] && echo "File not found: $INPUT" && exit 1

# ====== DETERMINE OUTPUT FILE ======
BASENAME=$(basename "$INPUT" .txt)
OUTPUT="report_${BASENAME#raw_}.csv"

# ====== WRITE HEADER ======
echo "Test Pattern,Block Size,QD,Threads,Read BW,Read IOPS,Write BW,Write IOPS,Read Latency,Write Latency" > "$OUTPUT"

# ====== PARSE TEST BLOCKS ======
awk '
BEGIN { FS="[ =,]+" }

/^===== / {
  # Extract test name and config
  split($2, id, "q"); pattern = toupper(id[1])
  bs=$5; qd=$7; threads=$9
  test_label = $2 " (Q= " qd ", T= " threads ")"
}

/^  read:/ {
  for (i = 1; i <= NF; i++) {
    if ($i == "IOPS") read_iops = $(i+1)
    if ($i == "BW") read_bw = $(i+1)
  }
}

/^  write:/ {
  for (i = 1; i <= NF; i++) {
    if ($i == "IOPS") write_iops = $(i+1)
    if ($i == "BW") write_bw = $(i+1)
  }
}

/^    lat \(usec\): min=/ {
  if (!read_lat) read_lat = $(8) "us"
}

/^    lat \(usec\): min=/ && prev ~ /write:/ {
  write_lat = $(8) "us"
}

/^$/ && test_label != "" {
  # Print row and reset
  printf "\"%s\",%s,%s,%s,%s,%s,%s,%s,%s,%s\n", test_label, bs, qd, threads, read_bw, read_iops, write_bw, write_iops, read_lat, write_lat
  test_label = read_bw = read_iops = write_bw = write_iops = read_lat = write_lat = ""
}

{ prev = $0 }
' "$INPUT" >> "$OUTPUT"

# ====== DONE ======
echo "✅ Parsed report saved to: $(realpath "$OUTPUT")"
