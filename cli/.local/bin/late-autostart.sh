#!/usr/bin/env bash

# Late autostart script using direct real-time hardware telemetry.
# Dynamically reserves N-1 cores for GNOME Mutter, preventing boot lags.

    LOG_FILE="$HOME/.local/state/late-autostart.log"
    mkdir -p "$(dirname "$LOG_FILE")"

    log_msg() {
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
    }

    wait_for_system_to_settle() {
        local label="$1"
        local max_iowait=15            # More lenient 15% disk I/O wait
        local sample_interval=0.5
        local max_retries=10           # 5s safety timeout
        local retries=0
        local target_idle=50           # More realistic 50% idle CPU

        log_msg "Waiting for system to settle before: $label (Target Idle: ${target_idle}%, Max IOWait: ${max_iowait}%)"

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

            if [ "$cpu_idle" -ge "$target_idle" ] && [ "$cpu_iowait" -le "$max_iowait" ]; then
                log_msg "System settled: idle=${cpu_idle}%, iowait=${cpu_iowait}% (took $((retries * 500))ms)"
                return 0
            fi

            retries=$((retries + 1))
        done
        log_msg "System did not settle within timeout: idle=${cpu_idle}%, iowait=${cpu_iowait}% (proceeding anyway)"
    }

    log_msg "Starting late-autostart orchestrator..."

    # 1. Start tmux server to trigger Continuum auto-restore
    log_msg "Starting tmux server..."
    tmux start-server

    # 2. Wait deterministically for tmux-resurrect restore process to complete
    log_msg "Waiting for Continuum session restore to finish..."
    while pgrep -f "tmux-resurrect/scripts/restore.sh" >/dev/null 2>&1; do
        sleep 0.25
    done
    log_msg "Continuum restore completed."

    # 3. Load via tmuxp only if the session was not restored
    if ! tmux has-session -t Development 2>/dev/null; then
        log_msg "Development session not found. Loading via tmuxp (blocking wait)..."
        tmuxp load -y -d development
        log_msg "Tmuxp layout successfully loaded."
    else
        log_msg "Development session successfully restored by Continuum."
    fi

    # 4. Launch Ghostty attached directly (highest priority, session is guaranteed to exist)
    log_msg "Launching Ghostty attached to Development session..."
    env -u DESKTOP_STARTUP_ID ghostty -e tmux attach-session -t Development &

    # 5. Wait for CPU to settle before Ulauncher
    wait_for_system_to_settle "Ulauncher"

    # 6. Launch Ulauncher
    log_msg "Launching Ulauncher..."
    /usr/bin/ulauncher --hide-window &

    # 7. Wait for CPU to settle before VS Code
    wait_for_system_to_settle "VS Code"

    # 8. Launch VS Code
    log_msg "Launching VS Code Insiders..."
    env -u DESKTOP_STARTUP_ID code-insiders &

    # 9. Wait for CPU to settle before Floorp
    wait_for_system_to_settle "Floorp"

    # 10. Launch Floorp
    log_msg "Launching Floorp..."
    env -u DESKTOP_STARTUP_ID flatpak run one.ablaze.floorp &

    # 11. Start the MCP Self-Healing Daemon (at the end, when system is idle)
    log_msg "Running MCP Self-Healing check..."
    mcp-self-heal &

    log_msg "Orchestrator completed."
