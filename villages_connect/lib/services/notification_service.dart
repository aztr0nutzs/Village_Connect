import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

// Notification preferences
class NotificationPreferences {
  final bool eventReminders;
  final bool emergencyAlerts;
  final bool communityAnnouncements;
  final bool messageNotifications;
  final bool dailyDigest;

  const NotificationPreferences({
    this.eventReminders = true,
    this.emergencyAlerts = true,
    this.communityAnnouncements = true,
    this.messageNotifications = true,
    this.dailyDigest = false,
  });

  NotificationPreferences copyWith({
    bool? eventReminders,
    bool? emergencyAlerts,
    bool? communityAnnouncements,
    bool? messageNotifications,
    bool? dailyDigest,
  }) {
    return NotificationPreferences(
      eventReminders: eventReminders ?? this.eventReminders,
      emergencyAlerts: emergencyAlerts ?? this.emergencyAlerts,
      communityAnnouncements: communityAnnouncements ?? this.communityAnnouncements,
      messageNotifications: messageNotifications ?? this.messageNotifications,
      dailyDigest: dailyDigest ?? this.dailyDigest,
    );
  }

  Map<String, dynamic> toJson() => {
        'eventReminders': eventReminders,
        'emergencyAlerts': emergencyAlerts,
        'communityAnnouncements': communityAnnouncements,
        'messageNotifications': messageNotifications,
        'dailyDigest': dailyDigest,
      };

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      NotificationPreferences(
        eventReminders: json['eventReminders'] ?? true,
        emergencyAlerts: json['emergencyAlerts'] ?? true,
        communityAnnouncements: json['communityAnnouncements'] ?? true,
        messageNotifications: json['messageNotifications'] ?? true,
        dailyDigest: json['dailyDigest'] ?? false,
      );
}

// Notification service
class NotificationService extends ChangeNotifier {
  static const String _preferencesKey = 'notification_preferences';

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  NotificationPreferences _preferences = const NotificationPreferences();
  bool _isInitialized = false;

  NotificationPreferences get preferences => _preferences;
  bool get isInitialized => _isInitialized;

  // Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize local notifications
      await _initializeLocalNotifications();

      // Initialize Firebase messaging
      await _initializeFirebaseMessaging();

      // Load saved preferences
      await _loadPreferences();

      _isInitialized = true;
      notifyListeners();

      debugPrint('Notification service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing notification service: $e');
    }
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const LinuxInitializationSettings linuxSettings =
        LinuxInitializationSettings(defaultActionName: 'Open notification');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      linux: linuxSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    await _createNotificationChannels();
  }

  // Create notification channels
  Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel eventsChannel = AndroidNotificationChannel(
      'events_channel',
      'Event Reminders',
      description: 'Reminders for upcoming community events',
      importance: Importance.high,
      playSound: true,
    );

    const AndroidNotificationChannel emergencyChannel = AndroidNotificationChannel(
      'emergency_channel',
      'Emergency Alerts',
      description: 'Critical emergency notifications',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    const AndroidNotificationChannel announcementsChannel = AndroidNotificationChannel(
      'announcements_channel',
      'Community Announcements',
      description: 'General community news and updates',
      importance: Importance.default_,
      playSound: true,
    );

    const AndroidNotificationChannel messagesChannel = AndroidNotificationChannel(
      'messages_channel',
      'Messages',
      description: 'New messages and replies',
      importance: Importance.default_,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(eventsChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(emergencyChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(announcementsChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(messagesChannel);
  }

  // Initialize Firebase messaging
  Future<void> _initializeFirebaseMessaging() async {
    // Request permission for iOS
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM token
    final fcmToken = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $fcmToken');

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_onMessageReceived);

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
  }

  // Request notification permissions
  Future<bool> requestPermissions() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted = await androidImplementation?.requestPermission();
      return granted ?? false;
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      return false;
    }
  }

  // Show a local notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? channelId,
    int? id,
    String? payload,
  }) async {
    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'default_channel',
        'Default',
        channelDescription: 'Default notification channel',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      linux: LinuxNotificationDetails(),
    );

    await _localNotifications.show(
      id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Schedule a notification
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? channelId,
    int? id,
    String? payload,
  }) async {
    final tz.TZDateTime scheduledTZDate = tz.TZDateTime.from(
      scheduledDate,
      tz.local,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'events_channel',
        'Event Reminders',
        channelDescription: 'Reminders for upcoming community events',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      linux: LinuxNotificationDetails(),
    );

    await _localNotifications.zonedSchedule(
      id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      scheduledTZDate,
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  // Cancel a scheduled notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  // Update notification preferences
  Future<void> updatePreferences(NotificationPreferences newPreferences) async {
    _preferences = newPreferences;
    await _savePreferences();
    notifyListeners();
  }

  // Load preferences from storage
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final preferencesJson = prefs.getString(_preferencesKey);

      if (preferencesJson != null) {
        _preferences = NotificationPreferences.fromJson(
          json.decode(preferencesJson),
        );
      }
    } catch (e) {
      debugPrint('Error loading notification preferences: $e');
    }
  }

  // Save preferences to storage
  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _preferencesKey,
        json.encode(_preferences.toJson()),
      );
    } catch (e) {
      debugPrint('Error saving notification preferences: $e');
    }
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Handle navigation based on payload
  }

  // Handle Firebase message received
  static Future<void> _onMessageReceived(RemoteMessage message) async {
    debugPrint('Received Firebase message: ${message.notification?.title}');

    // Show local notification for foreground messages
    final FlutterLocalNotificationsPlugin localNotifications =
        FlutterLocalNotificationsPlugin();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'announcements_channel',
        'Community Announcements',
        channelDescription: 'General community news and updates',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification?.title ?? 'Notification',
      message.notification?.body ?? '',
      notificationDetails,
      payload: json.encode(message.data),
    );
  }

  // Handle Firebase message opened app
  void _onMessageOpenedApp(RemoteMessage message) {
    debugPrint('Message opened app: ${message.notification?.title}');
    // Handle navigation based on message data
  }

  // Send a test notification
  Future<void> sendTestNotification() async {
    await showNotification(
      title: 'Test Notification',
      body: 'This is a test notification from Villages Connect!',
      channelId: 'default_channel',
    );
  }

  // Schedule event reminder
  Future<void> scheduleEventReminder({
    required String eventTitle,
    required DateTime eventDate,
    int minutesBefore = 60,
  }) async {
    if (!preferences.eventReminders) return;

    final reminderDate = eventDate.subtract(Duration(minutes: minutesBefore));

    if (reminderDate.isAfter(DateTime.now())) {
      await scheduleNotification(
        title: 'Event Reminder',
        body: '$eventTitle starts in ${minutesBefore ~/ 60} hour${minutesBefore ~/ 60 == 1 ? '' : 's'}',
        scheduledDate: reminderDate,
        channelId: 'events_channel',
      );
    }
  }

  // Send emergency alert
  Future<void> sendEmergencyAlert({
    required String title,
    required String message,
  }) async {
    if (!preferences.emergencyAlerts) return;

    await showNotification(
      title: title,
      body: message,
      channelId: 'emergency_channel',
    );
  }

  // Send community announcement
  Future<void> sendCommunityAnnouncement({
    required String title,
    required String message,
  }) async {
    if (!preferences.communityAnnouncements) return;

    await showNotification(
      title: title,
      body: message,
      channelId: 'announcements_channel',
    );
  }
}

// Firebase background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
}