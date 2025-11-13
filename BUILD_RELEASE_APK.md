# 🚀 Build Release APK - Complete Guide

## Quick Build (No Signing)

If you just want to test the release build without Play Store submission:

```bash
flutter build apk --release
```

**APK Location:** `build/app/outputs/flutter-apk/app-release.apk`

---

## 📦 Build Options

### Option 1: Single APK (Universal)
```bash
# Builds one APK that works on all Android devices
flutter build apk --release
```
**Size:** ~50-60 MB
**Use for:** Direct distribution, testing

### Option 2: Split APKs (Smaller)
```bash
# Builds separate APKs for different architectures
flutter build apk --split-per-abi --release
```
**Generates:**
- `app-armeabi-v7a-release.apk` (~20 MB) - 32-bit ARM
- `app-arm64-v8a-release.apk` (~25 MB) - 64-bit ARM (most modern phones)
- `app-x86_64-release.apk` (~25 MB) - 64-bit Intel (emulators)

**Use for:** Smaller downloads, better performance

### Option 3: App Bundle (For Play Store)
```bash
# Builds AAB for Google Play Store
flutter build appbundle --release
```
**Bundle Location:** `build/app/outputs/bundle/release/app-release.aab`
**Use for:** Play Store submission (required)

---

## 🔐 Signing the APK (For Production)

### Why Sign?
- Required for Play Store
- Allows app updates
- Proves app authenticity

### Step 1: Create Keystore

```bash
# On Windows (PowerShell)
keytool -genkey -v -keystore C:\Users\YourName\cazlync-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias cazlync

# On Mac/Linux
keytool -genkey -v -keystore ~/cazlync-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias cazlync
```

**You'll be asked:**
- Password (remember this!)
- Name
- Organization
- City
- State
- Country code

**IMPORTANT:** Save the keystore file and password securely!

### Step 2: Create key.properties

