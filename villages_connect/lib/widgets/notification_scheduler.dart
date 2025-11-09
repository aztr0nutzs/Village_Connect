import 'dart:async';
import 'package:flutter/material.dart';
import '../services/notification_service.dart';

// Notification scheduler widget
class NotificationScheduler extends StatefulWidget {
  final Widget child;

  const NotificationScheduler({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<NotificationScheduler> createState() => _NotificationSchedulerState();
}

class _NotificationSchedulerState extends State<NotificationScheduler> {
  Timer? _dailyDigestTimer;
  Timer? _eventReminderTimer;

  @override
  void initState() {
    super.initState();
    _scheduleRecurringNotifications();
  }

  @override
  void dispose() {
    _dailyDigestTimer?.cancel();
    _eventReminderTimer?.cancel();
    super.dispose();
  }

  // Schedule recurring notifications
  void _scheduleRecurringNotifications() {
    final notificationService = NotificationService();

    // Schedule daily digest (if enabled)
    _scheduleDailyDigest(notificationService);

    // Schedule event reminders (demo)
    _scheduleEventReminders(notificationService);
  }

  // Schedule daily community digest
  void _scheduleDailyDigest(NotificationService notificationService) {
    // Calculate time until 8 AM tomorrow
    final now = DateTime.now();
    final tomorrow8AM = DateTime(now.year, now.month, now.day + 1, 8, 0, 0);

    final durationUntil8AM = tomorrow8AM.difference(now);

    _dailyDigestTimer = Timer(durationUntil8AM, () {
      if (notificationService.preferences.dailyDigest) {
        notificationService.sendCommunityAnnouncement(
          title: 'Daily Community Digest',
          message: 'Check out today\'s community events and announcements!',
        );
      }

      // Reschedule for next day
      _scheduleDailyDigest(notificationService);
    });
  }

  // Schedule demo event reminders
  void _scheduleEventReminders(NotificationService notificationService) {
    // Demo: Schedule reminder for "Monthly Community Meeting" (assuming it's in 2 hours)
    final eventTime = DateTime.now().add(const Duration(hours: 2));

    notificationService.scheduleEventReminder(
      eventTitle: 'Monthly Community Meeting',
      eventDate: eventTime,
      minutesBefore: 60, // 1 hour before
    );

    // Demo: Schedule reminder for "Senior Fitness Class" (assuming it's tomorrow)
    final tomorrowFitness = DateTime.now().add(const Duration(days: 1, hours: 9, minutes: 30));

    notificationService.scheduleEventReminder(
      eventTitle: 'Senior Fitness Class',
      eventDate: tomorrowFitness,
      minutesBefore: 30, // 30 minutes before
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// Demo notification trigger buttons (for testing)
class NotificationDemoButtons extends StatelessWidget {
  const NotificationDemoButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notificationService = NotificationService();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification Demo',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => notificationService.sendTestNotification(),
                  icon: const Icon(Icons.notifications),
                  label: const Text('Test Notification'),
                ),
                ElevatedButton.icon(
                  onPressed: () => notificationService.sendEmergencyAlert(
                    title: 'Emergency Alert Demo',
                    message: 'This is a test emergency notification.',
                  ),
                  icon: const Icon(Icons.warning, color: Colors.white),
                  label: const Text('Emergency Alert'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => notificationService.sendCommunityAnnouncement(
                    title: 'Community Update',
                    message: 'New events have been added to the calendar!',
                  ),
                  icon: const Icon(Icons.campaign),
                  label: const Text('Announcement'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    final eventTime = DateTime.now().add(const Duration(minutes: 2));
                    notificationService.scheduleEventReminder(
                      eventTitle: 'Demo Event',
                      eventDate: eventTime,
                      minutesBefore: 1,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Event reminder scheduled for 1 minute from now')),
                    );
                  },
                  icon: const Icon(Icons.schedule),
                  label: const Text('Schedule Reminder'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}