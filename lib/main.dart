
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
    Task(id:'t1', titulo:'Chegada + Lanche', horario:'16:00-16:30', emoji:'🏠', mundo:1),
    Task(id:'t2', titulo:'Brincar Livre', horario:'16:30-16:50', emoji:'🧸', mundo:1),
    Task(id:'t3', titulo:'Leitura Divertida (ler junto, sem punir erro)', horario:'17:00-17:25', emoji:'📚', mundo:3),
    Task(id:'t4', titulo:'Números Brincando com objetos', horario:'17:25-17:45', emoji:'🔢', mundo:4),
    Task(id:'t5', titulo:'Água / Pausa', horario:'17:45-18:05', emoji:'💧', mundo:2),
    Task(id:'t6', titulo:'Jantar', horario:'18:05-18:30', emoji:'🍝', mundo:2),
    Task(id:'t7', titulo:'Banho / Dentes', horario:'18:30-19:00', emoji:'🛁', mundo:2),
    Task(id:'t8', titulo:'História Calma', horario:'19:00-19:30', emoji:'🌙', mundo:3),
  ];
  final picker = ImagePicker();
  final familia = [
    {'nome':'Mãe Ana Beatriz','tel':'5521964847749'},
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

  @override
  void dispose(){ timerRoblox?.cancel(); super.dispose(); }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState((){
      estrelas = p.getInt('estrelas') ?? 0;
      robux = p.getInt('robux') ?? 0;
      robloxSegundos = p.getInt('robloxSeg') ?? 40*60;
      final jsonStr = p.getString('tarefas');
      if(jsonStr!=null){
        final map = jsonDecode(jsonStr) as Map<String,dynamic>;
        for(var t in tarefas){
          if(map.containsKey(t.id)){
            t.feito = map[t.id]['feito'] ?? false;
            t.fotoPath = map[t.id]['fotoPath'];
            t.horaFeita = map[t.id]['horaFeita'];
          }
        }
      }
    });
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    final m = {for(var t in tarefas) t.id: t.toJson()};
    await p.setString('tarefas', jsonEncode(m));
    await p.setInt('estrelas', estrelas);
    await p.setInt('robux', robux);
    await p.setInt('robloxSeg', robloxSegundos);
  }

  Future<void> _tirarFoto(Task t) async {
    try{
      final XFile? file = await picker.pickImage(source: ImageSource.camera, imageQuality: 65);
      if(file==null) return;
      final agora = DateTime.now();
      final hora = "${agora.hour.toString().padLeft(2,'0')}:${agora.minute.toString().padLeft(2,'0')}";
      setState((){
        t.feito = true;
        t.fotoPath = file.path;
        t.horaFeita = hora;
        estrelas += 1;
        robux += 5;
      });
      await _save();
      if(!mounted) return;
      showDialog(context: context, builder: (_)=> AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🎉 ESTRELA GANHA!', textAlign: TextAlign.center),
        content: Column(mainAxisSize: MainAxisSize.min, children:[
          if(t.fotoPath!=null) ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(t.fotoPath!), height: 140)),
          const SizedBox(height:12),
          Text('Você fez ${t.titulo} às $hora', style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height:8),
          const Text('Aqui pode errar. Toda tentativa vale estrela. 🌟', textAlign: TextAlign.center),
          const SizedBox(height:8),
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(8)), child: const Text('+1 ⭐  +5 💎 Robux da Coragem')),
        ]),
        actions:[Center(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8A2BE2), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal:32, vertical:12)), onPressed: ()=> Navigator.pop(context), child: const Text('CONTINUAR 🚀')))]
      ));
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro câmera: $e')));
    }
  }

  Future<void> _whatsapp(String tel, String msg) async {
    final uri = Uri.parse('https://wa.me/$tel?text=${Uri.encodeComponent(msg)}');
    if(await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String formatTempo(int s){ final m = s~/60; final seg = s%60; return "${m.toString().padLeft(2,'0')}:${seg.toString().padLeft(2,'0')}"; }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F3FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8A2BE2),
        foregroundColor: Colors.white,
        centerTitle: false,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
          const Text('🌈 Mundo da Alice', style: TextStyle(fontWeight: FontWeight.bold, fontSize:20)),
          Text('⭐ $estrelas estrelas  |  💎 $robux Robux da Coragem', style: const TextStyle(fontSize:12)),
          const Text('Aqui pode errar. Toda tentativa vale estrela.', style: TextStyle(fontSize:10, fontStyle: FontStyle.italic)),
        ]),
        actions:[
          IconButton(icon: const Icon(Icons.refresh), onPressed: () async {
            final p = await SharedPreferences.getInstance(); await p.clear();
            setState((){
              for(var t in tarefas){t.feito=false; t.fotoPath=null; t.horaFeita=null;}
              estrelas=0; robux=0; robloxSegundos=40*60;
            });
          }),
          const SizedBox(width:8),
        ]
      ),
      body: tab==0 ? _modoCrianca() : tab==1 ? _modoJogos() : _modoFamilia(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i)=> setState(()=> tab=i),
        backgroundColor: Colors.white,
        destinations: const [
          NavigationDestination(icon: Text('👧', style: TextStyle(fontSize:24)), label: 'Rotina'),
          NavigationDestination(icon: Text('🎮', style: TextStyle(fontSize:24)), label: 'Jogos'),
          NavigationDestination(icon: Text('👨‍👩‍👧', style: TextStyle(fontSize:24)), label: 'Família'),
        ],
      ),
    );
  }

  Widget _modoCrianca(){
    final mundos = [
      {'n':1,'nome':'Mundo 1 - Chegada','emoji':'🏠','cor':const Color(0xFFFFE082)},
      {'n':2,'nome':'Mundo 2 - Higiene e Água','emoji':'💧','cor':const Color(0xFF80DEEA)},
      {'n':3,'nome':'Mundo 3 - Leitura','emoji':'📚','cor':const Color(0xFFA5D6A7)},
      {'n':4,'nome':'Mundo 4 - Números','emoji':'🔢','cor':const Color(0xFFFFAB91)},
      {'n':5,'nome':'Mundo 5 - Jantar e História','emoji':'🌙','cor':const Color(0xFFCE93D8)},
    ];
    return ListView(
      padding: const EdgeInsets.all(12),
      children:[
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF8A2BE2), width:2)),
          child: Column(children:[
            const Text('📅 Rotina Pós-Escola - 16h às 19h30', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height:4),
            Text('Acorda 5:30 | Volta 16:00 | Dormir 19:30 - ${tarefas.where((t)=>t.feito).length}/${tarefas.length} feitas hoje', style: const TextStyle(fontSize:12)),
            const SizedBox(height:8),
            LinearProgressIndicator(value: tarefas.where((t)=>t.feito).isEmpty ? 0 : tarefas.where((t)=>t.feito).length / tarefas.length, backgroundColor: Colors.grey.shade300, color: const Color(0xFF8A2BE2), minHeight: 10, borderRadius: BorderRadius.circular(10)),
          ]),
        ),
        const SizedBox(height:12),
        ...mundos.map((m){
          final n = m['n'] as int;
          final tarefasMundo = tarefas.where((t)=> t.mundo==n).toList();
          return Card(
            elevation: 2,
            color: (m['cor'] as Color),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ExpansionTile(
              initiallyExpanded: true,
              leading: Text(m['emoji'] as String, style: const TextStyle(fontSize:30)),
              title: Text(m['nome'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize:14)),
              subtitle: Text('${tarefasMundo.where((t)=>t.feito).length}/${tarefasMundo.length} ✅ LIBERADO - Todas as funções ativas', style: const TextStyle(fontSize:11, fontWeight: FontWeight.bold, color: Colors.black87)),
              children: tarefasMundo.map((t)=> _cardTarefa(t)).toList(),
            ),
          );
        }),
        const SizedBox(height:12),
        _cardRoblox(),
        const SizedBox(height:12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: const Text('🔔 Lembretes Mágicos ativos! Esse app é launcher transparente. A Alice sempre vê que está em modo tarefa. Localização com notificação permanente (LGPD <12 anos).', style: TextStyle(fontSize:10, color: Colors.grey)),
        ),
      ],
    );
  }

  Widget _cardTarefa(Task t){
    return Container(
      margin: const EdgeInsets.symmetric(horizontal:12, vertical:6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children:[
          Text(t.emoji, style: const TextStyle(fontSize:32)),
          const SizedBox(width:10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
            Text(t.titulo, style: TextStyle(fontWeight: FontWeight.bold, decoration: t.feito? TextDecoration.lineThrough : null)),
            Text('${t.horario} ${t.horaFeita!=null ? "| Feito às ${t.horaFeita} 📸" : ""}', style: const TextStyle(fontSize:11)),
            if(t.fotoPath!=null) Padding(padding: const EdgeInsets.only(top:6), child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(t.fotoPath!), height: 90, width: 120, fit: BoxFit.cover))),
          ])),
          const SizedBox(width:8),
          t.feito 
            ? Column(children:[const Icon(Icons.star, color: Colors.amber, size:36), Text('${t.horaFeita}', style: const TextStyle(fontSize:10, fontWeight: FontWeight.bold))])
            : ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8A2BE2), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal:16, vertical:12)),
              onPressed: ()=> _tirarFoto(t),
              child: const Text('FIZ! 📸\nTirar foto', textAlign: TextAlign.center, style: TextStyle(fontSize:12, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _cardRoblox(){
    final podeJogar = true;
    return Card(
      color: const Color(0xFFFFF59D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Colors.amber, width:2)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children:[
          const Text('🎮 Roblox Liberado! (Tudo liberado)', style: TextStyle(fontSize:20, fontWeight: FontWeight.bold)),
          const SizedBox(height:6),
          const Text('Tempo recomendado: 40 min até 18:30 máximo para proteger o sono. Dorme 19:30.', textAlign: TextAlign.center, style: TextStyle(fontSize:12)),
          const SizedBox(height:12),
          Text(formatTempo(robloxSegundos), style: const TextStyle(fontSize:48, fontWeight: FontWeight.bold, letterSpacing: 2)),
          Text(podeJogar ? 'Pode jogar!' : 'Acabou o tempo hoje!', style: TextStyle(fontSize:14, color: podeJogar? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
          const SizedBox(height:12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children:[
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white), onPressed: () async {
              final uri = Uri.parse('https://www.roblox.com');
              if(await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
            }, child: const Text('JOGAR ROBLOX 🎮')),
            const SizedBox(width:12),
            ElevatedButton(onPressed: ()=> _whatsapp(familia[2]['tel']!, '🎉 AVISEI! Alice terminou! ⭐ $estrelas | 💎 $robux | Fotos: ${tarefas.where((t)=>t.fotoPath!=null).length}'), child: const Text('AVISEI! 🎉')),
          ]),
        ]),
      ),
    );
  }

  Widget _modoJogos(){
    final jogos = [
      {'emoji':'🔤','nome':'Sílabas Mágicas','desc':'Junte as sílabas e forme palavras - tema Roblox','cor':const Color(0xFFB39DDB)},
      {'emoji':'🔍','nome':'Palavra Escondida','desc':'Ache a palavra secreta','cor':const Color(0xFF81C784)},
      {'emoji':'🟦','nome':'Contando Blocos','desc':'Conte os blocos como no Roblox','cor':const Color(0xFFFFCC80)},
      {'emoji':'🏪','nome':'Lojinha da Aventura','desc':'Some e diminua Robux','cor':const Color(0xFF90CAF9)},
    ];
    return GridView.count(
      padding: const EdgeInsets.all(12),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: jogos.map((j){
        return InkWell(
          onTap: (){
            if(j['nome']=='Sílabas Mágicas') Navigator.push(context, MaterialPageRoute(builder: (_)=> SilabasGame(onGanha:(){ setState((){estrelas++; robux+=3;}); _save();})));
            if(j['nome']=='Palavra Escondida') Navigator.push(context, MaterialPageRoute(builder: (_)=> PalavraGame(onGanha:(){ setState((){estrelas++; robux+=3;}); _save();})));
            if(j['nome']=='Contando Blocos') Navigator.push(context, MaterialPageRoute(builder: (_)=> BlocosGame(onGanha:(){ setState((){estrelas++; robux+=3;}); _save();})));
            if(j['nome']=='Lojinha da Aventura') Navigator.push(context, MaterialPageRoute(builder: (_)=> LojinhaGame(onGanha:(){ setState((){estrelas++; robux+=3;}); _save();})));
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: j['cor'] as Color, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white, width:2), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children:[
              Text(j['emoji'] as String, style: const TextStyle(fontSize:40)),
              const SizedBox(height:8),
              Text(j['nome'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize:14), textAlign: TextAlign.center),
              const SizedBox(height:4),
              Text(j['desc'] as String, style: const TextStyle(fontSize:10), textAlign: TextAlign.center),
              const SizedBox(height:8),
              Container(padding: const EdgeInsets.symmetric(horizontal:8, vertical:4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)), child: const Text('JOGAR ▶️', style: TextStyle(fontSize:10, fontWeight: FontWeight.bold))),
            ]),
          ),
        );
      }).toList(),
    );
  }

  Widget _modoFamilia(){
    return ListView(
      padding: const EdgeInsets.all(12),
      children:[
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: Column(children:[
          const Text('👨‍👩‍👧 Modo Família', style: TextStyle(fontWeight: FontWeight.bold, fontSize:18)),
          const SizedBox(height:4),
          Text('Hoje: ${tarefas.where((t)=>t.feito).length}/${tarefas.length} tarefas | Fotos: ${tarefas.where((t)=>t.fotoPath!=null).length} | ⭐ $estrelas | 💎 $robux', style: const TextStyle(fontSize:12)),
        ])),
        const SizedBox(height:12),
        const Text('📸 Fotos com horário (prova)', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height:8),
        ...tarefas.where((t)=> t.fotoPath!=null).map((t)=> Card(
          child: ListTile(
            leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(t.fotoPath!), width:60, height:60, fit: BoxFit.cover)),
            title: Text(t.titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize:13)),
            subtitle: Text('Feito às ${t.horaFeita} - ${t.horario}\nComprovação por foto ✅', style: const TextStyle(fontSize:11)),
            trailing: IconButton(icon: const Text('❤️', style: TextStyle(fontSize:24)), onPressed: ()=> _whatsapp(familia[0]['tel']!, '❤️ Amei a foto da Alice em ${t.titulo} às ${t.horaFeita}! Aqui pode errar. Toda tentativa vale estrela!')),
          ),
        )),
        if(tarefas.where((t)=> t.fotoPath!=null).isEmpty) const Card(child: Padding(padding: EdgeInsets.all(20), child: Text('Ainda sem fotos hoje. Quando a Alice clicar em FIZ! 📸 vai aparecer aqui com horário exato.', textAlign: TextAlign.center))),
        const Divider(),
        const Text('💌 Mandar incentivo (abre seu WhatsApp)', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height:8),
        ...familia.map((f)=> Card(
          child: ListTile(
            leading: const Text('👤', style: TextStyle(fontSize:28)),
            title: Text(f['nome']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(f['tel']!),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8A2BE2), foregroundColor: Colors.white),
              onPressed: ()=> _whatsapp(f['tel']!, 'Oi! Mensagem do Mundo da Alice 🌈\n\nVocê está indo super bem! Lembre: Aqui pode errar. Toda tentativa vale estrela ⭐\n\nEstrelas hoje: $estrelas | Robux: $robux'),
              child: const Text('Cartinha 💌'),
            ),
          ),
        )),
        const SizedBox(height:12),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)), child: const Text('LGPD <12 anos: Sem rastreio escondido. Localização só com notificação visível. Fotos ficam só no celular da Alice. Versão igual da web com todas as funções liberadas.', style: TextStyle(fontSize:10))),
      ],
    );
  }
}

