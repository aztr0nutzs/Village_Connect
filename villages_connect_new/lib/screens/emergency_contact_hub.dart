import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/emergency_contact.dart';
import '../services/storage_service.dart';

// Emergency Contact Hub Screen
class EmergencyContactHub extends StatefulWidget {
  const EmergencyContactHub({super.key});

  @override
  State<EmergencyContactHub> createState() => _EmergencyContactHubState();
}

class _EmergencyContactHubState extends State<EmergencyContactHub> {
  List<EmergencyContact> _contacts = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedCategory = 'all';

  final List<String> _categories = [
    'all',
    'emergency',
    'police',
    'fire',
    'medical',
    'utility',
    'community',
    'custom'
  ];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final storageService = context.read<StorageService>();
      final contactsData = await storageService.getAppState();

      if (contactsData['emergency_contacts'] != null) {
        final contactsJson = contactsData['emergency_contacts'] as List<dynamic>;
        _contacts = contactsJson
            .map((json) => EmergencyContact.fromJson(json))
            .toList();
      } else {
        // Load default emergency contacts
        _contacts = _getDefaultContacts();
        await _saveContacts();
      }

      // Sort contacts by priority
      _contacts.sort((a, b) => a.getPriority().compareTo(b.getPriority()));
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load contacts: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveContacts() async {
    try {
      final storageService = context.read<StorageService>();
      final contactsJson = _contacts.map((contact) => contact.toJson()).toList();
      await storageService.saveAppState({'emergency_contacts': contactsJson});
    } catch (e) {
      debugPrint('Error saving contacts: $e');
    }
  }

  List<EmergencyContact> _getDefaultContacts() {
    return [
      // Emergency Services
      EmergencyContact(
        id: '911',
        name: 'Emergency Services',
        phone: '911',
        category: 'emergency',
        description: 'For life-threatening emergencies only',
        isEmergency: true,
        createdAt: DateTime.now(),
      ),

      // Police
      EmergencyContact(
        id: 'police_non_emergency',
        name: 'Police Non-Emergency',
        phone: '(352) 754-6830',
        category: 'police',
        description: 'Sumter County Sheriff\'s Office non-emergency line',
        address: '1580 U.S. 301, Bushnell, FL 33513',
        latitude: 28.6619,
        longitude: -82.1136,
        createdAt: DateTime.now(),
      ),

      // Fire Department
      EmergencyContact(
        id: 'fire_department',
        name: 'Fire Department',
        phone: '(352) 754-4111',
        category: 'fire',
        description: 'Sumter County Fire Department',
        address: '445 N. U.S. Hwy 301, Sumterville, FL 33585',
        latitude: 28.7414,
        longitude: -82.0528,
        createdAt: DateTime.now(),
      ),

      // Medical
      EmergencyContact(
        id: 'villages_hospital',
        name: 'The Villages Hospital',
        phone: '(352) 751-8000',
        category: 'medical',
        description: 'Emergency room and medical services',
        address: '1451 El Camino Real, The Villages, FL 32159',
        latitude: 28.9167,
        longitude: -81.9636,
        createdAt: DateTime.now(),
      ),

      EmergencyContact(
        id: 'urgent_care',
        name: 'Urgent Care Center',
        phone: '(352) 259-4444',
        category: 'medical',
        description: 'Walk-in medical care for non-emergencies',
        address: '2800 SE 3rd St, Ocala, FL 34471',
        latitude: 29.1686,
        longitude: -82.1401,
        createdAt: DateTime.now(),
      ),

      // Utilities
      EmergencyContact(
        id: 'duke_energy',
        name: 'Duke Energy',
        phone: '1-800-700-8749',
        category: 'utility',
        description: 'Power outages and electrical emergencies',
        createdAt: DateTime.now(),
      ),

      EmergencyContact(
        id: 'progress_energy',
        name: 'Progress Energy',
        phone: '1-800-700-8749',
        category: 'utility',
        description: 'Natural gas emergencies',
        createdAt: DateTime.now(),
      ),

      // Community Services
      EmergencyContact(
        id: 'community_watch',
        name: 'Community Watch',
        phone: '(352) 750-1234',
        category: 'community',
        description: 'Neighborhood watch and security reporting',
        createdAt: DateTime.now(),
      ),

      EmergencyContact(
        id: 'villages_security',
        name: 'The Villages Security',
        phone: '(352) 753-5000',
        category: 'community',
        description: 'On-site security and gate access',
        createdAt: DateTime.now(),
      ),
    ];
  }

  List<EmergencyContact> get _filteredContacts {
    if (_selectedCategory == 'all') return _contacts;
    if (_selectedCategory == 'emergency') {
      return _contacts.where((contact) => contact.isEmergency).toList();
    }
    return _contacts.where((contact) => contact.category == _selectedCategory).toList();
  }

  Future<void> _callContact(EmergencyContact contact) async {
    final uri = Uri(scheme: 'tel', path: contact.phone);
    await _launchExternalUri(
      uri,
      errorMessage: 'Could not call ${contact.name}',
      mode: LaunchMode.platformDefault,
    );
  }

