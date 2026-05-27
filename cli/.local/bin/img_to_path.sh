#!/bin/bash
# =====================================================================
# AGY WORKFLOW - CAPTURE LATEST SCREENSHOT (SRE EDITION)
# =====================================================================

# 1. Smart mapping: Use XDG to find the directory regardless of OS language
PICS_DIR=$(xdg-user-dir PICTURES 2>/dev/null || echo "$HOME/Pictures")

# 2. Performance: O(1) fetch using time-sorted ls
LATEST_SCREENSHOT=$(ls -t "$PICS_DIR/Screenshots"/*.png "$PICS_DIR/Capturas de tela"/*.png 2>/dev/null | head -n 1)

if [ -n "$LATEST_SCREENSHOT" ] && [ -f "$LATEST_SCREENSHOT" ]; then
    # 3. Zero I/O: Create temporary symlink instead of copying bytes
    ln -sf "$LATEST_SCREENSHOT" /tmp/clip_img.png
    
    # 4. Fail-Safe: Validate wl-copy execution
    if echo -n "/tmp/clip_img.png" | wl-copy; then
        notify-send "Captured" "Ready to paste." -i image-x-generic -t 1500
    else
        notify-send "Error" "Clipboard sync failed." -i dialog-error -t 1500
    fi
else
    notify-send "Not Found" "No screenshots available." -i dialog-error -t 1500
fi
