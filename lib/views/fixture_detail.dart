import 'package:flutter/material.dart';
import '../models/fixture.dart';
import '../services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FixtureDetailPage extends StatefulWidget {
  final Fixture fixture;

  const FixtureDetailPage({super.key, required this.fixture});

  @override
  State<FixtureDetailPage> createState() => _FixtureDetailPageState();
}

class _FixtureDetailPageState extends State<FixtureDetailPage> {
  bool _isNotificationEnabled = false;
  bool _showTimeZones = false;
  bool _isLoading = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadNotificationState();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString('user_id') ?? 'guest';
  }

  Future<void> _loadNotificationState() async {
    await _loadCurrentUser();
    final prefs = await SharedPreferences.getInstance();
    final key = 'notification_${_currentUserId}_${widget.fixture.id}';
    setState(() {
      _isNotificationEnabled = prefs.getBool(key) ?? false;
    });
  }

  Future<void> _saveNotificationState(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'notification_${_currentUserId}_${widget.fixture.id}';
    await prefs.setBool(key, enabled);

    await _updateUserNotificationList(enabled);
  }

  Future<void> _updateUserNotificationList(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    final listKey = 'active_notifications_$_currentUserId';
    List<String> activeNotifications = prefs.getStringList(listKey) ?? [];

    String fixtureKey = widget.fixture.id.toString();

    if (enabled) {
      if (!activeNotifications.contains(fixtureKey)) {
        activeNotifications.add(fixtureKey);
      }
    } else {
      activeNotifications.remove(fixtureKey);
    }

    await prefs.setStringList(listKey, activeNotifications);
  }

  static Future<List<String>> getUserActiveNotifications(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('active_notifications_$userId') ?? [];
  }

  static Future<void> clearUserNotifications(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final activeNotifications = await getUserActiveNotifications(userId);

    for (String fixtureId in activeNotifications) {
      await NotificationService.cancelNotification(int.parse(fixtureId));
    }

    await prefs.remove('active_notifications_$userId');

    for (String fixtureId in activeNotifications) {
      await prefs.remove('notification_${userId}_$fixtureId');
    }
  }

  Future<void> _toggleNotification() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final hasPermission = await NotificationService.requestPermissions();

      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text('Notification permission denied'),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final newState = !_isNotificationEnabled;

      if (newState) {
        await NotificationService.showInstantNotification(
          id: 999,
          title: '✅ Reminder Enabled!',
          body:
              'You will be notified 1 hour before ${widget.fixture.homeTeamName} vs ${widget.fixture.awayTeamName}',
        );

        await NotificationService.scheduleMatchReminder(widget.fixture);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.notifications_active, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Match reminder set for ${widget.fixture.homeTeamName} vs ${widget.fixture.awayTeamName}',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else {
        await NotificationService.cancelNotification(widget.fixture.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.notifications_off, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text('Match reminder cancelled'),
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

      setState(() {
        _isNotificationEnabled = newState;
      });
      await _saveNotificationState(newState);
    } catch (e) {
      print('Error toggling notification: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                const Text('Failed to set reminder'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, String> _convertToTimeZones() {
    try {
      DateTime utcTime = DateTime.parse(widget.fixture.date);

      DateTime wibTime = utcTime.add(Duration(hours: 7));
      DateTime witaTime = utcTime.add(Duration(hours: 8));
      DateTime witTime = utcTime.add(Duration(hours: 9));
      DateTime londonTime = utcTime.add(Duration(hours: 1));

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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withAlpha(180),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withAlpha(80),
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
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
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

            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _showTimeZones ? null : 0,
              child: _showTimeZones
                  ? Container(
                      margin: const EdgeInsets.only(top: 16),
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
                    'Get notified 1 hour before the match starts',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

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
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
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
                            ? 'You will be notified 1 hour before kickoff'
                            : 'Tap to enable match reminder',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Switch(
                        value: _isNotificationEnabled,
                        onChanged: _isLoading
                            ? null
                            : (value) => _toggleNotification(),
                        activeColor: Colors.green,
                      ),
                      onTap: _isLoading ? null : _toggleNotification,
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
