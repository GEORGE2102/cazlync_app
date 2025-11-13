# ✅ Enum .name Error - FIXED!

## 🐛 Error

```
NoSuchMethodError: Class 'ListingStatus' has no instance getter 'name'.
```

## 🔍 Cause

The code was using `status.name` to get the enum value as a string, but this getter doesn't exist in the Dart version being used.

```dart
// Broken code
switch (status.name) {
  case 'active':
    return Colors.green;
}
```

## ✅ Solution

Changed to direct enum comparison instead of using `.name`:

```dart
// Fixed code
if (status == ListingStatus.active) return Colors.green;
if (status == ListingStatus.sold) return Colors.red;
if (status == ListingStatus.pending) return Colors.orange;
```

## 📁 Files Fixed

1. ✅ `lib/presentation/screens/my_listings_screen.dart`
   - Changed `_getStatusColor()` to use direct comparison
   - Changed `_getStatusIcon()` to use direct comparison
   - Changed `_getStatusText()` to use direct comparison
   - Changed button condition from `status.name == 'active'` to `status == ListingStatus.active`
   - Added ListingStatus import

---

**Status: FIXED** ✅

**App should now compile and run without errors!** 🎉



## 🔧 Additional Fix - ListingModel

### Problem Found
The `toFirestore()` method in `listing_model.dart` was also using `.name` on enums when saving to Firestore, causing crashes when marking listings as sold.

### Files Fixed (Update)
2. ✅ `lib/data/models/listing_model.dart`
   - Changed `status.name` to `_statusToString(status)`
   - Changed `bodyType?.name` to helper method
   - Changed `condition?.name` to helper method
   - Changed `transmissionType?.name` to helper method
   - Changed `fuelType?.name` to helper method

### Solution Applied

**Before (BROKEN):**
```dart
Map<String, dynamic> toFirestore() {
  return {
    'status': status.name,  // ❌ Crashes
    'bodyType': bodyType?.name,  // ❌ Crashes
  };
}
```

**After (FIXED):**
```dart
Map<String, dynamic> toFirestore() {
  return {
    'status': _statusToString(status),  // ✅ Works
    'bodyType': bodyType != null ? _bodyTypeToString(bodyType!) : null,  // ✅ Works
  };
}

// Helper methods added
static String _statusToString(ListingStatus status) {
  if (status == ListingStatus.active) return 'active';
  if (status == ListingStatus.sold) return 'sold';
  if (status == ListingStatus.rejected) return 'rejected';
  if (status == ListingStatus.deleted) return 'deleted';
  return 'pending';
}
```

---

**All enum.name usage eliminated!** ✅
