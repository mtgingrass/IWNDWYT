#!/bin/bash

# IWNDWYT Screenshot Automation Script
# Run this from the project root directory

echo "🤖 Starting automated screenshot capture for IWNDWYT..."

# Device types for App Store (you can modify these)
DEVICES=(
    "iPhone 15 Pro Max"
    "iPhone 15"
    "iPad Pro (12.9-inch) (6th generation)"
)

# Create screenshots directory
mkdir -p Screenshots
cd Screenshots

# Function to take screenshot
take_screenshot() {
    local device="$1"
    local screen_name="$2"
    local filename="${device// /_}_${screen_name}.png"
    
    echo "📸 Capturing: $screen_name on $device"
    xcrun simctl io booted screenshot "$filename"
    sleep 1
}

# Function to open simulator and app
setup_device() {
    local device="$1"
    echo "🚀 Setting up $device..."
    
    # Boot the device
    xcrun simctl boot "$device" 2>/dev/null || true
    sleep 3
    
    # Build and install app (adjust scheme name if different)
    cd ..
    xcodebuild -project "App/IWNDWYT/IWNDWYT.xcodeproj" \
               -scheme "IWNDWYT" \
               -destination "platform=iOS Simulator,name=$device" \
               clean build 2>/dev/null
    
    # Install the app
    xcrun simctl install "$device" "$(find ~/Library/Developer/Xcode/DerivedData -name "IWNDWYT.app" | head -1)"
    
    # Launch the app
    xcrun simctl launch "$device" com.markgingrass.IWNDWYT
    sleep 3
    
    cd Screenshots
}

# Main screenshot capture function
capture_screenshots() {
    local device="$1"
    echo "📱 Capturing screenshots for $device..."
    
    setup_device "$device"
    
    # Create device-specific directory
    mkdir -p "${device// /_}"
    cd "${device// /_}"
    
    # Screenshot sequence (adjust timing as needed)
    take_screenshot "$device" "01_main_screen"
    sleep 2
    
    # Navigate to settings (you'll need to adapt these based on your UI)
    echo "Tap settings icon..."
    sleep 1
    take_screenshot "$device" "02_settings"
    
    # Navigate to about
    echo "Tap about..."
    sleep 1
    take_screenshot "$device" "03_about"
    
    # Back to main and show milestone view
    echo "Navigate to milestone view..."
    sleep 1
    take_screenshot "$device" "04_milestones"
    
    # Add more navigation and screenshots as needed
    
    cd ..
    
    # Shutdown simulator
    xcrun simctl shutdown "$device"
}

# Main execution
for device in "${DEVICES[@]}"; do
    capture_screenshots "$device"
done

echo "✅ Screenshot capture complete! Check the Screenshots folder."
echo "📁 Screenshots saved in: $(pwd)"