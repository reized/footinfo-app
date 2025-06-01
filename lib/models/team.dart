class Team {
  final int id;
  final String name;
  final String logo;
  final String country;
  final String venueName;

  Team({
    required this.id,
    required this.name,
    required this.logo,
    required this.country,
    required this.venueName,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    final team = json['team'];
    final venue = json['venue'];
    return Team(
      id: team['id'],
      name: team['name'] ?? 'Unknown',
      logo: team['logo'] ?? 'Unknown',
      country: team['country'] ?? 'Unknown',
      venueName: venue['name'] ?? 'Unknown',
    );
  }
}
