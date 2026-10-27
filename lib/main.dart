import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;

class VozDaAlice {
  static final FlutterTts _tts = FlutterTts();
  static bool _ok = false;
  static Future<void> init() async {
    if(_ok) return;
    await _tts.setLanguage('pt-BR');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    _ok = true;
  }
  static Future<void> falar(String t) async {
    await init();
    await _tts.stop();
    String limpo = t.replaceAll('💎',' Robux ').replaceAll('⭐',' estrela ');
    await _tts.speak(limpo);
  }
}

void main(){
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
  Map<String,dynamic> toJson()=>{'id':id,'feito':feito,'fotoPath':fotoPath,'horaFeita':horaFeita};
}

class GameProg {
  int feitasHoje;
  String ultimoDia;
  bool concluidoHoje;
  bool desbloqueado;
  GameProg({this.feitasHoje=0, this.ultimoDia='', this.concluidoHoje=false, this.desbloqueado=false});
  Map<String,dynamic> toJson()=>{'feitas':feitasHoje,'dia':ultimoDia,'concluido':concluidoHoje,'desb':desbloqueado};
  static GameProg fromJson(Map<String,dynamic> j)=>GameProg(feitasHoje:j['feitas']??0, ultimoDia:j['dia']??'', concluidoHoje:j['concluido']??false, desbloqueado:j['desb']??false);
}

class ShopItem {
  final String id;
  final String nome;
  final String emoji;
  final int preco;
  bool comprado;
  ShopItem({required this.id, required this.nome, required this.emoji, required this.preco, this.comprado=false});
}

class FamilyUser {
  final String nome;
  final String senha;
  FamilyUser({required this.nome, required this.senha});
  Map<String,dynamic> toJson()=>{'nome':nome,'senha':senha};
  static FamilyUser fromJson(Map<String,dynamic> j)=>FamilyUser(nome:j['nome'], senha:j['senha']);
}

