import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'storage_service.dart';

// Notification Preferences Model
class NotificationPreferences {
  final bool eventReminders;
  final bool dailyDigest;
  final bool pushNotifications;
  final int reminderHoursBefore; // Hours before event to send reminder
  final String digestTime; // Time for daily digest (HH:mm format)
  final bool soundEnabled;
  final bool vibrationEnabled;

  NotificationPreferences({
    this.eventReminders = true,
    this.dailyDigest = false,
    this.pushNotifications = true,
    this.reminderHoursBefore = 24,
    this.digestTime = '08:00',
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      eventReminders: json['eventReminders'] ?? true,
      dailyDigest: json['dailyDigest'] ?? false,
      pushNotifications: json['pushNotifications'] ?? true,
      reminderHoursBefore: json['reminderHoursBefore'] ?? 24,
      digestTime: json['digestTime'] ?? '08:00',
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventReminders': eventReminders,
      'dailyDigest': dailyDigest,
      'pushNotifications': pushNotifications,
      'reminderHoursBefore': reminderHoursBefore,
      'digestTime': digestTime,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
    };
  }

  NotificationPreferences copyWith({
    bool? eventReminders,
    bool? dailyDigest,
    bool? pushNotifications,
    int? reminderHoursBefore,
    String? digestTime,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return NotificationPreferences(
      eventReminders: eventReminders ?? this.eventReminders,
      dailyDigest: dailyDigest ?? this.dailyDigest,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      reminderHoursBefore: reminderHoursBefore ?? this.reminderHoursBefore,
      digestTime: digestTime ?? this.digestTime,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }
}

// Scheduled Notification Model
class ScheduledNotification {
  final int id;
  final String title;
  final String body;
  final DateTime scheduledTime;
  final String type; // 'event_reminder', 'daily_digest', 'push_notification'
  final String? payload; // Additional data (event ID, etc.)

  ScheduledNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledTime,
    required this.type,
    this.payload,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'scheduledTime': scheduledTime.toIso8601String(),
      'type': type,
      'payload': payload,
    };
  }

  factory ScheduledNotification.fromJson(Map<String, dynamic> json) {
    return ScheduledNotification(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      scheduledTime: DateTime.parse(json['scheduledTime']),
      type: json['type'],
      payload: json['payload'],
    );
  }
}

