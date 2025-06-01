import 'package:flutter/material.dart';
import 'package:footinfo_app/services/user_service.dart';
import '../models/user.dart';

class RegisterPage extends StatelessWidget {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final userService = UserService();

  RegisterPage({super.key});

  void _register(BuildContext context) async {
    await userService.insertUser(UserModel(
        username: usernameController.text, password: passwordController.text));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Berhasil daftar')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daftar')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Username')),
            TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password')),
            SizedBox(height: 16),
            ElevatedButton(
                onPressed: () => _register(context), child: Text('Daftar')),
          ],
        ),
      ),
    );
  }
}
