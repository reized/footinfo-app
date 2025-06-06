import 'package:flutter/material.dart';

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Kesan',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Mata kuliah Teknologi dan Pemrograman Mobile memberikan materi dari pengetahuan yang sangat mendasar dalam pemrograman mobile, sehingga kita jadi tahu tentang pondasi bagaimana perangkat mobile bekerja, jaringan, dan sistemnya. Hal ini sangat membantu dalam memahami konsep pengembangan aplikasi mobile secara menyeluruh.',
              ),
              SizedBox(height: 24),
              Text(
                'Saran',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Untuk meningkatkan kualitas pembelajaran, sebaiknya ditambahkan lebih banyak contoh penerapan dalam bentuk kode di dalam materi, sehingga tidak hanya membahas konsep dasar tetapi juga implementasi praktisnya. Ini akan membantu mahasiswa lebih memahami bagaimana menerapkan teori ke dalam pengembangan aplikasi nyata.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}