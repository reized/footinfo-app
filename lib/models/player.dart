class Player {
  final int id;
  final String name;
  final String photo;
  final String age;
  final String nationality;
  final String position;
  final String height;
  final String weight;

  Player({
    required this.id,
    required this.name,
    required this.photo,
    required this.nationality,
    required this.age,
    required this.position,
    required this.height,
    required this.weight,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    final player = json['player'];
    return Player(
      id: player['id'],
      name: player['name'] ?? 'Unknown',
      photo: player['photo'] ?? 'Unknown',
      age: player['age']?.toString() ?? 'Unknown',
      nationality: player['nationality'] ?? 'Unknown',
      position: player['position'] ?? 'Unknown',
      height: player['height'] ?? 'Unknown',
      weight: player['weight'] ?? 'Unknown',
    );
  }
}
