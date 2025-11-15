# 🎨 App Icon Setup Guide

## Quick Setup Using Icon.Kitchen (Recommended)

### Step 1: Generate Icons

1. **Go to Icon Kitchen:**
   - Visit: https://icon.kitchen/

2. **Upload Your Logo:**
   - Click "Upload Image" or drag and drop your logo
   - The green background version works perfectly

3. **Configure Settings:**
   - **Platform:** Select "Android" (or "All" if you want iOS too)
   - **Shape:** Choose "Square" or "Circle" (Square recommended)
   - **Background:** The green background is already there, perfect!
   - **Padding:** Adjust if needed (10-15% recommended)

4. **Preview:**
   - Check how it looks on different devices
   - Make sure the logo is clearly visible

5. **Download:**
   - Click "Download"
   - You'll get a zip file with all icon sizes

### Step 2: Install Icons

1. **Extract the Zip File:**
   - Extract the downloaded zip file
   - You'll see folders like `mipmap-hdpi`, `mipmap-xhdpi`, etc.

2. **Copy to Android Project:**
   ```
   Copy these folders to:
   android/app/src/main/res/
   
   Replace the existing mipmap folders:
   - mipmap-hdpi
   - mipmap-mdpi
   - mipmap-xhdpi
   - mipmap-xxhdpi
   - mipmap-xxxhdpi
   ```

3. **Verify Files:**
   Each folder should contain:
   - `ic_launcher.png` (regular icon)
   - `ic_launcher_foreground.png` (adaptive icon foreground)
   - `ic_launcher_round.png` (round icon)

### Step 3: Update AndroidManifest.xml

The manifest should already reference the icon, but verify:

```xml
<application
    android:icon="@mipmap/ic_launcher"
    android:roundIcon="@mipmap/ic_launcher_round"
    ...>
```

### Step 4: Clean and Rebuild

Run these commands:

```bash
# Clean the build
flutter clean

# Get dependencies
flutter pub get

# Rebuild the app
flutter run
```

---

## Alternative: Manual Icon Generation

If you prefer to do it manually:

### Using Flutter Launcher Icons Package

1. **Add to pubspec.yaml:**
   ```yaml
   dev_dependencies:
     flutter_launcher_icons: ^0.13.1
   
   flutter_launcher_icons:
     android: true
     ios: false
     image_path: "assets/logo/cazlync_icon.png"
     adaptive_icon_background: "#4CAF50"
     adaptive_icon_foreground: "assets/logo/cazlync_icon.png"
   ```

2. **Save your logo:**
   - Save the logo as `assets/logo/cazlync_icon.png`
   - Make sure it's at least 1024x1024 pixels

3. **Generate icons:**
   ```bash
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```

---

## Icon Size Requirements

Android requires these sizes:

| Folder | Size | DPI |
|--------|------|-----|
| mipmap-mdpi | 48x48 | 160 |
| mipmap-hdpi | 72x72 | 240 |
| mipmap-xhdpi | 96x96 | 320 |
| mipmap-xxhdpi | 144x144 | 480 |
| mipmap-xxxhdpi | 192x192 | 640 |

---

## Tips for Best Results

1. **Logo Quality:**
   - Use high resolution (1024x1024 or higher)
   - PNG format with transparency (if needed)
   - Clear and simple design works best

2. **Background Color:**
   - Your green background (#4CAF50) matches Zambian colors ✓
   - Looks professional and recognizable ✓

3. **Testing:**
   - Test on different Android versions
   - Check both light and dark themes
   - Verify on different screen sizes

4. **Adaptive Icons:**
   - Android 8.0+ uses adaptive icons
   - They can be shaped differently by device manufacturers
   - Make sure important elements are in the "safe zone" (center 66%)

---

## Quick Steps Summary

1. ✅ Go to https://icon.kitchen/
2. ✅ Upload your green logo image
3. ✅ Select "Android" platform
4. ✅ Download the generated icons
5. ✅ Extract and copy to `android/app/src/main/res/`
6. ✅ Run `flutter clean && flutter run`
7. ✅ Your new icon is live!

---

## Troubleshooting

**Icon not showing?**
- Run `flutter clean`
- Delete the app from device
- Reinstall with `flutter run`

**Icon looks blurry?**
- Use higher resolution source image
- Regenerate with Icon Kitchen

**Wrong colors?**
- Make sure you uploaded the green background version
- Check the preview before downloading

---

## Current Logo Location

Your logo should be saved at:
- `assets/logo/cazlync_logo.png` (for in-app use)
- `assets/logo/cazlync_icon.png` (for app icon - save the green version here)

---

**Ready to go!** Follow the Icon Kitchen method for the easiest setup. 🚀
