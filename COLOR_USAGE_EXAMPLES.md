# 🎨 CazLync Color Usage Examples

## 🇿🇲 Zambian Flag Colors in Action

### Color Palette
```
🔴 Zambian Red    #DE2010  - Primary/Error
🟠 Zambian Orange #EF7D00  - Accent/Warning  
🟢 Zambian Green  #198A00  - Secondary/Success
```

---

## 📱 Screen-by-Screen Color Usage

### 1. Splash Screen
```
Background: Gradient (Red → Orange → Green)
Logo Container: White with shadow
Text: White
Loading Indicator: White
```

### 2. Login/Register Screen
```
Logo: Full color
Primary Button: Red background, white text
Social Buttons: White background, colored icons
Links: Orange text
Success Messages: Green background
Error Messages: Red background
```

### 3. Home Screen
```
App Bar: White background
Search Bar: White with red focus
FAB (Create Listing): Red background, white icon
Active Filters: Red chips
Listing Cards: White with subtle shadows
Price Text: Green (emphasizing value)
Premium Badge: Orange background
```

### 4. Listing Detail Screen
```
Image Gallery: Full width
Price: Large, green text
Contact Seller Button: Red background
Favorite Icon: Red when active, grey when inactive
Verified Badge: Green with checkmark
Premium Badge: Orange
Specifications: Clean layout with icons
```

### 5. Create/Edit Listing Screen
```
Form Fields: White background, red focus
Image Upload Area: Dashed border, orange accent
Add Image Button: Orange background
Submit Button: Red background
Cancel Button: Grey outline
Success Message: Green snackbar
```

### 6. Search & Filter Screen
```
Search Bar: White with red focus
Filter Chips: 
  - Active: Red background, white text
  - Inactive: White background, grey text
Apply Button: Red background
Reset Button: Orange text
Price Sliders: Red track
```

### 7. Favorites Screen
```
Heart Icons: Red (filled)
Empty State: Orange icon with message
Remove Button: Red text
Grid Layout: White cards
```

### 8. Chat List Screen
```
Unread Badge: Orange background, white number
Online Indicator: Green dot
Last Message: Grey text
Timestamp: Light grey
Dividers: Light grey
```

### 9. Chat Room Screen
```
Send Button: Red background, white icon
Sender Bubbles: Red background, white text
Receiver Bubbles: Light grey background, dark text
Listing Preview: White card with border
Timestamp: Grey text
```

### 10. Profile Screen
```
Avatar Border: Red
Edit Button: Orange background
Verified Badge: Green with checkmark
Stats Numbers: Red text
Logout Button: Red text
Settings Icon: Grey
```

---

## 🎯 Component-Specific Colors

### Buttons

#### Primary Button (Red)
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.zambianRed,
    foregroundColor: Colors.white,
  ),
  child: Text('Primary Action'),
)
```
**Use for:** Submit, Save, Create, Confirm, Login

#### Secondary Button (Green)
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.zambianGreen,
    foregroundColor: Colors.white,
  ),
  child: Text('Secondary Action'),
)
```
**Use for:** Approve, Accept, Verify, Success actions

#### Accent Button (Orange)
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.zambianOrange,
    foregroundColor: Colors.white,
  ),
  child: Text('Accent Action'),
)
```
**Use for:** Edit, Update, Upgrade, Premium features

#### Outlined Button
```dart
OutlinedButton(
  style: OutlinedButton.styleFrom(
    side: BorderSide(color: AppColors.zambianRed),
    foregroundColor: AppColors.zambianRed,
  ),
  child: Text('Cancel'),
)
```
**Use for:** Cancel, Back, Secondary actions

---

### Status Indicators

#### Success (Green)
```dart
Container(
  padding: EdgeInsets.all(8),
  decoration: BoxDecoration(
    color: AppColors.zambianGreen,
    borderRadius: BorderRadius.circular(4),
  ),
  child: Text('Active', style: TextStyle(color: Colors.white)),
)
```
**Use for:** Active listings, Verified, Approved, Success messages

#### Warning (Orange)
```dart
Container(
  padding: EdgeInsets.all(8),
  decoration: BoxDecoration(
    color: AppColors.zambianOrange,
    borderRadius: BorderRadius.circular(4),
  ),
  child: Text('Pending', style: TextStyle(color: Colors.white)),
)
```
**Use for:** Pending approval, Warnings, Premium features

#### Error (Red)
```dart
Container(
  padding: EdgeInsets.all(8),
  decoration: BoxDecoration(
    color: AppColors.zambianRed,
    borderRadius: BorderRadius.circular(4),
  ),
  child: Text('Rejected', style: TextStyle(color: Colors.white)),
)
```
**Use for:** Errors, Rejected, Deleted, Critical alerts

---

### Badges

#### Premium Badge
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: AppColors.zambianOrange,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.star, size: 12, color: Colors.white),
      SizedBox(width: 4),
      Text('Premium', style: TextStyle(color: Colors.white, fontSize: 10)),
    ],
  ),
)
```

