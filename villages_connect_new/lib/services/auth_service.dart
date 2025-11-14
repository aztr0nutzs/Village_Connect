import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'storage_service.dart';

// Authentication States
enum AuthState {
  initial,
  authenticated,
  unauthenticated,
  guest,
  loading,
  error,
}

// User Model
class AppUser {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime? createdAt;
  final DateTime? lastSignInAt;
  final bool isEmailVerified;
  final bool isGuest;

  AppUser({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.createdAt,
    this.lastSignInAt,
    this.isEmailVerified = false,
    this.isGuest = false,
  });

  factory AppUser.fromFirebaseUser(User user, {bool isGuest = false}) {
    return AppUser(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      createdAt: user.metadata.creationTime,
      lastSignInAt: user.metadata.lastSignInTime,
      isEmailVerified: user.emailVerified,
      isGuest: isGuest,
    );
  }

  factory AppUser.guest() {
    return AppUser(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      email: 'guest@thevillages.com',
      displayName: 'Guest User',
      isGuest: true,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt?.toIso8601String(),
      'lastSignInAt': lastSignInAt?.toIso8601String(),
      'isEmailVerified': isEmailVerified,
      'isGuest': isGuest,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      lastSignInAt: json['lastSignInAt'] != null ? DateTime.tryParse(json['lastSignInAt']) : null,
      isEmailVerified: json['isEmailVerified'] ?? false,
      isGuest: json['isGuest'] ?? false,
    );
  }
}

// Authentication Service
class AuthService extends ChangeNotifier {
  final FlutterSecureStorage _secureStorage;
  final StorageService _storageService;
  final bool _firebaseEnabled;
  FirebaseAuth? _firebaseAuth;

  AuthState _authState = AuthState.initial;
  AppUser? _currentUser;
  String? _errorMessage;
  StreamSubscription<User?>? _authStateSubscription;
  late final Future<void> _initialization;

  static const String _userKey = 'current_user';
  static const String _guestModeKey = 'guest_mode_enabled';

  AuthService(
    this._storageService, {
    bool firebaseEnabled = true,
  })  : _firebaseEnabled = firebaseEnabled,
        _secureStorage = const FlutterSecureStorage() {
    if (_firebaseEnabled) {
      _firebaseAuth = FirebaseAuth.instance;
    }
    _initialization = _initializeAuth();
  }

  Future<void> ensureInitialized() => _initialization;

  bool get supportsFirebaseAuth => _canUseFirebaseAuth;