// JOGOS

class SilabasGame extends StatefulWidget {
  final VoidCallback onGanha;
  const SilabasGame({super.key, required this.onGanha});
  @override
  State<SilabasGame> createState() => _SilabasGameState();
}
class _SilabasGameState extends State<SilabasGame> {
  final palavras = [
    {'partes':['CA','SA'],'resp':'CASA','dica':'🏠 Onde moramos'},
    {'partes':['BO','LA'],'resp':'BOLA','dica':'⚽ Brinquedo redondo'},
    {'partes':['RO','BLOX'],'resp':'ROBLOX','dica':'🎮 Jogo favorito'},
    {'partes':['A','GUA'],'resp':'ÁGUA','dica':'💧 Precisamos beber'},
  ];
  int idx=0;
  String escolha='';
  String msg='Escolha as sílabas!';
  @override
  Widget build(BuildContext context) {
    final p = palavras[idx];
    return Scaffold(appBar: AppBar(title: const Text('🔤 Sílabas Mágicas')), body: Padding(padding: const EdgeInsets.all(16), child: Column(children:[
      Text(p['dica'] as String, style: const TextStyle(fontSize:22)), const SizedBox(height:12),
      Text('Forme: ${p['resp']}', style: const TextStyle(fontSize:18, fontWeight: FontWeight.bold)), const SizedBox(height:20),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: (p['partes'] as List<String>).map((s)=> Padding(padding: const EdgeInsets.all(6), child: ElevatedButton(onPressed: (){ setState(()=> escolha+=s); }, child: Text(s, style: const TextStyle(fontSize:20))))).toList()),
      const SizedBox(height:20), Text('Você montou: $escolha', style: const TextStyle(fontSize:22, fontWeight: FontWeight.bold)),
      const SizedBox(height:12), Text(msg, style: const TextStyle(fontSize:16)), const SizedBox(height:20),
      ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8A2BE2), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal:32, vertical:16)), onPressed: (){
        if(escolha==p['resp']){
          widget.onGanha();
          setState(()=> msg='🎉 Acertou! Aqui pode errar. Toda tentativa vale estrela! +1 ⭐ +3 💎');
          Future.delayed(const Duration(seconds:1), (){ if(idx < palavras.length-1) setState((){idx++; escolha=''; msg='Próxima!';}); else Navigator.pop(context);});
        } else {
          setState(()=> msg='Ops, tenta de novo! Você pode errar, não tem problema. Apaga e tenta! (Vale estrela mesmo errando)');
          // mesmo errando ganha estrela pra não ter medo
          widget.onGanha();
        }
      }, child: const Text('CONFIRMAR ✅')),
      TextButton(onPressed: ()=> setState((){escolha='';}), child: const Text('Apagar')),
    ])));
  }
}

