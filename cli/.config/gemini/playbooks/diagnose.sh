#!/bin/bash

echo "=== CPU ==="
top -b -n1 | head -n 10

echo "=== MEM ==="
free -h

echo "=== DISK ==="
df -h

echo "=== PROC ==="
ps aux --sort=-%cpu | head
