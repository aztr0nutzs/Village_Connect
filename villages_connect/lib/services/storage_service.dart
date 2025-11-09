import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Storage keys
class StorageKeys {
  static const String userSettings = 'user_settings';
  static const String cachedEvents = 'cached_events';
  static const String recentlyViewed = 'recently_viewed';
  static const String appState = 'app_state';

  // Secure storage keys
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
}

// User settings model
class UserSettings {
  final String preferredVillage;
  final List<String> favoriteRecCenters;
  final String theme;
  final int fontSize;
  final bool notificationsEnabled;
  final String language;

  const UserSettings({
    this.preferredVillage = 'The Villages',
    this.favoriteRecCenters = const [],
    this.theme = 'light',
    this.fontSize = 18,
    this.notificationsEnabled = true,
    this.language = 'en',
  });

  Map<String, dynamic> toJson() => {
        'preferredVillage': preferredVillage,
        'favoriteRecCenters': favoriteRecCenters,
        'theme': theme,
        'fontSize': fontSize,
        'notificationsEnabled': notificationsEnabled,
        'language': language,
      };

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
        preferredVillage: json['preferredVillage'] ?? 'The Villages',
        favoriteRecCenters: List<String>.from(json['favoriteRecCenters'] ?? []),
        theme: json['theme'] ?? 'light',
        fontSize: json['fontSize'] ?? 18,
        notificationsEnabled: json['notificationsEnabled'] ?? true,
        language: json['language'] ?? 'en',
      );
}

// Cached event model
class CachedEvent {
  final int id;
  final String title;
  final String description;
  final String date;
  final String time;
  final String location;
  final String category;
  final int capacity;
  final int registered;
  final bool isRegistered;
  final DateTime cachedAt;

  CachedEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.category,
    required this.capacity,
    required this.registered,
    required this.isRegistered,
    DateTime? cachedAt,
  }) : cachedAt = cachedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'date': date,
        'time': time,
        'location': location,
        'category': category,
        'capacity': capacity,
        'registered': registered,
        'isRegistered': isRegistered,
        'cachedAt': cachedAt.toIso8601String(),
      };

  factory CachedEvent.fromJson(Map<String, dynamic> json) => CachedEvent(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        date: json['date'],
        time: json['time'],
        location: json['location'],
        category: json['category'],
        capacity: json['capacity'],
        registered: json['registered'],
        isRegistered: json['isRegistered'],
        cachedAt: DateTime.parse(json['cachedAt']),
      );
}

// Recently viewed item model
class RecentlyViewedItem {
  final String type; // 'event', 'facility', 'article'
  final int id;
  final String title;
  final String subtitle;
  final DateTime viewedAt;

  RecentlyViewedItem({
    required this.type,
    required this.id,
    required this.title,
    required this.subtitle,
    DateTime? viewedAt,
  }) : viewedAt = viewedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'type': type,
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'viewedAt': viewedAt.toIso8601String(),
      };

  factory RecentlyViewedItem.fromJson(Map<String, dynamic> json) =>
      RecentlyViewedItem(
        type: json['type'],
        id: json['id'],
        title: json['title'],
        subtitle: json['subtitle'],
        viewedAt: DateTime.parse(json['viewedAt']),
      );
}

// Storage service
class StorageService extends ChangeNotifier {
  static const String _hiveBoxName = 'villages_connect_box';
  static const Duration _cacheExpiry = Duration(hours: 24); // 24 hours

  late Box _hiveBox;
  late FlutterSecureStorage _secureStorage;
  late SharedPreferences _sharedPreferences;

  bool _isInitialized = false;
  UserSettings _userSettings = const UserSettings();

  bool get isInitialized => _isInitialized;
  UserSettings get userSettings => _userSettings;

  // Initialize storage service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Hive
      await Hive.initFlutter();
      _hiveBox = await Hive.openBox(_hiveBoxName);

      // Initialize secure storage
      _secureStorage = const FlutterSecureStorage();

      // Initialize shared preferences
      _sharedPreferences = await SharedPreferences.getInstance();

      // Load user settings
      await _loadUserSettings();

      _isInitialized = true;
      notifyListeners();

