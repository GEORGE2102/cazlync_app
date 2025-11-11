# CazLync Logo Setup Guide

## 📱 Setting Up the App Launcher Icon

### Step 1: Save the Logo Image
1. Save the CazLync Sales logo image you provided as `cazlync_logo.png`
2. Place it in the `assets/logo/` directory
3. Recommended size: **1024x1024 pixels** (the tool will generate all required sizes)

### Step 2: Generate Launcher Icons
Once the logo is saved, run these commands:

```bash
# Install dependencies
flutter pub get

# Generate launcher icons
flutter pub run flutter_launcher_icons
```

This will automatically generate:
- ✅ Android launcher icons (all densities: mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- ✅ Android adaptive icons (with black background)
- ✅ iOS app icons (all required sizes)

### Step 3: Verify Installation
After generation, you should see:
- Android icons in: `android/app/src/main/res/mipmap-*/`
- iOS icons in: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

---

## 🎨 Using the Logo Throughout the App

The logo has been configured to be used in multiple places:

### 1. Splash Screen (Already Implemented)
**Location**: `lib/main.dart` - `SplashScreen` widget

Current implementation uses a car icon. Update to use the logo:

```dart
// Replace the Icon widget with:
Image.asset(
  'assets/logo/cazlync_logo.png',
  width: 150,
  height: 150,
)
```

### 2. Login Screen
**Location**: `lib/presentation/screens/login_screen.dart`

Add logo at the top of the login form:

```dart
Image.asset(
  'assets/logo/cazlync_logo.png',
  width: 120,
  height: 120,
),
const SizedBox(height: 24),
Text('Welcome to CazLync', ...),
```

### 3. Register Screen
**Location**: `lib/presentation/screens/register_screen.dart`

Similar to login screen, add logo at the top.

### 4. App Bar (Optional)
For a branded app bar, you can add a small logo:

```dart
AppBar(
  title: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.asset(
        'assets/logo/cazlync_logo.png',
        height: 32,
      ),
      const SizedBox(width: 8),
      const Text('CazLync'),
    ],
  ),
)
```

### 5. Empty States
Use the logo in empty states for a branded experience:

```dart
Image.asset(
  'assets/logo/cazlync_logo.png',
  width: 100,
  height: 100,
  opacity: const AlwaysStoppedAnimation(0.3),
),
```

---

## 📁 Assets Structure

```
assets/
├── logo/
│   └── cazlync_logo.png          # Main logo (1024x1024)
└── images/
    └── (other app images)
```

---

## 🎯 Logo Usage Best Practices

### Sizes:
- **Splash Screen**: 150x150 dp
- **Login/Register**: 120x120 dp
- **App Bar**: 32-40 dp height
- **Empty States**: 80-100 dp
- **Launcher Icon**: Auto-generated from 1024x1024

### Colors:
The logo uses:
- Red (#FF0000 or similar)
- Orange (#FF6B35 or similar)
- Green (#4CAF50 or similar)
- Black background (#000000)

These colors work well on:
- ✅ White backgrounds
- ✅ Light gray backgrounds
- ✅ Black backgrounds (as shown in the logo)

### Spacing:
- Always add padding around the logo (16-24 dp)
- Maintain aspect ratio (don't stretch)
- Use `BoxFit.contain` when needed

---

## 🚀 Quick Implementation

I'll now update the key screens to use the logo. After you save the logo image to `assets/logo/cazlync_logo.png`, run:

```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

Then the logo will be:
1. ✅ Set as launcher icon (Android & iOS)
2. ✅ Used in splash screen
3. ✅ Used in login screen
4. ✅ Used in register screen
5. ✅ Available for use anywhere in the app

---

## 📝 Next Steps

1. **Save the logo** to `assets/logo/cazlync_logo.png`
2. **Run the commands** above
3. **Test the app** to see the new launcher icon
4. **Verify** the logo appears correctly on different screen sizes

---

## ✅ Configuration Complete

The pubspec.yaml has been updated with:
- ✅ Assets directories configured
- ✅ flutter_launcher_icons package added
- ✅ Launcher icon configuration set
- ✅ Black background for adaptive icons

**Ready to generate icons once the logo is saved!**