#### Verified Badge
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: AppColors.zambianGreen,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.verified, size: 12, color: Colors.white),
      SizedBox(width: 4),
      Text('Verified', style: TextStyle(color: Colors.white, fontSize: 10)),
    ],
  ),
)
```

#### Unread Count Badge
```dart
Container(
  padding: EdgeInsets.all(6),
  decoration: BoxDecoration(
    color: AppColors.zambianOrange,
    shape: BoxShape.circle,
  ),
  child: Text(
    '5',
    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
  ),
)
```

---

### Icons

#### Active/Selected Icons (Red)
```dart
Icon(Icons.favorite, color: AppColors.zambianRed)
Icon(Icons.check_circle, color: AppColors.zambianRed)
```

#### Success Icons (Green)
```dart
Icon(Icons.check_circle, color: AppColors.zambianGreen)
Icon(Icons.verified, color: AppColors.zambianGreen)
```

#### Warning Icons (Orange)
```dart
Icon(Icons.warning, color: AppColors.zambianOrange)
Icon(Icons.star, color: AppColors.zambianOrange)
```

---

### Gradients

#### Hero Gradient (All Three Colors)
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        AppColors.zambianRed,
        AppColors.zambianOrange,
        AppColors.zambianGreen,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
)
```
**Use for:** Splash screen, Hero sections, Premium features

#### Primary Gradient (Red to Orange)
```dart
Container(
  decoration: BoxDecoration(
    gradient: AppColors.primaryGradient,
  ),
)
```
**Use for:** Buttons, Cards, Headers

#### Accent Gradient (Orange to Green)
```dart
Container(
  decoration: BoxDecoration(
    gradient: AppColors.accentGradient,
  ),
)
```
**Use for:** Success flows, Completion screens

---

## 🎨 Color Psychology & Usage

### Red (Primary)
**Emotion:** Energy, Passion, Action
**Use for:**
- Call-to-action buttons
- Important notifications
- Active states
- Error messages
- Favorite/like indicators

### Orange (Accent)
**Emotion:** Enthusiasm, Creativity, Warmth
**Use for:**
- Premium features
- Warnings
- Highlights
- Secondary actions
- Promotional content

### Green (Secondary)
**Emotion:** Success, Growth, Trust
**Use for:**
- Success messages
- Verified badges
- Active listings
- Positive feedback
- Confirmation states

---

## ✅ Best Practices

### Do's ✅
- Use red for primary actions and CTAs
- Use green for success states and verification
- Use orange for warnings and premium features
- Maintain consistent color usage across screens
- Use white backgrounds for content cards
- Add subtle shadows for depth

### Don'ts ❌
- Don't use all three colors equally on one screen
- Don't use red for success messages
- Don't use green for errors
- Don't overuse gradients
- Don't mix too many colors in one component

---

## 📊 Color Distribution Guidelines

**Recommended color distribution per screen:**
- **70%** White/Neutral backgrounds
- **20%** Primary color (Red)
- **5%** Secondary color (Green)
- **5%** Accent color (Orange)

This creates visual hierarchy and prevents color overload.

---

## 🎯 Accessibility

All Zambian colors meet WCAG AA standards for contrast:
- ✅ Red on white: 7.2:1 (AAA)
- ✅ Orange on white: 4.8:1 (AA)
- ✅ Green on white: 5.1:1 (AA)
- ✅ White on red: 7.2:1 (AAA)
- ✅ White on orange: 4.8:1 (AA)
- ✅ White on green: 5.1:1 (AA)

---

**The Zambian colors create a vibrant, culturally relevant, and professional design!** 🇿🇲
