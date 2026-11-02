import 'package:flutter/material.dart';

void main() {
  runApp(const AliceApp());
}

class AliceApp extends StatelessWidget {
  const AliceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mundo da Alice',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE040FB),
          secondary: const Color(0xFF7C4DFF),
        ),
      ),
      home: const HomeAlice(),
    );
  }
}

class HomeAlice extends StatelessWidget {
  const HomeAlice({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      appBar: AppBar(
        title: const Text('Mundo da Alice - Rosa e Roxo'),
        backgroundColor: const Color(0xFFE040FB),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_stories, size: 80, color: Color(0xFF7C4DFF)),
            const SizedBox(height: 20),
            const Text('Build 103 Verde!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Rotina com foto, jogos e lojinha Robux'),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C4DFF)),
              child: const Text('FIZ! 📸'),
            ),
          ],
        ),
      ),
    );
  }
}
