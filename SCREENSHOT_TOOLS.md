# Third-Party Screenshot Tools for IWNDWYT

## Professional Tools

### 1. **Fastlane Snapshot** (Free - Recommended)
- **What**: Automated screenshot generation
- **Setup**: Add to existing fastlane config
- **Pros**: Industry standard, highly configurable
- **Time**: 1-2 hours setup, then automated forever

```ruby
# Fastfile addition
lane :screenshots do
  snapshot
end
```

### 2. **AppLaunchpad** (Paid - $99/year)
- **What**: Complete App Store asset generation
- **Features**: Screenshots, app previews, marketing materials
- **Pros**: Professional templates, batch processing
- **Best for**: Multiple apps or frequent updates

### 3. **RocketSim** (Free/Paid)
- **What**: Xcode Simulator enhancement
- **Features**: Easy screenshot capture, device frames
- **Pros**: Integrates with existing workflow
- **Best for**: Quick manual screenshots with polish

### 4. **Screenshot Path** (Free browser tool)
- **What**: Add device frames to existing screenshots
- **Process**: Take screenshots → Upload → Download framed versions
- **Best for**: Post-processing existing screenshots

## Quick Setup: Fastlane Snapshot

If you want the professional approach:

### Install Fastlane
```bash
# Install fastlane
sudo gem install fastlane

# Initialize in project
cd /Users/markgingrass/Developer/IWNDWYT
fastlane init
```

### Configure Snapshot
```bash
# Add snapshot to project
fastlane snapshot init
```

### Basic Snapfile Configuration
```ruby
# Snapfile
devices([
  "iPhone 15 Pro Max",
  "iPhone 15", 
  "iPad Pro (12.9-inch) (6th generation)"
])

languages([
  "en-US"
])

# Output directory
output_directory("./Screenshots")

# Clear previous screenshots
clear_previous_screenshots(true)

# Skip open summary
skip_open_summary(true)
```

## Recommendation

**For immediate needs (today):** Use Option 2 (Manual) - 10 minutes total

**For long-term efficiency:** Set up Option 1 (Automation script) or Fastlane - saves hours on future releases

**For professional polish:** Consider AppLaunchpad or RocketSim for device frames and marketing materials

The manual approach will get you App Store-ready screenshots in about 10 minutes, which is probably the best immediate solution.