# ====== GENERATE GRAPHS ======
IOPS_PLOT="iops_graph.png"
LAT_PLOT="latency_graph.png"

# Extract simplified data for plotting
PLOT_DATA="plot_data.tmp"

awk -F',' 'NR>1 { 
  print $1, $4, $7, $8, $9 
}' "$CSV_OUTPUT" > "$PLOT_DATA"

# === IOPS Graph ===
gnuplot -persist <<-EOF
set terminal png size 1000,600
set output "$IOPS_PLOT"
set title "FIO IOPS Results"
set xlabel "Test Name"
set ylabel "IOPS"
set style data histograms
set style fill solid
set boxwidth 0.5
set xtics rotate by -45
set key outside
plot "$PLOT_DATA" using 2:xtic(1) title "Read IOPS", \
     "" using 3 title "Write IOPS"
EOF

# === Latency Graph ===
gnuplot -persist <<-EOF
set terminal png size 1000,600
set output "$LAT_PLOT"
set title "FIO Latency Results (μs)"
set xlabel "Test Name"
set ylabel "Latency (μs)"
set style data histograms
set style fill solid
set boxwidth 0.5
set xtics rotate by -45
set key outside
plot "$PLOT_DATA" using 4:xtic(1) title "Read Latency", \
     "" using 5 title "Write Latency"
EOF

rm -f "$PLOT_DATA"

echo
echo "📊 Graphs generated:"
echo " - $(realpath "$IOPS_PLOT")"
echo " - $(realpath "$LAT_PLOT")"
