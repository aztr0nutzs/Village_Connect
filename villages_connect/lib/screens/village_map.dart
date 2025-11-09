import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';

// Map Location Model
class MapLocation {
  final String id;
  final String name;
  final String type; // 'rec_center', 'event', 'golf_course', 'town_square'
  final double latitude;
  final double longitude;
  final String description;
  final String? address;
  final String? phone;
  final Map<String, dynamic>? additionalData;

  MapLocation({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.description,
    this.address,
    this.phone,
    this.additionalData,
  });

  // Convert from API models
  factory MapLocation.fromRecreationCenter(RecreationCenter center) {
    return MapLocation(
      id: center.id,
      name: center.name,
      type: 'rec_center',
      latitude: center.latitude,
      longitude: center.longitude,
      description: center.description,
      address: center.address,
      phone: center.phone,
      additionalData: {
        'facilities': center.facilities,
        'amenities': center.amenities,
        'hours': center.hours,
        'isActive': center.isActive,
      },
    );
  }

  factory MapLocation.fromApiEvent(ApiEvent event) {
    return MapLocation(
      id: event.id,
      name: event.title,
      type: 'event',
      latitude: 28.0, // Default coordinates - would need actual event location
      longitude: -82.0,
      description: event.description,
      address: event.location,
      additionalData: {
        'startDate': event.startDate.toIso8601String(),
        'endDate': event.endDate.toIso8601String(),
        'category': event.category,
        'organizer': event.organizer,
        'registrationUrl': event.registrationUrl,
      },
    );
  }

  // Get marker icon based on type
  BitmapDescriptor getMarkerIcon() {
    // In a real app, you'd load custom marker icons
    // For now, we'll use default markers with different colors
    switch (type) {
      case 'rec_center':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case 'event':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case 'golf_course':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case 'town_square':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      default:
        return BitmapDescriptor.defaultMarker;
    }
  }

  // Get info window title
  String getInfoTitle() {
    switch (type) {
      case 'rec_center':
        return '🏊 $name';
      case 'event':
        return '📅 $name';
      case 'golf_course':
        return '⛳ $name';
      case 'town_square':
        return '🏛️ $name';
      default:
        return name;
    }
  }
}

// Village Map Screen
class VillageMap extends StatefulWidget {
  const VillageMap({Key? key}) : super(key: key);

  @override
  State<VillageMap> createState() => _VillageMapState();
}

