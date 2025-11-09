import 'package:flutter/material.dart';

// Event model
class Event {
  final String id;
  final String title;
  final String description;
  final String date;
  final String time;
  final String location;
  final String category;
  final int capacity;
  final int registered;
  final bool isRegistered;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.category,
    required this.capacity,
    required this.registered,
    this.isRegistered = false,
  });
}

// Event Directory Screen
class EventDirectory extends StatefulWidget {
  const EventDirectory({Key? key}) : super(key: key);

  @override
  State<EventDirectory> createState() => _EventDirectoryState();
}

class _EventDirectoryState extends State<EventDirectory> {
  String selectedCategory = 'all';
  String searchQuery = '';

  // Sample events data
  final List<Event> allEvents = [
    Event(
      id: '1',
      title: 'Monthly Community Meeting',
      description: 'Join us for our monthly community meeting where we discuss upcoming events, share announcements, and connect with neighbors.',
      date: '2024-01-25',
      time: '2:00 PM - 4:00 PM',
      location: 'Clubhouse Main Hall',
      category: 'social',
      capacity: 100,
      registered: 45,
    ),
    Event(
      id: '2',
      title: 'Senior Fitness Class',
      description: 'Gentle exercise class designed for seniors. Includes chair exercises, light stretching, and balance activities.',
      date: '2024-01-26',
      time: '10:00 AM - 11:00 AM',
      location: 'Fitness Center',
      category: 'fitness',
      capacity: 20,
      registered: 18,
      isRegistered: true,
    ),
    Event(
      id: '3',
      title: 'Computer Basics Workshop',
      description: 'Learn the basics of using computers and smartphones. Topics include email, internet browsing, and video calling.',
      date: '2024-01-28',
      time: '1:00 PM - 3:00 PM',
      location: 'Computer Lab',
      category: 'educational',
      capacity: 15,
      registered: 12,
    ),
    Event(
      id: '4',
      title: 'Movie Night: Classic Films',
      description: 'Enjoy a screening of classic movies from the golden age of cinema. Popcorn and refreshments provided.',
      date: '2024-01-30',
      time: '7:00 PM - 9:00 PM',
      location: 'Recreation Center',
      category: 'entertainment',
      capacity: 80,
      registered: 67,
    ),
    Event(
      id: '5',
      title: 'Volunteer Opportunity: Food Bank',
      description: 'Help sort and pack food donations for local families in need. Training provided, all skill levels welcome.',
      date: '2024-02-02',
      time: '9:00 AM - 12:00 PM',
      location: 'Community Center',
      category: 'volunteer',
      capacity: 25,
      registered: 8,
    ),
  ];

  List<Event> get filteredEvents {
    return allEvents.where((event) {
      final matchesCategory = selectedCategory == 'all' || event.category == selectedCategory;
      final matchesSearch = searchQuery.isEmpty ||
          event.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          event.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
          event.category.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  final List<String> categories = ['all', 'social', 'fitness', 'educational', 'entertainment', 'volunteer'];

  String getCategoryDisplayName(String category) {
    switch (category) {
      case 'all': return 'All Events';
      case 'social': return 'Social';
      case 'fitness': return 'Fitness';
      case 'educational': return 'Educational';
      case 'entertainment': return 'Entertainment';
      case 'volunteer': return 'Volunteer';
      default: return category;
    }
  }

  Color getCategoryColor(String category) {
    switch (category) {
      case 'social': return Colors.blue;
      case 'fitness': return Colors.green;
      case 'educational': return Colors.purple;
      case 'entertainment': return Colors.orange;
      case 'volunteer': return Colors.teal;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Directory'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search events...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Category Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((category) {
                      final isSelected = selectedCategory == category;
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(getCategoryDisplayName(category)),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              selectedCategory = category;
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: getCategoryColor(category).withOpacity(0.2),
                          checkmarkColor: getCategoryColor(category),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Results Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Showing ${filteredEvents.length} of ${allEvents.length} events',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),

          // Events List
          Expanded(
            child: filteredEvents.isEmpty
                ? const Center(
                    child: Text(
                      'No events found matching your criteria',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = filteredEvents[index];
                      return EventCard(
                        event: event,
                        onRegisterToggle: () {
                          // Handle registration toggle
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                event.isRegistered
                                    ? 'Unregistered from ${event.title}'
                                    : 'Registered for ${event.title}'
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Event Card Widget
class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onRegisterToggle;

  const EventCard({
    Key? key,
    required this.event,
    required this.onRegisterToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and category
            Row(
              children: [
                Expanded(
                  child: Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(event.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getCategoryDisplayName(event.category),
                    style: TextStyle(
                      color: _getCategoryColor(event.category),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              event.description,
              style: TextStyle(
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),

            const SizedBox(height: 12),

            // Event details
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  _formatDate(event.date),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  event.time,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    event.location,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Capacity and registration
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${event.registered}/${event.capacity} registered',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                ElevatedButton(
                  onPressed: event.registered >= event.capacity && !event.isRegistered
                      ? null
                      : onRegisterToggle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: event.isRegistered ? Colors.green : null,
                  ),
                  child: Text(
                    event.isRegistered
                        ? 'Registered'
                        : event.registered >= event.capacity
                            ? 'Full'
                            : 'Register',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'social': return 'Social';
      case 'fitness': return 'Fitness';
      case 'educational': return 'Educational';
      case 'entertainment': return 'Entertainment';
      case 'volunteer': return 'Volunteer';
      default: return category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'social': return Colors.blue;
      case 'fitness': return Colors.green;
      case 'educational': return Colors.purple;
      case 'entertainment': return Colors.orange;
      case 'volunteer': return Colors.teal;
      default: return Colors.grey;
    }
  }
}