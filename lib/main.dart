
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const AliceApp());

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
          primary: const Color(0xFF7C4DFF),
          secondary: const Color(0xFFE040FB),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF0F8),
      ),
      home: const AliceHome(),
    );
  }
}

class Mundo {
  final String nome;
  final String emoji;
  final List<String> tarefas;
  bool desbloqueado;
  Mundo(this.nome, this.emoji, this.tarefas, {this.desbloqueado = false});
}

class AliceHome extends StatefulWidget {
  const AliceHome({super.key});
  @override
  State<AliceHome> createState() => _AliceHomeState();
}

class _AliceHomeState extends State<AliceHome> {
  final picker = ImagePicker();
  int estrelas = 0;
  int robux = 0;
  int mundoAtual = 0;
  Map<String, Uint8List?> fotos = {};
  Map<String, bool> feitas = {};
  bool robloxLiberado = false;
  int minutosRoblox = 40;

  late List<Mundo> mundos = [
    Mundo('Mundo 1 - Acordar', '🌞', ['Arrumar cama', 'Escovar dentes', 'Tomar café'], desbloqueado: true),
    Mundo('Mundo 2 - Estudar', '📚', ['Ler 1 página', 'Jogo das sílabas BOLA', 'Escrever nome']),
    Mundo('Mundo 3 - Ajudar', '💜', ['Guardar brinquedos', 'Ajudar na mesa', 'Foto da organização']),
    Mundo('Mundo 4 - Brincar', '🎮', ['Jogo evolutivo 1', 'Jogo evolutivo 2', 'Desenho livre']),
    Mundo('Mundo 5 - Noite', '🌙', ['Banho', 'Jantar', 'História']),
  ];

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      estrelas = prefs.getInt('estrelas') ?? 0;
      robux = prefs.getInt('robux') ?? 0;
      mundoAtual = prefs.getInt('mundoAtual') ?? 0;
      robloxLiberado = prefs.getBool('robloxLiberado') ?? false;
    });
  }

  Future<void> salvar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('estrelas', estrelas);
    await prefs.setInt('robux', robux);
    await prefs.setInt('mundoAtual', mundoAtual);
    await prefs.setBool('robloxLiberado', robloxLiberado);
  }

  Future<void> tirarFoto(String tarefa) async {
    final XFile? img = await picker.pickImage(source: ImageSource.camera, imageQuality: 60);
    if (img != null) {
      final bytes = await img.readAsBytes();
      setState(() {
        fotos[tarefa] = bytes;
        feitas[tarefa] = true;
        estrelas += 10;
        robux += 10;
        verificarMundo();
      });
      salvar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Foto da "$tarefa" salva! +10 estrelas ⭐'), backgroundColor: const Color(0xFF7C4DFF)),
      );
    }
  }

  void verificarMundo() {
    final tarefasDoMundo = mundos[mundoAtual].tarefas;
    bool todasFeitas = tarefasDoMundo.every((t) => feitas[t] == true);
    if (todasFeitas && mundoAtual < mundos.length - 1) {
      setState(() {
        mundos[mundoAtual + 1].desbloqueado = true;
        mundoAtual++;
        if (mundoAtual == 2) {
          robloxLiberado = true;
          minutosRoblox = 40;
        }
      });
      showDialog(context: context, builder: (_) => AlertDialog(
        title: const Text('🎉 Mundo liberado!'),
        content: Text('Você liberou o ${mundos[mundoAtual].nome}'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Continuar'))],
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF7C4DFF),
        foregroundColor: Colors.white,
        title: const Text('Mundo da Alice - Rosa e Roxo'),
        actions: [
          Padding(padding: const EdgeInsets.only(right: 12), child: Center(child: Text('⭐ $estrelas  |  R\$ $robux', style: const TextStyle(fontWeight: FontWeight.bold)))),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Timer Roblox
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: robloxLiberado ? Colors.green[100] : Colors.grey[200], borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE040FB), width: 2)),
              child: Row(
                children: [
                  Icon(robloxLiberado ? Icons.videogame_asset : Icons.lock, color: const Color(0xFF7C4DFF), size: 32),
                  const SizedBox(width: 12),
                  Expanded(child: Text(robloxLiberado ? 'Roblox liberado: $minutosRoblox min até 18:30' : 'Complete o Mundo 2 para liberar 40 min de Roblox', style: const TextStyle(fontWeight: FontWeight.bold))),
                  if (robloxLiberado) ElevatedButton(onPressed: () { setState(() { robloxLiberado = false; }); salvar(); }, child: const Text('Pausar')),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Mundos
            ...mundos.asMap().entries.map((entry) {
              int idx = entry.key;
              Mundo m = entry.value;
              bool ativo = idx == mundoAtual;
              return Card(
                color: m.desbloqueado ? Colors.white : Colors.grey[300],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: ativo ? const Color(0xFFE040FB) : Colors.transparent, width: 3)),
                child: ExpansionTile(
                  initiallyExpanded: ativo,
                  leading: Text(m.emoji, style: const TextStyle(fontSize: 32)),
                  title: Text(m.nome, style: TextStyle(fontWeight: FontWeight.bold, color: m.desbloqueado ? const Color(0xFF7C4DFF) : Colors.grey)),
                  subtitle: Text(m.desbloqueado ? (ativo ? 'Faça as tarefas com foto 📸' : 'Concluído ✅') : '🔒 Bloqueado - termine o anterior'),
                  children: m.tarefas.map((tarefa) {
                    bool feita = feitas[tarefa] == true;
                    return ListTile(
                      leading: fotos[tarefa] != null ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.memory(fotos[tarefa]!, width: 50, height: 50, fit: BoxFit.cover)) : Icon(feita ? Icons.check_circle : Icons.circle_outlined, color: const Color(0xFFE040FB)),
                      title: Text(tarefa),
                      trailing: m.desbloqueado ? ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE040FB), foregroundColor: Colors.white),
                        onPressed: () => tirarFoto(tarefa),
                        icon: const Icon(Icons.camera_alt),
                        label: Text(feita ? 'TROCAR 📸' : 'FIZ! 📸'),
                      ) : null,
                    );
                  }).toList(),
                ),
              );
            }),
            const SizedBox(height: 12),
            // Lojinha
            Card(
              color: const Color(0xFF7C4DFF),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  const Text('Lojinha de Robux - Alice', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    _itemLoja('10 Robux', 50, '🎁'),
                    _itemLoja('40 min Roblox', 100, '🎮'),
                    _itemLoja('História nova', 30, '📖'),
                  ]),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemLoja(String nome, int preco, String emoji) {
    bool pode = robux >= preco;
    return Column(children: [
      Text(emoji, style: const TextStyle(fontSize: 32)),
      Text(nome, style: const TextStyle(color: Colors.white, fontSize: 12)),
      const SizedBox(height: 4),
      ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: pode ? Colors.white : Colors.grey, foregroundColor: const Color(0xFF7C4DFF)),
        onPressed: pode ? () { setState(() { robux -= preco; if (nome.contains('Roblox')) { robloxLiberado = true; minutosRoblox = 40; } }); salvar(); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Comprou $nome!'))); } : null,
        child: Text('$preco R\$'),
      ),
    ]);
  }
}