  Future<void> _showLocation(EmergencyContact contact) async {
    if (!contact.hasLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location not available for ${contact.name}')),
      );
      return;
    }

    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${contact.latitude},${contact.longitude}',
    );
    await _launchExternalUri(
      uri,
      errorMessage: 'Could not open maps for ${contact.name}',
    );
  }

  void _togglePin(EmergencyContact contact) {
    setState(() {
      final index = _contacts.indexWhere((c) => c.id == contact.id);
      if (index != -1) {
        _contacts[index] = contact.copyWith(
          isPinned: !contact.isPinned,
          updatedAt: DateTime.now(),
        );
        _contacts.sort((a, b) => a.getPriority().compareTo(b.getPriority()));
        _saveContacts();
      }
    });

    final action = contact.isPinned ? 'unpinned from' : 'pinned to';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${contact.name} $action quick access')),
    );
  }

  Future<void> _launchExternalUri(
    Uri uri, {
    String? errorMessage,
    LaunchMode mode = LaunchMode.externalApplication,
  }) async {
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: mode);
      } else {
        _showSnackBar(errorMessage ?? 'Unable to open link.');
      }
    } catch (e) {
      _showSnackBar('${errorMessage ?? 'Unable to open link'}: $e');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _addCustomContact() {
    // Navigate to add contact screen (would be implemented)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add custom contact feature coming soon')),
    );
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'all':
        return 'All Contacts';
      case 'emergency':
        return 'Emergency (911)';
      case 'police':
        return 'Police';
      case 'fire':
        return 'Fire';
      case 'medical':
        return 'Medical';
      case 'utility':
        return 'Utilities';
      case 'community':
        return 'Community';
      case 'custom':
        return 'Personal';
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addCustomContact,
            tooltip: 'Add Custom Contact',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadContacts,
            tooltip: 'Refresh Contacts',
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Access',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      final categoryContacts = category == 'all'
                          ? _contacts
                          : category == 'emergency'
                              ? _contacts.where((c) => c.isEmergency).toList()
                              : _contacts.where((c) => c.category == category).toList();

                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text('${_getCategoryDisplayName(category)} (${categoryContacts.length})'),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: category == 'emergency'
                              ? Colors.red.withOpacity(0.2)
                              : Colors.blue.withOpacity(0.2),
                          checkmarkColor: category == 'emergency' ? Colors.red : Colors.blue,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Content
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
                              onPressed: _loadContacts,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredContacts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.contact_phone, size: 64, color: Colors.grey),
                                const SizedBox(height: 16),
                                Text(
                                  'No $_selectedCategory contacts found',
                                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredContacts.length,
                            itemBuilder: (context, index) {
                              final contact = _filteredContacts[index];
                              return EmergencyContactCard(
                                contact: contact,
                                onCall: () => _callContact(contact),
                                onShowLocation: contact.hasLocation ? () => _showLocation(contact) : null,
                                onTogglePin: contact.category == 'custom' ? () => _togglePin(contact) : null,
                              );
                            },
                          ),
          ),
        ],
      ),

      // Emergency FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _callContact(_contacts.firstWhere((c) => c.id == '911')),
        label: const Text('EMERGENCY 911'),
        icon: const Icon(Icons.call),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
    );
  }
}

// Emergency Contact Card Widget
class EmergencyContactCard extends StatelessWidget {
  final EmergencyContact contact;
  final VoidCallback onCall;
  final VoidCallback? onShowLocation;
  final VoidCallback? onTogglePin;

  const EmergencyContactCard({
    super.key,
    required this.contact,
    required this.onCall,
    this.onShowLocation,
    this.onTogglePin,
  });

  @override
  Widget build(BuildContext context) {
    final isEmergency = contact.isEmergency;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isEmergency ? Colors.red[50] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isEmergency ? Colors.red : _getCategoryColor(contact.category),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Text(
                      contact.getCategoryIcon(),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Contact Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isEmergency ? Colors.red[900] : Colors.black,
                        ),
                      ),
                      Text(
                        contact.getFormattedPhone(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      if (contact.relationship != null)
                        Text(
                          contact.relationship!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                          ),
                        ),
                    ],
                  ),
                ),

                // Pin button for custom contacts
                if (onTogglePin != null)
                  IconButton(
                    icon: Icon(
                      contact.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                      color: contact.isPinned ? Colors.blue : Colors.grey,
                    ),
                    onPressed: onTogglePin,
                    tooltip: contact.isPinned ? 'Unpin contact' : 'Pin to quick access',
                  ),
              ],
            ),

            // Description
            if (contact.description != null) ...[
              const SizedBox(height: 12),
              Text(
                contact.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],

            // Address
            if (contact.address != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      contact.address!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Action Buttons
            const SizedBox(height: 16),
            Row(
              children: [
                // Call Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onCall,
                    icon: const Icon(Icons.call),
                    label: const Text('Call'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEmergency ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),

                // Location Button
                if (onShowLocation != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onShowLocation,
                      icon: const Icon(Icons.map),
                      label: const Text('Location'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'police':
        return Colors.blue;
      case 'fire':
        return Colors.orange;
      case 'medical':
        return Colors.red;
      case 'utility':
        return Colors.purple;
      case 'community':
        return Colors.teal;
      case 'custom':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
}