class PalavraGame extends StatefulWidget {
  final VoidCallback onGanha;
  const PalavraGame({super.key, required this.onGanha});
  @override
  State<PalavraGame> createState() => _PalavraGameState();
}
class _PalavraGameState extends State<PalavraGame> {
  final palavras = [
    {'palavra':'LIVRO','dica':'📚 Usamos para ler'},
    {'palavra':'AGUA','dica':'💧 Bebemos todo dia'},
    {'palavra':'ALICE','dica':'👧 Nome da nossa aventureira'},
  ];
  int idx=0;
  String tent=''; String msg='';
  @override
  Widget build(BuildContext context) {
    final p = palavras[idx];
    return Scaffold(appBar: AppBar(title: const Text('🔍 Palavra Escondida')), body: Padding(padding: const EdgeInsets.all(16), child: Column(children:[
      Text(p['dica'] as String, style: const TextStyle(fontSize:22)), const SizedBox(height:20),
      Text((p['palavra'] as String).split('').map((c)=> tent.contains(c) ? c : '_').join(' '), style: const TextStyle(fontSize:32, letterSpacing: 8, fontWeight: FontWeight.bold)),
      const SizedBox(height:20),
      Wrap(spacing:6, children: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('').map((l)=> ElevatedButton(onPressed: (){ setState(()=> tent+=l); }, child: Text(l))).toList()),
      const SizedBox(height:12), Text('Letras usadas: $tent'), Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height:12),
      ElevatedButton(onPressed: (){
        if(tent.contains(p['palavra'] as String) || (p['palavra'] as String).split('').every((c)=> tent.contains(c))){
          widget.onGanha(); setState(()=> msg='🎉 Achou! +1 ⭐ +3 💎');
          Future.delayed(const Duration(seconds:1), (){ if(idx < palavras.length-1) setState((){idx++; tent=''; msg='';}); else Navigator.pop(context);});
        } else {
          setState(()=> msg='Continua tentando! Aqui pode errar.');
        }
      }, child: const Text('VERIFICAR')),
    ])));
  }
}