class AliceApp extends StatelessWidget {
  const AliceApp({super.key});
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner:false,
      title:'Mundo da Alice',
      theme: ThemeData(useMaterial3:true, colorSchemeSeed: const Color(0xFF8A2BE2)),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState()=>_HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{
  int tab=0;
  int estrelas=0;
  int robux=0;
  int robloxSegundos=40*60;
  Timer? timerRoblox;
  List<Task> tarefas=[
    Task(id:'t1', titulo:'Chegada + Lanche', horario:'16:00-16:30', emoji:'🏠', mundo:1),
    Task(id:'t2', titulo:'Brincar Livre', horario:'16:30-16:50', emoji:'🧸', mundo:1),
    Task(id:'t3', titulo:'Leitura Divertida', horario:'17:00-17:25', emoji:'📚', mundo:2),
    Task(id:'t4', titulo:'Números Brincando', horario:'17:25-17:45', emoji:'🔢', mundo:2),
    Task(id:'t5', titulo:'Água / Pausa', horario:'17:45-18:05', emoji:'💧', mundo:2),
    Task(id:'t6', titulo:'Jantar', horario:'18:05-18:30', emoji:'🍝', mundo:2),
    Task(id:'t7', titulo:'Banho / Dentes', horario:'18:30-19:00', emoji:'🛁', mundo:3),
    Task(id:'t8', titulo:'História Calma', horario:'19:00-19:30', emoji:'🌙', mundo:3),
    Task(id:'t9', titulo:'Roblox Liberado', horario:'19:30', emoji:'🎮', mundo:5),
  ];
  Map<String, GameProg> games={
    'silabas': GameProg(desbloqueado:true),
    'palavra': GameProg(),
    'blocos': GameProg(),
    'lojinha': GameProg(),
    'memoria': GameProg(),
    'caca': GameProg(),
    'turbo': GameProg(),
  };
  List<ShopItem> loja=[
    ShopItem(id:'memoria', nome:'Jogo da Memória', emoji:'🧩', preco:50),
    ShopItem(id:'caca', nome:'Caça Palavras', emoji:'🔍', preco:70),
    ShopItem(id:'turbo', nome:'Matemática Turbo', emoji:'🚀', preco:100),
  ];
  List<FamilyUser> familia=[
    FamilyUser(nome:'Ana Beatriz', senha:'1234'),
    FamilyUser(nome:'Matheus', senha:'1234'),
    FamilyUser(nome:'Jean', senha:'1234'),
  ];
  FamilyUser? logado;
  bool familiaBloqueada=true;
  final picker=ImagePicker();
  String hojeStr='';

  @override
  void initState(){
    super.initState();
    hojeStr=DateTime.now().toIso8601String().split('T')[0];
    _load();
    timerRoblox=Timer.periodic(const Duration(seconds:1), (t){
      if(robloxSegundos>0){ setState(()=> robloxSegundos--); _save(); }
    });
  }

  @override
  void dispose(){ timerRoblox?.cancel(); super.dispose(); }

  Future<void> _load() async {
    final p=await SharedPreferences.getInstance();
    setState((){
      estrelas=p.getInt('estrelas')??0;
      robux=p.getInt('robux')??0;
      robloxSegundos=p.getInt('robloxSeg')??40*60;
      hojeStr=DateTime.now().toIso8601String().split('T')[0];
      final jsonStr=p.getString('tarefas');
      if(jsonStr!=null){
        final map=jsonDecode(jsonStr) as Map<String,dynamic>;
        for(var t in tarefas){
          if(map.containsKey(t.id)){
            t.feito=map[t.id]['feito']??false;
            t.fotoPath=map[t.id]['fotoPath'];
            t.horaFeita=map[t.id]['horaFeita'];
          }
        }
      }
      for(var k in games.keys){
        var j=p.getString('game_$k');
        if(j!=null){
          try{ games[k]=GameProg.fromJson(jsonDecode(j)); }catch(_){}
        }
        if(games[k]!.ultimoDia != hojeStr){
          games[k]!.feitasHoje=0;
          games[k]!.concluidoHoje=false;
          games[k]!.ultimoDia=hojeStr;
        }
      }
      for(var item in loja){
        item.comprado=p.getBool('loja_${item.id}')??false;
        if(item.comprado) games[item.id]!.desbloqueado=true;
      }
      var fjson=p.getString('familia_users');
      if(fjson!=null){
        try{
          var list=jsonDecode(fjson) as List;
          familia=list.map((e)=> FamilyUser.fromJson(e)).toList();
        }catch(_){}
      }
    });
    _checkDesbloqueios();
  }

  Future<void> _save() async {
    final p=await SharedPreferences.getInstance();
    final m={for(var t in tarefas) t.id: t.toJson()};
    await p.setString('tarefas', jsonEncode(m));
    await p.setInt('estrelas', estrelas);
    await p.setInt('robux', robux);
    await p.setInt('robloxSeg', robloxSegundos);
    for(var k in games.keys){
      await p.setString('game_$k', jsonEncode(games[k]!.toJson()));
    }
    for(var item in loja){
      await p.setBool('loja_${item.id}', item.comprado);
    }
    await p.setString('familia_users', jsonEncode(familia.map((e)=> e.toJson()).toList()));
  }

  void _checkDesbloqueios(){
    setState((){
      if(tarefas[0].feito) games['palavra']!.desbloqueado=true;
      if(tarefas[1].feito) games['blocos']!.desbloqueado=true;
      if(tarefas[2].feito) games['lojinha']!.desbloqueado=true;
      bool todosJogosBaseOk = games['silabas']!.feitasHoje>=20 && games['palavra']!.feitasHoje>=20 && games['blocos']!.feitasHoje>=20 && games['lojinha']!.feitasHoje>=20;
      bool tarefasOk = tarefas.where((t)=> t.id!='t9').every((t)=> t.feito);
      if(tarefasOk && todosJogosBaseOk){
        tarefas[8].feito=true;
      }
    });
    _save();
  }

  Future<void> _tirarFoto(Task t) async {
    try{
      final XFile? file=await picker.pickImage(source: ImageSource.camera, imageQuality:65);
      if(file==null) return;
      final agora=DateTime.now();
      final hora="${agora.hour.toString().padLeft(2,'0')}:${agora.minute.toString().padLeft(2,'0')}";
      setState((){
        t.feito=true;
        t.fotoPath=file.path;
        t.horaFeita=hora;
        estrelas+=1;
        robux+=5;
      });
      await _save();
      _checkDesbloqueios();
      VozDaAlice.falar('Muito bem! ${t.titulo} concluido! Ganhou estrela!');
      if(!mounted) return;
      showDialog(context: context, builder: (_)=> AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🎉 ESTRELA GANHA!', textAlign: TextAlign.center),
        content: Column(mainAxisSize: MainAxisSize.min, children:[
          if(t.fotoPath!=null) ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(t.fotoPath!), height:140)),
          const SizedBox(height:12),
          Text('Você fez ${t.titulo} às $hora', style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height:8),
          const Text('Aqui pode errar. Toda tentativa vale estrela.', textAlign: TextAlign.center),
          const SizedBox(height:8),
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(8)), child: const Text('+1 ⭐  +5 💎 Robux')),
        ]),
        actions:[Center(child: ElevatedButton(onPressed: ()=> Navigator.pop(context), child: const Text('CONTINUAR')))],
      ));
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro câmera: $e')));
    }
  }

  void _onJogoGanha(String gameId){
    setState((){
      var g=games[gameId]!;
      if(g.ultimoDia != hojeStr){ g.feitasHoje=0; g.concluidoHoje=false; g.ultimoDia=hojeStr; }
      g.feitasHoje++;
      estrelas++;
      robux+=2;
      if(g.feitasHoje>=20 && !g.concluidoHoje){
        g.concluidoHoje=true;
        robux+=10;
        Future.delayed(const Duration(milliseconds:300), (){
          if(!mounted) return;
          showDialog(context: context, builder: (_)=> AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('🎉 Parabéns pelo seu esforço!'),
            content: Column(mainAxisSize: MainAxisSize.min, children:[
              Text('Você fez 20 questões de ${gameId}! Incrível!'),
              const SizedBox(height:12),
              const Text('Ganhou +10 💎 bônus!', style: TextStyle(fontWeight: FontWeight.bold)),
            ]),
            actions:[ElevatedButton(onPressed: ()=> Navigator.pop(context), child: const Text('OBA!'))],
          ));
          VozDaAlice.falar('Parabéns pelo seu esforço! Você fez vinte questões! Ganhou bônus de Robux!');
        });
        _checkSeLiberaRobloxAuto();
      }
    });
    _save();
    _checkDesbloqueios();
  }

  void _checkSeLiberaRobloxAuto(){
    bool todosOk = games['silabas']!.feitasHoje>=20 && games['palavra']!.feitasHoje>=20 && games['blocos']!.feitasHoje>=20 && games['lojinha']!.feitasHoje>=20;
    if(todosOk){
      var robloxTask=tarefas.firstWhere((t)=> t.id=='t9');
      if(!robloxTask.feito){
        setState((){
          robloxTask.feito=true;
          robloxTask.horaFeita="${DateTime.now().hour}:${DateTime.now().minute}";
          estrelas+=5;
          robux+=20;
        });
        VozDaAlice.falar('Uau! Você completou todos os jogos de hoje! Roblox liberado automaticamente!');
        _save();
      }
    }
  }

  void _comprarJogo(ShopItem item){
    if(robux>=item.preco && !item.comprado){
      setState((){
        robux-=item.preco;
        item.comprado=true;
        games[item.id]!.desbloqueado=true;
        estrelas+=2;
      });
      VozDaAlice.falar('Você comprou ${item.nome}');
      _save();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Comprou ${item.nome}!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Robux insuficiente. Você tem $robux, precisa de ${item.preco}')));
    }
  }

  String formatTempo(int s){ final m=s~/60; final seg=s%60; return "${m.toString().padLeft(2,'0')}:${seg.toString().padLeft(2,'0')}"; }

  Widget _buildRotina(){
    return ListView(
      padding: const EdgeInsets.all(16),
      children:[
        Card(color: Colors.purple.shade50, child: ListTile(leading: const Text('⭐', style: TextStyle(fontSize:28)), title: Text('$estrelas estrelas | $robux 💎 Robux | Roblox ${formatTempo(robloxSegundos)}'), trailing: IconButton(icon: const Icon(Icons.volume_up), onPressed: ()=> VozDaAlice.falar('Você tem $estrelas estrelas e $robux Robux')))),
        ...tarefas.map((task){
          bool bloqueado=false;
          int idx=tarefas.indexOf(task);
          if(idx>0 && !tarefas[idx-1].feito && task.id!='t9') bloqueado=true;
          if(task.id=='t9'){
            bool pode=tarefas.where((t)=> t.id!='t9').every((t)=> t.feito) && games['silabas']!.feitasHoje>=20 && games['palavra']!.feitasHoje>=20 && games['blocos']!.feitasHoje>=20 && games['lojinha']!.feitasHoje>=20;
            // simplifica: só libera se tarefas ok
            bloqueado = !tarefas.where((t)=> t.id!='t9').every((t)=> t.feito);
          }
          return Card(
            color: task.feito? Colors.green.shade50 : bloqueado? Colors.grey.shade200 : Colors.white,
            child: ListTile(
              leading: Text(task.emoji, style: const TextStyle(fontSize:28)),
              title: Text(task.titulo),
              subtitle: Text('${task.horario} ${task.feito? '• Feito às ${task.horaFeita} ✅' : bloqueado? '🔒 Faça a anterior' : ''}'),
              trailing: bloqueado? const Icon(Icons.lock) : task.feito? const Icon(Icons.check_circle, color: Colors.green) : ElevatedButton(onPressed: ()=> _tirarFoto(task), child: const Text('FIZ!')),
              onTap: ()=> VozDaAlice.falar(task.titulo),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildJogos(){
    List<Map<String,dynamic>> todos=[
      {'id':'silabas','nome':'Sílabas Mágicas','emoji':'🔤','desc':'20 por dia'},
      {'id':'palavra','nome':'Palavra Escondida','emoji':'🔍','desc':'20 por dia'},
      {'id':'blocos','nome':'Contando Blocos','emoji':'🟦','desc':'20 por dia'},
      {'id':'lojinha','nome':'Lojinha da Aventura','emoji':'🏪','desc':'20 por dia'},
      {'id':'memoria','nome':'Jogo da Memória','emoji':'🧩','desc':'Compre na loja'},
      {'id':'caca','nome':'Caça Palavras','emoji':'🔎','desc':'Compre na loja'},
      {'id':'turbo','nome':'Matemática Turbo','emoji':'🚀','desc':'Compre na loja'},
    ];
    return GridView.count(
      crossAxisCount:2,
      padding: const EdgeInsets.all(12),
      crossAxisSpacing:12,
      mainAxisSpacing:12,
      children: todos.map((j){
        var prog=games[j['id']]!;
        bool desbloq=prog.desbloqueado;
        return Card(
          color: desbloq? Colors.white : Colors.grey.shade300,
          child: InkWell(
            onTap: desbloq? (){
              if(j['id']=='silabas') Navigator.push(context, MaterialPageRoute(builder: (_)=> SilabasGame(onGanha: ()=> _onJogoGanha('silabas'))));
              if(j['id']=='palavra') Navigator.push(context, MaterialPageRoute(builder: (_)=> PalavraGame(onGanha: ()=> _onJogoGanha('palavra'))));
              if(j['id']=='blocos') Navigator.push(context, MaterialPageRoute(builder: (_)=> BlocosGame(onGanha: ()=> _onJogoGanha('blocos'))));
              if(j['id']=='lojinha') Navigator.push(context, MaterialPageRoute(builder: (_)=> LojinhaGame(onGanha: ()=> _onJogoGanha('lojinha'))));
              if(j['id']=='memoria') Navigator.push(context, MaterialPageRoute(builder: (_)=> MemoriaGame(onGanha: ()=> _onJogoGanha('memoria'))));
              if(j['id']=='caca') Navigator.push(context, MaterialPageRoute(builder: (_)=> CacaGame(onGanha: ()=> _onJogoGanha('caca'))));
              if(j['id']=='turbo') Navigator.push(context, MaterialPageRoute(builder: (_)=> TurboGame(onGanha: ()=> _onJogoGanha('turbo'))));
            } : null,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children:[
                Text(j['emoji'], style: const TextStyle(fontSize:40)),
                const SizedBox(height:8),
                Text(j['nome'], style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height:4),
                Text(j['desc'], style: const TextStyle(fontSize:10), textAlign: TextAlign.center),
                const SizedBox(height:8),
                if(!desbloq) const Icon(Icons.lock, size:20) else Column(children:[
                  Text('${prog.feitasHoje}/20 hoje', style: TextStyle(fontSize:12, fontWeight: FontWeight.bold, color: prog.concluidoHoje? Colors.green : Colors.black)),
                  LinearProgressIndicator(value: (prog.feitasHoje/20).clamp(0,1), backgroundColor: Colors.grey.shade200, color: prog.concluidoHoje? Colors.green : Colors.purple),
                  if(prog.concluidoHoje) const Text('✅ Concluído!', style: TextStyle(fontSize:10, color: Colors.green, fontWeight: FontWeight.bold)),
                ]),
              ]),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLoja(){
    return ListView(
      padding: const EdgeInsets.all(16),
      children:[
        Card(color: Colors.amber.shade100, child: ListTile(leading: const Text('💎', style: TextStyle(fontSize:30)), title: Text('Seus Robux: $robux'), subtitle: const Text('Compre mais joguinhos! Sempre soma!'), trailing: IconButton(icon: const Icon(Icons.volume_up), onPressed: ()=> VozDaAlice.falar('Você tem $robux Robux para comprar jogos')))),
        ...loja.map((item){
          return Card(
            child: ListTile(
              leading: Text(item.emoji, style: const TextStyle(fontSize:32)),
              title: Text(item.nome),
              subtitle: Text(item.comprado? '✅ Já comprado' : '${item.preco} 💎 Robux'),
              trailing: item.comprado? const Icon(Icons.check, color: Colors.green) : ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green), onPressed: ()=> _comprarJogo(item), child: const Text('COMPRAR')),
              onTap: ()=> VozDaAlice.falar(item.nome),
            ),
          );
        }),
        const Card(color: Color(0xFFF3E5F5), child: ListTile(title: Text('💡 Como ganhar Robux?'), subtitle: Text('• Tarefa com foto = +5 💎\n• Cada questão = +2 💎\n• 20 questões = +10 bônus\n• Todos 20/20 = +20 bônus e Roblox auto'))),
      ],
    );
  }

  Widget _buildFamilia(){
    if(familiaBloqueada){ return _buildFamiliaLogin(); }
    return ListView(
      padding: const EdgeInsets.all(16),
      children:[
        Card(color: Colors.blue.shade50, child: ListTile(leading: const Icon(Icons.family_restroom), title: Text('Olá, ${logado!.nome}!'), subtitle: const Text('Modo Família Protegido 🔒'), trailing: IconButton(icon: const Icon(Icons.logout), onPressed: (){ setState(()=> familiaBloqueada=true); }))),
        Card(child: ListTile(title: Text('⭐ $estrelas estrelas'), subtitle: Text('💎 $robux Robux'))),
        Card(child: Column(children: tarefas.map((t)=> ListTile(leading: Text(t.emoji), title: Text(t.titulo), subtitle: t.fotoPath!=null? Text('Foto ok • ${t.horaFeita}') : const Text('Sem foto'), trailing: t.feito? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.pending))).toList())),
        Card(child: ListTile(title: const Text('Gerenciar Família'), subtitle: const Text('Adicionar vó, tio, etc'), onTap: _showAddFamilia)),
        ...familia.map((f)=> Card(child: ListTile(leading: const Icon(Icons.person), title: Text(f.nome)))),
        Card(color: Colors.red.shade50, child: ListTile(title: const Text('Sair do Modo Família'), trailing: const Icon(Icons.lock), onTap: (){ setState(()=> familiaBloqueada=true); })),
      ],
    );
  }

  Widget _buildFamiliaLogin(){
    String nomeSel=familia.isNotEmpty? familia[0].nome : '';
    String senha='';
    return StatefulBuilder(builder: (context, setLocal){
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children:[
          const Icon(Icons.lock, size:60, color: Colors.purple),
          const SizedBox(height:16),
          const Text('Modo Família Protegido', style: TextStyle(fontSize:22, fontWeight: FontWeight.bold)),
          const SizedBox(height:8),
          const Text('Só responsáveis entram. Alice não pode ver.', style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
          const SizedBox(height:24),
          DropdownButtonFormField<String>(
            value: nomeSel.isEmpty? null : nomeSel,
            decoration: const InputDecoration(labelText: 'Quem é você?', border: OutlineInputBorder()),
            items: familia.map((f)=> DropdownMenuItem(value: f.nome, child: Text(f.nome))).toList(),
            onChanged: (v){ setLocal(()=> nomeSel=v??''); },
          ),
          const SizedBox(height:12),
          TextFormField(decoration: const InputDecoration(labelText: 'Senha', border: OutlineInputBorder()), obscureText:true, onChanged: (v)=> senha=v),
          const SizedBox(height:16),
          SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical:14)), onPressed: (){
            var achou=familia.where((f)=> f.nome==nomeSel && f.senha==senha).toList();
            if(achou.isNotEmpty){
              setState(()=> {logado=achou.first, familiaBloqueada=false});
              VozDaAlice.falar('Olá ${logado!.nome}, modo família liberado');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nome ou senha errada!')));
            }
          }, child: const Text('ENTRAR'))),
          const SizedBox(height:12),
          TextButton(onPressed: _showAddFamilia, child: const Text('Criar novo responsável')),
        ]),
      );
    });
  }

  void _showAddFamilia(){
    String nome=''; String senha='';
    showDialog(context: context, builder: (_)=> AlertDialog(
      title: const Text('Novo responsável'),
      content: Column(mainAxisSize: MainAxisSize.min, children:[
        TextField(decoration: const InputDecoration(labelText: 'Nome (ex: Vó Maria)'), onChanged: (v)=> nome=v),
        TextField(decoration: const InputDecoration(labelText: 'Senha'), obscureText:true, onChanged: (v)=> senha=v),
      ]),
      actions:[
        TextButton(onPressed: ()=> Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(onPressed: (){
          if(nome.isNotEmpty && senha.isNotEmpty){
            setState(()=> familia.add(FamilyUser(nome:nome, senha:senha)));
            _save();
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Responsável $nome criado!')));
          }
        }, child: const Text('Criar')),
      ],
    ));
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: const Color(0xFFF8F3FF),
      appBar: AppBar(backgroundColor: const Color(0xFF8A2BE2), foregroundColor: Colors.white, title: const Text('Mundo da Alice'), centerTitle:true),
      body: [ _buildRotina(), _buildJogos(), _buildLoja(), _buildFamilia()][tab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tab,
        onTap: (i){ setState(()=> tab=i); },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Rotina'),
          BottomNavigationBarItem(icon: Icon(Icons.games), label: 'Jogos'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Loja'),
          BottomNavigationBarItem(icon: Icon(Icons.lock), label: 'Família'),
        ],
      ),
    );
  }
}

// JOGOS - horizontais, voz, cores fixas, sem accent bug

class SilabasGame extends StatefulWidget {
  final VoidCallback onGanha;
  const SilabasGame({super.key, required this.onGanha});
  @override
  State<SilabasGame> createState()=>_SilabasGameState();
}
class _SilabasGameState extends State<SilabasGame>{
  final palavras=[
    {'resp':'CASA','exibe':'CASA','dica':'Onde moramos','s1':'CA','s2':'SA'},
    {'resp':'BOLA','exibe':'BOLA','dica':'Brinquedo redondo','s1':'BO','s2':'LA'},
    {'resp':'GATO','exibe':'GATO','dica':'Miau','s1':'GA','s2':'TO'},
    {'resp':'AGUA','exibe':'ÁGUA','dica':'Para beber','s1':'A','s2':'GUA'},
    {'resp':'LIVRO','exibe':'LIVRO','dica':'Para ler','s1':'LI','s2':'VRO'},
  ];
  int idx=0; String montada=''; String msg='';
  Map<String,String> get p=> palavras[idx % palavras.length] as Map<String,String>;
  String _semAcento(String s){ return s.replaceAll('Á','A').replaceAll('À','A').replaceAll('Â','A').replaceAll('Ã','A').replaceAll('É','E').replaceAll('Ê','E').replaceAll('Í','I').replaceAll('Ó','O').replaceAll('Ô','O').replaceAll('Ú','U').replaceAll('Ç','C'); }
  @override
  Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(title: const Text('🔤 Sílabas Mágicas'), actions:[IconButton(icon: const Icon(Icons.volume_up), onPressed: ()=> VozDaAlice.falar('Sílabas mágicas. Forme a palavra ${p['exibe']}'))]), body: Padding(padding: const EdgeInsets.all(20), child: Column(children:[
      InkWell(onTap: ()=> VozDaAlice.falar('Forme a palavra ${p['exibe']}'), child: Text('Forme: ${p['exibe']}', style: const TextStyle(fontSize:26, fontWeight: FontWeight.bold))),
      Text(p['dica']!, style: const TextStyle(color: Colors.grey)), const SizedBox(height:12),
      Wrap(spacing:12, children:[
        ElevatedButton(onPressed: (){ setState(()=> montada+=p['s1']!); VozDaAlice.falar(p['s1']!); }, child: Text(p['s1']!)),
        ElevatedButton(onPressed: (){ setState(()=> montada+=p['s2']!); VozDaAlice.falar(p['s2']!); }, child: Text(p['s2']!)),
        ElevatedButton(onPressed: ()=> setState(()=> montada=''), child: const Text('Limpar')),
      ]),
      const SizedBox(height:20), Text('Você montou: $montada', style: const TextStyle(fontSize:22)), Text(msg, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
      const SizedBox(height:20),
      ElevatedButton(onPressed: (){
        if(_semAcento(montada.toUpperCase())==_semAcento(p['resp']!.toUpperCase())){
          widget.onGanha(); setState(()=> msg='🎉 Acertou! +1 ⭐ +2 💎'); VozDaAlice.falar('Acertou! ${p['resp']}'); Future.delayed(const Duration(seconds:1), ()=> setState((){ idx++; montada=''; msg=''; }));
        } else { setState(()=> msg='Tenta de novo! Aqui pode errar.'); VozDaAlice.falar('Tenta de novo'); }
      }, child: const Text('CONFIRMAR')),
    ])));
  }
}

class PalavraGame extends StatefulWidget {
  final VoidCallback onGanha;
  const PalavraGame({super.key, required this.onGanha});
  @override
  State<PalavraGame> createState()=>_PalavraGameState();
}
class _PalavraGameState extends State<PalavraGame>{
  final palavras=[
    {'palavra':'LIVRO','dica':'Usamos para ler'},
    {'palavra':'AGUA','dica':'Bebemos todo dia'},
    {'palavra':'ALICE','dica':'Nome da aventureira'},
  ];
  int idx=0; String tent=''; String msg='';
  @override
  Widget build(BuildContext context){
    final p=palavras[idx % palavras.length];
    return Scaffold(appBar: AppBar(title: const Text('🔍 Palavra Escondida'), actions:[IconButton(icon: const Icon(Icons.volume_up), onPressed: ()=> VozDaAlice.falar('Palavra escondida. Dica ${p['dica']}'))]), body: Padding(padding: const EdgeInsets.all(16), child: Column(children:[
      Text(p['dica'] as String, style: const TextStyle(fontSize:22)), const SizedBox(height:20),
      Text((p['palavra'] as String).split('').map((c)=> tent.contains(c)? c : '_').join(' '), style: const TextStyle(fontSize:32, letterSpacing:8, fontWeight: FontWeight.bold)),
      const SizedBox(height:20),
      Wrap(spacing:6, children: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('').map((l)=> ElevatedButton(onPressed: (){ setState(()=> tent+=l); }, child: Text(l))).toList()),
      const SizedBox(height:12), Text('Letras usadas: $tent'), Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height:12),
      ElevatedButton(onPressed: (){
        if((p['palavra'] as String).split('').every((c)=> tent.contains(c))){
          widget.onGanha(); setState(()=> msg='🎉 Achou! +1 ⭐ +2 💎'); VozDaAlice.falar('Achou ${p['palavra']}'); Future.delayed(const Duration(seconds:1), (){ if(idx < palavras.length-1) setState((){ idx++; tent=''; msg='';}); else Navigator.pop(context);});
        } else { setState(()=> msg='Continua tentando!'); }
      }, child: const Text('VERIFICAR')),
    ])));
  }
}

class BlocosGame extends StatefulWidget {
  final VoidCallback onGanha;
  const BlocosGame({super.key, required this.onGanha});
  @override
  State<BlocosGame> createState()=>_BlocosGameState();
}
class _BlocosGameState extends State<BlocosGame>{
  int qtd=0; int resp=0; String msg='';
  final rand=Random();
  List<Color> cores=[];
  @override
  void initState(){ super.initState(); _nova(); }
  void _nova(){ setState((){ qtd=rand.nextInt(8)+2; resp=0; msg='Conte os blocos'; cores=List.generate(qtd, (_)=> Colors.primaries[rand.nextInt(Colors.primaries.length)]); }); VozDaAlice.falar('Conte os blocos. Quantos blocos tem?'); }
  @override
  Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(title: const Text('🟦 Contando Blocos'), actions:[IconButton(icon: const Icon(Icons.volume_up), onPressed: ()=> VozDaAlice.falar('Quantos blocos? $qtd blocos'))]), body: Padding(padding: const EdgeInsets.all(16), child: Column(children:[
      InkWell(onTap: ()=> VozDaAlice.falar('Quantos blocos?'), child: const Text('Quantos blocos?', style: TextStyle(fontSize:20, fontWeight: FontWeight.bold))),
      const SizedBox(height:12),
      Wrap(spacing:8, runSpacing:8, children: List.generate(qtd, (i)=> Container(width:50, height:50, decoration: BoxDecoration(color: cores.isNotEmpty? cores[i] : Colors.blue, borderRadius: BorderRadius.circular(8), border: Border.all(width:2)), child: const Center(child: Text('🧱'))))),
      const SizedBox(height:20),
      Wrap(alignment: WrapAlignment.center, spacing:8, runSpacing:8, children: List.generate(10, (i)=> SizedBox(width:60, height:45, child: ElevatedButton(onPressed: ()=> setState(()=> resp=i+1), child: Text('${i+1}', style: const TextStyle(fontSize:18)))))),
      const SizedBox(height:12), Text('Você escolheu: $resp', style: const TextStyle(fontSize:20)), Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height:12),
      ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8A2BE2), foregroundColor: Colors.white), onPressed: (){
        if(resp==qtd){ widget.onGanha(); setState(()=> msg='🎉 Acertou! $qtd blocos!'); VozDaAlice.falar('Acertou $qtd blocos'); Future.delayed(const Duration(seconds:1), _nova); }
        else { setState(()=> msg='Quase! Conta de novo. Vale estrela mesmo errando!'); widget.onGanha(); }
      }, child: const Text('CONFIRMAR')),
    ])));
  }
}