  Future<void> _initializeAuth() async {
    try {
      _authState = AuthState.loading;
      notifyListeners();

      if (!_canUseFirebaseAuth) {
        await _enterGuestMode();
        debugPrint('AuthService initialized in guest-only mode (Firebase unavailable).');
        return;
      }

      // Listen to auth state changes
      _authStateSubscription = _firebaseAuth!.authStateChanges().listen(
        _onAuthStateChanged,
        onError: _onAuthError,
      );

      // Check for guest mode
      final guestModeEnabled = await _secureStorage.read(key: _guestModeKey);
      if (guestModeEnabled == 'true') {
        await _enterGuestMode();
      }

      debugPrint('AuthService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing AuthService: $e');
      _authState = AuthState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  bool get _canUseFirebaseAuth => _firebaseEnabled && _firebaseAuth != null;

  bool _ensureFirebaseAvailable(String action) {
    if (_canUseFirebaseAuth) {
      return true;
    }

    _errorMessage = '$action is unavailable in guest mode on this platform.';
    _authState = AuthState.guest;
    notifyListeners();
    return false;
  }

  void _onAuthStateChanged(User? firebaseUser) {
    if (firebaseUser != null) {
      _currentUser = AppUser.fromFirebaseUser(firebaseUser);
      _authState = AuthState.authenticated;
      _saveUserData();
    } else {
      // Check if we're in guest mode
      final guestModeEnabled = _secureStorage.read(key: _guestModeKey);
      guestModeEnabled.then((enabled) {
        if (enabled == 'true' && _currentUser?.isGuest == true) {
          _authState = AuthState.guest;
        } else {
          _authState = AuthState.unauthenticated;
          _currentUser = null;
        }
        notifyListeners();
      });
    }
    notifyListeners();
  }

  void _onAuthError(Object error) {
    debugPrint('Auth state error: $error');
    _authState = AuthState.error;
    _errorMessage = error.toString();
    notifyListeners();
  }

  // Authentication Methods
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    if (!_ensureFirebaseAvailable('Email sign-in')) {
      return false;
    }

    try {
      _authState = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      final userCredential = await _firebaseAuth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        _currentUser = AppUser.fromFirebaseUser(userCredential.user!);
        _authState = AuthState.authenticated;
        await _saveUserData();
        await _exitGuestMode(); // Exit guest mode if user signs in
        notifyListeners();
        return true;
      }

      return false;
    } on FirebaseAuthException catch (e) {
      _authState = AuthState.unauthenticated;
      _errorMessage = _getFirebaseAuthErrorMessage(e);
      notifyListeners();
      return false;
    } catch (e) {
      _authState = AuthState.error;
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> createUserWithEmailAndPassword(String email, String password, {String? displayName}) async {
    if (!_ensureFirebaseAvailable('Account creation')) {
      return false;
    }

    try {
      _authState = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      final userCredential = await _firebaseAuth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Update display name if provided
        if (displayName != null && displayName.isNotEmpty) {
          await userCredential.user!.updateDisplayName(displayName);
          await userCredential.user!.reload();
        }

        // Send email verification
        await userCredential.user!.sendEmailVerification();

        _currentUser = AppUser.fromFirebaseUser(userCredential.user!);
        _authState = AuthState.authenticated;
        await _saveUserData();
        await _exitGuestMode(); // Exit guest mode if user registers
        notifyListeners();
        return true;
      }

      return false;
    } on FirebaseAuthException catch (e) {
      _authState = AuthState.unauthenticated;
      _errorMessage = _getFirebaseAuthErrorMessage(e);
      notifyListeners();
      return false;
    } catch (e) {
      _authState = AuthState.error;
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> signOut() async {
    if (!_canUseFirebaseAuth) {
      await _exitGuestMode();
      _currentUser = null;
      _authState = AuthState.unauthenticated;
      await _clearUserData();
      notifyListeners();
      return true;
    }

    try {
      await _firebaseAuth!.signOut();
      await _exitGuestMode();
      _currentUser = null;
      _authState = AuthState.unauthenticated;
      await _clearUserData();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error signing out: $e');
      _errorMessage = 'Error signing out: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Guest Mode
  Future<bool> enterGuestMode() async {
    try {
      await _enterGuestMode();
      return true;
    } catch (e) {
      debugPrint('Error entering guest mode: $e');
      _errorMessage = 'Error entering guest mode: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<void> _enterGuestMode() async {
    _currentUser = AppUser.guest();
    _authState = AuthState.guest;
    await _secureStorage.write(key: _guestModeKey, value: 'true');
    await _saveUserData();
    notifyListeners();
  }

  Future<void> _exitGuestMode() async {
    await _secureStorage.delete(key: _guestModeKey);
  }

  // Password Reset
  Future<bool> sendPasswordResetEmail(String email) async {
    if (!_ensureFirebaseAvailable('Password reset')) {
      return false;
    }

    try {
      await _firebaseAuth!.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getFirebaseAuthErrorMessage(e);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error sending password reset: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Email Verification
  Future<bool> sendEmailVerification() async {
    if (!_ensureFirebaseAvailable('Email verification')) {
      return false;
    }

    try {
      final user = _firebaseAuth!.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Error sending verification email: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> reloadUser() async {
    if (!_ensureFirebaseAvailable('Reload user')) {
      return false;
    }

    try {
      await _firebaseAuth!.currentUser?.reload();
      if (_firebaseAuth!.currentUser != null) {
        _currentUser = AppUser.fromFirebaseUser(_firebaseAuth!.currentUser!);
        await _saveUserData();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error reloading user: $e');
      return false;
    }
  }

  // Data Persistence
  Future<void> _saveUserData() async {
    if (_currentUser != null) {
      try {
        await _storageService.saveAppState({_userKey: _currentUser!.toJson()});
      } catch (e) {
        debugPrint('Error saving user data: $e');
      }
    }
  }

  Future<void> _clearUserData() async {
    try {
      await _storageService.saveAppState({_userKey: null});
    } catch (e) {
      debugPrint('Error clearing user data: $e');
    }
  }

  // Utility Methods
  String _getFirebaseAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password authentication is not enabled.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }

  // Getters
  AuthState get authState => _authState;
  AppUser? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _authState == AuthState.authenticated;
  bool get isGuest => _authState == AuthState.guest;
  bool get isLoading => _authState == AuthState.loading;
  bool get hasError => _authState == AuthState.error;

  // User Profile Updates
  Future<bool> updateDisplayName(String displayName) async {
    if (!_ensureFirebaseAvailable('Profile updates')) {
      return false;
    }

    try {
      await _firebaseAuth!.currentUser?.updateDisplayName(displayName);
      await reloadUser();
      return true;
    } catch (e) {
      _errorMessage = 'Error updating display name: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateEmail(String email) async {
    if (!_ensureFirebaseAvailable('Email updates')) {
      return false;
    }

    try {
      final user = _firebaseAuth!.currentUser;
      if (user == null) {
        _errorMessage = 'No authenticated user.';
        notifyListeners();
        return false;
      }

      await user.verifyBeforeUpdateEmail(email);
      await reloadUser();
      return true;
    } catch (e) {
      _errorMessage = 'Error updating email: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePassword(String password) async {
    if (!_ensureFirebaseAvailable('Password updates')) {
      return false;
    }

    try {
      await _firebaseAuth!.currentUser?.updatePassword(password);
      return true;
    } catch (e) {
      _errorMessage = 'Error updating password: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Account Deletion
  Future<bool> deleteAccount() async {
    if (!_ensureFirebaseAvailable('Account deletion')) {
      return false;
    }

    try {
      await _firebaseAuth!.currentUser?.delete();
      await _clearUserData();
      _currentUser = null;
      _authState = AuthState.unauthenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error deleting account: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Cleanup
  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  // Authentication Guards
  bool canAccessPremiumFeatures() {
    return isAuthenticated && !isGuest;
  }

  bool canAccessCommunityFeatures() {
    return isAuthenticated || isGuest; // Allow guest access to basic features
  }

  // Token Management (for API calls)
  Future<String?> getIdToken() async {
    if (!_canUseFirebaseAuth) {
      return null;
    }

    try {
      return await _firebaseAuth!.currentUser?.getIdToken();
    } catch (e) {
      debugPrint('Error getting ID token: $e');
      return null;
    }
  }

  Future<bool> refreshToken() async {
    if (!_canUseFirebaseAuth) {
      return false;
    }

    try {
      await _firebaseAuth!.currentUser?.getIdToken(true);
      return true;
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      return false;
    }
  }
}