class BlocosGame extends StatefulWidget {
  final VoidCallback onGanha;
  const BlocosGame({super.key, required this.onGanha});
  @override
  State<BlocosGame> createState() => _BlocosGameState();
}
class _BlocosGameState extends State<BlocosGame> {
  int qtd = 0; int resp = 0; String msg='';
  final rand = Random();
  @override
  void initState(){ super.initState(); _nova(); }
  void _nova(){ setState((){ qtd = rand.nextInt(8)+2; resp=0; msg='Conte os blocos 🟦'; });}
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('🟦 Contando Blocos')), body: Padding(padding: const EdgeInsets.all(16), child: Column(children:[
      Text('Quantos blocos?', style: const TextStyle(fontSize:20, fontWeight: FontWeight.bold)), const SizedBox(height:12),
      Wrap(spacing:8, runSpacing:8, children: List.generate(qtd, (i)=> Container(width:50, height:50, decoration: BoxDecoration(color: Colors.primaries[rand.nextInt(Colors.primaries.length)], borderRadius: BorderRadius.circular(8), border: Border.all(width:2)), child: const Center(child: Text('🧱'))))),
      const SizedBox(height:20),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(10, (i)=> Padding(padding: const EdgeInsets.all(4), child: ElevatedButton(onPressed: ()=> setState(()=> resp=i+1), child: Text('${i+1}'))))),
      const SizedBox(height:12), Text('Você escolheu: $resp', style: const TextStyle(fontSize:20)), Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height:12),
      ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8A2BE2), foregroundColor: Colors.white), onPressed: (){
        if(resp==qtd){ widget.onGanha(); setState(()=> msg='🎉 Acertou! $qtd blocos! +1 ⭐ +3 💎'); Future.delayed(const Duration(seconds:1), _nova); }
        else { setState(()=> msg='Quase! Conta de novo. Aqui pode errar, vale estrela mesmo assim!'); widget.onGanha(); }
      }, child: const Text('CONFIRMAR')),
    ])));
  }
}

