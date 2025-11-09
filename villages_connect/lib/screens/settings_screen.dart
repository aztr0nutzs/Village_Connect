import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/accessibility_service.dart';
import '../models/emergency_contact.dart';

// Settings Screen
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Appearance Section
                  _buildSectionHeader('Appearance'),
                  _buildAppearanceSettings(),

                  const SizedBox(height: 24),

                  // Notifications Section
                  _buildSectionHeader('Notifications'),
                  _buildNotificationSettings(),

                  const SizedBox(height: 24),

                  // Accessibility Section
                  _buildSectionHeader('Accessibility'),
                  _buildAccessibilitySettings(),

                  const SizedBox(height: 24),

                  // Locations Section
                  _buildSectionHeader('Saved Locations'),
                  _buildLocationSettings(),

                  const SizedBox(height: 24),

                  // About Section
                  _buildSectionHeader('About & Legal'),
                  _buildAboutSettings(),

                  const SizedBox(height: 24),

                  // Data Management Section
                  _buildSectionHeader('Data Management'),
                  _buildDataManagementSettings(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildAppearanceSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Theme Selection
            ListTile(
              title: const Text('Theme'),
              subtitle: const Text('Choose your preferred theme'),
              trailing: DropdownButton<String>(
                value: 'light', // TODO: Implement theme switching
                items: const [
                  DropdownMenuItem(value: 'light', child: Text('Light')),
                  DropdownMenuItem(value: 'dark', child: Text('Dark')),
                  DropdownMenuItem(value: 'system', child: Text('System')),
                ],
                onChanged: (value) {
                  // TODO: Implement theme switching
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Theme switching coming soon')),
                  );
                },
              ),
            ),

            const Divider(),

            // High Visibility Mode
            Consumer<AccessibilityService>(
              builder: (context, accessibility, child) {
                return SwitchListTile(
                  title: const Text('High Visibility Mode'),
                  subtitle: const Text('Pure black and white colors for maximum contrast'),
                  value: accessibility.isHighVisibilityMode,
                  onChanged: (value) async {
                    await accessibility.toggleHighVisibilityMode();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('High visibility mode ${value ? 'enabled' : 'disabled'}')),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<NotificationService>(
          builder: (context, notificationService, child) {
            if (!notificationService.isInitialized) {
              return const ListTile(
                title: Text('Loading notification settings...'),
                leading: CircularProgressIndicator(),
              );
            }

            final prefs = notificationService.preferences;

            return Column(
              children: [
                // Event Reminders
                SwitchListTile(
                  title: const Text('Event Reminders'),
                  subtitle: const Text('Get notified before saved events'),
                  value: prefs.eventReminders,
                  onChanged: (value) async {
                    await notificationService.updatePreferences(
                      prefs.copyWith(eventReminders: value),
                    );
                  },
                ),

                // Reminder Timing
                if (prefs.eventReminders)
                  ListTile(
                    title: const Text('Reminder Timing'),
                    subtitle: Text('${prefs.reminderHoursBefore} hours before event'),
                    trailing: DropdownButton<int>(
                      value: prefs.reminderHoursBefore,
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('1 hour')),
                        DropdownMenuItem(value: 6, child: Text('6 hours')),
                        DropdownMenuItem(value: 24, child: Text('24 hours')),
                        DropdownMenuItem(value: 48, child: Text('48 hours')),
                      ],
                      onChanged: (value) async {
                        if (value != null) {
                          await notificationService.updatePreferences(
                            prefs.copyWith(reminderHoursBefore: value),
                          );
                        }
                      },
                    ),
                  ),

                const Divider(),

                // Daily Digest
                SwitchListTile(
                  title: const Text('Daily Digest'),
                  subtitle: const Text('Daily summary of events and announcements'),
                  value: prefs.dailyDigest,
                  onChanged: (value) async {
                    await notificationService.updatePreferences(
                      prefs.copyWith(dailyDigest: value),
                    );
                  },
                ),

                // Digest Time
                if (prefs.dailyDigest)
                  ListTile(
                    title: const Text('Digest Time'),
                    subtitle: Text('Daily at ${prefs.digestTime}'),
                    trailing: ElevatedButton(
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                            hour: int.parse(prefs.digestTime.split(':')[0]),
                            minute: int.parse(prefs.digestTime.split(':')[1]),
                          ),
                        );
                        if (time != null) {
                          final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                          await notificationService.updatePreferences(
                            prefs.copyWith(digestTime: timeString),
                          );
                        }
                      },
                      child: const Text('Change Time'),
                    ),
                  ),

                const Divider(),

                // Push Notifications
                SwitchListTile(
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Official announcements and updates'),
                  value: prefs.pushNotifications,
                  onChanged: (value) async {
                    await notificationService.updatePreferences(
                      prefs.copyWith(pushNotifications: value),
                    );
                  },
                ),

                const Divider(),

                // Sound & Vibration
                SwitchListTile(
                  title: const Text('Sound'),
                  subtitle: const Text('Play sound with notifications'),
                  value: prefs.soundEnabled,
                  onChanged: (value) async {
                    await notificationService.updatePreferences(
                      prefs.copyWith(soundEnabled: value),
                    );
                  },
                ),

                SwitchListTile(
                  title: const Text('Vibration'),
                  subtitle: const Text('Vibrate device for notifications'),
                  value: prefs.vibrationEnabled,
                  onChanged: (value) async {
                    await notificationService.updatePreferences(
                      prefs.copyWith(vibrationEnabled: value),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAccessibilitySettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<AccessibilityService>(
          builder: (context, accessibility, child) {
            if (!accessibility.isInitialized) {
              return const ListTile(
                title: Text('Loading accessibility settings...'),
                leading: CircularProgressIndicator(),
              );
            }

            final prefs = accessibility.preferences;

            return Column(
              children: [
                // Text Size
                ListTile(
                  title: const Text('Text Size'),
                  subtitle: Text('Current: ${prefs.textSize.name}'),
                  trailing: DropdownButton<TextSize>(
                    value: prefs.textSize,
                    items: TextSize.values.map((size) {
                      return DropdownMenuItem(
                        value: size,
                        child: Text(size.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) async {
                      if (value != null) {
                        await accessibility.setTextSize(value);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Text size changed to ${value.name}')),
                        );
                      }
                    },
                  ),
                ),

                const Divider(),

                // Voice Feedback
                SwitchListTile(
                  title: const Text('Voice Feedback'),
                  subtitle: const Text('Speak headlines and important information'),
                  value: prefs.voiceFeedbackEnabled,
                  onChanged: (value) async {
                    await accessibility.toggleVoiceFeedback();
                  },
                ),

                // Text-to-Speech
                SwitchListTile(
                  title: const Text('Text-to-Speech'),
                  subtitle: const Text('Enable speech synthesis'),
                  value: prefs.textToSpeechEnabled,
                  onChanged: (value) async {
                    await accessibility.toggleTextToSpeech();
                  },
                ),

                // TTS Test Button
                if (prefs.textToSpeechEnabled)
                  ListTile(
                    title: const Text('Test Text-to-Speech'),
                    trailing: ElevatedButton(
                      onPressed: () async {
                        await accessibility.testTTS();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Testing text-to-speech...')),
                        );
                      },
                      child: const Text('Test'),
                    ),
                  ),

                const Divider(),

                // Screen Reader
                SwitchListTile(
                  title: const Text('Screen Reader Support'),
                  subtitle: const Text('Enhanced support for screen readers'),
                  value: prefs.screenReaderEnabled,
                  onChanged: (value) async {
                    await accessibility.toggleScreenReader();
                  },
                ),

                // Focus Highlight
                SwitchListTile(
                  title: const Text('Focus Highlight'),
                  subtitle: const Text('Show focus indicators for keyboard navigation'),
                  value: prefs.focusHighlightEnabled,
                  onChanged: (value) async {
                    await accessibility.toggleFocusHighlight();
                  },
                ),

                // Reduce Motion
                SwitchListTile(
                  title: const Text('Reduce Motion'),
                  subtitle: const Text('Minimize animations and transitions'),
                  value: prefs.reduceMotion,
                  onChanged: (value) async {
                    await accessibility.toggleReduceMotion();
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLocationSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              title: const Text('Saved Locations'),
              subtitle: const Text('Manage your frequently visited locations'),
              trailing: ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to location management screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Location management coming soon')),
                  );
                },
                child: const Text('Manage'),
              ),
            ),

            const Divider(),

            ListTile(
              title: const Text('Clear Location History'),
              subtitle: const Text('Remove all saved location data'),
              trailing: ElevatedButton(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear Location History'),
                      content: const Text('This will remove all saved locations. This action cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    // TODO: Implement location history clearing
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Location history cleared')),
                    );
                  }
                },
                child: const Text('Clear'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              title: const Text('Privacy Policy'),
              subtitle: const Text('Read our privacy policy'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () async {
                const url = 'https://thevillages.com/privacy-policy'; // Placeholder URL
                try {
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not open privacy policy')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error opening privacy policy')),
                  );
                }
              },
            ),

            const Divider(),

            ListTile(
              title: const Text('Terms of Service'),
              subtitle: const Text('Read our terms of service'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () async {
                const url = 'https://thevillages.com/terms-of-service'; // Placeholder URL
                try {
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not open terms of service')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error opening terms of service')),
                  );
                }
              },
            ),

            const Divider(),

            const ListTile(
              title: Text('Version'),
              subtitle: Text('Villages Connect v1.0.0'),
            ),

            const ListTile(
              title: Text('About Villages Connect'),
              subtitle: Text('A senior-friendly community app for The Villages, FL'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataManagementSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              title: const Text('Export Settings'),
              subtitle: const Text('Save your settings to a file'),
              trailing: ElevatedButton(
                onPressed: () async {
                  setState(() => _isLoading = true);
                  try {
                    // TODO: Implement settings export
                    await Future.delayed(const Duration(seconds: 1)); // Simulate export
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Settings exported successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error exporting settings: $e')),
                    );
                  } finally {
                    setState(() => _isLoading = false);
                  }
                },
                child: const Text('Export'),
              ),
            ),

            const Divider(),

            ListTile(
              title: const Text('Import Settings'),
              subtitle: const Text('Load settings from a file'),
              trailing: ElevatedButton(
                onPressed: () async {
                  // TODO: Implement settings import
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings import coming soon')),
                  );
                },
                child: const Text('Import'),
              ),
            ),

            const Divider(),

            ListTile(
              title: const Text('Reset to Defaults'),
              subtitle: const Text('Reset all settings to default values'),
              trailing: ElevatedButton(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Reset Settings'),
                      content: const Text('This will reset all settings to their default values. This action cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    setState(() => _isLoading = true);
                    try {
                      final storageService = context.read<StorageService>();
                      final notificationService = context.read<NotificationService>();
                      final accessibilityService = context.read<AccessibilityService>();

                      // Clear all stored preferences
                      await storageService.saveAppState({
                        'notification_preferences': null,
                        'accessibility_preferences': null,
                        'emergency_contacts': null,
                        // TODO: Clear other preferences as needed
                      });

                      // Reset services to defaults
                      await notificationService.updatePreferences(NotificationPreferences());
                      await accessibilityService.updatePreferences(AccessibilityPreferences());

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Settings reset to defaults')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error resetting settings: $e')),
                      );
                    } finally {
                      setState(() => _isLoading = false);
                    }
                  }
                },
                child: const Text('Reset'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ),

            const Divider(),

            ListTile(
              title: const Text('Clear All Data'),
              subtitle: const Text('Remove all app data and preferences'),
              trailing: ElevatedButton(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear All Data'),
                      content: const Text('This will permanently delete all app data, settings, and preferences. This action cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Delete All'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    setState(() => _isLoading = true);
                    try {
                      final storageService = context.read<StorageService>();
                      await storageService.clearAllData();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('All data cleared successfully')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error clearing data: $e')),
                      );
                    } finally {
                      setState(() => _isLoading = false);
                    }
                  }
                },
                child: const Text('Clear All'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}