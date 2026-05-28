#!/usr/bin/env bash

# Late autostart script with dynamic load-aware scheduling (feedback loop)
# Helps prevent CPU spikes and graphical stutters in GNOME Mutter on boot.

wait_for_system_to_settle() {
    local target_idle_ratio=${1:-80}  # We want at least 80% of the initial baseline idle CPU
    local max_iowait=${2:-5}         # Maximum disk I/O wait percentage
    local sample_interval=0.5
    local max_retries=20             # 10 seconds timeout limit
    local retries=0

    # 1. Sample system idle baseline (0.5 seconds evaluation)
    read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat
    local t1=$((user + nice + system + idle + iowait + irq + softirq + steal))
    local i1=$idle
    sleep 0.5
    read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat
    local t2=$((user + nice + system + idle + iowait + irq + softirq + steal))
    local i2=$idle
    local dt=$((t2 - t1))
    local di=$((i2 - i1))
    if [ "$dt" -eq 0 ]; then dt=1; fi
    local baseline_idle=$(( (di * 100) / dt ))

    # Calculate dynamic idle threshold relative to current boot load baseline
    local dynamic_idle=$(( (baseline_idle * target_idle_ratio) / 100 ))

    # Safety net: never drop target below 65% idle even under heavy background load
    if [ "$dynamic_idle" -lt 65 ]; then
        dynamic_idle=65
    fi

    # 2. Monitor load stability loop
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

        # Active feedback-loop trigger condition
        if [ "$cpu_idle" -ge "$dynamic_idle" ] && [ "$cpu_iowait" -le "$max_iowait" ]; then
            return 0
        fi

        retries=$((retries + 1))
    done
}

# Wait 2 seconds for GNOME Shell display transitions and Overview animations to finish rendering
sleep 2

# Launch VS Code Insiders (Workspace 2 candidate) with background occlusion bypass flags
code-insiders --disable-renderer-backgrounding --disable-backgrounding-occluded-windows &

# Wait for system CPU and IO bar to settle before launching next heavy app
wait_for_system_to_settle 80 5

# Launch Floorp Browser (Workspace 3 candidate)
flatpak run one.ablaze.floorp &