class _VillageMapState extends State<VillageMap> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoading = true;
  String? _errorMessage;
  Set<Marker> _markers = {};
  Set<MapLocation> _locations = {};
  String _selectedFilter = 'all';

  // The Villages center coordinates
  static const LatLng _villagesCenter = LatLng(28.9386, -82.0038);

  final List<String> _filterOptions = [
    'all',
    'rec_center',
    'event',
    'golf_course',
    'town_square'
  ];

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get user location
      await _getCurrentLocation();

      // Load locations
      await _loadLocations();

      // Create markers
      _createMarkers();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize map: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Use default location
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Use default location
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
      // Continue with default location
    }
  }

  Future<void> _loadLocations() async {
    final apiService = context.read<ApiService>();

    // Load recreation centers
    final recCentersResponse = await apiService.fetchRecreationCenters();
    if (recCentersResponse.success && recCentersResponse.data != null) {
      final recCenterLocations = recCentersResponse.data!
          .map((center) => MapLocation.fromRecreationCenter(center))
          .toSet();
      _locations.addAll(recCenterLocations);
    }

    // Load events
    final eventsResponse = await apiService.fetchEvents();
    if (eventsResponse.success && eventsResponse.data != null) {
      final eventLocations = eventsResponse.data!
          .where((event) => event.location.isNotEmpty) // Only events with locations
          .map((event) => MapLocation.fromApiEvent(event))
          .toSet();
      _locations.addAll(eventLocations);
    }

    // Add static locations (golf courses and town squares)
    _addStaticLocations();
  }

  void _addStaticLocations() {
    // Sample golf courses
    final golfCourses = [
      MapLocation(
        id: 'golf1',
        name: 'The Villages North Course',
        type: 'golf_course',
        latitude: 28.95,
        longitude: -82.01,
        description: '18-hole championship golf course',
        address: '123 Golf Way, The Villages, FL',
      ),
      MapLocation(
        id: 'golf2',
        name: 'The Villages South Course',
        type: 'golf_course',
        latitude: 28.92,
        longitude: -81.98,
        description: 'Scenic golf course with water features',
        address: '456 Fairway Drive, The Villages, FL',
      ),
    ];

    // Sample town squares
    final townSquares = [
      MapLocation(
        id: 'square1',
        name: 'Spanish Springs Town Square',
        type: 'town_square',
        latitude: 28.94,
        longitude: -82.00,
        description: 'Central gathering place with shops and restaurants',
        address: '789 Town Square Blvd, The Villages, FL',
      ),
      MapLocation(
        id: 'square2',
        name: 'Lake Sumter Town Square',
        type: 'town_square',
        latitude: 28.93,
        longitude: -81.97,
        description: 'Lakeside town square with entertainment venues',
        address: '321 Lakeview Plaza, The Villages, FL',
      ),
    ];

    _locations.addAll([...golfCourses, ...townSquares]);
  }

  void _createMarkers() {
    final filteredLocations = _selectedFilter == 'all'
        ? _locations
        : _locations.where((location) => location.type == _selectedFilter);

    _markers = filteredLocations.map((location) {
      return Marker(
        markerId: MarkerId(location.id),
        position: LatLng(location.latitude, location.longitude),
        icon: location.getMarkerIcon(),
        infoWindow: InfoWindow(
          title: location.getInfoTitle(),
          snippet: location.description,
          onTap: () => _showLocationDetails(location),
        ),
      );
    }).toSet();
  }

  void _showLocationDetails(MapLocation location) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.4,
        maxChildSize: 0.8,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    location.getInfoTitle(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                location.description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),

              // Address
              if (location.address != null) ...[
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        location.address!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Phone
              if (location.phone != null && location.phone!.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.phone, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      location.phone!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Additional info based on type
              if (location.additionalData != null) ...[
                _buildAdditionalInfo(location),
                const SizedBox(height: 16),
              ],

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _getDirections(location),
                      icon: const Icon(Icons.directions),
                      label: const Text('Get Directions'),
                    ),
                  ),
                  if (location.phone != null && location.phone!.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _callLocation(location),
                        icon: const Icon(Icons.phone),
                        label: const Text('Call'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo(MapLocation location) {
    final data = location.additionalData!;
    final widgets = <Widget>[];

    switch (location.type) {
      case 'rec_center':
        if (data['facilities'] != null) {
          widgets.add(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Facilities:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: (data['facilities'] as List<String>).map((facility) {
                    return Chip(
                      label: Text(facility, style: const TextStyle(fontSize: 12)),
                      backgroundColor: Colors.blue.withOpacity(0.1),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }
        break;

      case 'event':
        if (data['startDate'] != null) {
          final startDate = DateTime.parse(data['startDate']);
          final endDate = DateTime.parse(data['endDate']);
          widgets.add(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date: ${_formatEventDate(startDate)}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Time: ${_formatEventTime(startDate)} - ${_formatEventTime(endDate)}',
                  style: const TextStyle(fontSize: 16),
                ),
                if (data['category'] != null)
                  Text(
                    'Category: ${data['category']}',
                    style: const TextStyle(fontSize: 16),
                  ),
              ],
            ),
          );
        }
        break;
    }

    return Column(children: widgets);
  }

  Future<void> _getDirections(MapLocation location) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${location.latitude},${location.longitude}';

    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open maps to ${location.name}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening directions: $e')),
      );
    }
  }

  Future<void> _callLocation(MapLocation location) async {
    final url = 'tel:${location.phone}';

    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not call ${location.name}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error making call: $e')),
      );
    }
  }

  void _filterLocations(String filter) {
    setState(() {
      _selectedFilter = filter;
      _createMarkers();
    });
  }

  void _centerOnUser() {
    if (_currentPosition != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        ),
      );
    }
  }

  void _centerOnVillages() {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_villagesCenter, 12),
      );
    }
  }

  String _formatEventDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  String _formatEventTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final amPm = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $amPm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Village Map'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _centerOnUser,
            tooltip: 'Center on My Location',
          ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: _centerOnVillages,
            tooltip: 'Center on The Villages',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter buttons
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[100],
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filterOptions.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_getFilterDisplayName(filter)),
                      selected: isSelected,
                      onSelected: (selected) => _filterLocations(filter),
                      backgroundColor: Colors.white,
                      selectedColor: Colors.blue.withOpacity(0.2),
                      checkmarkColor: Colors.blue,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Map or loading/error state
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              style: const TextStyle(fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _initializeMap,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _currentPosition != null
                              ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                              : _villagesCenter,
                          zoom: 12,
                        ),
                        markers: _markers,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false, // We have our own button
                        onMapCreated: (controller) {
                          _mapController = controller;
                        },
                        mapType: MapType.normal,
                        zoomControlsEnabled: true,
                        zoomGesturesEnabled: true,
                        scrollGesturesEnabled: true,
                        tiltGesturesEnabled: true,
                        rotateGesturesEnabled: true,
                      ),
          ),
        ],
      ),
    );
  }

  String _getFilterDisplayName(String filter) {
    switch (filter) {
      case 'all':
        return 'All Locations';
      case 'rec_center':
        return 'Rec Centers';
      case 'event':
        return 'Events';
      case 'golf_course':
        return 'Golf Courses';
      case 'town_square':
        return 'Town Squares';
      default:
        return filter;
    }
  }
}