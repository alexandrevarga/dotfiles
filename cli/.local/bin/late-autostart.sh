#!/usr/bin/env bash

# Late autostart script using direct real-time hardware telemetry.
# Dynamically reserves N-1 cores for GNOME Mutter, preventing boot lags.

wait_for_system_to_settle() {
    local max_iowait=5             # Maximum 5% disk I/O wait
    local sample_interval=0.5
    local max_retries=20           # 10s safety timeout
    local retries=0

    # Calculate dynamic target idle based on actual CPU cores
    # We want at least N-1 cores to be 100% idle (Mutter protection)
    local num_cores=$(nproc)
    local target_idle=$(( 100 - (100 / num_cores) ))

    while [ $retries -lt $max_retries ]; do
        read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat
        local prev_total=$((user + nice + system + idle + iowait + irq + softirq + steal))
        local prev_idle=$idle
        local prev_iowait=$iowait

        sleep "$sample_interval"

        read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat
        local total=$((user + nice + system + idle + iowait + irq + softirq + steal))
        local diff_total=$((total - prev_total))
        local diff_idle=$((idle - prev_idle))
        local diff_iowait=$((iowait - prev_iowait))

        if [ "$diff_total" -eq 0 ]; then diff_total=1; fi

        local cpu_idle=$(( (diff_idle * 100) / diff_total ))
        local cpu_iowait=$(( (diff_iowait * 100) / diff_total ))

        # Evaluate against calculated physical resource constraints
        if [ "$cpu_idle" -ge "$target_idle" ] && [ "$cpu_iowait" -le "$max_iowait" ]; then
            return 0
        fi

        retries=$((retries + 1))
    done
}

# 1. Wait 2 seconds for GNOME Shell compositor to stabilize
sleep 2

# 2. Setup tmux session (tmuxp) in background asynchronously (decoupled from autostart)
tmuxp load -d development &

# 3. Wait for CPU to settle before next launch
wait_for_system_to_settle

# 4. Spawn VS Code Insiders without GPU backgrounding crash flags
code-insiders &

# 5. Wait for VS Code to finish cold start
wait_for_system_to_settle

# 6. Spawn Floorp Browser
flatpak run one.ablaze.floorp &
