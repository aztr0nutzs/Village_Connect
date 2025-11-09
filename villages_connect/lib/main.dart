import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:accessibility_tools/accessibility_tools.dart';
import 'firebase_options.dart';
import 'screens/home_dashboard.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'services/auth_service.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'services/accessibility_service.dart';
import 'services/cache_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize services
  final storageService = StorageService();
  await storageService.initialize();

  final authService = AuthService(storageService);
  final notificationService = NotificationService(storageService);
  final accessibilityService = AccessibilityService(storageService);
  final cacheService = CacheService(storageService);

  // Wait for services to initialize
  await Future.wait([
    authService._initializeAuth(),
    notificationService._initializeService(),
    accessibilityService._initializeService(),
    cacheService._initializeCache(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        ChangeNotifierProvider<AuthService>.value(value: authService),
        ChangeNotifierProvider<NotificationService>.value(value: notificationService),
        ChangeNotifierProvider<AccessibilityService>.value(value: accessibilityService),
        ChangeNotifierProvider<CacheService>.value(value: cacheService),
      ],
      child: const VillagesConnectApp(),
    ),
  );
}

class VillagesConnectApp extends StatelessWidget {
  const VillagesConnectApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AccessibilityService>(
      builder: (context, accessibility, child) {
        return MaterialApp(
          title: 'Villages Connect',
          debugShowCheckedModeBanner: false,

          // Theme configuration
          theme: _buildTheme(Brightness.light, accessibility),
          darkTheme: _buildTheme(Brightness.dark, accessibility),
          themeMode: ThemeMode.system, // TODO: Make this configurable

          // Accessibility tools for development
          builder: (context, child) => AccessibilityTools(
            child: child!,
          ),

          // Route configuration
          initialRoute: '/',
          routes: {
            '/': (context) => const AuthWrapper(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegistrationScreen(),
            '/home': (context) => const HomeDashboard(),
          },

          // Error handling
          builder: (context, widget) {
            ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
              return Material(
                child: Container(
                  color: Colors.red.shade100,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Something went wrong!',
                        style: Theme.of(context).textTheme.headline6,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        errorDetails.exception.toString(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Restart the app
                          runApp(const VillagesConnectApp());
                        },
                        child: const Text('Restart App'),
                      ),
                    ],
                  ),
                ),
              );
            };
            return widget!;
          },
        );
      },
    );
  }

  ThemeData _buildTheme(Brightness brightness, AccessibilityService accessibility) {
    final isDark = brightness == Brightness.dark;
    final highVisibilityColors = accessibility.getHighVisibilityColors();

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,

      // Color scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: isDark ? Colors.blue.shade700 : Colors.blue.shade600,
        brightness: brightness,
      ).copyWith(
        // Override with high visibility colors if enabled
        primary: highVisibilityColors['primary'] ?? (isDark ? Colors.blue.shade300 : Colors.blue.shade600),
        background: highVisibilityColors['background'] ?? (isDark ? Colors.grey.shade900 : Colors.white),
        surface: highVisibilityColors['surface'] ?? (isDark ? Colors.grey.shade800 : Colors.grey.shade50),
      ),

      // Typography with accessibility scaling
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: accessibility.getScaledFontSize(32),
          fontWeight: FontWeight.bold,
          color: highVisibilityColors['textPrimary'] ?? (isDark ? Colors.white : Colors.black87),
        ),
        headlineMedium: TextStyle(
          fontSize: accessibility.getScaledFontSize(28),
          fontWeight: FontWeight.bold,
          color: highVisibilityColors['textPrimary'] ?? (isDark ? Colors.white : Colors.black87),
        ),
        headlineSmall: TextStyle(
          fontSize: accessibility.getScaledFontSize(24),
          fontWeight: FontWeight.w600,
          color: highVisibilityColors['textPrimary'] ?? (isDark ? Colors.white : Colors.black87),
        ),
        titleLarge: TextStyle(
          fontSize: accessibility.getScaledFontSize(22),
          fontWeight: FontWeight.w600,
          color: highVisibilityColors['textPrimary'] ?? (isDark ? Colors.white : Colors.black87),
        ),
        titleMedium: TextStyle(
          fontSize: accessibility.getScaledFontSize(18),
          fontWeight: FontWeight.w500,
          color: highVisibilityColors['textPrimary'] ?? (isDark ? Colors.white : Colors.black87),
        ),
        titleSmall: TextStyle(
          fontSize: accessibility.getScaledFontSize(16),
          fontWeight: FontWeight.w500,
          color: highVisibilityColors['textSecondary'] ?? (isDark ? Colors.white70 : Colors.black54),
        ),
        bodyLarge: TextStyle(
          fontSize: accessibility.getScaledFontSize(16),
          color: highVisibilityColors['textPrimary'] ?? (isDark ? Colors.white : Colors.black87),
        ),
        bodyMedium: TextStyle(
          fontSize: accessibility.getScaledFontSize(14),
          color: highVisibilityColors['textSecondary'] ?? (isDark ? Colors.white70 : Colors.black54),
        ),
        bodySmall: TextStyle(
          fontSize: accessibility.getScaledFontSize(12),
          color: highVisibilityColors['textSecondary'] ?? (isDark ? Colors.white60 : Colors.black45),
        ),
      ),

      // Component themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, 48), // Accessibility: minimum touch target
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
      ),

      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      ),

      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Bottom navigation theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        selectedItemColor: Colors.blue.shade600,
        unselectedItemColor: isDark ? Colors.white60 : Colors.black45,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),

      // Dialog theme
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 8,
      ),

      // SnackBar theme
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Accessibility improvements
      visualDensity: VisualDensity.adaptivePlatformDensity,
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        // Show loading while determining auth state
        if (authService.authState == AuthState.initial ||
            authService.authState == AuthState.loading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading Villages Connect...'),
                ],
              ),
            ),
          );
        }

        // Show login/register if unauthenticated
        if (authService.authState == AuthState.unauthenticated) {
          return const LoginScreen();
        }

        // Show home if authenticated or guest
        return const HomeDashboard();
      },
    );
  }
}