# Villages Connect

A senior-friendly community app designed specifically for residents of The Villages, FL. This app provides easy access to community events, directories, messaging, and emergency contacts with a focus on accessibility and usability for seniors.

## Features

### ✅ Completed Features

- **Dashboard**: Welcome screen with quick access to all app features
- **Events**: Community event listings with registration and filtering
- **Directory**: Resident contact information and emergency contacts
- **Messages**: Community announcements and communications
- **Emergency**: Important contact information and emergency resources
- **Navigation**: Senior-friendly navigation system

### 🎯 Key Design Principles

- **Senior-Friendly**: Large fonts (18px+), high contrast colors, generous touch targets
- **Accessibility**: Screen reader compatible, voice commands, high contrast mode
- **Intuitive**: Simple navigation, clear information hierarchy, minimal cognitive load
- **Responsive**: Works on tablets, phones, and web browsers

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

## Technology Stack

### Flutter Implementation
- **Framework**: Flutter 3.x+
- **Language**: Dart
- **UI**: Material Design 3
- **State Management**: Provider (planned)
- **Backend**: Firebase (planned)

### React Implementation (Alternative)
- **Framework**: React 18+
- **Language**: TypeScript
- **Styling**: CSS-in-JS (styled-components)
- **Routing**: React Router 6
- **Build Tool**: Vite

## Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK (2.19+)
- Android Studio / VS Code
- iOS Simulator (macOS only)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd villages_connect
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
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

## Development Guidelines

### Code Style
- Follow Dart/Flutter best practices
- Use meaningful variable and function names
- Add comprehensive documentation
- Keep functions small and focused

### UI/UX Guidelines
- **Font Sizes**: Minimum 18px for body text, 24px+ for headings
- **Touch Targets**: Minimum 48px for all interactive elements
- **Colors**: High contrast ratios (4.5:1 minimum)
- **Spacing**: Generous padding and margins for easy reading

### Accessibility
- Support screen readers with proper semantics
- Provide alternative text for images
- Ensure keyboard navigation works
- Test with high contrast mode enabled

## Contributing

1. Check the [TASKS.md](TASKS.md) file for current development tasks
2. Create a feature branch from `main`
3. Implement changes following the guidelines above
4. Test thoroughly on multiple devices
5. Submit a pull request with a clear description

## Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter drive --target=test_driver/app.dart
```

### Accessibility Testing
- Use Flutter's accessibility tools
- Test with screen readers
- Verify high contrast mode compatibility

## Deployment

### Android APK
```bash
flutter build apk --release
```

### iOS App Store
```bash
flutter build ios --release
```

### Web Version
```bash
flutter build web --release
```

## Support

For support or questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation in [TASKS.md](TASKS.md)

## License

This project is licensed under the Apache License 2.0 - see the LICENSE file for details.

## Acknowledgments

- Designed specifically for The Villages community
- Built with senior accessibility in mind
- Community-driven development approach

---

**Last updated**: November 8, 2024
**Version**: 0.1.0