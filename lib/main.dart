import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AliceApp());
}

class Task {
  final String id;
  final String titulo;
  final String horario;
  final String emoji;
  final int mundo;
  bool feito;
  String? fotoPath;
  String? horaFeita;
  Task({required this.id, required this.titulo, required this.horario, required this.emoji, required this.mundo, this.feito=false, this.fotoPath, this.horaFeita});
  Map<String,dynamic> toJson() => {'id':id,'feito':feito,'fotoPath':fotoPath,'horaFeita':horaFeita};
}

class AliceApp extends StatelessWidget {
  const AliceApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mundo da Alice',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF8A2BE2), fontFamily: 'Roboto'),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int tab = 0;
  int estrelas = 0;
  int robux = 0;
  int robloxSegundos = 40*60;
  Timer? timerRoblox;
  List<Task> tarefas = [
    Task(id:'t1', titulo:'Chegada + Lanche', horario:'16:00-16:30', emoji:'ð ', mundo:1),
    Task(id:'t2', titulo:'Brincar Livre', horario:'16:30-16:50', emoji:'ð§¸', mundo:1),
    Task(id:'t3', titulo:'Leitura Divertida (ler junto, sem punir erro)', horario:'17:00-17:25', emoji:'ð', mundo:3),
    Task(id:'t4', titulo:'NÃºmeros Brincando com objetos', horario:'17:25-17:45', emoji:'ð¢', mundo:4),
    Task(id:'t5', titulo:'Ãgua / Pausa', horario:'17:45-18:05', emoji:'ð§', mundo:2),
    Task(id:'t6', titulo:'Jantar', horario:'18:05-18:30', emoji:'ð', mundo:2),
    Task(id:'t7', titulo:'Banho / Dentes', horario:'18:30-19:00', emoji:'ð', mundo:2),
    Task(id:'t8', titulo:'HistÃ³ria Calma', horario:'19:00-19:30', emoji:'ð', mundo:3),
  ];
  final picker = ImagePicker();
  final familia = [
    {'nome':'MÃ£e Ana Beatriz','tel':'5521964847749'},
    {'nome':'Pai Matheus','tel':'5521997963651'},
    {'nome':'Padrasto Jean','tel':'5521970774736'},
  ];

  @override
  void initState() {
    super.initState();
    _load();
    timerRoblox = Timer.periodic(const Duration(seconds:1), (t){
      if(robloxSegundos>0){ setState(()=> robloxSegundos--); }
    });
  }
