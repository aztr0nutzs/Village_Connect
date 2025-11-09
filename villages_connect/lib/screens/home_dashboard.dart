import 'package:flutter/material.dart';

// Dashboard item model
class DashboardItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const DashboardItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });
}

// Reusable Dashboard Card Widget
class DashboardCard extends StatelessWidget {
  final DashboardItem item;

  const DashboardCard({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                size: 48,
                color: item.color,
              ),
              const SizedBox(height: 12),
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                item.subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Home Dashboard Screen
class HomeDashboard extends StatefulWidget {
  const HomeDashboard({Key? key}) : super(key: key);

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  // Sample dashboard data
  final List<DashboardItem> dashboardItems = [
    DashboardItem(
      title: 'Events',
      subtitle: 'Community events & activities',
      icon: Icons.event,
      color: Colors.blue,
      onTap: () {
        // Navigate to events screen
        print('Navigate to Events');
      },
    ),
    DashboardItem(
      title: 'Rec Centers',
      subtitle: 'Fitness & recreation facilities',
      icon: Icons.fitness_center,
      color: Colors.green,
      onTap: () {
        // Navigate to rec centers screen
        print('Navigate to Rec Centers');
      },
    ),
    DashboardItem(
      title: 'News',
      subtitle: 'Community announcements',
      icon: Icons.article,
      color: Colors.orange,
      onTap: () {
        // Navigate to news screen
        print('Navigate to News');
      },
    ),
    DashboardItem(
      title: 'Directory',
      subtitle: 'Resident contacts',
      icon: Icons.contacts,
      color: Colors.purple,
      onTap: () {
        // Navigate to directory screen
        print('Navigate to Directory');
      },
    ),
    DashboardItem(
      title: 'Messages',
      subtitle: 'Inbox & communications',
      icon: Icons.message,
      color: Colors.teal,
      onTap: () {
        // Navigate to messages screen
        print('Navigate to Messages');
      },
    ),
    DashboardItem(
      title: 'Emergency',
      subtitle: 'Important contacts',
      icon: Icons.emergency,
      color: Colors.red,
      onTap: () {
        // Navigate to emergency screen
        print('Navigate to Emergency');
      },
    ),
  ];

  // Sample announcements
  final List<Map<String, dynamic>> announcements = [
    {
      'title': 'Community Meeting',
      'message': 'Monthly community meeting this Thursday at 2 PM in the clubhouse.',
      'date': 'Jan 25, 2024',
      'priority': 'normal',
    },
    {
      'title': 'Weather Alert',
      'message': 'Heavy rain expected tomorrow. Please take precautions.',
      'date': 'Jan 14, 2024',
      'priority': 'high',
    },
    {
      'title': 'New Fitness Classes',
      'message': 'Senior yoga and water aerobics classes starting next week.',
      'date': 'Jan 12, 2024',
      'priority': 'normal',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Villages Connect',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Profile/settings action
              print('Open Profile');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Welcome back, John!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getCurrentTime(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getCurrentDate(),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions Title
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Dashboard Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: dashboardItems.length,
              itemBuilder: (context, index) {
                final item = dashboardItems[index];
                return DashboardCard(item: item);
              },
            ),

            const SizedBox(height: 32),

            // Announcements Section
            Text(
              'Announcements',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Announcements List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                final announcement = announcements[index];
                return _buildAnnouncementCard(announcement);
              },
            ),
          ],
        ),
      ),
    );
  }


  // Build announcement card widget
  Widget _buildAnnouncementCard(Map<String, dynamic> announcement) {
    final isHighPriority = announcement['priority'] == 'high';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      color: isHighPriority ? Colors.orange[50] : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isHighPriority ? Colors.orange : Colors.grey[300]!,
          width: isHighPriority ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    announcement['title'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isHighPriority)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'HIGH',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              announcement['message'],
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              announcement['date'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Get current time formatted for display
  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final amPm = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $amPm';
  }

  // Get current date formatted for display
  String _getCurrentDate() {
    final now = DateTime.now();
    final weekdays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final months = ['January', 'February', 'March', 'April', 'May', 'June',
                   'July', 'August', 'September', 'October', 'November', 'December'];

    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';
  }
}