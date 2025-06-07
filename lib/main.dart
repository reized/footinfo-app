import 'package:flutter/material.dart';
import 'package:footinfo_app/config/api_config.dart';
import 'package:footinfo_app/views/login_page.dart';
import 'package:footinfo_app/views/main_page.dart';
import 'package:footinfo_app/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ApiConfig.initialize();

  if (!ApiConfig.validateConfig()) {
    print('Warning: Environment configuration is incomplete!');
  }

  await NotificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: ApiConfig.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
      ),
      home: FutureBuilder<bool>(
        future: checkLogin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return snapshot.data! ? MainPage() : LoginPage();
        },
      ),
    );
  }
}
