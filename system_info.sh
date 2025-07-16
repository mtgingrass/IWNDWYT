#!/bin/bash

# System Information Collection Script
# This script gathers comprehensive system information for debugging purposes

echo "========================================="
echo "SYSTEM INFORMATION REPORT"
echo "Generated: $(date)"
echo "========================================="
echo

# Basic System Info
echo "--- BASIC SYSTEM INFO ---"
echo "Hostname: $(hostname)"
echo "Username: $(whoami)"
echo "Operating System: $(uname -s)"
echo "OS Version: $(sw_vers -productVersion 2>/dev/null || uname -r)"
echo "Build Version: $(sw_vers -buildVersion 2>/dev/null || echo 'N/A')"
echo "Kernel: $(uname -r)"
echo "Architecture: $(uname -m)"
echo "Uptime: $(uptime | awk '{print $3,$4}' | sed 's/,//')"
echo

# Hardware Info
echo "--- HARDWARE INFO ---"
if command -v system_profiler >/dev/null 2>&1; then
    echo "Model: $(system_profiler SPHardwareDataType | grep "Model Name" | awk -F': ' '{print $2}')"
    echo "Model ID: $(system_profiler SPHardwareDataType | grep "Model Identifier" | awk -F': ' '{print $2}')"
    echo "Processor: $(system_profiler SPHardwareDataType | grep "Processor Name" | awk -F': ' '{print $2}')"
    echo "Processor Speed: $(system_profiler SPHardwareDataType | grep "Processor Speed" | awk -F': ' '{print $2}')"
    echo "Cores: $(system_profiler SPHardwareDataType | grep "Total Number of Cores" | awk -F': ' '{print $2}')"
    echo "Memory: $(system_profiler SPHardwareDataType | grep "Memory" | awk -F': ' '{print $2}')"
    echo "Serial Number: $(system_profiler SPHardwareDataType | grep "Serial Number" | awk -F': ' '{print $2}')"
else
    echo "CPU: $(grep -m1 'model name' /proc/cpuinfo 2>/dev/null | cut -d':' -f2 | sed 's/^ *//' || echo 'N/A')"
    echo "Memory: $(free -h 2>/dev/null | awk '/^Mem:/ {print $2}' || echo 'N/A')"
fi
echo

# Memory Usage
echo "--- MEMORY USAGE ---"
if command -v vm_stat >/dev/null 2>&1; then
    vm_stat | head -10
elif command -v free >/dev/null 2>&1; then
    free -h
fi
echo

# Disk Usage
echo "--- DISK USAGE ---"
df -h
echo

# Development Environment
echo "--- DEVELOPMENT ENVIRONMENT ---"
echo "Shell: $SHELL"
echo "Terminal: $TERM"
if command -v git >/dev/null 2>&1; then
    echo "Git version: $(git --version)"
fi
if command -v xcode-select >/dev/null 2>&1; then
    echo "Xcode path: $(xcode-select -p 2>/dev/null || echo 'Not installed')"
fi
if command -v xcodebuild >/dev/null 2>&1; then
    echo "Xcodebuild version: $(xcodebuild -version 2>/dev/null | head -1 || echo 'Not available')"
fi
if command -v swift >/dev/null 2>&1; then
    echo "Swift version: $(swift --version 2>/dev/null | head -1 || echo 'Not available')"
fi
if command -v node >/dev/null 2>&1; then
    echo "Node.js version: $(node --version)"
fi
if command -v npm >/dev/null 2>&1; then
    echo "npm version: $(npm --version)"
fi
if command -v python3 >/dev/null 2>&1; then
    echo "Python3 version: $(python3 --version)"
fi
if command -v brew >/dev/null 2>&1; then
    echo "Homebrew version: $(brew --version | head -1)"
fi
echo

# Network Info
echo "--- NETWORK INFO ---"
echo "Active network interfaces:"
if command -v ifconfig >/dev/null 2>&1; then
    ifconfig | grep -E "^[a-z]|inet " | grep -A1 "flags.*UP"
elif command -v ip >/dev/null 2>&1; then
    ip addr show | grep -E "^[0-9]|inet "
fi
echo

# Environment Variables (filtered for privacy)
echo "--- ENVIRONMENT VARIABLES (filtered) ---"
env | grep -E "^(PATH|HOME|USER|SHELL|TERM|LANG|LC_|TMPDIR|PWD)" | sort
echo

# macOS Specific Info
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "--- macOS SPECIFIC INFO ---"
    echo "System Integrity Protection: $(csrutil status 2>/dev/null || echo 'Unable to determine')"
    echo "Available disk space on root:"
    df -h / | tail -1
    echo
    
    echo "--- INSTALLED SIMULATORS ---"
    if command -v xcrun >/dev/null 2>&1; then
        xcrun simctl list devices available 2>/dev/null | grep -E "iPhone|iPad" | head -10
    fi
    echo
fi

# Process Info
echo "--- TOP PROCESSES (by CPU) ---"
if command -v top >/dev/null 2>&1; then
    top -l 1 -n 10 -o cpu 2>/dev/null | grep -A 10 "PID.*COMMAND" || ps aux | sort -nr -k 3 | head -10
elif command -v ps >/dev/null 2>&1; then
    ps aux | sort -nr -k 3 | head -10
fi
echo

echo "--- TOP PROCESSES (by Memory) ---"
if command -v top >/dev/null 2>&1; then
    top -l 1 -n 10 -o rsize 2>/dev/null | grep -A 10 "PID.*COMMAND" || ps aux | sort -nr -k 4 | head -10
elif command -v ps >/dev/null 2>&1; then
    ps aux | sort -nr -k 4 | head -10
fi
echo

# Security Info
echo "--- SECURITY INFO ---"
if command -v security >/dev/null 2>&1; then
    echo "Keychain status:"
    security list-keychains 2>/dev/null | head -5
fi
echo

echo "========================================="
echo "REPORT COMPLETE"
echo "========================================="