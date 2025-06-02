import '../services/currency_service.dart';

class Player {
  final int id;
  final String name;
  final String photo;
  final String age;
  final String nationality;
  final String position;
  final String height;
  final String weight;
  late final double marketValueUSD;

  Player({
    required this.id,
    required this.name,
    required this.photo,
    required this.nationality,
    required this.age,
    required this.position,
    required this.height,
    required this.weight,
  }) {
    // Generate random market value when player is created
    marketValueUSD = CurrencyService.generateRandomMarketValue();
  }

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

  // Get market value in specific currency
  double getMarketValue(String currency) {
    return CurrencyService.convertCurrency(marketValueUSD, 'USD', currency);
  }

  // Get formatted market value in specific currency
  String getFormattedMarketValue(String currency) {
    final value = getMarketValue(currency);
    return CurrencyService.formatCurrency(value, currency);
  }
}
