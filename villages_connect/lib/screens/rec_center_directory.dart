import 'package:flutter/material.dart';

// Recreation Center model
class RecCenter {
  final String id;
  final String name;
  final String description;
  final String address;
  final String phone;
  final List<String> amenities;
  final List<String> activities;
  final Map<String, String> hours;
  final bool isOpen;
  final double distance; // in miles

  const RecCenter({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.phone,
    required this.amenities,
    required this.activities,
    required this.hours,
    required this.isOpen,
    required this.distance,
  });
}

// Recreation Center Directory Screen
class RecCenterDirectory extends StatefulWidget {
  const RecCenterDirectory({Key? key}) : super(key: key);

  @override
  State<RecCenterDirectory> createState() => _RecCenterDirectoryState();
}

class _RecCenterDirectoryState extends State<RecCenterDirectory> {
  String selectedFilter = 'all';
  String searchQuery = '';

  // Sample recreation centers data
  final List<RecCenter> allCenters = [
    RecCenter(
      id: '1',
      name: 'Main Community Center',
      description: 'The heart of The Villages recreation. Features multiple gyms, pools, and community spaces.',
      address: '123 Main Street, The Villages, FL 32162',
      phone: '(352) 555-0100',
      amenities: ['Gym', 'Pool', 'Tennis Courts', 'Basketball Court', 'Library', 'Computer Lab'],
      activities: ['Swimming', 'Tennis', 'Basketball', 'Yoga', 'Aerobics', 'Computer Classes'],
      hours: {
        'Monday-Friday': '5:00 AM - 10:00 PM',
        'Saturday': '6:00 AM - 10:00 PM',
        'Sunday': '8:00 AM - 8:00 PM',
      },
      isOpen: true,
      distance: 0.5,
    ),
    RecCenter(
      id: '2',
      name: 'Fitness & Wellness Center',
      description: 'Dedicated to health and wellness with state-of-the-art equipment and fitness classes.',
      address: '456 Health Way, The Villages, FL 32163',
      phone: '(352) 555-0101',
      amenities: ['Cardio Equipment', 'Weight Room', 'Sauna', 'Lockers', 'Personal Training'],
      activities: ['Spinning', 'Pilates', 'Personal Training', 'Senior Fitness', 'Water Aerobics'],
      hours: {
        'Monday-Thursday': '5:00 AM - 9:00 PM',
        'Friday': '5:00 AM - 8:00 PM',
        'Saturday-Sunday': '7:00 AM - 7:00 PM',
      },
      isOpen: true,
      distance: 1.2,
    ),
    RecCenter(
      id: '3',
      name: 'Aquatic Center',
      description: 'Indoor and outdoor pools with therapeutic and recreational swimming options.',
      address: '789 Water Street, The Villages, FL 32159',
      phone: '(352) 555-0102',
      amenities: ['Indoor Pool', 'Outdoor Pool', 'Hot Tub', 'Steam Room', 'Pool Deck'],
      activities: ['Swim Lessons', 'Water Aerobics', 'Therapeutic Swimming', 'Lap Swimming'],
      hours: {
        'Monday-Friday': '6:00 AM - 9:00 PM',
        'Saturday': '7:00 AM - 8:00 PM',
        'Sunday': '9:00 AM - 6:00 PM',
      },
      isOpen: false,
      distance: 2.1,
    ),
    RecCenter(
      id: '4',
      name: 'Arts & Crafts Center',
      description: 'Creative space for painting, pottery, woodworking, and other artistic pursuits.',
      address: '321 Creative Lane, The Villages, FL 32162',
      phone: '(352) 555-0103',
      amenities: ['Art Studio', 'Pottery Wheel', 'Woodworking Shop', 'Dark Room', 'Gallery'],
      activities: ['Painting', 'Pottery', 'Woodworking', 'Photography', 'Sculpture'],
      hours: {
        'Tuesday-Saturday': '9:00 AM - 4:00 PM',
        'Sunday-Monday': 'Closed',
      },
      isOpen: true,
      distance: 0.8,
    ),
    RecCenter(
      id: '5',
      name: 'Sports Complex',
      description: 'Multi-sport facility with courts and fields for various athletic activities.',
      address: '654 Athletic Drive, The Villages, FL 32163',
      phone: '(352) 555-0104',
      amenities: ['Tennis Courts', 'Pickleball Courts', 'Basketball Courts', 'Soccer Field', 'Track'],
      activities: ['Tennis', 'Pickleball', 'Basketball', 'Soccer', 'Walking', 'Running'],
      hours: {
        'Daily': '6:00 AM - 10:00 PM',
      },
      isOpen: true,
      distance: 1.5,
    ),
  ];

