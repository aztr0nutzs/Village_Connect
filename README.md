# 🏡 Village Connect

<img width="2048" height="512" alt="Village Connect Banner" src="https://github.com/user-attachments/assets/62be3f46-216a-41fb-8ec1-644efccc44eb" />

**A Comprehensive Community Platform for The Villages, Florida**

Village Connect is a full-stack community application platform designed to help residents of The Villages stay connected with community events, neighbors, and services. The platform consists of a mobile Flutter application and a FastAPI backend that provides data ingestion and API services.

[![CI Pipeline](https://github.com/aztr0nutzs/Village_Connect/workflows/CI%20Pipeline/badge.svg)](https://github.com/aztr0nutzs/Village_Connect/actions)
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-009688?style=flat&logo=fastapi&logoColor=white)

## 📚 Table of Contents

- [Architecture Overview](#architecture-overview)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
  - [Backend Setup](#backend-setup)
  - [Mobile App Setup](#mobile-app-setup)
- [Development](#development)
- [For End Users](#for-end-users)
- [Documentation](#documentation)
- [Contributing](#contributing)
- [License](#license)

## 🏗️ Architecture Overview

Village Connect is organized as a monorepo containing both the mobile application and backend services:

```
┌─────────────────────────────────────────────────────────────┐
│                     Village Connect System                   │
└─────────────────────────────────────────────────────────────┘

┌──────────────┐          ┌──────────────┐          ┌──────────────┐
│              │          │              │          │              │
│    Mobile    │◄────────►│   Backend    │◄────────►│  External    │
│  Flutter App │   API    │   FastAPI    │  Scrape  │   Sources    │
│              │          │              │          │              │
└──────────────┘          └──────────────┘          └──────────────┘
       │                         │
       │                         │
       ▼                         ▼
┌──────────────┐          ┌──────────────┐
│   Firebase   │          │   Database   │
│  Auth/Cloud  │          │              │
└──────────────┘          └──────────────┘
```

### Technology Stack

**Mobile App:**
- Flutter 3.24+ (Dart 3.3+)
- Firebase Auth & Firestore
- Provider for state management
- Offline-first architecture

**Backend:**
- FastAPI (Python 3.9+)
- SQLAlchemy ORM
- httpx + BeautifulSoup4 for web scraping
- Async request handling

## 📁 Project Structure

```
Village_Connect/
├── backend/              # FastAPI backend service
│   ├── app.py           # Main FastAPI application
│   ├── requirements.txt # Python dependencies
│   ├── scrapers/        # Data ingestion modules
│   ├── api/             # API route definitions
│   ├── models/          # Data models and schemas
│   └── tests/           # Backend tests
│
├── mobile/              # Flutter mobile application
│   ├── lib/
│   │   ├── screens/    # UI screens
│   │   ├── services/   # Business logic
│   │   ├── models/     # Data models
│   │   └── widgets/    # Reusable components
│   ├── assets/         # Images, icons, fonts
│   ├── test/           # Unit and widget tests
│   └── pubspec.yaml    # Flutter dependencies
│
├── docs/               # Project documentation
│   ├── ARCHITECTURE.md # System architecture details
│   ├── TASKS.md        # Task tracking
│   ├── WORKLOG.md      # Development log
│   └── DECISIONS.md    # Design decisions (ADRs)
│
├── .github/
│   └── workflows/
│       └── ci.yml      # CI/CD pipeline
│
└── README.md           # This file
```

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

**For Backend:**
- Python 3.9 or higher
- pip (Python package manager)

**For Mobile:**
- Flutter SDK 3.24 or higher
- Dart SDK 3.3 or higher
- Android Studio (for Android development)
- Xcode (for iOS development, macOS only)

### Backend Setup

1. **Navigate to the backend directory:**
   ```bash
   cd backend
   ```

2. **Create a virtual environment:**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Run the development server:**
   ```bash
   python app.py
   ```
   
   Or with uvicorn:
   ```bash
   uvicorn app:app --reload --host 0.0.0.0 --port 8000
   ```

5. **Access the API:**
   - API: http://localhost:8000
   - API Documentation: http://localhost:8000/docs
   - Health Check: http://localhost:8000/api/v1/health

### Mobile App Setup

1. **Navigate to the mobile directory:**
   ```bash
   cd mobile
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase:**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication and Firestore
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place configuration files in the appropriate directories

4. **Run the app:**
   ```bash
   # List available devices
   flutter devices
   
   # Run on connected device or emulator
   flutter run
   ```

5. **Build for production:**
   ```bash
   # Android APK
   flutter build apk --release
   
   # Android App Bundle
   flutter build appbundle --release
   
   # iOS (macOS only)
   flutter build ios --release
   ```

## 🛠️ Development

### Running Tests

**Backend:**
```bash
cd backend
pytest tests/ -v
```

**Mobile:**
```bash
cd mobile
flutter test
```

### Linting and Formatting

**Backend:**
```bash
cd backend

# Lint with flake8
flake8 .

# Format with black
black .

# Type checking with mypy
mypy . --ignore-missing-imports
```

**Mobile:**
```bash
cd mobile

# Format code
dart format .

# Analyze code
flutter analyze
```

### CI/CD Pipeline

The project uses GitHub Actions for continuous integration. The pipeline includes:

- **Backend:** Linting (flake8, black, mypy) and testing (pytest)
- **Mobile:** Linting (dart format, flutter analyze) and testing (flutter test)

Workflows run automatically on:
- Push to `main`, `develop`, or `copilot/**` branches
- Pull requests to `main` or `develop`

## 📖 Documentation

Comprehensive documentation is available in the `/docs/` directory:

- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** - System architecture, data flow, and component details
- **[TASKS.md](docs/TASKS.md)** - Project task tracking and roadmap
- **[WORKLOG.md](docs/WORKLOG.md)** - Development activity log
- **[DECISIONS.md](docs/DECISIONS.md)** - Architecture Decision Records (ADRs)

For mobile app-specific documentation, see [mobile/README.md](mobile/README.md).

## ✨ Key Features

### For Residents

- **📅 Community Events** - Browse and register for community events
- **👥 Resident Directory** - Connect with neighbors
- **💬 Messaging** - Community announcements and direct messages
- **🚨 Emergency Services** - Quick access to emergency contacts
- **♿ Accessibility** - Large text, high contrast, voice feedback
- **📱 Offline Support** - Full functionality without internet

### For Administrators

- **🔄 Data Ingestion** - Automated scraping of event data
- **🔌 REST API** - Efficient endpoints for mobile app
- **📊 Analytics** - (Coming soon) Usage insights and metrics
- **🔐 Security** - Firebase authentication and secure API

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes and commit: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

Please ensure:
- Code passes all linting and tests
- New features include appropriate tests
- Documentation is updated as needed

## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with ❤️ for **The Villages, Florida** community
- Special thanks to all beta testers and contributors
- Icons provided by [Material Design Icons](https://materialdesignicons.com/)

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/aztr0nutzs/Village_Connect/issues)
- **Discussions:** [GitHub Discussions](https://github.com/aztr0nutzs/Village_Connect/discussions)
- **Email:** support@villagesconnect.com

---

## 🧓 For End Users

If you're a resident looking to use the Village Connect app, here's your quick-start guide:

### How to Get the App on Your Device 📲

You can install this app on almost any smartphone (like an iPhone 🍎 or Samsung 📱) or a tablet (like an iPad 🍏).

For Apple (iPhone or iPad) Users 🍎

    Find and tap on the "App Store" icon. It looks like a blue square with a white "A". 🟦

    Tap on the "Search" tab, which is in the bottom-right corner and has a magnifying glass icon. 🔍

    In the search bar at the top, type: Village_Connect

    You should see our app in the results. Tap the "Get" button next to it. ✅

        Tool Tip: You may need to double-click the side button on your phone or enter your Apple password to confirm the download. This is normal and safe. 👍

    The app will download and appear on your home screen. ✨

For Android (Samsung, Google, etc.) Users 🤖

    Find and tap on the "Play Store" icon. It looks like a colorful triangle. ▶️

    Tap on the search bar at the very top of the screen. 🔎

    In the search bar, type: Village_Connect

    You should see our app in the results. Tap the green "Install" button. ✅

    The app will download and appear on your app screen. ✨

Your Quick-Start Guide (The 5 Main Features) ⭐

Here are the most important things you can do with the Village_Connect app. 👇

    See What's Happening: Events & Activities! 🎉

        What it is: A complete, up-to-date calendar of every event, club meeting, and activity in the community. 🗓️

        Why it's helpful: You'll never miss a pickleball game 🏸, card night 🃏, or town-hall meeting again. 🙌

    Create Your Profile: Say Hello! 🧑‍🤝‍🧑

        What it is: Your own personal "page" in the app. You can add your name, a photo 📸, and maybe a few of your interests. hobby 🎨

        Why it's helpful: It helps neighbors put a name to a face and lets you sign up for events. 😊

    Search and Filter: Find What You Need! 🔍

        What it is: A search bar, just like on Google, but only for our community. 🎯

        Why it's helpful: Instantly find what you're looking for. Just type "billiards" 🎱 or "Saturday" ☀️ to see only the events that match.

    Save Your Favorites: Keep Track! ❤️

        What it is: A "bookmark" button (it may look like a heart or a star) for events you're interested in. ⭐

        Why it's helpful: You can save events you like into your own personal list, making them easy to find later. ✅

    Get Reminders & Alerts: Stay Informed! 🔔

        What it is: The app can send you a little "ping" (a notification) on your phone before an event you've saved. ⏰

        Why it's helpful: It's like a friendly tap on the shoulder so you don't forget about that concert 🎶 or club meeting. 😉

<img width="1024" height="1024" alt="Gemini_Generated_Image_bsce6pbsce6pbsce" src="https://github.com/user-attachments/assets/fb38903c-a2e0-4212-a157-956e50415082" />

Full How-To Guide: Using Village_Connect 📖

<img width="1024" height="1024" alt="Gemini_Generated_Image_bsce6pbsce6pbsce(1)" src="https://github.com/user-attachments/assets/49814983-2cc7-4996-9491-c4c59b4ad91f" />

Let's walk through the app step-by-step. 🚶‍♀️🚶‍♂️

How to Create Your Account 🧑‍💻



The first time you open the app, it will ask you to "Sign Up" or "Log In."

    Tap the "Sign Up" button. 👋

    The app will ask for your basic information, such as:

        Your Name 📛

        Your Email Address ✉️

        A new Password 🔑

    Fill in these fields. ✍️

        Tool Tip: Your password is like a secret key. Choose something you can remember but that others wouldn't guess. It's a good idea to write it down in a safe place. 🤫

    Once you're done, tap the "Create Account" or "Register" button. ✅

    That's it! You'll now be logged in. 🎉 In the future, you'll just use the "Log In" button with your email and the password you just created. ➡️

How to See Events & Activities 🎉

When you open the app, you will most likely land on the main Home screen 🏠 or Events screen. 🗓️

    This screen will show you a list of all upcoming events, probably starting with what's happening today. ☀️

    You can scroll with your finger (swipe up and down) to see the full list. 👇👆

    If you see an event you want to know more about, just tap on it. 👉

    A new screen will open showing you all the details: ℹ️

        What the event is 📝

        When it starts and ends ⏰

        Where it is (the location or recreation center) 📍

        A description of the event 🗒️

How to Search for Specific Events 🔍

If you're looking for something specific, the Search feature is your best friend. 🕵️‍♀️

    Look for a magnifying glass icon (🔍) or a bar that says "Search". It's usually at the top of the screen. 🔝

    Tap on the search bar. Your on-screen keyboard will pop up. ⌨️

    Type what you're looking for. ✍️

        Example: Golf ⛳

        Example: Mahjong 🀄

        Example: Saturday 🗓️

    The app will automatically filter the list to show you only the events that match your search. ✅

How to Save a "Favorite" Event ❤️

When you find an event you don't want to forget, save it as a "Favorite." ⭐

    When you are looking at the details for an event, look for a Heart icon (❤️) or a Star icon (⭐).

    Tap the icon! It will usually fill in with color, showing you've saved it. 💖

    That's it! The event is now saved. ✅

    To find your list of saved events, look for a "Favorites" or "My Events" section in the app menu. 📋

How to Get Notifications (Alerts) 🔔

A notification is a small pop-up message from the app that appears on your phone's screen. 📱

    For Reminders: When you save an event as a "Favorite" (see above), the app may ask if you want a reminder. You can set it to alert you 1 hour before the event, for example. ⏰

    For Community News: The app might also send alerts for important, all-community news, like a road closure 🚧 or a special holiday schedule. 🥳

    Tool Tip: The first time you use the app, your phone will ask, "Allow 'Village_Connect' to send you notifications?" It is highly recommended that you tap "Allow" to get these helpful reminders. ✅ You can always change this later in your phone's Settings. ⚙️

Need Help? ❓

Using new technology can be tricky, but don't worry. Help is always available. 🤗

(Note: This section needs to be filled in by the project team)

<img width="1024" height="1024" alt="Gemini_Generated_Image_sy07amsy07amsy07" src="https://github.com/user-attachments/assets/829ce68c-9f6e-42b3-aa0a-2196c18aead5" />

    For App Help: [Insert Email Address or Contact Person's Name Here] 📧

    For Club & Event Info: [Insert Phone Number or Email for Main Rec. Center Here] 📞

---

**Made with ❤️ for The Villages Community**

*Stay connected, stay engaged, stay active!*