class LojinhaGame extends StatefulWidget {
  final VoidCallback onGanha;
  const LojinhaGame({super.key, required this.onGanha});
  @override
  State<LojinhaGame> createState()=>_LojinhaGameState();
}
class _LojinhaGameState extends State<LojinhaGame>{
  int a=3,b=2,resp=0; String msg=''; final rand=Random();
  @override
  void initState(){ super.initState(); _nova(); }
  void _nova(){ setState((){a=rand.nextInt(5)+1; b=rand.nextInt(5)+1; resp=0; msg='';}); VozDaAlice.falar('Você tem $a Robux, ganhou mais $b, quanto tem agora?'); }
  @override
  Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(title: const Text('🏪 Lojinha da Aventura'), actions:[IconButton(icon: const Icon(Icons.volume_up), onPressed: ()=> VozDaAlice.falar('Lojinha. Você tem $a Robux, ganhou mais $b, quanto tem agora?'))]), body: Padding(padding: const EdgeInsets.all(20), child: Column(children:[
      InkWell(onTap: ()=> VozDaAlice.falar('Você tem $a Robux, ganhou mais $b'), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.yellow.shade100, borderRadius: BorderRadius.circular(16)), child: Column(children:[
        Text('Você tem $a 💎 Robux', style: const TextStyle(fontSize:20)), Text('Ganhou mais $b 💎', style: const TextStyle(fontSize:20)), const SizedBox(height:12),
        const Text('Quanto tem agora?', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height:8),
        Text('$a + $b = ?', style: const TextStyle(fontSize:28, fontWeight: FontWeight.bold)),
      ]))),
      const SizedBox(height:20),
      Wrap(alignment: WrapAlignment.center, spacing:8, runSpacing:8, children: List.generate(10, (i)=> SizedBox(width:60, height:45, child: ElevatedButton(onPressed: ()=> setState(()=> resp=i+1), child: Text('${i+1}', style: const TextStyle(fontSize:18)))))),
      const SizedBox(height:12), Text('Resposta: $resp', style: const TextStyle(fontSize:22)), Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height:12),
      ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal:32, vertical:14)), onPressed: (){
        if(resp==a+b){ widget.onGanha(); setState(()=> msg='🎉 Isso! ${a+b} Robux!'); VozDaAlice.falar('Isso! ${a+b} Robux'); Future.delayed(const Duration(seconds:1), _nova); }
        else { setState(()=> msg='Ops, tenta somar com os dedinhos!'); widget.onGanha(); }
      }, child: const Text('COMPRAR')),
    ])));
  }
}

