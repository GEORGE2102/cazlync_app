# CazLync Mobile App

CazLync is a mobile application platform for buying and selling cars in Zambia. Built with Flutter, it provides a seamless experience for car buyers, sellers, and dealers.

## Features

- 🔐 Multi-method authentication (Email, Phone, Google, Facebook)
- 🚗 Browse and search car listings with advanced filters
- 📸 Post car listings with multiple images
- 💬 Real-time chat between buyers and sellers
- 🔔 Push notifications for messages and updates
- ⭐ Save favorite listings
- 👤 User profile management
- 🛡️ Verified seller badges
- 💎 Premium listing options for dealers
- 👨‍💼 Admin dashboard for content moderation

## Tech Stack

- **Framework**: Flutter 3.x
- **State Management**: Riverpod
- **Backend**: Firebase (Auth, Firestore, Storage, Messaging)
- **Local Storage**: Hive
- **Image Handling**: flutter_image_compress, cached_network_image

## Project Structure

```
lib/
├── core/
│   ├── constants/      # App colors, themes, and constants
│   ├── errors/         # Error handling (failures, exceptions)
│   └── utils/          # Utility functions and validators
├── data/
│   ├── models/         # Data models and DTOs
│   ├── repositories/   # Repository implementations
│   └── services/       # Firebase and external services
├── domain/
│   ├── entities/       # Business entities
│   └── repositories/   # Repository interfaces
└── presentation/
    ├── controllers/    # Riverpod controllers
    ├── screens/        # UI screens
    └── widgets/        # Reusable widgets
```

## Getting Started

### Prerequisites

- Flutter SDK 3.x or higher
- Dart 3.x or higher
- Firebase project setup
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Firebase:
   - Add `google-services.json` for Android
   - Add `GoogleService-Info.plist` for iOS

4. Run the app:
   ```bash
   flutter run
   ```

## Firebase Configuration

This app requires Firebase configuration for:
- Authentication (Email, Phone, Google, Facebook)
- Cloud Firestore (Database)
- Cloud Storage (Images)
- Cloud Messaging (Push notifications)
- Analytics & Crashlytics

## Development

### Running Tests

```bash
flutter test
```

### Building for Production

Android:
```bash
flutter build apk --release
```

iOS:
```bash
flutter build ios --release
```

## Color Palette

- Primary: #D32F2F (CazLync Red)
- Secondary: #212121 (Deep Charcoal)
- Accent: #FFD54F (Amber)
- Background: #F5F5F5
- Success: #4CAF50
- Error: #E53935

## License

Copyright © 2025 CazLync. All rights reserved.
