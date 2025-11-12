# 🎨 Quick Color Reference Card

## 🇿🇲 Zambian Colors

```
🔴 RED     #DE2010  rgb(222, 32, 16)
🟠 ORANGE  #EF7D00  rgb(239, 125, 0)
🟢 GREEN   #198A00  rgb(25, 138, 0)
```

---

## 📋 Copy-Paste Code

### Import Colors
```dart
import 'package:cazlync/core/constants/app_colors.dart';
```

### Use Colors
```dart
// Direct colors
AppColors.zambianRed
AppColors.zambianOrange
AppColors.zambianGreen

// Semantic names
AppColors.primary    // Red
AppColors.secondary  // Green
AppColors.accent     // Orange

// Status colors
AppColors.success    // Green
AppColors.error      // Red
AppColors.warning    // Orange
```

### Buttons
```dart
// Red button
ElevatedButton(
  onPressed: () {},
  child: Text('Submit'),
)

// Green button
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.zambianGreen,
  ),
  child: Text('Approve'),
)

// Orange button
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.zambianOrange,
  ),
  child: Text('Edit'),
)
```

### Badges
```dart
// Success badge (Green)
Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: AppColors.zambianGreen,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text('Active', style: TextStyle(color: Colors.white, fontSize: 12)),
)

// Premium badge (Orange)
Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: AppColors.zambianOrange,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text('Premium', style: TextStyle(color: Colors.white, fontSize: 12)),
)
```

### Gradients
```dart
// Full gradient (Red → Orange → Green)
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        AppColors.zambianRed,
        AppColors.zambianOrange,
        AppColors.zambianGreen,
      ],
    ),
  ),
)

// Primary gradient (Red → Orange)
Container(
  decoration: BoxDecoration(
    gradient: AppColors.primaryGradient,
  ),
)

// Accent gradient (Orange → Green)
Container(
  decoration: BoxDecoration(
    gradient: AppColors.accentGradient,
  ),
)
```

### Icons
```dart
Icon(Icons.favorite, color: AppColors.zambianRed)
Icon(Icons.verified, color: AppColors.zambianGreen)
Icon(Icons.star, color: AppColors.zambianOrange)
```

### Text
```dart
Text(
  'Price: K 50,000',
  style: TextStyle(
    color: AppColors.zambianGreen,
    fontWeight: FontWeight.bold,
  ),
)
```

### Snackbars
```dart
// Success
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Success!'),
    backgroundColor: AppColors.zambianGreen,
  ),
);

// Error
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Error!'),
    backgroundColor: AppColors.zambianRed,
  ),
);

// Warning
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Warning!'),
    backgroundColor: AppColors.zambianOrange,
  ),
);
```

---

## 🎯 When to Use Each Color

### 🔴 Red (Primary)
- Primary buttons (Submit, Save, Login)
- Active states (selected tabs, favorites)
- Error messages
- Delete/Remove actions
- Important notifications

### 🟠 Orange (Accent)
- Premium features
- Warning messages
- Edit/Update actions
- Highlights
- Promotional content

### 🟢 Green (Secondary)
- Success messages
- Verified badges
- Active/Approved status
- Confirmation actions
- Positive feedback

---

## 📱 Logo Setup

1. Save logo as: `assets/logo/cazlync_logo.png`
2. Run: `flutter pub run flutter_launcher_icons`
3. Run: `flutter clean && flutter pub get && flutter run`

---

## ✅ Quick Test

```dart
// Test all colors
Column(
  children: [
    Container(height: 50, color: AppColors.zambianRed),
    Container(height: 50, color: AppColors.zambianOrange),
    Container(height: 50, color: AppColors.zambianGreen),
  ],
)
```

---

**Keep this card handy while coding!** 🇿🇲