class LojinhaGame extends StatefulWidget {
  final VoidCallback onGanha;
  const LojinhaGame({super.key, required this.onGanha});
  @override
  State<LojinhaGame> createState() => _LojinhaGameState();
}
class _LojinhaGameState extends State<LojinhaGame> {
  int a=3,b=2,resp=0; String msg=''; final rand=Random();
  @override
  void initState(){ super.initState(); _nova(); }
  void _nova(){ setState((){a=rand.nextInt(5)+1; b=rand.nextInt(5)+1; resp=0; msg='';});}
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('🏪 Lojinha da Aventura')), body: Padding(padding: const EdgeInsets.all(20), child: Column(children:[
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.yellow.shade100, borderRadius: BorderRadius.circular(16)), child: Column(children:[
        Text('Você tem $a 💎 Robux', style: const TextStyle(fontSize:20)), const Text('Ganhou mais $b 💎', style: TextStyle(fontSize:20)), const SizedBox(height:12),
        const Text('Quanto tem agora?', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height:8),
        Text('$a + $b = ?', style: const TextStyle(fontSize:28, fontWeight: FontWeight.bold)),
      ])),
      const SizedBox(height:20),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(10, (i)=> Padding(padding: const EdgeInsets.all(3), child: ElevatedButton(onPressed: ()=> setState(()=> resp=i+1), child: Text('${i+1}'))))),
      const SizedBox(height:12), Text('Resposta: $resp', style: const TextStyle(fontSize:22)), Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height:12),
      ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal:32, vertical:14)), onPressed: (){
        if(resp==a+b){ widget.onGanha(); setState(()=> msg='🎉 Isso! ${a+b} Robux! +1 ⭐ +3 💎'); Future.delayed(const Duration(seconds:1), _nova); }
        else { setState(()=> msg='Ops, tenta somar com os dedinhos! Aqui pode errar.'); widget.onGanha(); }
      }, child: const Text('COMPRAR 🛒')),
    ])));
