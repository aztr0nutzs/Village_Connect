import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

// Dashboard item model
class DashboardItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  const DashboardItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
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
        onTap: () => Navigator.of(context).pushNamed(item.route),
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
  List<NewsArticle> latestNews = [];
  List<ApiEvent> upcomingEvents = [];
  bool isLoadingNews = true;
  bool isLoadingEvents = true;
  String? newsError;
  String? eventsError;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    await Future.wait([
      _loadLatestNews(),
      _loadUpcomingEvents(),
    ]);
  }

  Future<void> _loadLatestNews() async {
    if (!mounted) return;
    setState(() {
      isLoadingNews = true;
      newsError = null;
    });

    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.fetchNews(limit: 3);

      if (!mounted) return;
      if (response.success && response.data != null) {
        setState(() {
          latestNews = response.data!.take(3).toList();
        });
      } else {
        setState(() {
          newsError = response.error ?? 'Failed to load news';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        newsError = 'Failed to load news: ${e.toString()}';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        isLoadingNews = false;
      });
    }
  }

  Future<void> _loadUpcomingEvents() async {
    if (!mounted) return;
    setState(() {
      isLoadingEvents = true;
      eventsError = null;
    });

    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.fetchEvents(limit: 3);

      if (!mounted) return;
      if (response.success && response.data != null) {
        setState(() {
          upcomingEvents = response.data!.take(3).toList();
        });
      } else {
        setState(() {
          eventsError = response.error ?? 'Failed to load events';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        eventsError = 'Failed to load events: ${e.toString()}';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        isLoadingEvents = false;
      });
    }
  }

  final List<DashboardItem> dashboardItems = [
    const DashboardItem(
      title: 'Events',
      subtitle: 'Community events & activities',
      icon: Icons.event,
      color: Colors.blue,
      route: '/event-directory',
    ),
    const DashboardItem(
      title: 'Rec Centers',
      subtitle: 'Fitness & recreation facilities',
      icon: Icons.fitness_center,
      color: Colors.green,
      route: '/rec-center-directory',
    ),
    const DashboardItem(
      title: 'News',
      subtitle: 'Community announcements',
      icon: Icons.article,
      color: Colors.orange,
      route: '/news-feed',
    ),
    const DashboardItem(
      title: 'Directory',
      subtitle: 'Resident contacts',
      icon: Icons.contacts,
      color: Colors.purple,
      route: '/emergency-contact-hub', // Placeholder
    ),
    const DashboardItem(
      title: 'Messages',
      subtitle: 'Inbox & communications',
      icon: Icons.message,
      color: Colors.teal,
      route: '/home', // Placeholder
    ),
    const DashboardItem(
      title: 'Emergency',
      subtitle: 'Important contacts',
      icon: Icons.emergency,
      color: Colors.red,
      route: '/emergency-contact-hub',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

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
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
            tooltip: 'Refresh Dashboard',
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.of(context).pushNamed('/profile'),
            tooltip: 'Profile',
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
                        'Welcome back, ${authService.currentUser?.displayName ?? 'Guest'}!',
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

            // Live Content Sections
            if (isLoadingNews || isLoadingEvents)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              ),

            if (newsError != null || eventsError != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.red[50],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Unable to load live content',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (newsError != null) Text('News: $newsError'),
                      if (eventsError != null) Text('Events: $eventsError'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loadDashboardData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),

            if (!isLoadingNews && !isLoadingEvents && latestNews.isEmpty && upcomingEvents.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    'No recent news or upcoming events.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            if (latestNews.isNotEmpty || upcomingEvents.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  Text(
                    'Latest Updates',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Latest News
                  if (latestNews.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent News',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...latestNews.map((news) => _buildNewsCard(news)),
                      ],
                    ),

                  // Upcoming Events
                  if (upcomingEvents.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        Text(
                          'Upcoming Events',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...upcomingEvents.map((event) => _buildEventCard(event)),
                      ],
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }


  // Build news card widget
  Widget _buildNewsCard(NewsArticle news) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
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
                    news.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'NEWS',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              news.summary,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              'By ${news.author} • ${DateFormat.yMMMd().format(news.publishedAt.toLocal())}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build event card widget
  Widget _buildEventCard(ApiEvent event) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
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
                    event.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'EVENT',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              event.description,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  DateFormat.yMMMd().format(event.startDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    event.location,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Get current time formatted for display
  String _getCurrentTime() {
    return DateFormat.jm().format(DateTime.now());
  }

  // Get current date formatted for display
  String _getCurrentDate() {
    return DateFormat.yMMMMEEEEd().format(DateTime.now());
  }
}
