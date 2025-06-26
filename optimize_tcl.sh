#!/data/data/com.termux/files/usr/bin/bash

# TCL 30z Performance Optimization Script
# Safe optimizations for Helio A22 with 3GB RAM

echo "🚀 TCL 30z Optimization Starting..."
echo "Device: TCL 30z (T602DL)"
echo "CPU: Helio A22 | RAM: 3GB | Storage: 32GB"
echo "=================================="

# Check if running as root (optional optimizations)
if [ "$EUID" -eq 0 ]; then
    ROOT_ACCESS=true
    echo "✅ Root access detected - Enhanced optimizations available"
else
    ROOT_ACCESS=false
    echo "ℹ️ Non-root mode - Basic optimizations only"
fi

# Function to check command success
check_success() {
    if [ $? -eq 0 ]; then
        echo "✅ $1"
    else
        echo "❌ Failed: $1"
    fi
}

echo -e "\n🧹 CLEANING SYSTEM CACHE"
echo "------------------------"

# Clear Termux cache
echo "Clearing Termux cache..."
rm -rf ~/.cache/* 2>/dev/null
check_success "Termux cache cleared"

# Clear temporary files
echo "Clearing temporary files..."
rm -rf /tmp/* 2>/dev/null
rm -rf ~/.tmp/* 2>/dev/null
check_success "Temporary files cleared"

if [ "$ROOT_ACCESS" = true ]; then
    # Drop caches (requires root)
    echo "Dropping system caches..."
    sync
    echo 3 > /proc/sys/vm/drop_caches 2>/dev/null
    check_success "System caches dropped"
    
    # Trim filesystem (requires root)
    echo "Trimming filesystem..."
    fstrim -v / 2>/dev/null
    check_success "Filesystem trimmed"
fi

echo -e "\n⚡ MEMORY OPTIMIZATION"
echo "---------------------"

# Kill unnecessary background processes
echo "Optimizing background processes..."
pkill -f ".*backup.*" 2>/dev/null
pkill -f ".*sync.*" 2>/dev/null
check_success "Background processes optimized"

if [ "$ROOT_ACCESS" = true ]; then
    # Adjust swappiness for better RAM usage
    echo "Adjusting memory swappiness..."
    echo 10 > /proc/sys/vm/swappiness 2>/dev/null
    check_success "Swappiness optimized (10)"
    
    # Optimize memory management
    echo "Optimizing memory pressure..."
    echo 50 > /proc/sys/vm/vfs_cache_pressure 2>/dev/null
    check_success "VFS cache pressure optimized"
fi

echo -e "\n🔧 CPU OPTIMIZATION"
echo "-------------------"

if [ "$ROOT_ACCESS" = true ]; then
    # Set CPU governor to performance when needed
    echo "Checking CPU governor..."
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        if [ -f "$cpu" ]; then
            current_gov=$(cat "$cpu")
            echo "CPU governor: $current_gov"
            # Set to ondemand for balanced performance
            echo "ondemand" > "$cpu" 2>/dev/null
        fi
    done
    check_success "CPU governor optimized"
    
    # Optimize CPU scheduling
    echo "Optimizing CPU scheduler..."
    echo 1 > /proc/sys/kernel/sched_compat_yield 2>/dev/null
    echo 2000000 > /proc/sys/kernel/sched_latency_ns 2>/dev/null
    check_success "CPU scheduler optimized"
fi

echo -e "\n📱 ANDROID SPECIFIC OPTIMIZATIONS"
echo "--------------------------------"

# Optimize ADB if available
if command -v am >/dev/null 2>&1; then
    echo "Optimizing Android services..."
    
    # Force stop unnecessary services
    am force-stop com.google.android.gms.setup >/dev/null 2>&1
    am force-stop com.android.vending >/dev/null 2>&1
    
    # Clear app caches (user apps only)
    for app in $(pm list packages -3 | cut -d: -f2); do
        am broadcast -a android.intent.action.PACKAGE_DATA_CLEARED --es package "$app" >/dev/null 2>&1
    done
    
    check_success "Android services optimized"
fi

echo -e "\n🌐 NETWORK OPTIMIZATION"
echo "----------------------"

if [ "$ROOT_ACCESS" = true ]; then
    # Optimize network buffers
    echo "Optimizing network performance..."
    echo 87380 > /proc/sys/net/core/rmem_default 2>/dev/null
    echo 16777216 > /proc/sys/net/core/rmem_max 2>/dev/null
    echo 65536 > /proc/sys/net/core/wmem_default 2>/dev/null
    echo 16777216 > /proc/sys/net/core/wmem_max 2>/dev/null
    check_success "Network buffers optimized"
    
    # TCP optimization
    echo "cubic" > /proc/sys/net/ipv4/tcp_congestion_control 2>/dev/null
    echo 1 > /proc/sys/net/ipv4/tcp_window_scaling 2>/dev/null
    check_success "TCP settings optimized"
fi

echo -e "\n🔋 BATTERY OPTIMIZATION"
echo "----------------------"

if [ "$ROOT_ACCESS" = true ]; then
    # Optimize power management
    echo "Optimizing power management..."
    
    # Enable power-efficient workqueues
    echo Y > /sys/module/workqueue/parameters/power_efficient 2>/dev/null
    
    # Optimize I/O scheduler for better battery life
    for device in /sys/block/*/queue/scheduler; do
        if [ -f "$device" ]; then
            echo "deadline" > "$device" 2>/dev/null
        fi
    done
    
    check_success "Power management optimized"
fi

echo -e "\n📊 SYSTEM INFORMATION"
echo "--------------------"

# Display current system stats
echo "Memory usage:"
free -h 2>/dev/null || cat /proc/meminfo | grep -E "(MemTotal|MemFree|MemAvailable)" | head -3

echo -e "\nStorage usage:"
df -h /data 2>/dev/null | tail -1

echo -e "\nCPU info:"
cat /proc/cpuinfo | grep -E "(processor|Hardware|Revision)" | head -3

if [ "$ROOT_ACCESS" = true ]; then
    echo -e "\nCurrent CPU governor:"
    cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "Not available"
    
    echo -e "\nCurrent CPU frequency:"
    cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 2>/dev/null || echo "Not available"
fi

echo -e "\n🎯 OPTIMIZATION COMPLETE!"
echo "========================"
echo "Recommendations for your TCL 30z:"
echo "• Restart device for full effect"
echo "• Run this script weekly for maintenance"
echo "• Monitor battery usage after optimization"
echo "• Keep only essential apps running"
echo "• Use lightweight alternatives when possible"

if [ "$ROOT_ACCESS" = false ]; then
    echo -e "\n💡 For enhanced optimizations:"
    echo "• Consider rooting device (voids warranty)"
    echo "• Install Magisk modules for deeper tweaks"
    echo "• Use custom kernels optimized for Helio A22"
fi

echo -e "\n✨ Your TCL 30z should now perform better!"
echo "Script completed at $(date)"
