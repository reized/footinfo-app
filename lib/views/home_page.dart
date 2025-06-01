import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Footinfo', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Center(child: Text('Home Page')),
    );
  }
}
