import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

// Event Calendar Screen
class EventCalendar extends StatefulWidget {
  const EventCalendar({Key? key}) : super(key: key);

  @override
  State<EventCalendar> createState() => _EventCalendarState();
}

class _EventCalendarState extends State<EventCalendar> {
  bool _isMonthlyView = true; // true for monthly, false for weekly
  DateTime _currentDate = DateTime.now();
  List<ApiEvent> _events = [];
  bool _isLoading = true;
  String? _errorMessage;
  Set<String> _interestedEvents = {}; // Track interested events

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.fetchEvents(limit: 100); // Get more events for calendar

      if (response.success && response.data != null) {
        setState(() {
          _events = response.data!;
        });
      } else {
        setState(() {
          _errorMessage = response.error ?? 'Failed to load events';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load events: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshEvents() async {
    await _loadEvents();
  }

  void _toggleView() {
    setState(() {
      _isMonthlyView = !_isMonthlyView;
    });
  }

  void _previousPeriod() {
    setState(() {
      if (_isMonthlyView) {
        _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
      } else {
        _currentDate = _currentDate.subtract(const Duration(days: 7));
      }
    });
  }

  void _nextPeriod() {
    setState(() {
      if (_isMonthlyView) {
        _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
      } else {
        _currentDate = _currentDate.add(const Duration(days: 7));
      }
    });
  }

  void _toggleInterest(String eventId) {
    setState(() {
      if (_interestedEvents.contains(eventId)) {
        _interestedEvents.remove(eventId);
      } else {
        _interestedEvents.add(eventId);
      }
    });

    final event = _events.firstWhere((e) => e.id == eventId);
    final action = _interestedEvents.contains(eventId) ? 'interested in' : 'no longer interested in';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You are $action ${event.title}')),
    );
  }

  Future<void> _addToCalendar(ApiEvent event) async {
    // In a real app, this would integrate with device calendar
    // For now, we'll show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${event.title} added to your calendar')),
    );
  }

  Future<void> _openRegistration(ApiEvent event) async {
    // In a real app, this would open external registration URL
    // For now, we'll show the registration info
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening registration for ${event.title}')),
    );
  }

  List<ApiEvent> _getEventsForDate(DateTime date) {
    return _events.where((event) {
      final eventDate = event.startDate;
      return eventDate.year == date.year &&
             eventDate.month == date.month &&
             eventDate.day == date.day;
    }).toList();
  }

  List<ApiEvent> _getEventsForWeek(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    return _events.where((event) {
      final eventDate = event.startDate;
      return eventDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
             eventDate.isBefore(weekEnd.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Calendar'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: Icon(_isMonthlyView ? Icons.view_week : Icons.calendar_view_month),
            onPressed: _toggleView,
            tooltip: _isMonthlyView ? 'Switch to Weekly View' : 'Switch to Monthly View',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshEvents,
            tooltip: 'Refresh Events',
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar Header
          _buildCalendarHeader(),

          // Loading/Error States
          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_errorMessage != null)
            Expanded(
              child: Center(
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
                      onPressed: _refreshEvents,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else
            // Calendar View
            Expanded(
              child: _isMonthlyView
                  ? _buildMonthlyView()
                  : _buildWeeklyView(),
            ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    final periodText = _isMonthlyView
        ? '${_getMonthName(_currentDate.month)} ${_currentDate.year}'
        : 'Week of ${_formatDate(_getWeekStart(_currentDate))}';

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 32),
            onPressed: _previousPeriod,
          ),
          Text(
            periodText,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 32),
            onPressed: _nextPeriod,
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyView() {
    final daysInMonth = _getDaysInMonth(_currentDate.year, _currentDate.month);
    final firstDayOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    final startingWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday

    return Column(
      children: [
        // Day headers
        Row(
          children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
              .map((day) => Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      color: Colors.blue[50],
                      child: Text(
                        day,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ))
              .toList(),
        ),

        // Calendar grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.2,
            ),
            itemCount: 42, // 6 weeks * 7 days
            itemBuilder: (context, index) {
              final dayOffset = index - (startingWeekday - 1);
              final date = firstDayOfMonth.add(Duration(days: dayOffset));
              final isCurrentMonth = date.month == _currentDate.month;
              final isToday = date.year == DateTime.now().year &&
                             date.month == DateTime.now().month &&
                             date.day == DateTime.now().day;
              final dayEvents = _getEventsForDate(date);

              return GestureDetector(
                onTap: dayEvents.isNotEmpty ? () => _showDayEvents(date, dayEvents) : null,
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isToday
                        ? Colors.blue[100]
                        : isCurrentMonth
                            ? Colors.white
                            : Colors.grey[100],
                    border: Border.all(
                      color: isToday ? Colors.blue : Colors.grey[300]!,
                      width: isToday ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            color: isCurrentMonth ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                      if (dayEvents.isNotEmpty)
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            itemCount: dayEvents.length,
                            itemBuilder: (context, eventIndex) {
                              final event = dayEvents[eventIndex];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 1),
                                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                                decoration: BoxDecoration(
                                  color: _getEventColor(event.category),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Text(
                                  event.title,
                                  style: const TextStyle(
                                    fontSize: 8,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyView() {
    final weekStart = _getWeekStart(_currentDate);
    final weekEvents = _getEventsForWeek(weekStart);

    return Column(
      children: [
        // Time slots (simplified for demo)
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: weekEvents.length,
            itemBuilder: (context, index) {
              final event = weekEvents[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
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
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getEventColor(event.category),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              event.category.toUpperCase(),
                              style: const TextStyle(
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
                        '${_formatDate(event.startDate)} at ${_formatTime(event.startDate)} - ${_formatTime(event.endDate)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.description,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _addToCalendar(event),
                              icon: const Icon(Icons.calendar_today),
                              label: const Text('Add to Calendar'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _toggleInterest(event.id),
                              icon: Icon(
                                _interestedEvents.contains(event.id)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _interestedEvents.contains(event.id)
                                    ? Colors.red
                                    : null,
                              ),
                              label: Text(
                                _interestedEvents.contains(event.id)
                                    ? 'Interested'
                                    : 'Mark Interested',
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (event.registrationUrl != null && event.registrationUrl!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _openRegistration(event),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              child: const Text('Register Now'),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDayEvents(DateTime date, List<ApiEvent> events) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Events on ${_formatDate(date)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_formatTime(event.startDate)} - ${_formatTime(event.endDate)}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            Text(event.description),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _addToCalendar(event);
                                    },
                                    child: const Text('Add to Calendar'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _toggleInterest(event.id);
                                    },
                                    child: const Text('Mark Interested'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods
  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  String _formatDate(DateTime date) {
    return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final amPm = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $amPm';
  }

  Color _getEventColor(String category) {
    switch (category.toLowerCase()) {
      case 'social': return Colors.blue;
      case 'fitness': return Colors.green;
      case 'educational': return Colors.purple;
      case 'entertainment': return Colors.orange;
      case 'volunteer': return Colors.teal;
      default: return Colors.grey;
    }
  }
}