import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

// Recreation Center model (keeping for compatibility but will be replaced by API model)
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
  const RecCenterDirectory({super.key});

  @override
  State<RecCenterDirectory> createState() => _RecCenterDirectoryState();
}

class _RecCenterDirectoryState extends State<RecCenterDirectory> {
  String selectedFilter = 'all';
  String searchQuery = '';
  List<RecreationCenter> centers = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCenters();
  }

  Future<void> _loadCenters() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.fetchRecreationCenters(
        district: selectedFilter == 'all' ? 'all' : selectedFilter,
        amenity: 'all', // Could be enhanced to filter by specific amenities
      );

      if (response.success && response.data != null) {
        setState(() {
          centers = response.data!;
        });
      } else {
        setState(() {
          errorMessage = response.error ?? 'Failed to load recreation centers';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load recreation centers: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshCenters() async {
    await _loadCenters();
  }

  // Sample recreation centers data (fallback)
  final List<RecCenter> allCenters = [
    const RecCenter(
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
    const RecCenter(
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
    const RecCenter(
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
    const RecCenter(
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
    const RecCenter(
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

  List<RecreationCenter> get filteredCenters {
    final sourceCenters = centers.isNotEmpty ? centers : allCenters.map((center) => RecreationCenter(
      id: center.id,
      name: center.name,
      address: center.address,
      district: 'General', // Default district
      phone: center.phone,
      hours: center.hours,
      facilities: center.amenities, // Map amenities to facilities
      amenities: center.amenities,
      latitude: 28.0, // Default coordinates
      longitude: -82.0,
      description: center.description,
      isActive: center.isOpen,
      imageUrl: '',
      additionalInfo: {},
    )).toList();

    return sourceCenters.where((center) {
      final matchesFilter = selectedFilter == 'all' ||
          (selectedFilter == 'open' && center.isActive) ||
          center.facilities.any((facility) =>
              facility.toLowerCase().contains(selectedFilter.toLowerCase())) ||
          center.amenities.any((amenity) =>
              amenity.toLowerCase().contains(selectedFilter.toLowerCase()));

      final matchesSearch = searchQuery.isEmpty ||
          center.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          center.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
          center.facilities.any((facility) =>
              facility.toLowerCase().contains(searchQuery.toLowerCase())) ||
          center.amenities.any((amenity) =>
              amenity.toLowerCase().contains(searchQuery.toLowerCase()));

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
            icon: const Icon(Icons.refresh),
            onPressed: _refreshCenters,
            tooltip: 'Refresh Centers',
          ),
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

          // Results Count and Status
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                if (isLoading)
                  const CircularProgressIndicator()
                else if (errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.red[50],
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                        TextButton(
                          onPressed: _refreshCenters,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    'Showing ${filteredCenters.length} of ${centers.isNotEmpty ? centers.length : allCenters.length} centers',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
              ],
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
  final RecreationCenter center;

  const RecCenterCard({
    required this.center,
    super.key,
  });

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
                        center.address,
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
                    color: center.isActive ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    center.isActive ? 'Open' : 'Closed',
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

                // Facilities
                const Text(
                  'Facilities:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: center.facilities.map((facility) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        facility,
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                ),

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
                        color: Colors.green.withOpacity(0.1),
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

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Call center - using tel: URL scheme
                          // This will open the phone dialer on mobile devices
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Calling ${center.phone}')),
                          );
                          // In a real app, you would use: url_launcher package
                          // launch('tel:${center.phone}');
                        },
                        icon: const Icon(Icons.phone),
                        label: const Text('Call'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Get directions - using maps URL scheme
                          // This will open maps app on mobile devices
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Opening maps to ${center.name}')),
                          );
                          // In a real app, you would use: url_launcher package
                          // launch(mapsUrl);
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