Create `android/key.properties`:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=cazlync
storeFile=C:/Users/YourName/cazlync-keystore.jks
```

**On Mac/Linux:**
```properties
storeFile=/Users/YourName/cazlync-keystore.jks
```

### Step 3: Update build.gradle

The signing configuration should already be in `android/app/build.gradle.kts`.

If not, add this before `android {`:

```kotlin
// Load keystore properties
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
```

And inside `android { buildTypes {`:

```kotlin
signingConfigs {
    create("release") {
        keyAlias = keystoreProperties["keyAlias"] as String
        keyPassword = keystoreProperties["keyPassword"] as String
        storeFile = file(keystoreProperties["storeFile"] as String)
        storePassword = keystoreProperties["storePassword"] as String
    }
}

buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
        // ... other settings
    }
}
```

### Step 4: Build Signed APK

```bash
flutter build apk --release
```

Now your APK is signed and ready for distribution!

---

## 🎯 Quick Build Commands

```bash
# 1. Clean previous builds
flutter clean

# 2. Get dependencies
flutter pub get

# 3. Build release APK
flutter build apk --release

# 4. Find your APK
# Location: build/app/outputs/flutter-apk/app-release.apk
```

---

## 📱 Install APK on Device

### Method 1: ADB (If device connected)
```bash
flutter install --release
```

### Method 2: Manual Install
1. Copy `app-release.apk` to your phone
2. Open file manager on phone
3. Tap the APK file
4. Enable "Install from unknown sources" if prompted
5. Tap "Install"

### Method 3: Share via Cloud
1. Upload APK to Google Drive/Dropbox
2. Share link with users
3. Users download and install

---

## 🔍 Verify Build

### Check APK Size
```bash
# On Windows
dir build\app\outputs\flutter-apk\app-release.apk

# On Mac/Linux
ls -lh build/app/outputs/flutter-apk/app-release.apk
```

**Expected size:** 40-60 MB

### Test APK
```bash
# Install on connected device
adb install build/app/outputs/flutter-apk/app-release.apk

# Or use Flutter
flutter install --release
```

### Check for Errors
```bash
# Analyze code
flutter analyze

# Check for issues
flutter doctor
```

---

## 🐛 Troubleshooting

### Error: "Gradle build failed"

**Solution 1: Clean and rebuild**
```bash
flutter clean
flutter pub get
flutter build apk --release
```

**Solution 2: Update Gradle**
```bash
cd android
./gradlew clean
cd ..
flutter build apk --release
```

### Error: "Signing key not found"

**Solution:** Build without signing for testing
```bash
flutter build apk --release --no-shrink
```

Or create keystore (see signing section above)

### Error: "Out of memory"

**Solution:** Increase Gradle memory

Edit `android/gradle.properties`:
```properties
org.gradle.jvmargs=-Xmx4096m -XX:MaxPermSize=512m
```

### Error: "SDK not found"

**Solution:** Set Android SDK path
```bash
# Check Flutter doctor
flutter doctor

# Set SDK path if needed
export ANDROID_HOME=/path/to/android/sdk
```

---

## 📊 Build Optimization

### Reduce APK Size

**1. Enable ProGuard (Shrinking)**
Already enabled in `build.gradle.kts`:
```kotlin
buildTypes {
    release {
        isMinifyEnabled = true
        isShrinkResources = true
    }
}
```

**2. Split by ABI**
```bash
flutter build apk --split-per-abi --release
```

**3. Remove unused resources**
```bash
flutter build apk --release --target-platform android-arm64
```

### Improve Performance

**1. Use release mode**
```bash
flutter build apk --release
```

**2. Enable obfuscation**
```bash
flutter build apk --release --obfuscate --split-debug-info=./debug-info
```

---

## 📦 Distribution Options

### Option 1: Direct APK Distribution
**Pros:**
- Instant distribution
- No approval process
- Easy updates

**Cons:**
- Users need to enable "Unknown sources"
- Manual update process
- Limited reach

**Best for:** Beta testing, internal distribution

### Option 2: Google Play Store
**Pros:**
- Professional distribution
- Automatic updates
- Wide reach
- User trust

**Cons:**
- $25 one-time fee
- Review process (1-3 days)
- Store policies

**Best for:** Public release

### Option 3: Alternative Stores
- **APKPure**
- **Aptoide**
- **Amazon Appstore**
- **Samsung Galaxy Store**

---

## ✅ Pre-Release Checklist

Before building release APK:

- [ ] All features tested
- [ ] No critical bugs
- [ ] Firebase configured
- [ ] App icons set
- [ ] Splash screen configured
- [ ] Version number updated
- [ ] App name correct
- [ ] Permissions declared
- [ ] Privacy policy ready
- [ ] Signing key created (if needed)

---

## 🎯 Version Management

### Update Version

Edit `pubspec.yaml`:
```yaml
version: 1.0.0+1
#        ↑     ↑
#     version  build number
```

**Version format:** `MAJOR.MINOR.PATCH+BUILD`

**Example:**
- `1.0.0+1` - First release
- `1.0.1+2` - Bug fix
- `1.1.0+3` - New features
- `2.0.0+4` - Major update

### Build with Version
```bash
flutter build apk --release --build-name=1.0.0 --build-number=1
```

---

## 📱 Testing Release Build

### Test Checklist

- [ ] App launches successfully
- [ ] All screens load
- [ ] Authentication works
- [ ] Listings display correctly
- [ ] Search and filter work
- [ ] Chat functions properly
- [ ] Notifications appear
- [ ] Images load
- [ ] No crashes
- [ ] Performance is good

### Test on Multiple Devices

**Minimum:**
- 1 low-end device (2GB RAM)
- 1 mid-range device (4GB RAM)
- 1 high-end device (6GB+ RAM)

**Different Android versions:**
- Android 8 (API 26)
- Android 10 (API 29)
- Android 12+ (API 31+)

---

## 🚀 Quick Start

**Just want to build and test?**

```bash
# 1. Build APK
flutter build apk --release

# 2. Install on device
flutter install --release

# 3. Test the app
# Open app on device and test all features

# 4. Share APK
# Copy from: build/app/outputs/flutter-apk/app-release.apk
```

**APK is ready to share!** 🎉

---

## 📞 Quick Commands Reference

```bash
# Build universal APK
flutter build apk --release

# Build split APKs (smaller)
flutter build apk --split-per-abi --release

# Build app bundle (Play Store)
flutter build appbundle --release

# Install on device
flutter install --release

# Clean build
flutter clean && flutter pub get && flutter build apk --release

# Check build
flutter doctor
flutter analyze
```

---

**Ready to build your release APK!** 🚀