      debugPrint('Storage service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing storage service: $e');
    }
  }

  // User Settings Management
  Future<void> saveUserSettings(UserSettings settings) async {
    _userSettings = settings;
    await _hiveBox.put(StorageKeys.userSettings, settings.toJson());
    notifyListeners();
  }

  Future<void> _loadUserSettings() async {
    final settingsJson = _hiveBox.get(StorageKeys.userSettings);
    if (settingsJson != null) {
      _userSettings = UserSettings.fromJson(settingsJson);
    }
  }

  Future<void> updateUserSettings({
    String? preferredVillage,
    List<String>? favoriteRecCenters,
    String? theme,
    int? fontSize,
    bool? notificationsEnabled,
    String? language,
  }) async {
    final updatedSettings = UserSettings(
      preferredVillage: preferredVillage ?? _userSettings.preferredVillage,
      favoriteRecCenters: favoriteRecCenters ?? _userSettings.favoriteRecCenters,
      theme: theme ?? _userSettings.theme,
      fontSize: fontSize ?? _userSettings.fontSize,
      notificationsEnabled: notificationsEnabled ?? _userSettings.notificationsEnabled,
      language: language ?? _userSettings.language,
    );
    await saveUserSettings(updatedSettings);
  }

  // Cached Events Management
  Future<void> cacheEvents(List<CachedEvent> events) async {
    final eventsJson = events.map((e) => e.toJson()).toList();
    await _hiveBox.put(StorageKeys.cachedEvents, eventsJson);
  }

  Future<List<CachedEvent>> getCachedEvents() async {
    final eventsJson = _hiveBox.get(StorageKeys.cachedEvents) as List<dynamic>?;
    if (eventsJson == null) return [];

    final events = eventsJson
        .map((e) => CachedEvent.fromJson(e))
        .where((event) => DateTime.now().difference(event.cachedAt) < _cacheExpiry)
        .toList();

    return events;
  }

  Future<void> clearExpiredCache() async {
    final events = await getCachedEvents();
    final validEvents = events
        .where((event) => DateTime.now().difference(event.cachedAt) < _cacheExpiry)
        .toList();
    await cacheEvents(validEvents);
  }

  // Recently Viewed Items Management
  Future<void> addRecentlyViewed(RecentlyViewedItem item) async {
    final recentItems = await getRecentlyViewed();

    // Remove if already exists
    recentItems.removeWhere((existing) =>
        existing.type == item.type && existing.id == item.id);

    // Add to beginning
    recentItems.insert(0, item);

    // Keep only last 10 items
    if (recentItems.length > 10) {
      recentItems.removeRange(10, recentItems.length);
    }

    final itemsJson = recentItems.map((i) => i.toJson()).toList();
    await _hiveBox.put(StorageKeys.recentlyViewed, itemsJson);
  }

  Future<List<RecentlyViewedItem>> getRecentlyViewed() async {
    final itemsJson = _hiveBox.get(StorageKeys.recentlyViewed) as List<dynamic>?;
    if (itemsJson == null) return [];

    return itemsJson.map((i) => RecentlyViewedItem.fromJson(i)).toList();
  }

  Future<void> clearRecentlyViewed() async {
    await _hiveBox.delete(StorageKeys.recentlyViewed);
  }

  // Secure Storage for Sensitive Data
  Future<void> saveSecureData(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> getSecureData(String key) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> deleteSecureData(String key) async {
    await _secureStorage.delete(key: key);
  }

  Future<void> saveAuthToken(String token) async {
    await saveSecureData(StorageKeys.authToken, token);
  }

  Future<String?> getAuthToken() async {
    return await getSecureData(StorageKeys.authToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await saveSecureData(StorageKeys.refreshToken, token);
  }

  Future<String?> getRefreshToken() async {
    return await getSecureData(StorageKeys.refreshToken);
  }

  Future<void> saveUserId(String userId) async {
    await saveSecureData(StorageKeys.userId, userId);
  }

  Future<String?> getUserId() async {
    return await getSecureData(StorageKeys.userId);
  }

  Future<void> clearAuthData() async {
    await deleteSecureData(StorageKeys.authToken);
    await deleteSecureData(StorageKeys.refreshToken);
    await deleteSecureData(StorageKeys.userId);
  }

  // App State Management
  Future<void> saveAppState(Map<String, dynamic> state) async {
    final stateJson = json.encode(state);
    await _sharedPreferences.setString(StorageKeys.appState, stateJson);
  }

  Future<Map<String, dynamic>> getAppState() async {
    final stateJson = _sharedPreferences.getString(StorageKeys.appState);
    if (stateJson == null) return {};

    return json.decode(stateJson);
  }

  // Utility Methods
  Future<void> clearAllData() async {
    await _hiveBox.clear();
    await _secureStorage.deleteAll();
    await _sharedPreferences.clear();
    _userSettings = const UserSettings();
    notifyListeners();
  }

  Future<void> clearCache() async {
    await _hiveBox.delete(StorageKeys.cachedEvents);
    await _hiveBox.delete(StorageKeys.recentlyViewed);
  }

  // Get storage statistics
  Future<Map<String, dynamic>> getStorageStats() async {
    final cachedEvents = await getCachedEvents();
    final recentItems = await getRecentlyViewed();

    return {
      'cachedEventsCount': cachedEvents.length,
      'recentlyViewedCount': recentItems.length,
      'userSettings': _userSettings.toJson(),
      'hasAuthToken': await getAuthToken() != null,
      'hasUserId': await getUserId() != null,
    };
  }
}