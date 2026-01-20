# Mobile App

This directory contains the mobile application for Village Connect.

## Technology Stack

- **Framework:** Flutter (recommended) or React Native
- **Language:** Dart (Flutter) or JavaScript/TypeScript (React Native)
- **State Management:** TBD (Provider, Riverpod, Redux, etc.)

## Project Structure (Flutter)

```
mobile/
├── lib/
│   ├── main.dart            # Application entry point
│   ├── models/              # Data models
│   ├── screens/             # UI screens
│   ├── widgets/             # Reusable widgets
│   ├── services/            # API and business logic
│   └── utils/               # Utility functions
├── test/                    # Test files
├── assets/                  # Images, fonts, etc.
├── pubspec.yaml            # Flutter dependencies
└── README.md               # This file
```

## Getting Started

### Prerequisites

**For Flutter:**
- Flutter SDK 3.0 or higher
- Dart SDK (included with Flutter)
- Android Studio or Xcode (for mobile development)

**For React Native:**
- Node.js 16 or higher
- npm or yarn
- React Native CLI
- Android Studio or Xcode

### Installation (Flutter)

1. Navigate to the mobile directory:
   ```bash
   cd mobile
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run
   ```

### Installation (React Native)

1. Navigate to the mobile directory:
   ```bash
   cd mobile
   ```

2. Install dependencies:
   ```bash
   npm install
   # or
   yarn install
   ```

3. Run the application:
   ```bash
   # For iOS
   npm run ios
   # or
   yarn ios

   # For Android
   npm run android
   # or
   yarn android
   ```

## Running on Devices

### Android

1. Connect your Android device via USB or start an Android emulator
2. Run `flutter run` (Flutter) or `npm run android` (React Native)

### iOS

1. Open Xcode
2. Configure your development team
3. Run `flutter run` (Flutter) or `npm run ios` (React Native)

## Running Tests

**Flutter:**
```bash
flutter test
```

**React Native:**
```bash
npm test
# or
yarn test
```

## Building for Production

### Flutter

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

### React Native

**Android:**
```bash
cd android
./gradlew assembleRelease
```

**iOS:**
```bash
cd ios
xcodebuild -workspace VillageConnect.xcworkspace -scheme VillageConnect -configuration Release
```

## Features

- [ ] Event browsing and calendar view
- [ ] Event search and filtering
- [ ] User profiles
- [ ] Favorite events
- [ ] Push notifications
- [ ] Community news feed
- [ ] User authentication

## Development Guidelines

1. Follow the official style guides for Flutter or React Native
2. Write unit tests for business logic
3. Write widget/component tests for UI
4. Use meaningful variable and function names
5. Comment complex logic
6. Keep components small and focused

## Troubleshooting

TBD - Common issues and solutions will be added here
