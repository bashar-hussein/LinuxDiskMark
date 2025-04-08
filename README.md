![License](https://img.shields.io/github/license/ShipwreckIII/LinuxDiskMark)
![Last Commit](https://img.shields.io/github/last-commit/ShipwreckIII/LinuxDiskMark)

# TrueNAS Benchmark Script

A single bash script to:

1. **Run disk I/O benchmarks** using `fio`
2. **Parse raw results** into a CSV
3. **Display the CSV** directly in the terminal

## 🔧 Features

- Detects the ZFS pool name from the current path.
- Prompts for:
  - Context label (`data`, `vm`, `backup`, etc.)
  - Test file size (`1G`, `500M`, etc.)
  - Runtime in seconds
- Runs 4 common `fio` tests (sequential/random, 1M/4k blocks, different queue depths)
- Outputs:
  - Raw benchmark file: `raw_<POOL>_<CONTEXT>.txt`
  - Parsed CSV: `<POOL>_<CONTEXT>.csv`

## 🖥️ Requirements

- `fio` (install with `apt install fio` or equivalent)
- Bash (Linux or TrueNAS environment)

## 🚀 Usage

```bash
chmod +x benchmark.sh
./benchmark.sh
```
Follow the prompts.


📁 Output Example
raw_tank_vm.txt

tank_vm.csv

📝 Notes
The script deletes the test file after the run.

All results are saved in the current working directory.

## 📜 License

This project is licensed under the [MIT License](LICENSE).
