import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'storage_service.dart';

// Cache Configuration
class CacheConfig {
  static const Duration defaultCacheDuration = Duration(days: 7);
  static const Duration eventCacheDuration = Duration(hours: 1);
  static const Duration mapCacheDuration = Duration(days: 30);
  static const String eventsCacheKey = 'cached_events';
  static const String centersCacheKey = 'cached_centers';
  static const String mapsCacheKey = 'cached_maps';
  static const String staticDataCacheKey = 'cached_static_data';
}

// Cached Data Models
class CachedEventsData {
  final List<Map<String, dynamic>> events;
  final DateTime cachedAt;
  final DateTime? expiresAt;

  CachedEventsData({
    required this.events,
    required this.cachedAt,
    this.expiresAt,
  });

  factory CachedEventsData.fromJson(Map<String, dynamic> json) {
    return CachedEventsData(
      events: List<Map<String, dynamic>>.from(json['events'] ?? []),
      cachedAt: DateTime.parse(json['cachedAt']),
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'events': events,
      'cachedAt': cachedAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  bool get isExpired {
    return expiresAt?.isBefore(DateTime.now()) ?? false;
  }
}

class CachedCentersData {
  final List<Map<String, dynamic>> centers;
  final DateTime cachedAt;
  final DateTime? expiresAt;

  CachedCentersData({
    required this.centers,
    required this.cachedAt,
    this.expiresAt,
  });

  factory CachedCentersData.fromJson(Map<String, dynamic> json) {
    return CachedCentersData(
      centers: List<Map<String, dynamic>>.from(json['centers'] ?? []),
      cachedAt: DateTime.parse(json['cachedAt']),
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'centers': centers,
      'cachedAt': cachedAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  bool get isExpired {
    return expiresAt?.isBefore(DateTime.now()) ?? false;
  }
}

class CachedMapsData {
  final List<Map<String, dynamic>> mapData;
  final DateTime cachedAt;
  final DateTime? expiresAt;

  CachedMapsData({
    required this.mapData,
    required this.cachedAt,
    this.expiresAt,
  });

  factory CachedMapsData.fromJson(Map<String, dynamic> json) {
    return CachedMapsData(
      mapData: List<Map<String, dynamic>>.from(json['mapData'] ?? []),
      cachedAt: DateTime.parse(json['cachedAt']),
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mapData': mapData,
      'cachedAt': cachedAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  bool get isExpired {
    return expiresAt?.isBefore(DateTime.now()) ?? false;
  }
}

// Cache Service
class CacheService extends ChangeNotifier {
  final StorageService _storageService;
  final DefaultCacheManager _cacheManager;
  final Connectivity _connectivity;

  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  bool _isOnline = false;

  // Cached data
  CachedEventsData? _eventsData;
  CachedCentersData? _centersData;
  CachedMapsData? _mapsData;

  CacheService(this._storageService)
      : _cacheManager = DefaultCacheManager(),
        _connectivity = Connectivity() {
    _initializeCache();
  }

  Future<void> _initializeCache() async {
    try {
      // Initialize connectivity monitoring
      _connectivityResult = await _connectivity.checkConnectivity();
      _isOnline = _connectivityResult != ConnectivityResult.none;

      // Listen to connectivity changes
      _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);

      // Load cached data
      await _loadCachedData();

      debugPrint('CacheService initialized successfully. Online: $_isOnline');
    } catch (e) {
      debugPrint('Error initializing CacheService: $e');
    }
  }

  void _onConnectivityChanged(ConnectivityResult result) {
    final wasOnline = _isOnline;
    _connectivityResult = result;
    _isOnline = result != ConnectivityResult.none;

    if (!wasOnline && _isOnline) {
      // Came back online - trigger sync
      _syncDataWhenOnline();
    }

    notifyListeners();
    debugPrint('Connectivity changed: $_connectivityResult, Online: $_isOnline');
  }

  Future<void> _syncDataWhenOnline() async {
    try {
      // Sync expired or missing data
      if (_eventsData?.isExpired ?? true) {
        await refreshEventsCache();
      }
      if (_centersData?.isExpired ?? true) {
        await refreshCentersCache();
      }
      if (_mapsData?.isExpired ?? true) {
        await refreshMapsCache();
      }
    } catch (e) {
      debugPrint('Error syncing data when online: $e');
    }
  }

  // Connectivity Status
  ConnectivityResult get connectivityResult => _connectivityResult;
  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;

  // Events Cache Management
  Future<void> _loadCachedData() async {
    try {
      final cachedData = await _storageService.getAppState();

      // Load events data
      final eventsJson = cachedData[CacheConfig.eventsCacheKey];
      if (eventsJson != null) {
        _eventsData = CachedEventsData.fromJson(eventsJson);
      }

      // Load centers data
      final centersJson = cachedData[CacheConfig.centersCacheKey];
      if (centersJson != null) {
        _centersData = CachedCentersData.fromJson(centersJson);
      }

      // Load maps data
      final mapsJson = cachedData[CacheConfig.mapsCacheKey];
      if (mapsJson != null) {
        _mapsData = CachedMapsData.fromJson(mapsJson);
      }
    } catch (e) {
      debugPrint('Error loading cached data: $e');
    }
  }

  Future<void> _saveCachedData() async {
    try {
      final cachedData = <String, dynamic>{};

      if (_eventsData != null) {
        cachedData[CacheConfig.eventsCacheKey] = _eventsData!.toJson();
      }
      if (_centersData != null) {
        cachedData[CacheConfig.centersCacheKey] = _centersData!.toJson();
      }
      if (_mapsData != null) {
        cachedData[CacheConfig.mapsCacheKey] = _mapsData!.toJson();
      }

      await _storageService.saveAppState(cachedData);
    } catch (e) {
      debugPrint('Error saving cached data: $e');
    }
  }

  // Events Cache
  Future<List<Map<String, dynamic>>> getEventsData({bool forceRefresh = false}) async {
    if (forceRefresh || (_eventsData?.isExpired ?? true)) {
      if (_isOnline) {
        await refreshEventsCache();
      } else if (_eventsData == null) {
        // Return default events if offline and no cache
        return _getDefaultEventsData();
      }
    }

    return _eventsData?.events ?? _getDefaultEventsData();
  }

  Future<void> refreshEventsCache() async {
    if (!_isOnline) return;

    try {
      // TODO: Replace with actual API call
      final eventsData = await _fetchEventsFromAPI();

      _eventsData = CachedEventsData(
        events: eventsData,
        cachedAt: DateTime.now(),
        expiresAt: DateTime.now().add(CacheConfig.eventCacheDuration),
      );

      await _saveCachedData();
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing events cache: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchEventsFromAPI() async {
    // TODO: Implement actual API call
    // For now, return default data
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    return _getDefaultEventsData();
  }

  List<Map<String, dynamic>> _getDefaultEventsData() {
    return [
      {
        'id': '1',
        'title': 'Monthly Community Meeting',
        'description': 'Join us for our monthly community meeting...',
        'date': '2024-01-25',
        'time': '2:00 PM - 4:00 PM',
        'location': 'Clubhouse Main Hall',
        'category': 'social',
      },
      // Add more default events...
    ];
  }

  // Centers Cache
  Future<List<Map<String, dynamic>>> getCentersData({bool forceRefresh = false}) async {
    if (forceRefresh || (_centersData?.isExpired ?? true)) {
      if (_isOnline) {
        await refreshCentersCache();
      } else if (_centersData == null) {
        return _getDefaultCentersData();
      }
    }

    return _centersData?.centers ?? _getDefaultCentersData();
  }

  Future<void> refreshCentersCache() async {
    if (!_isOnline) return;

    try {
      final centersData = await _fetchCentersFromAPI();

      _centersData = CachedCentersData(
        centers: centersData,
        cachedAt: DateTime.now(),
        expiresAt: DateTime.now().add(CacheConfig.defaultCacheDuration),
      );

      await _saveCachedData();
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing centers cache: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCentersFromAPI() async {
    await Future.delayed(const Duration(seconds: 1));
    return _getDefaultCentersData();
  }

  List<Map<String, dynamic>> _getDefaultCentersData() {
    return [
      {
        'id': '1',
        'name': 'The Villages Clubhouse',
        'address': '123 Main St, The Villages, FL',
        'phone': '(352) 555-0123',
        'services': ['events', 'dining', 'activities'],
      },
      // Add more default centers...
    ];
  }

  // Maps Cache
  Future<List<Map<String, dynamic>>> getMapsData({bool forceRefresh = false}) async {
    if (forceRefresh || (_mapsData?.isExpired ?? true)) {
      if (_isOnline) {
        await refreshMapsCache();
      } else if (_mapsData == null) {
        return _getDefaultMapsData();
      }
    }

    return _mapsData?.mapData ?? _getDefaultMapsData();
  }

  Future<void> refreshMapsCache() async {
    if (!_isOnline) return;

    try {
      final mapsData = await _fetchMapsFromAPI();

      _mapsData = CachedMapsData(
        mapData: mapsData,
        cachedAt: DateTime.now(),
        expiresAt: DateTime.now().add(CacheConfig.mapCacheDuration),
      );

      await _saveCachedData();
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing maps cache: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchMapsFromAPI() async {
    await Future.delayed(const Duration(seconds: 1));
    return _getDefaultMapsData();
  }

  List<Map<String, dynamic>> _getDefaultMapsData() {
    return [
      {
        'id': '1',
        'name': 'The Villages Map',
        'url': 'https://example.com/map.jpg',
        'bounds': {'north': 28.95, 'south': 28.85, 'east': -81.9, 'west': -82.0},
      },
      // Add more map data...
    ];
  }

  // Image Caching
  Future<File?> getCachedImage(String imageUrl) async {
    try {
      final fileInfo = await _cacheManager.getFileFromCache(imageUrl);
      if (fileInfo != null && fileInfo.validTill.isAfter(DateTime.now())) {
        return fileInfo.file;
      }

      // Download and cache the image
      final file = await _cacheManager.downloadFile(imageUrl);
      return file.file;
    } catch (e) {
      debugPrint('Error caching image $imageUrl: $e');
      return null;
    }
  }

  Future<void> preloadImages(List<String> imageUrls) async {
    try {
      await Future.wait(
        imageUrls.map((url) => _cacheManager.downloadFile(url)),
      );
    } catch (e) {
      debugPrint('Error preloading images: $e');
    }
  }

  // Asset Preloading
  Future<void> preloadAssets(List<String> assetPaths) async {
    try {
      // Preload critical assets
      for (final assetPath in assetPaths) {
        // TODO: Implement asset preloading logic
        debugPrint('Preloading asset: $assetPath');
      }
    } catch (e) {
      debugPrint('Error preloading assets: $e');
    }
  }

  // Cache Management
  Future<void> clearAllCache() async {
    try {
      await _cacheManager.emptyCache();
      _eventsData = null;
      _centersData = null;
      _mapsData = null;
      await _saveCachedData();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  Future<void> clearExpiredCache() async {
    try {
      if (_eventsData?.isExpired ?? false) _eventsData = null;
      if (_centersData?.isExpired ?? false) _centersData = null;
      if (_mapsData?.isExpired ?? false) _mapsData = null;
      await _saveCachedData();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing expired cache: $e');
    }
  }

  // Cache Statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final cacheStats = await _cacheManager.getFileCount();
      final cacheSize = await _cacheManager.getCacheSize();

      return {
        'fileCount': cacheStats,
        'cacheSize': cacheSize,
        'eventsCached': _eventsData != null,
        'centersCached': _centersData != null,
        'mapsCached': _mapsData != null,
        'isOnline': _isOnline,
        'connectivity': _connectivityResult.toString(),
      };
    } catch (e) {
      debugPrint('Error getting cache stats: $e');
      return {};
    }
  }

  // Background Sync
  Future<void> performBackgroundSync() async {
    if (!_isOnline) return;

    try {
      await Future.wait([
        refreshEventsCache(),
        refreshCentersCache(),
        refreshMapsCache(),
      ]);
    } catch (e) {
      debugPrint('Error performing background sync: $e');
    }
  }

  // Error Handling for Offline States
  Future<T> handleOfflineRequest<T>(
    Future<T> Function() onlineRequest,
    T Function() offlineFallback,
  ) async {
    if (_isOnline) {
      try {
        return await onlineRequest();
      } catch (e) {
        debugPrint('Online request failed, falling back to offline: $e');
        return offlineFallback();
      }
    } else {
      return offlineFallback();
    }
  }

  // Cleanup
  Future<void> dispose() async {
    await _cacheManager.dispose();
    super.dispose();
  }
}