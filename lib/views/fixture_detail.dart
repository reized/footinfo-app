import 'package:flutter/material.dart';
import '../models/fixture.dart';

class FixtureDetailPage extends StatefulWidget {
  final Fixture fixture;

  const FixtureDetailPage({super.key, required this.fixture});

  @override
  State<FixtureDetailPage> createState() => _FixtureDetailPageState();
}

class _FixtureDetailPageState extends State<FixtureDetailPage> {
  bool _isNotificationEnabled = false;
  bool _showTimeZones = false;

  void _toggleNotification() {
    setState(() {
      _isNotificationEnabled = !_isNotificationEnabled;
    });

    if (_isNotificationEnabled) {
      // Show snackbar when notification is enabled
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.notifications_active, color: Colors.white),
              const SizedBox(width: 8),
              const Text('Pengingat pertandingan diaktifkan'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      // Show snackbar when notification is disabled
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.notifications_off, color: Colors.white),
              const SizedBox(width: 8),
              const Text('Pengingat pertandingan dinonaktifkan'),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Map<String, String> _convertToTimeZones() {
    try {
      DateTime utcTime = DateTime.parse(widget.fixture.date);

      // Convert to different time zones
      DateTime wibTime = utcTime.add(Duration(hours: 7)); // UTC+7
      DateTime witaTime = utcTime.add(Duration(hours: 8)); // UTC+8
      DateTime witTime = utcTime.add(Duration(hours: 9)); // UTC+9
      DateTime londonTime = utcTime.add(
        Duration(hours: 1),
      ); // UTC+1 (GMT+1 for summer time)

      String formatTime(DateTime time) {
        return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      }

      return {
        'WIB': formatTime(wibTime),
        'WITA': formatTime(witaTime),
        'WIT': formatTime(witTime),
        'London': formatTime(londonTime),
        'UTC': widget.fixture.time,
      };
    } catch (e) {
      return {
        'WIB': widget.fixture.time,
        'WITA': widget.fixture.time,
        'WIT': widget.fixture.time,
        'London': widget.fixture.time,
        'UTC': widget.fixture.time,
      };
    }
  }

  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      List<String> months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      List<String> days = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];

      String dayName = days[date.weekday - 1];
      String month = months[date.month - 1];

      return '$dayName, ${date.day} $month ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'NS':
        return 'Not Started';
      case 'LIVE':
        return 'Live Now';
      case 'HT':
        return 'Half Time';
      case 'FT':
        return 'Full Time';
      case 'CANC':
        return 'Cancelled';
      case 'SUSP':
        return 'Suspended';
      case 'PST':
        return 'Postponed';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'NS':
        return Colors.blue;
      case 'LIVE':
        return Colors.red;
      case 'HT':
        return Colors.orange;
      case 'FT':
        return Colors.green;
      case 'CANC':
      case 'SUSP':
      case 'PST':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  Widget _buildTeamSection(String teamName, String teamLogo, bool isHome) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                teamLogo,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.sports_soccer,
                      size: 40,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            teamName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            isHome ? 'HOME' : 'AWAY',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeZoneCard(
    String zone,
    String time,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            zone,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timeZones = _convertToTimeZones();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Match Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Teams Section with Purple Background
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.purple,
                    Colors.purple.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildTeamSection(
                        widget.fixture.homeTeamName,
                        widget.fixture.homeTeamLogo,
                        true,
                      ),

                      // VS Section
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Text(
                                'VS',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      _buildTeamSection(
                        widget.fixture.awayTeamName,
                        widget.fixture.awayTeamLogo,
                        false,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Match Time and Venue Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Date
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formatDate(widget.fixture.date),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Time with Time Zone Toggle
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showTimeZones = !_showTimeZones;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Theme.of(context).primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.fixture.time,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _showTimeZones
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(widget.fixture.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(widget.fixture.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Venue at the bottom
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.stadium,
                          color: Colors.orange,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Venue',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.fixture.venueName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Time Zones Section (Expandable)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _showTimeZones ? null : 0,
              child: _showTimeZones
                  ? Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                color: Colors.purple,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Match Time in Different Zones',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Indonesian Time Zones
                          Row(
                            children: [
                              Expanded(
                                child: _buildTimeZoneCard(
                                  'WIB',
                                  timeZones['WIB']!,
                                  Icons.location_on,
                                  Colors.red,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTimeZoneCard(
                                  'WITA',
                                  timeZones['WITA']!,
                                  Icons.location_on,
                                  Colors.orange,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: _buildTimeZoneCard(
                                  'WIT',
                                  timeZones['WIT']!,
                                  Icons.location_on,
                                  Colors.green,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTimeZoneCard(
                                  'London',
                                  timeZones['London']!,
                                  Icons.public,
                                  Colors.blue,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'UTC Time: ${timeZones['UTC']}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 24),

            // Notification Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Match Reminder',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Get notified before the match starts',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  // Notification Toggle
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _isNotificationEnabled
                              ? Colors.green.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _isNotificationEnabled
                              ? Icons.notifications_active
                              : Icons.notifications_off,
                          color: _isNotificationEnabled
                              ? Colors.green
                              : Colors.grey,
                          size: 24,
                        ),
                      ),
                      title: Text(
                        _isNotificationEnabled
                            ? 'Reminder Enabled'
                            : 'Enable Reminder',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        _isNotificationEnabled
                            ? 'You will be notified 30 minutes before kickoff'
                            : 'Tap to enable match reminder',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Switch(
                        value: _isNotificationEnabled,
                        onChanged: (value) => _toggleNotification(),
                        activeColor: Colors.green,
                      ),
                      onTap: _toggleNotification,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
