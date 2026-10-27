import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const TestApp());

class TestApp extends StatelessWidget {
  const TestApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF8A2BE2),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🌈 Mundo da Alice - Teste Camera', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final picker = ImagePicker();
                  final file = await picker.pickImage(source: ImageSource.camera);
                  print(file?.path);
                },
                child: const Text('FIZ! 📸 Tirar foto'),
              ),
              const SizedBox(height: 20),
              const Text('Aqui pode errar. Toda tentativa vale estrela.', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
