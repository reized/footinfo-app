import 'package:flutter/material.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kesan Pesan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Message',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Thank you for using FootInfo App. This app was built with the hope of helping users access football team information easily and interactively. We appreciate every feedback and hope this app can be useful for football fans everywhere.',
              ),
              SizedBox(height: 24),
              Text(
                'Impression',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Developing this application has been a great learning experience. We enjoyed exploring the API, implementing features, and solving challenges along the way. We hope the users also enjoy the experience while using the app.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
