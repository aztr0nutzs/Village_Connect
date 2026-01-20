# 🏡 Villages Connect

**A Senior-Friendly Community App for The Villages, Florida**

Villages Connect is a comprehensive mobile application designed specifically for residents of The Villages, FL. Built with accessibility and ease of use in mind, it provides seamless access to community events, resident directory, messaging, and emergency services.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white)

## ✨ Features

### 🏠 **Dashboard**
- Welcome screen with current time and date
- Quick access to all major features
- Real-time announcements and updates
- Personalized greeting for logged-in users

### 📅 **Community Events**
- Browse upcoming community events
- Filter by category (Social, Educational, Fitness, etc.)
- Register for events with one tap
- Event reminders and notifications
- Offline event access

### 👥 **Resident Directory**
- Search and connect with fellow residents
- Emergency contact information
- Interest-based filtering
- Privacy controls and permissions

### 💬 **Messages**
- Community announcements and updates
- Direct messaging capabilities
- Message filtering (All, Unread, Read)
- Priority message indicators

### 🚨 **Emergency Services**
- Quick access to emergency contacts
- Medical, security, maintenance, and utility services
- One-tap calling functionality
- Location-based emergency services

### ⚙️ **Settings & Accessibility**
- **Text Size**: Small, Medium, Large options
- **High Visibility Mode**: Pure black/white colors
- **Voice Feedback**: Text-to-speech for headlines
- **Notification Preferences**: Customizable alerts
- **Theme Selection**: Light/Dark mode support

### 🔐 **Authentication**
- Secure email/password login
- Guest mode for quick access
- Account registration with email verification
- Password reset functionality
- Profile management

### 📱 **Offline Support**
- Full functionality without internet
- Automatic data synchronization
- Cached content for instant access
- Smart retry when connection restored

## Project Structure

```
villages_connect/
├─ lib/                    # Flutter source code
│  ├─ screens/            # Screen components
│  │  ├─ home_dashboard.dart
│  │  ├─ event_directory.dart
│  │  ├─ rec_center_directory.dart
│  │  └─ news_feed.dart
│  ├─ widgets/            # Reusable UI components
│  ├─ models/             # Data models and classes
│  └─ services/           # API and data services
├─ assets/                # Images, icons, fonts
├─ TASKS.md              # Development task list (20 issues)
└─ README.md             # This file
```

## 🛠️ Architecture

### Tech Stack
- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **Authentication**: Firebase Auth
- **Database**: Firebase Firestore
- **Notifications**: Firebase Cloud Messaging
- **Storage**: Secure local storage + cloud sync
- **Maps**: Google Maps integration

### Project Structure
```
lib/
├── main.dart              # App entry point & service initialization
├── screens/               # UI screens
│   ├── home_dashboard.dart
│   ├── events_screen.dart
│   ├── directory_screen.dart
│   ├── messages_screen.dart
│   ├── emergency_screen.dart
│   └── settings_screen.dart
├── services/              # Business logic & external APIs
│   ├── auth_service.dart
│   ├── cache_service.dart
│   ├── notification_service.dart
│   └── accessibility_service.dart
├── models/                # Data models
├── widgets/               # Reusable UI components
└── utils/                 # Helper functions
```

## 🚀 Getting Started

### Prerequisites

- **Flutter**: Version 3.24+ ([Install Flutter](https://flutter.dev/docs/get-started/install))
- **Dart**: Version 3.3+
- **Android Studio**: For Android development
- **Xcode**: For iOS development (macOS only)
- **Firebase Account**: For authentication and notifications

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/aztr0nutzs/Villages-Connect.git
   cd villages-connect
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication and Firestore
   - Add your Android and iOS apps to Firebase
   - Download and place `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

4. **Run the app**
   ```bash
   flutter run
   ```

### Build for Production

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

**iOS (macOS only):**
```bash
flutter build ios --release
```

### Development Setup

1. **Code formatting**
   ```bash
   flutter format lib/
   ```

2. **Static analysis**
   ```bash
   flutter analyze
   ```

3. **Run tests**
   ```bash
   flutter test
   ```

## 🎯 Key Features for Seniors

### Accessibility First
- **Large Text Options**: 125% maximum size scaling
- **High Contrast Mode**: Pure black text on white backgrounds
- **Voice Feedback**: Text-to-speech for important information
- **Simple Navigation**: Clear, large touch targets
- **Screen Reader Support**: Full compatibility with accessibility tools

### Senior-Friendly Design
- **Clear Typography**: Easy-to-read fonts and sizes
- **Intuitive Icons**: Meaningful symbols for quick recognition
- **Consistent Layout**: Familiar patterns throughout the app
- **Emergency Access**: Prominent emergency contact buttons
- **Guest Mode**: No account required for basic features

### Offline Capability
- **Always Available**: Core features work without internet
- **Smart Caching**: Important data stored locally
- **Background Sync**: Automatic updates when online
- **Data Preservation**: User preferences never lost

## 📱 Screenshots

*Screenshots will be added after initial release*

## 🔧 Configuration

### Environment Variables
Create a `.env` file in the root directory:
```env
FIREBASE_API_KEY=your_api_key
FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
FIREBASE_PROJECT_ID=your_project_id
```

### Firebase Configuration
Update `lib/firebase_options.dart` with your Firebase project configuration.

## 🧪 Testing

Run the test suite:
```bash
flutter test --coverage
```

Run integration tests:
```bash
flutter test integration_test/
```

## 📚 Documentation

- [API Documentation](./docs/API.md)
- [Deployment Guide](./docs/DEPLOYMENT.md)
- [Contributing Guidelines](./docs/CONTRIBUTING.md)
- [Accessibility Guide](./docs/ACCESSIBILITY.md)

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](./docs/CONTRIBUTING.md) for details.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built for the amazing community of **The Villages, Florida**
- Special thanks to all beta testers and contributors
- Icons provided by [Material Design Icons](https://materialdesignicons.com/)

## 📞 Support

- **Email**: support@villagesconnect.com
- **Issues**: [GitHub Issues](https://github.com/aztr0nutzs/Villages-Connect/issues)
- **Discussions**: [GitHub Discussions](https://github.com/aztr0nutzs/Villages-Connect/discussions)

## 🔄 Version History

### [1.0.0] - 2024-01-15
- Initial release
- Complete community features
- Accessibility and offline support
- Firebase integration
- Production-ready builds

---

**Made with ❤️ for The Villages Community**

*Stay connected, stay engaged, stay active!*