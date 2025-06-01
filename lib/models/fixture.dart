class Fixture {
  final int id;
  final String date;
  final String time;
  final String homeTeamName;
  final String homeTeamLogo;
  final String awayTeamName;
  final String awayTeamLogo;
  final String venueName;
  final String status;

  Fixture({
    required this.id,
    required this.date,
    required this.time,
    required this.homeTeamName,
    required this.homeTeamLogo,
    required this.awayTeamName,
    required this.awayTeamLogo,
    required this.venueName,
    required this.status,
  });

  factory Fixture.fromJson(Map<String, dynamic> json) {
    final fixture = json['fixture'];
    final teams = json['teams'];
    final venue = json['venue'] ?? {};

    // Parse date & time
    DateTime dateTime = DateTime.parse(fixture['date']);
    String formattedTime =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    return Fixture(
      id: fixture['id'],
      date: fixture['date'] ?? '',
      time: formattedTime,
      homeTeamName: teams['home']['name'] ?? 'Unknown',
      homeTeamLogo: teams['home']['logo'] ?? '',
      awayTeamName: teams['away']['name'] ?? 'Unknown',
      awayTeamLogo: teams['away']['logo'] ?? '',
      venueName: venue['name'] ?? 'Unknown Venue',
      status: fixture['status']['short'] ?? 'NS',
    );
  }
}
