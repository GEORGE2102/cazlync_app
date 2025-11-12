# 📁 Logo Setup Instructions

## Save Your Logo Here

Please save the CazLync Sales logo image in this folder as:

**Filename:** `cazlync_logo.png`

### Requirements:
- **Format:** PNG (with transparent background preferred)
- **Size:** 1024x1024 pixels (recommended)
- **Minimum:** 512x512 pixels
- **Location:** `assets/logo/cazlync_logo.png`

---

## After Saving the Logo

### Step 1: Generate App Icons
Run this command in your terminal:

```bash
flutter pub run flutter_launcher_icons
```

This will automatically create:
- ✅ Android launcher icons (all densities)
- ✅ iOS app icons (all sizes)  
- ✅ Adaptive icons for Android 8.0+

### Step 2: Clean and Rebuild
```bash
flutter clean
flutter pub get
flutter run
```

---

## What This Logo Is Used For

1. **Splash Screen** - Shown when app launches
2. **Login Screen** - Displayed at the top
3. **Register Screen** - Displayed at the top
4. **App Icon** - Your device home screen icon
5. **About Screen** - Company branding

---

## Current Logo Location

The logo should be saved as:
```
assets/
  └── logo/
      └── cazlync_logo.png  ← Save your logo here!
```

---

## Troubleshooting

**Logo not showing?**
1. Make sure filename is exactly: `cazlync_logo.png`
2. Run `flutter clean` and `flutter pub get`
3. Restart the app

**App icon not updating?**
1. Run `flutter pub run flutter_launcher_icons`
2. Uninstall the app from device/emulator
3. Reinstall with `flutter run`

---

**Need help?** Check `ZAMBIAN_COLORS_UPDATE.md` for complete setup guide.