  List<RecCenter> get filteredCenters {
    return allCenters.where((center) {
      final matchesFilter = selectedFilter == 'all' ||
          (selectedFilter == 'open' && center.isOpen) ||
          (selectedFilter == 'nearby' && center.distance <= 1.0) ||
          center.amenities.any((amenity) =>
              amenity.toLowerCase().contains(selectedFilter.toLowerCase()));

      final matchesSearch = searchQuery.isEmpty ||
          center.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          center.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
          center.amenities.any((amenity) =>
              amenity.toLowerCase().contains(searchQuery.toLowerCase())) ||
          center.activities.any((activity) =>
              activity.toLowerCase().contains(searchQuery.toLowerCase()));

      return matchesFilter && matchesSearch;
    }).toList();
  }

  final List<String> filterOptions = ['all', 'open', 'nearby', 'gym', 'pool', 'tennis', 'arts'];

  String getFilterDisplayName(String filter) {
    switch (filter) {
      case 'all': return 'All Centers';
      case 'open': return 'Currently Open';
      case 'nearby': return 'Nearby (< 1 mile)';
      case 'gym': return 'Fitness Centers';
      case 'pool': return 'Pools';
      case 'tennis': return 'Tennis Courts';
      case 'arts': return 'Arts & Crafts';
      default: return filter;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recreation Centers'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              // Open map view
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Map view coming soon!')),
              );
            },
          ),
        ],
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
                    hintText: 'Search centers, amenities, activities...',
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

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: filterOptions.map((filter) {
                      final isSelected = selectedFilter == filter;
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(getFilterDisplayName(filter)),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              selectedFilter = filter;
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: Colors.blue.withOpacity(0.2),
                          checkmarkColor: Colors.blue,
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
              'Showing ${filteredCenters.length} of ${allCenters.length} centers',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),

          // Centers List
          Expanded(
            child: filteredCenters.isEmpty
                ? const Center(
                    child: Text(
                      'No recreation centers found matching your criteria',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredCenters.length,
                    itemBuilder: (context, index) {
                      final center = filteredCenters[index];
                      return RecCenterCard(center: center);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Recreation Center Card Widget
class RecCenterCard extends StatelessWidget {
  final RecCenter center;

  const RecCenterCard({
    Key? key,
    required this.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        center.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${center.distance.toStringAsFixed(1)} miles away',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: center.isOpen ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    center.isOpen ? 'Open' : 'Closed',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                Text(
                  center.description,
                  style: TextStyle(
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 16),

                // Contact Info
                Row(
                  children: [
                    const Icon(Icons.phone, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      center.phone,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        center.address,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Hours
                const Text(
                  'Hours:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                ...center.hours.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      '${entry.key}: ${entry.value}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }),

                const SizedBox(height: 16),

                // Amenities
                const Text(
                  'Amenities:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: center.amenities.map((amenity) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        amenity,
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Activities
                const Text(
                  'Activities:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: center.activities.map((activity) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        activity,
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Call center
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Calling ${center.name}')),
                          );
                        },
                        icon: const Icon(Icons.phone),
                        label: const Text('Call'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Get directions
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Getting directions to ${center.name}')),
                          );
                        },
                        icon: const Icon(Icons.directions),
                        label: const Text('Directions'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}