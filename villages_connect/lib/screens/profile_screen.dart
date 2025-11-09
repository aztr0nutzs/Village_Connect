import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

// Profile Screen
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final storageService = context.read<StorageService>();

    // Load from storage service if available, otherwise use defaults
    _firstNameController.text = 'John';
    _lastNameController.text = 'Doe';
    _phoneController.text = '(352) 555-0123';
    _addressController.text = '123 Palm Drive, The Villages, FL 32162';

    // In a real app, this would load from the storage service
    // final userData = await storageService.getUserData();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Here you would call AuthService.updateProfile()
    // For demo, just show success
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      setState(() => _isEditing = false);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Cancel editing - reload original data
        _loadUserData();
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: _toggleEdit,
            tooltip: _isEditing ? 'Cancel' : 'Edit Profile',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 3,
                  ),
                ),
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Theme.of(context).primaryColor,
                ),
              ),

              const SizedBox(height: 24),

              // User Info Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Name Fields
                      if (_isEditing) ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _firstNameController,
                                decoration: const InputDecoration(
                                  labelText: 'First Name',
                                  border: OutlineInputBorder(),
                                ),
                                style: const TextStyle(fontSize: 18),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _lastNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Last Name',
                                  border: OutlineInputBorder(),
                                ),
                                style: const TextStyle(fontSize: 18),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ] else ...[
                        Text(
                          '${_firstNameController.text} ${_lastNameController.text}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'demo@villagesconnect.com',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Phone Field
                      if (_isEditing) ...[
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            prefixIcon: Icon(Icons.phone),
                            border: OutlineInputBorder(),
                          ),
                          style: const TextStyle(fontSize: 18),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                      ] else ...[
                        ListTile(
                          leading: const Icon(Icons.phone),
                          title: const Text('Phone'),
                          subtitle: Text(_phoneController.text),
                        ),
                      ],

                      // Address Field
                      if (_isEditing) ...[
                        TextFormField(
                          controller: _addressController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Address',
                            prefixIcon: Icon(Icons.home),
                            border: OutlineInputBorder(),
                          ),
                          style: const TextStyle(fontSize: 18),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                      ] else ...[
                        ListTile(
                          leading: const Icon(Icons.home),
                          title: const Text('Address'),
                          subtitle: Text(_addressController.text),
                        ),
                      ],

                      // Member Since
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Member Since'),
                        subtitle: const Text('November 2024'),
                      ),

                      // Account Status
                      ListTile(
                        leading: const Icon(Icons.verified_user, color: Colors.green),
                        title: const Text('Account Status'),
                        subtitle: const Text('Active Member'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Action Buttons
              if (_isEditing) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _toggleEdit,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.grey),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Quick Actions
                Column(
                  children: [
                    Consumer<NotificationService>(
                      builder: (context, notificationService, child) {
                        return ExpansionTile(
                          leading: const Icon(Icons.notifications),
                          title: const Text('Notification Settings'),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Column(
                                children: [
                                  SwitchListTile(
                                    title: const Text('Event Reminders'),
                                    subtitle: const Text('Get notified about upcoming events'),
                                    value: notificationService.preferences.eventReminders,
                                    onChanged: (value) {
                                      final newPrefs = notificationService.preferences.copyWith(eventReminders: value);
                                      notificationService.updatePreferences(newPrefs);
                                    },
                                  ),
                                  SwitchListTile(
                                    title: const Text('Emergency Alerts'),
                                    subtitle: const Text('Critical emergency notifications'),
                                    value: notificationService.preferences.emergencyAlerts,
                                    onChanged: (value) {
                                      final newPrefs = notificationService.preferences.copyWith(emergencyAlerts: value);
                                      notificationService.updatePreferences(newPrefs);
                                    },
                                  ),
                                  SwitchListTile(
                                    title: const Text('Community Announcements'),
                                    subtitle: const Text('News and updates from the community'),
                                    value: notificationService.preferences.communityAnnouncements,
                                    onChanged: (value) {
                                      final newPrefs = notificationService.preferences.copyWith(communityAnnouncements: value);
                                      notificationService.updatePreferences(newPrefs);
                                    },
                                  ),
                                  SwitchListTile(
                                    title: const Text('Message Notifications'),
                                    subtitle: const Text('New messages and replies'),
                                    value: notificationService.preferences.messageNotifications,
                                    onChanged: (value) {
                                      final newPrefs = notificationService.preferences.copyWith(messageNotifications: value);
                                      notificationService.updatePreferences(newPrefs);
                                    },
                                  ),
                                  SwitchListTile(
                                    title: const Text('Daily Digest'),
                                    subtitle: const Text('Daily summary of community activity'),
                                    value: notificationService.preferences.dailyDigest,
                                    onChanged: (value) {
                                      final newPrefs = notificationService.preferences.copyWith(dailyDigest: value);
                                      notificationService.updatePreferences(newPrefs);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.security),
                      title: const Text('Privacy & Security'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Privacy settings coming soon!')),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.help),
                      title: const Text('Help & Support'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Help & support coming soon!')),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text('Sign Out'),
                      textColor: Colors.red,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Sign Out'),
                            content: const Text('Are you sure you want to sign out?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  // Navigate to login screen
                                  Navigator.of(context).pushReplacementNamed('/login');
                                },
                                child: const Text(
                                  'Sign Out',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      // Add demo notification buttons at the bottom for testing
      bottomNavigationBar: Consumer<NotificationService>(
        builder: (context, notificationService, child) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Notification Demo',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => notificationService.sendTestNotification(),
                        icon: const Icon(Icons.notifications, size: 18),
                        label: const Text('Test', style: TextStyle(fontSize: 14)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => notificationService.sendEmergencyAlert(
                          title: 'Emergency Demo',
                          message: 'This is a test emergency notification.',
                        ),
                        icon: const Icon(Icons.warning, size: 18),
                        label: const Text('Alert', style: TextStyle(fontSize: 14)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}