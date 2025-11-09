import 'package:flutter/material.dart';

// Navigation guard for protecting routes
class NavigationGuard extends StatelessWidget {
  final Widget child;
  final bool isAuthenticated;
  final Widget? fallbackScreen;

  const NavigationGuard({
    Key? key,
    required this.child,
    this.isAuthenticated = true, // Default to authenticated for now
    this.fallbackScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isAuthenticated) {
      return child;
    } else {
      // Return fallback screen or default login screen
      return fallbackScreen ?? const Scaffold(
        body: Center(
          child: Text(
            'Please log in to access this feature',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }
  }
}

// Custom page transitions
class AppPageTransitions {
  static PageRouteBuilder<T> fadeTransition<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }

  static PageRouteBuilder<T> slideUpTransition<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }

  static PageRouteBuilder<T> scaleTransition<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.fastOutSlowIn,
            ),
          ),
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }
}

// Custom bottom navigation bar with better accessibility
class AccessibleBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;

  const AccessibleBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: items,
      currentIndex: currentIndex,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey,
      selectedFontSize: 14,
      unselectedFontSize: 12,
      type: BottomNavigationBarType.fixed,
      onTap: onTap,
      elevation: 8,
      // Enhanced accessibility
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
      ),
      backgroundColor: Colors.white,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    );
  }
}

// Route observer for analytics and navigation tracking
class AppRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    // Track navigation for analytics
    print('Navigated to: ${route.settings.name ?? 'Unknown'}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    // Track back navigation
    print('Navigated back from: ${route.settings.name ?? 'Unknown'}');
  }
}

// Global route observer instance
final appRouteObserver = AppRouteObserver();