# 🧪 CazLync App - Testing Guide

## 🚀 Quick Start

### 1. Run the App
```bash
flutter pub get
flutter run
```

### 2. Choose Your Device
- Android Emulator
- iOS Simulator
- Physical Device

---

## ✅ TEST CHECKLIST

### Authentication Tests

#### Registration Flow:
- [ ] Open app → See splash screen with logo
- [ ] Tap "Create Account"
- [ ] Enter name, email, password
- [ ] Tap "Sign Up"
- [ ] Should navigate to home screen
- [ ] Check if user is logged in

#### Login Flow:
- [ ] Tap "Login"
- [ ] Enter email & password
- [ ] Tap "Sign In"
- [ ] Should navigate to home screen

#### Social Auth:
- [ ] Try Google Sign-In
- [ ] Try Facebook Login
- [ ] Verify profile created

---

### Listing Tests

#### Browse Listings:
- [ ] Home screen shows listings in grid
- [ ] Scroll to load more (pagination)
- [ ] Tap listing → Opens detail screen
- [ ] See images, price, details
- [ ] Swipe through image gallery

#### Search & Filter:
- [ ] Tap search bar
- [ ] Type "Toyota" → See filtered results
- [ ] Tap filter button
- [ ] Select filters (brand, price, year)
- [ ] Tap "Apply" → See filtered results
- [ ] See active filter chips
- [ ] Tap X on chip → Remove filter
- [ ] Tap "Clear All" → Remove all filters

#### Create Listing:
- [ ] Tap FAB (+) button
- [ ] Fill in all fields
- [ ] Tap "Add Images"
- [ ] Select 3-5 images
- [ ] Review form
- [ ] Tap "Publish"
- [ ] Should see success message
- [ ] Listing appears in home

---

### Favorites Tests

#### Add Favorite:
- [ ] Tap heart icon on listing card
- [ ] Heart fills with red color
- [ ] Tap Favorites tab
- [ ] See listing in favorites

#### Remove Favorite:
- [ ] Tap filled heart icon
- [ ] Heart empties
- [ ] Listing removed from favorites

#### Sync Test:
- [ ] Add favorite on Device A
- [ ] Open app on Device B (same account)
- [ ] Should see favorite synced

---

### Chat Tests

#### Start Chat:
- [ ] Open listing detail
- [ ] Tap "Contact Seller"
- [ ] Chat room opens
- [ ] See listing preview at top
- [ ] Type message
- [ ] Tap send
- [ ] Message appears instantly

#### Chat List:
- [ ] Tap Messages tab
- [ ] See all conversations
- [ ] See last message preview
- [ ] See unread count badge
- [ ] Tap conversation → Opens chat room

#### Real-Time:
- [ ] Send message from Device A
- [ ] Should appear on Device B instantly
- [ ] Check read receipts (double check)

---

### Profile Tests

#### View Profile:
- [ ] Tap Profile tab
- [ ] See user name, email
- [ ] See profile avatar
- [ ] See menu items

#### Logout:
- [ ] Tap "Logout" button
- [ ] Should return to login screen
- [ ] Try accessing protected screens
- [ ] Should redirect to login

---

## 🐛 COMMON ISSUES & FIXES

### Issue: App won't build
```bash
flutter clean
flutter pub get
flutter run
```

### Issue: Firebase not configured
- Check `google-services.json` (Android)
- Check `GoogleService-Info.plist` (iOS)
- Verify Firebase project settings

### Issue: Images not uploading
- Check Firebase Storage rules
- Verify internet connection
- Check image size (< 5MB)

### Issue: Chat not working
- Check Firestore rules
- Verify user is authenticated
- Check internet connection

### Issue: Notifications not showing
- Check FCM configuration
- Verify notification permissions
- Check device settings

---

## 📊 PERFORMANCE TESTS

### Load Time:
- [ ] App starts in < 3 seconds
- [ ] Splash screen shows immediately
- [ ] Home screen loads in < 2 seconds

### Image Loading:
- [ ] Images load progressively
- [ ] Placeholders show while loading
- [ ] Cached images load instantly

### Scrolling:
- [ ] Smooth scrolling in lists
- [ ] No lag when scrolling fast
- [ ] Pagination works smoothly

### Real-Time:
- [ ] Messages appear instantly
- [ ] Favorites sync in < 1 second
- [ ] Chat updates in real-time

---

## 🔒 SECURITY TESTS

### Authentication:
- [ ] Can't access app without login
- [ ] Session persists after app restart
- [ ] Logout clears session

### Data Access:
- [ ] Can't edit other users' listings
- [ ] Can't delete other users' data
- [ ] Can only see own favorites

### Chat:
- [ ] Can only see own conversations
- [ ] Can't access other users' chats
- [ ] Messages are private

---

## 📱 DEVICE TESTS

### Android:
- [ ] Test on Android 8.0+
- [ ] Test different screen sizes
- [ ] Test back button behavior
- [ ] Test app permissions

### iOS:
- [ ] Test on iOS 12.0+
- [ ] Test on iPhone & iPad
- [ ] Test swipe gestures
- [ ] Test app permissions

---

## 🎯 USER SCENARIOS

### Scenario 1: First-Time User
1. Download app
2. Create account
3. Browse listings
4. Search for specific car
5. Save favorites
6. Contact seller
7. Chat with seller

### Scenario 2: Seller
1. Login
2. Create new listing
3. Upload photos
4. Set price & details
5. Publish listing
6. Receive message from buyer
7. Reply to buyer

### Scenario 3: Buyer
1. Login
2. Search for car
3. Apply filters
4. View details
5. Save to favorites
6. Contact seller
7. Negotiate via chat

---

## ✅ ACCEPTANCE CRITERIA

### Must Work:
- ✅ User can register/login
- ✅ User can browse listings
- ✅ User can search & filter
- ✅ User can create listings
- ✅ User can save favorites
- ✅ User can chat with sellers
- ✅ Real-time updates work

### Should Work:
- ✅ Images load quickly
- ✅ App is responsive
- ✅ No crashes
- ✅ Data persists
- ✅ Offline mode (partial)

### Nice to Have:
- ⏳ Push notifications
- ⏳ Advanced analytics
- ⏳ Social sharing
- ⏳ Premium features

---

## 🚨 CRITICAL BUGS TO WATCH

### High Priority:
- App crashes on startup
- Can't login/register
- Images won't upload
- Chat messages not sending
- Data not saving

### Medium Priority:
- Slow loading times
- UI glitches
- Filter not working
- Favorites not syncing

### Low Priority:
- Minor UI issues
- Text overflow
- Color inconsistencies
- Animation stutters

---

## 📝 BUG REPORT TEMPLATE

```
**Bug Title**: [Short description]

**Steps to Reproduce**:
1. Open app
2. Navigate to...
3. Tap on...
4. Observe...

**Expected Behavior**:
[What should happen]

**Actual Behavior**:
[What actually happens]

**Device Info**:
- Device: [e.g., Pixel 6]
- OS: [e.g., Android 13]
- App Version: 1.0.0

**Screenshots**:
[Attach if applicable]

**Priority**: High/Medium/Low
```

---

## 🎉 TESTING COMPLETE!

Once all tests pass:
1. ✅ Document any issues found
2. ✅ Fix critical bugs
3. ✅ Retest affected areas
4. ✅ Get user feedback
5. ✅ Prepare for deployment

---

## 📞 SUPPORT

If you encounter issues:
1. Check this guide
2. Review error messages
3. Check Firebase console
4. Review Firestore rules
5. Check device logs

**Happy Testing!** 🚀