class MemoriaGame extends StatefulWidget {
  final VoidCallback onGanha;
  const MemoriaGame({super.key, required this.onGanha});
  @override
  State<MemoriaGame> createState()=>_MemoriaGameState();
}
class _MemoriaGameState extends State<MemoriaGame>{
  int acertos=0;
  @override
  Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(title: const Text('🧩 Memória')), body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children:[
      const Text('Jogo da Memória', style: TextStyle(fontSize:20)), const SizedBox(height:12),
      Text('$acertos/20', style: const TextStyle(fontSize:28, fontWeight: FontWeight.bold)),
      const SizedBox(height:12),
      ElevatedButton(onPressed: (){ widget.onGanha(); setState(()=> acertos++); VozDaAlice.falar('Ponto $acertos'); if(acertos>=20) Navigator.pop(context); }, child: const Text('GANHAR PONTO')),
    ])));
  }
}
class CacaGame extends StatefulWidget {
  final VoidCallback onGanha;
  const CacaGame({super.key, required this.onGanha});
  @override
  State<CacaGame> createState()=>_CacaGameState();
}
class _CacaGameState extends State<CacaGame>{
  int acertos=0;
  @override
  Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(title: const Text('🔎 Caça Palavras')), body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children:[
      const Text('Caça Palavras', style: TextStyle(fontSize:20)),
      Text('$acertos/20', style: const TextStyle(fontSize:28, fontWeight: FontWeight.bold)),
      ElevatedButton(onPressed: (){ widget.onGanha(); setState(()=> acertos++); if(acertos>=20) Navigator.pop(context); }, child: const Text('GANHAR PONTO')),
    ])));
  }
}
class TurboGame extends StatefulWidget {
  final VoidCallback onGanha;
  const TurboGame({super.key, required this.onGanha});
  @override
  State<TurboGame> createState()=>_TurboGameState();
}
class _TurboGameState extends State<TurboGame>{
  int acertos=0;
  @override
  Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(title: const Text('🚀 Turbo')), body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children:[
      const Text('Matemática Turbo', style: TextStyle(fontSize:20)),
      Text('$acertos/20', style: const TextStyle(fontSize:28, fontWeight: FontWeight.bold)),
      ElevatedButton(onPressed: (){ widget.onGanha(); setState(()=> acertos++); if(acertos>=20) Navigator.pop(context); }, child: const Text('GANHAR PONTO')),
    ])));
  }
}