// Notification Service
class NotificationService extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  final StorageService _storageService;

  NotificationPreferences _preferences = NotificationPreferences();
  List<ScheduledNotification> _scheduledNotifications = [];
  bool _isInitialized = false;

  static const String _preferencesKey = 'notification_preferences';
  static const String _scheduledNotificationsKey = 'scheduled_notifications';

  NotificationService(this._storageService)
      : _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin() {
    _initializeService();
  }

  Future<void> _initializeService() async {
    try {
      // Initialize timezone
      tz.initializeTimeZones();
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));

      // Initialize notifications
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
        onDidReceiveBackgroundNotificationResponse: _onDidReceiveBackgroundNotificationResponse,
      );

      // Load preferences and scheduled notifications
      await _loadPreferences();
      await _loadScheduledNotifications();

      _isInitialized = true;
      notifyListeners();

      debugPrint('NotificationService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing NotificationService: $e');
    }
  }

  // Preferences Management
  Future<void> _loadPreferences() async {
    try {
      final data = await _storageService.getAppState();
      final prefsData = data[_preferencesKey];
      if (prefsData != null) {
        _preferences = NotificationPreferences.fromJson(prefsData);
      }
    } catch (e) {
      debugPrint('Error loading notification preferences: $e');
    }
  }

  Future<void> _savePreferences() async {
    try {
      await _storageService.saveAppState({_preferencesKey: _preferences.toJson()});
    } catch (e) {
      debugPrint('Error saving notification preferences: $e');
    }
  }

  Future<void> updatePreferences(NotificationPreferences newPreferences) async {
    _preferences = newPreferences;
    await _savePreferences();

    // Update scheduled notifications based on new preferences
    await _updateScheduledNotifications();

    notifyListeners();
  }

  NotificationPreferences get preferences => _preferences;

  // Scheduled Notifications Management
  Future<void> _loadScheduledNotifications() async {
    try {
      final data = await _storageService.getAppState();
      final notificationsData = data[_scheduledNotificationsKey];
      if (notificationsData != null && notificationsData is List) {
        _scheduledNotifications = notificationsData
            .map((json) => ScheduledNotification.fromJson(json))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading scheduled notifications: $e');
    }
  }

  Future<void> _saveScheduledNotifications() async {
    try {
      final notificationsJson = _scheduledNotifications.map((n) => n.toJson()).toList();
      await _storageService.saveAppState({_scheduledNotificationsKey: notificationsJson});
    } catch (e) {
      debugPrint('Error saving scheduled notifications: $e');
    }
  }

  // Event Reminder Scheduling
  Future<void> scheduleEventReminder({
    required String eventId,
    required String eventTitle,
    required DateTime eventDateTime,
  }) async {
    if (!preferences.eventReminders) return;

    final reminderTime = eventDateTime.subtract(
      Duration(hours: preferences.reminderHoursBefore),
    );

    // Don't schedule if reminder time is in the past
    if (reminderTime.isBefore(DateTime.now())) return;

    final notificationId = _generateNotificationId('event_$eventId');
    final notification = ScheduledNotification(
      id: notificationId,
      title: 'Event Reminder',
      body: '$eventTitle starts in ${preferences.reminderHoursBefore} hours',
      scheduledTime: reminderTime,
      type: 'event_reminder',
      payload: eventId,
    );

    await _scheduleNotification(notification);
    _scheduledNotifications.add(notification);
    await _saveScheduledNotifications();
  }

  Future<void> cancelEventReminder(String eventId) async {
    final notificationId = _generateNotificationId('event_$eventId');
    await _flutterLocalNotificationsPlugin.cancel(notificationId);

    _scheduledNotifications.removeWhere((n) => n.id == notificationId && n.type == 'event_reminder');
    await _saveScheduledNotifications();
  }

  // Daily Digest Scheduling
  Future<void> scheduleDailyDigest() async {
    if (!preferences.dailyDigest) {
      await cancelDailyDigest();
      return;
    }

    final now = DateTime.now();
    final digestTimeParts = preferences.digestTime.split(':');
    final digestHour = int.parse(digestTimeParts[0]);
    final digestMinute = int.parse(digestTimeParts[1]);

    var digestTime = DateTime(now.year, now.month, now.day, digestHour, digestMinute);
    if (digestTime.isBefore(now)) {
      // Schedule for tomorrow
      digestTime = digestTime.add(const Duration(days: 1));
    }

    final notificationId = _generateNotificationId('daily_digest');
    final notification = ScheduledNotification(
      id: notificationId,
      title: 'Daily Digest',
      body: 'Check out today\'s events and announcements in The Villages',
      scheduledTime: digestTime,
      type: 'daily_digest',
    );

    await _scheduleNotification(notification);

    // Remove old daily digest notifications
    _scheduledNotifications.removeWhere((n) => n.type == 'daily_digest');
    _scheduledNotifications.add(notification);
    await _saveScheduledNotifications();
  }

  Future<void> cancelDailyDigest() async {
    final notificationId = _generateNotificationId('daily_digest');
    await _flutterLocalNotificationsPlugin.cancel(notificationId);

    _scheduledNotifications.removeWhere((n) => n.type == 'daily_digest');
    await _saveScheduledNotifications();
  }

  // Push Notification for Official Updates
  Future<void> showPushNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!preferences.pushNotifications) return;

    const notificationId = 999999; // Use a high ID for push notifications
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'official_updates',
        'Official Updates',
        channelDescription: 'Official announcements and updates from The Villages',
        importance: Importance.high,
        priority: Priority.high,
        sound: preferences.soundEnabled ? null : null,
        enableVibration: preferences.vibrationEnabled,
      ),
      iOS: DarwinNotificationDetails(
        sound: preferences.soundEnabled ? null : null,
        presentAlert: true,
        presentBadge: true,
        presentSound: preferences.soundEnabled,
      ),
    );

    await _flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Notification Scheduling Helper
  Future<void> _scheduleNotification(ScheduledNotification notification) async {
    final scheduledDate = tz.TZDateTime.from(notification.scheduledTime, tz.local);

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'scheduled_notifications',
        'Scheduled Notifications',
        channelDescription: 'Scheduled reminders and notifications',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      notification.id,
      notification.title,
      notification.body,
      scheduledDate,
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: notification.payload,
    );
  }

  // Update all scheduled notifications based on current preferences
  Future<void> _updateScheduledNotifications() async {
    // Cancel all existing notifications
    await _flutterLocalNotificationsPlugin.cancelAll();

    // Clear scheduled notifications list
    _scheduledNotifications.clear();

    // Re-schedule based on preferences
    if (preferences.dailyDigest) {
      await scheduleDailyDigest();
    }

    // Note: Event reminders would need to be re-scheduled from saved events
    // This would be called when the app loads saved events

    await _saveScheduledNotifications();
  }

  // Notification Response Handlers
  void _onDidReceiveNotificationResponse(NotificationResponse notificationResponse) {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      debugPrint('Notification tapped with payload: $payload');
      // Handle navigation based on payload (event ID, etc.)
      // This would typically trigger navigation to relevant screens
    }
  }

  void _onDidReceiveBackgroundNotificationResponse(NotificationResponse notificationResponse) {
    // Handle background notification response
    debugPrint('Background notification response: ${notificationResponse.payload}');
  }

  // Utility Methods
  int _generateNotificationId(String prefix) {
    // Generate a unique ID based on prefix and current time
    return prefix.hashCode + DateTime.now().millisecondsSinceEpoch.hashCode;
  }

  // Get scheduled notifications for display
  List<ScheduledNotification> getScheduledNotifications() {
    return List.unmodifiable(_scheduledNotifications);
  }

  // Check if notifications are initialized
  bool get isInitialized => _isInitialized;

  // Request permissions (call this from UI when needed)
  Future<bool> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final bool? granted = await androidImplementation?.requestPermission();
    return granted ?? false;
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    _scheduledNotifications.clear();
    await _saveScheduledNotifications();
  }

  // Get pending notifications count
  Future<int> getPendingNotificationsCount() async {
    final pending = await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return pending.length;
  }
}