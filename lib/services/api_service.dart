import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> fetchTeams(String query) async {
  final response = await http.get(
    Uri.parse('https://v3.football.api-sports.io/teams?search=$query'),
    headers: {
      'x-apisports-key': '86ab1cfe67a66269855aa7f7d32ce1e7',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print(data);
  } else {
    throw Exception('Gagal memuat data tim');
  }
}
