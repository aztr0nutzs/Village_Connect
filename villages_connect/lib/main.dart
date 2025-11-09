import 'package:flutter/material.dart';
import 'screens/home_dashboard.dart';
import 'screens/event_directory.dart';
import 'screens/rec_center_directory.dart';
import 'screens/news_feed.dart';
import 'widgets/navigation_guard.dart';

void main() {
  runApp(const VillagesConnectApp());
}

class VillagesConnectApp extends StatelessWidget {
  const VillagesConnectApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      home: const NavigationGuard(
        child: MainNavigation(),
        isAuthenticated: true, // For now, allow access
      ),
      routes: {
        '/dashboard': (context) => const NavigationGuard(
          child: HomeDashboard(),
          isAuthenticated: true,
        ),
        '/events': (context) => const NavigationGuard(
          child: EventDirectory(),
          isAuthenticated: true,
        ),
        '/rec-centers': (context) => const NavigationGuard(
          child: RecCenterDirectory(),
          isAuthenticated: true,
        ),
        '/news': (context) => const NavigationGuard(
          child: NewsFeed(),
          isAuthenticated: true,
        ),
      },
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
  ];

  static const List<String> _titles = [
    'Dashboard',
    'Events',
    'Rec Centers',
    'News',
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 28),
            label: 'Home',
            tooltip: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event, size: 28),
            label: 'Events',
            tooltip: 'Community Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center, size: 28),
            label: 'Rec Centers',
            tooltip: 'Recreation Centers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article, size: 28),
            label: 'News',
            tooltip: 'Community News',
          ),
        ],
      ),
    );
  }
}