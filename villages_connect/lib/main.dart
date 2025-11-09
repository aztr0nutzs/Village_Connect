import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_dashboard.dart';
import 'screens/event_directory.dart';
import 'screens/rec_center_directory.dart';
import 'screens/news_feed.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/profile_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'widgets/navigation_guard.dart';
import 'widgets/notification_scheduler.dart';

void main() {
  runApp(const VillagesConnectApp());
}

class VillagesConnectApp extends StatefulWidget {
  const VillagesConnectApp({Key? key}) : super(key: key);

  @override
  State<VillagesConnectApp> createState() => _VillagesConnectAppState();
}

class _VillagesConnectAppState extends State<VillagesConnectApp> {
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Initialize auth service
      await _authService.initialize();

      // Initialize notification service
      await _notificationService.initialize();

      // Request notification permissions
      await _notificationService.requestPermissions();

    } catch (e) {
      debugPrint('Error initializing services: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authService),
        ChangeNotifierProvider.value(value: _notificationService),
      ],
      child: Consumer<AuthService>(
        builder: (context, authService, _) {
          return MaterialApp(
            title: 'Villages Connect',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              fontFamily: 'Roboto',
              textTheme: const TextTheme(
                headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                bodyLarge: TextStyle(fontSize: 18),
                bodyMedium: TextStyle(fontSize: 16),
                bodySmall: TextStyle(fontSize: 14),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  minimumSize: const Size(88, 48),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              inputDecorationTheme: const InputDecorationTheme(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(),
              ),
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                  TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                },
              ),
            ),
            navigatorObservers: [appRouteObserver],
            home: NotificationScheduler(
              child: authService.isAuthenticated
                  ? const MainNavigation()
                  : const LoginScreen(),
            ),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegistrationScreen(),
              '/dashboard': (context) => NavigationGuard(
                    child: const HomeDashboard(),
                    isAuthenticated: authService.isAuthenticated,
                    fallbackScreen: const LoginScreen(),
                  ),
              '/events': (context) => NavigationGuard(
                    child: const EventDirectory(),
                    isAuthenticated: authService.isAuthenticated,
                    fallbackScreen: const LoginScreen(),
                  ),
              '/rec-centers': (context) => NavigationGuard(
                    child: const RecCenterDirectory(),
                    isAuthenticated: authService.isAuthenticated,
                    fallbackScreen: const LoginScreen(),
                  ),
              '/news': (context) => NavigationGuard(
                    child: const NewsFeed(),
                    isAuthenticated: authService.isAuthenticated,
                    fallbackScreen: const LoginScreen(),
                  ),
              '/profile': (context) => NavigationGuard(
                    child: const ProfileScreen(),
                    isAuthenticated: authService.isAuthenticated,
                    fallbackScreen: const LoginScreen(),
                  ),
            },
          );
        },
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    HomeDashboard(),
    EventDirectory(),
    RecCenterDirectory(),
    NewsFeed(),
    ProfileScreen(),
  ];

  static const List<String> _titles = [
    'Dashboard',
    'Events',
    'Rec Centers',
    'News',
    'Profile',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(fontSize: 24),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon!')),
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: AccessibleBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 28),
            label: 'Home',
            tooltip: 'Dashboard',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.event, size: 28),
            label: 'Events',
            tooltip: 'Community Events',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center, size: 28),
            label: 'Rec Centers',
            tooltip: 'Recreation Centers',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.article, size: 28),
            label: 'News',
            tooltip: 'Community News',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person, size: 28),
            label: 'Profile',
            tooltip: 'My Profile',
          ),
        ],
      ),
    );
  }
}