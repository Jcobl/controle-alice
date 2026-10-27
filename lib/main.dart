import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VozDaAlice {
  static final FlutterTts _tts = FlutterTts();
  static bool _iniciado = false;
  static Future<void> _init() async {
    if(_iniciado) return;
    await _tts.setLanguage("pt-BR");
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _iniciado = true;
  }
  static Future<void> falar(String texto) async {
    await _init();
    await _tts.stop();
    String limpo = texto.replaceAll(RegExp(r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]+', unicode: true), '').replaceAll('💎',' Robux ').replaceAll('⭐',' estrela ').replaceAll('🧱',' bloco ').replaceAll('🏠',' casa ');
    await _tts.speak(limpo);
  }
}

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
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mundo da Alice',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF8A2BE2)),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int tab = 0;
  int estrelas = 0;
  int robux = 0;
  List<Task> tasks = [];
  Map<String, GameProg> games = {};
  List<ShopItem> loja = [];
  List<FamilyUser> familia = [];
  FamilyUser? logado;
  bool familiaBloqueada = true;
  final picker = ImagePicker();
  String hojeStr = '';

  @override
  void initState() {
    super.initState();
    hojeStr = DateTime.now().toIso8601String().split('T')[0];
    _initDados();
    _load();
  }

  void _initDados() {
    tasks = [
      Task(id:'chegada', titulo:'Cheguei! Lanche', horario:'16:00', emoji:'🏠', mundo:1),
      Task(id:'brincar', titulo:'Brincar Livre', horario:'16:30', emoji:'🧸', mundo:1),
      Task(id:'leitura', titulo:'Leitura Divertida', horario:'17:00', emoji:'📚', mundo:2),
      Task(id:'numeros', titulo:'Números Brincando', horario:'17:25', emoji:'🔢', mundo:2),
      Task(id:'agua', titulo:'Água e Pausa', horario:'17:45', emoji:'💧', mundo:3),
      Task(id:'jantar', titulo:'Jantar', horario:'18:05', emoji:'🍽️', mundo:3),
      Task(id:'banho', titulo:'Banho e Dentes', horario:'18:30', emoji:'🛁', mundo:4),
      Task(id:'historia', titulo:'História Calma', horario:'19:00', emoji:'🌙', mundo:4),
      Task(id:'roblox', titulo:'Roblox Liberado', horario:'19:30', emoji:'🎮', mundo:5),
    ];
    games = {
      'silabas': GameProg(desbloqueado:false),
      'palavra': GameProg(desbloqueado:false),
      'blocos': GameProg(desbloqueado:false),
      'lojinha': GameProg(desbloqueado:false),
      'memoria': GameProg(desbloqueado:false),
      'caca': GameProg(desbloqueado:false),
      'turbo': GameProg(desbloqueado:false),
    };
    loja = [
      ShopItem(id:'memoria', nome:'Jogo da Memória', emoji:'🧩', preco:50),
      ShopItem(id:'caca', nome:'Caça Palavras', emoji:'🔍', preco:70),
      ShopItem(id:'turbo', nome:'Matemática Turbo', emoji:'🚀', preco:100),
    ];
    familia = [
      FamilyUser(nome:'Ana Beatriz', senha:'1234'),
      FamilyUser(nome:'Matheus', senha:'1234'),
      FamilyUser(nome:'Jean', senha:'1234'),
    ];
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      estrelas = p.getInt('estrelas') ?? 0;
      robux = p.getInt('robux') ?? 0;
      hojeStr = DateTime.now().toIso8601String().split('T')[0];
      // tasks
      for(var t in tasks){
        t.feito = p.getBool('task_${t.id}') ?? false;
        t.fotoPath = p.getString('foto_${t.id}');
        t.horaFeita = p.getString('hora_${t.id}');
      }
      // games
      for(var k in games.keys){
        var j = p.getString('game_$k');
        if(j!=null){
          try{ games[k]=GameProg.fromJson(jsonDecode(j)); }catch(_){}
        }
        // reset diário
        if(games[k]!.ultimoDia != hojeStr){
          games[k]!.feitasHoje = 0;
          games[k]!.concluidoHoje = false;
          games[k]!.ultimoDia = hojeStr;
        }
      }
      // loja
      for(var item in loja){
        item.comprado = p.getBool('loja_${item.id}') ?? false;
        if(item.comprado) games[item.id]!.desbloqueado = true;
      }
      // familia
      var fjson = p.getString('familia_users');
      if(fjson!=null){
        try{
          var list = jsonDecode(fjson) as List;
          familia = list.map((e)=> FamilyUser.fromJson(e)).toList();
        }catch(_){}
      }
    });
    _checkDesbloqueios();
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('estrelas', estrelas);
    await p.setInt('robux', robux);
    for(var t in tasks){
      await p.setBool('task_${t.id}', t.feito);
      if(t.fotoPath!=null) await p.setString('foto_${t.id}', t.fotoPath!);
      if(t.horaFeita!=null) await p.setString('hora_${t.id}', t.horaFeita!);
    }
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
      // Progressivo: cada tarefa libera um joguinho
      if(tasks[0].feito) games['silabas']!.desbloqueado = true;
      if(tasks[1].feito) games['palavra']!.desbloqueado = true;
      if(tasks[2].feito) games['blocos']!.desbloqueado = true;
      if(tasks[3].feito) games['lojinha']!.desbloqueado = true;
      // Roblox só libera se todas as tarefas principais feitas e pelo menos 20 questões em cada jogo base
      bool todosJogosBaseOk = (games['silabas']!.concluidoHoje || games['silabas']!.feitasHoje>=20) &&
                              (games['palavra']!.concluidoHoje || games['palavra']!.feitasHoje>=20) &&
                              (games['blocos']!.concluidoHoje || games['blocos']!.feitasHoje>=20) &&
                              (games['lojinha']!.concluidoHoje || games['lojinha']!.feitasHoje>=20);
      bool tarefasOk = tasks.where((t)=> t.id!='roblox').every((t)=> t.feito);
      if(tarefasOk && todosJogosBaseOk){
        // libera roblox
      }
    });
    _save();
  }

  Future<void> _tirarFoto(Task task) async {
    try{
      final XFile? f = await picker.pickImage(source: ImageSource.camera, imageQuality:60);
      if(f!=null){
        var agora = DateTime.now();
        setState((){
          task.feito = true;
          task.fotoPath = f.path;
          task.horaFeita = "${agora.hour.toString().padLeft(2,'0')}:${agora.minute.toString().padLeft(2,'0')}";
          estrelas++;
          robux+=3;
        });
        VozDaAlice.falar("Muito bem! ${task.titulo} concluído! Ganhou estrela!");
        await _save();
        _checkDesbloqueios();
        // se foi tarefa que libera jogo, avisa
        if(task.id=='chegada') VozDaAlice.falar("Você desbloqueou Sílabas Mágicas!");
        if(task.id=='brincar') VozDaAlice.falar("Você desbloqueou Palavra Escondida!");
        if(task.id=='leitura') VozDaAlice.falar("Você desbloqueou Contando Blocos!");
        if(task.id=='numeros') VozDaAlice.falar("Você desbloqueou Lojinha da Aventura!");
      }
    }catch(e){}
  }

  void _onJogoGanha(String gameId){
    setState((){
      var g = games[gameId]!;
      if(g.ultimoDia != hojeStr){
        g.feitasHoje=0; g.concluidoHoje=false; g.ultimoDia=hojeStr;
      }
      g.feitasHoje++;
      estrelas++;
      robux+=2;
      if(g.feitasHoje >= 20 && !g.concluidoHoje){
        g.concluidoHoje=true;
        // parabéns
        Future.delayed(Duration(milliseconds:300), (){
          showDialog(context: context, builder: (_)=> AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text("🎉 Parabéns pelo seu esforço!"),
            content: Column(mainAxisSize: MainAxisSize.min, children:[
              Text("Você fez 20 questões de ${gameId}! Incrível!"),
              SizedBox(height:12),
              Text("Ganhou +10 💎 Robux bônus!", style: TextStyle(fontWeight: FontWeight.bold)),
            ]),
            actions:[ElevatedButton(onPressed: ()=> Navigator.pop(context), child: Text("OBA!"))],
          ));
          VozDaAlice.falar("Parabéns pelo seu esforço! Você fez vinte questões! Ganhou bônus de Robux!");
        });
        robux+=10;
        // cheque automático no Roblox se todos completos
        _checkSeLiberaRobloxAuto();
      }
    });
    _save();
    _checkDesbloqueios();
  }

  void _checkSeLiberaRobloxAuto(){
    bool todosOk = games['silabas']!.concluidoHoje && games['palavra']!.concluidoHoje && games['blocos']!.concluidoHoje && games['lojinha']!.concluidoHoje;
    if(todosOk){
      var robloxTask = tasks.firstWhere((t)=> t.id=='roblox');
      if(!robloxTask.feito){
        setState((){
          robloxTask.feito=true;
          robloxTask.horaFeita="${DateTime.now().hour}:${DateTime.now().minute}";
          estrelas+=5;
          robux+=20;
        });
        VozDaAlice.falar("Uau! Você completou todos os jogos de hoje! Roblox liberado automaticamente!");
        _save();
      }
    }
  }

  void _comprarJogo(ShopItem item){
    if(robux >= item.preco && !item.comprado){
      setState((){
        robux-=item.preco;
        item.comprado=true;
        games[item.id]!.desbloqueado=true;
        estrelas+=2;
      });
      VozDaAlice.falar("Você comprou ${item.nome} por ${item.preco} Robux! Boa!");
      _save();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Comprou ${item.nome}! 🎉")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Robux insuficiente. Você tem $robux 💎, precisa de ${item.preco}")));
    }
  }

  Widget _buildRotina(){
    return ListView(
      padding: EdgeInsets.all(16),
      children:[
        Card(color: Colors.purple.shade50, child: ListTile(leading: Text("⭐", style: TextStyle(fontSize:28)), title: Text("$estrelas estrelas | $robux 💎 Robux"), trailing: IconButton(icon: Text("🔊"), onPressed: ()=> VozDaAlice.falar("Você tem $estrelas estrelas e $robux Robux")))),
        ...tasks.map((task){
          bool bloqueado = false;
          int idx = tasks.indexOf(task);
          if(idx>0 && !tasks[idx-1].feito && task.id!='roblox') bloqueado = true;
          // roblox bloqueado até tudo
          if(task.id=='roblox'){
            bool podeRoblox = tasks.where((t)=> t.id!='roblox').every((t)=> t.feito) && games['silabas']!.concluidoHoje && games['palavra']!.concluidoHoje && games['blocos']!.concluidoHoje && games['lojinha']!.concluidoHoje;
            bloqueado = !podeRoblox;
          }
          return Card(
            color: task.feito ? Colors.green.shade50 : bloqueado ? Colors.grey.shade200 : Colors.white,
            child: ListTile(
              leading: Text(task.emoji, style: TextStyle(fontSize:28)),
              title: Text(task.titulo, style: TextStyle(fontWeight: task.feito? FontWeight.bold : FontWeight.normal)),
              subtitle: Text("${task.horario} ${task.feito ? '• Feito às ${task.horaFeita} ✅' : bloqueado ? '🔒 Faça a anterior' : ''}"),
              trailing: bloqueado ? Icon(Icons.lock) : task.feito ? Icon(Icons.check_circle, color: Colors.green) : ElevatedButton(onPressed: ()=> _tirarFoto(task), child: Text("FIZ! 📸")),
              onTap: ()=> VozDaAlice.falar(task.titulo),
            ),
          );
        }).toList(),
        SizedBox(height:20),
        if(tasks.every((t)=> t.feito)) Card(color: Colors.amber.shade100, child: ListTile(title: Text("🎉 Todos de hoje feitos! Parabéns pelo seu esforço!", style: TextStyle(fontWeight: FontWeight.bold)), subtitle: Text("Roblox liberado até 18:30"), onTap: ()=> VozDaAlice.falar("Parabéns pelo seu esforço! Todos os deveres feitos!"))),
      ],
    );
  }

  Widget _buildJogos(){
    List<Map<String,dynamic>> todosJogos = [
      {'id':'silabas','nome':'Sílabas Mágicas','emoji':'🔤','desc':'20 questões por dia'},
      {'id':'palavra','nome':'Palavra Escondida','emoji':'🔍','desc':'20 questões por dia'},
      {'id':'blocos','nome':'Contando Blocos','emoji':'🟦','desc':'20 questões por dia'},
      {'id':'lojinha','nome':'Lojinha da Aventura','emoji':'🏪','desc':'20 questões por dia'},
      {'id':'memoria','nome':'Jogo da Memória','emoji':'🧩','desc':'Compre na loja'},
      {'id':'caca','nome':'Caça Palavras','emoji':'🔎','desc':'Compre na loja'},
      {'id':'turbo','nome':'Matemática Turbo','emoji':'🚀','desc':'Compre na loja'},
    ];
    return GridView.count(
      crossAxisCount:2,
      padding: EdgeInsets.all(12),
      crossAxisSpacing:12,
      mainAxisSpacing:12,
      children: todosJogos.map((j){
        var prog = games[j['id']]!;
        bool desbloq = prog.desbloqueado;
        return Card(
          color: desbloq ? Colors.white : Colors.grey.shade300,
          child: InkWell(
            onTap: desbloq ? (){
              if(j['id']=='silabas') Navigator.push(context, MaterialPageRoute(builder: (_)=> SilabasGame(onGanha: ()=> _onJogoGanha('silabas'))));
              if(j['id']=='palavra') Navigator.push(context, MaterialPageRoute(builder: (_)=> PalavraGame(onGanha: ()=> _onJogoGanha('palavra'))));
              if(j['id']=='blocos') Navigator.push(context, MaterialPageRoute(builder: (_)=> BlocosGame(onGanha: ()=> _onJogoGanha('blocos'))));
              if(j['id']=='lojinha') Navigator.push(context, MaterialPageRoute(builder: (_)=> LojinhaGame(onGanha: ()=> _onJogoGanha('lojinha'))));
              if(j['id']=='memoria') Navigator.push(context, MaterialPageRoute(builder: (_)=> MemoriaGame(onGanha: ()=> _onJogoGanha('memoria'))));
              if(j['id']=='caca') Navigator.push(context, MaterialPageRoute(builder: (_)=> CacaGame(onGanha: ()=> _onJogoGanha('caca'))));
              if(j['id']=='turbo') Navigator.push(context, MaterialPageRoute(builder: (_)=> TurboGame(onGanha: ()=> _onJogoGanha('turbo'))));
            } : null,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children:[
                Text(j['emoji'], style: TextStyle(fontSize:40)),
                SizedBox(height:8),
                Text(j['nome'], style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                SizedBox(height:4),
                Text(j['desc'], style: TextStyle(fontSize:10), textAlign: TextAlign.center),
                SizedBox(height:8),
                if(!desbloq) Icon(Icons.lock, size:20) else Column(children:[
                  Text("${prog.feitasHoje}/20 hoje", style: TextStyle(fontSize:12, fontWeight: FontWeight.bold, color: prog.concluidoHoje ? Colors.green : Colors.black)),
                  LinearProgressIndicator(value: (prog.feitasHoje/20).clamp(0,1), backgroundColor: Colors.grey.shade200, color: prog.concluidoHoje ? Colors.green : Colors.purple),
                  if(prog.concluidoHoje) Text("✅ Concluído!", style: TextStyle(fontSize:10, color: Colors.green, fontWeight: FontWeight.bold)),
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
      padding: EdgeInsets.all(16),
      children:[
        Card(color: Colors.amber.shade100, child: ListTile(leading: Text("💎", style: TextStyle(fontSize:30)), title: Text("Seus Robux: $robux"), subtitle: Text("Compre mais joguinhos! Sempre soma!"), trailing: IconButton(icon: Text("🔊"), onPressed: ()=> VozDaAlice.falar("Você tem $robux Robux para comprar jogos")))),
        ...loja.map((item){
          return Card(
            child: ListTile(
              leading: Text(item.emoji, style: TextStyle(fontSize:32)),
              title: Text(item.nome),
              subtitle: Text(item.comprado ? "✅ Já comprado - desbloqueado!" : "${item.preco} 💎 Robux"),
              trailing: item.comprado ? Icon(Icons.check, color: Colors.green) : ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green), onPressed: ()=> _comprarJogo(item), child: Text("COMPRAR")),
              onTap: ()=> VozDaAlice.falar(item.nome),
            ),
          );
        }).toList(),
        Card(color: Colors.purple.shade50, child: ListTile(title: Text("💡 Como ganhar Robux?"), subtitle: Text("• Tarefa com foto = +3 💎\n• Cada questão do joguinho = +2 💎\n• 20 questões = +10 bônus\n• Todos jogos 20/20 = +20 bônus e Roblox auto liberado"))),
      ],
    );
  }

  Widget _buildFamilia(){
    if(familiaBloqueada){
      return _buildFamiliaLogin();
    }
    return ListView(
      padding: EdgeInsets.all(16),
      children:[
        Card(color: Colors.blue.shade50, child: ListTile(leading: Icon(Icons.family_restroom), title: Text("Olá, ${logado!.nome}!"), subtitle: Text("Modo Família Protegido 🔒"), trailing: IconButton(icon: Icon(Icons.logout), onPressed: (){ setState((){ familiaBloqueada=true; logado=null; }); }))),
        Card(child: ListTile(title: Text("⭐ $estrelas estrelas"), subtitle: Text("💎 $robux Robux"))),
        Card(child: Column(children: tasks.map((t)=> ListTile(leading: Text(t.emoji), title: Text(t.titulo), subtitle: t.fotoPath!=null ? Text("Foto: ${t.fotoPath!.split('/').last} • ${t.horaFeita}") : Text("Sem foto ainda"), trailing: t.feito ? Icon(Icons.check_circle, color: Colors.green) : Icon(Icons.pending))).toList())),
        Card(child: ListTile(title: Text("Gerenciar Família"), subtitle: Text("Adicionar vó, tio, etc"), onTap: _showAddFamilia)),
        ...familia.map((f)=> Card(child: ListTile(leading: Icon(Icons.person), title: Text(f.nome), subtitle: Text("Senha: ****")))).toList(),
        Card(color: Colors.red.shade50, child: ListTile(title: Text("Sair do Modo Família"), trailing: Icon(Icons.lock), onTap: (){ setState((){ familiaBloqueada=true; logado=null; }); })),
      ],
    );
  }

  Widget _buildFamiliaLogin(){
    String nomeSel = familia.isNotEmpty ? familia[0].nome : '';
    String senha = '';
    return StatefulBuilder(builder: (context, setLocal){
      return Padding(
        padding: EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children:[
          Icon(Icons.lock, size:60, color: Colors.purple),
          SizedBox(height:16),
          Text("Modo Família Protegido", style: TextStyle(fontSize:22, fontWeight: FontWeight.bold)),
          SizedBox(height:8),
          Text("Só responsáveis entram. Alice não pode ver.", style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
          SizedBox(height:24),
          DropdownButtonFormField<String>(
            value: nomeSel.isEmpty ? null : nomeSel,
            decoration: InputDecoration(labelText: "Quem é você?", border: OutlineInputBorder()),
            items: familia.map((f)=> DropdownMenuItem(value: f.nome, child: Text(f.nome))).toList(),
            onChanged: (v){ setLocal(()=> nomeSel=v!); },
          ),
          SizedBox(height:12),
          TextFormField(decoration: InputDecoration(labelText: "Senha", border: OutlineInputBorder()), obscureText: true, onChanged: (v)=> senha=v),
          SizedBox(height:16),
          SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(vertical:14)), onPressed: (){
            var achou = familia.where((f)=> f.nome==nomeSel && f.senha==senha).toList();
            if(achou.isNotEmpty){
              setState((){ logado=achou.first; familiaBloqueada=false; });
              VozDaAlice.falar("Olá ${logado!.nome}, modo família liberado");
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Nome ou senha errada!")));
            }
          }, child: Text("ENTRAR"))),
          SizedBox(height:12),
          TextButton(onPressed: _showAddFamilia, child: Text("Criar novo responsável (mãe, pai, vó)")),
        ]),
      );
    });
  }

  void _showAddFamilia(){
    String nome=''; String senha='';
    showDialog(context: context, builder: (_)=> AlertDialog(
      title: Text("Novo responsável"),
      content: Column(mainAxisSize: MainAxisSize.min, children:[
        TextField(decoration: InputDecoration(labelText: "Nome (ex: Vó Maria)"), onChanged: (v)=> nome=v),
        TextField(decoration: InputDecoration(labelText: "Senha"), obscureText:true, onChanged: (v)=> senha=v),
      ]),
      actions:[
        TextButton(onPressed: ()=> Navigator.pop(context), child: Text("Cancelar")),
        ElevatedButton(onPressed: (){
          if(nome.isNotEmpty && senha.isNotEmpty){
            setState(()=> familia.add(FamilyUser(nome:nome, senha:senha)));
            _save();
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Responsável $nome criado!")));
          }
        }, child: Text("Criar")),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [ _buildRotina(), _buildJogos(), _buildLoja(), _buildFamilia() ][tab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tab,
        onTap: (i){
          if(i==3 && familiaBloqueada){
            // pede login
          }
          setState(()=> tab=i);
          if(i==0) VozDaAlice.falar("Rotina");
          if(i==1) VozDaAlice.falar("Jogos");
          if(i==2) VozDaAlice.falar("Lojinha");
          if(i==3) VozDaAlice.falar("Modo família protegido com senha");
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Rotina"),
          BottomNavigationBarItem(icon: Icon(Icons.games), label: "Jogos"),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "Loja"),
          BottomNavigationBarItem(icon: Icon(Icons.lock), label: "Família"),
        ],
      ),
    );
  }
}

// JOGOS - com 20 questões, horizontal, voz, cores fixas

class SilabasGame extends StatefulWidget {
  final VoidCallback onGanha;
  const SilabasGame({super.key, required this.onGanha});
  @override
  State<SilabasGame> createState() => _SilabasGameState();
}
class _SilabasGameState extends State<SilabasGame> {
  List<Map<String,String>> palavras = [
    {'resp':'CASA','exibe':'CA-SA','dica':'CA SA - onde moramos','s1':'CA','s2':'SA'},
    {'resp':'BOLA','exibe':'BO-LA','dica':'BO LA - brinquedo','s1':'BO','s2':'LA'},
    {'resp':'GATO','exibe':'GA-TO','dica':'GA TO - miau','s1':'GA','s2':'TO'},
    {'resp':'AGUA','exibe':'A-GUA','dica':'A GUA - pra beber','s1':'A','s2':'GUA'},
    {'resp':'LIVRO','exibe':'LI-VRO','dica':'LI VRO - pra ler','s1':'LI','s2':'VRO'},
  ];
  int idx=0; String montada=''; String msg=''; final rand=Random();
  Map<String,String> get p => palavras[idx % palavras.length];
  String _semAcento(String s){ return s.replaceAll('Á','A').replaceAll('Â','A').replaceAll('Ã','A').replaceAll('É','E').replaceAll('Ê','E').replaceAll('Í','I').replaceAll('Ó','O').replaceAll('Ô','O').replaceAll('Ú','U').replaceAll('Ç','C'); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('🔤 Sílabas Mágicas'), actions: [IconButton(icon: Text('🔊', style: TextStyle(fontSize:24)), onPressed: ()=> VozDaAlice.falar('Sílabas mágicas. Forme a palavra ${p['exibe']} . Dica ${p['dica']}'))]), body: Padding(padding: EdgeInsets.all(20), child: Column(children:[
      InkWell(onTap: ()=> VozDaAlice.falar('Forme a palavra ${p['exibe']}'), child: Text('Forme: ${p['exibe']}', style: TextStyle(fontSize:26, fontWeight: FontWeight.bold))),
      Text(p['dica']!, style: TextStyle(color: Colors.grey)), SizedBox(height:12),
      Wrap(spacing:12, children:[
        ElevatedButton(onPressed: (){ setState(()=> montada+=p['s1']!); VozDaAlice.falar(p['s1']!); }, child: Text(p['s1']!)), 
        ElevatedButton(onPressed: (){ setState(()=> montada+=p['s2']!); VozDaAlice.falar(p['s2']!); }, child: Text(p['s2']!)),
        ElevatedButton(onPressed: ()=> setState(()=> montada=''), child: Text('Limpar')),
      ]),
      SizedBox(height:20), Text('Você montou: $montada', style: TextStyle(fontSize:22)), Text(msg, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
      SizedBox(height:20),
      ElevatedButton(onPressed: (){
        if(_semAcento(montada.toUpperCase()) == _semAcento(p['resp']!.toUpperCase())){
          widget.onGanha(); setState(()=> msg='🎉 Acertou! +1 ⭐ +2 💎'); VozDaAlice.falar('Acertou! ${p['resp']}'); Future.delayed(Duration(seconds:1), ()=> setState((){ idx++; montada=''; msg=''; }));
        } else { setState(()=> msg='Tenta de novo! Aqui pode errar.'); VozDaAlice.falar('Tenta de novo'); }
      }, child: Text('CONFIRMAR')),
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
  List<String> palavras=['CASA','BOLA','GATO','LIVRO','AGUA','SOL','LUA','PEIXE'];
  int idx=0; String tentativa=''; String msg='';
  @override
  Widget build(BuildContext context) {
    String palavra = palavras[idx % palavras.length];
    String escondida = palavra[0] + ' _ ' * (palavra.length-2) + palavra[palavra.length-1];
    return Scaffold(appBar: AppBar(title: Text('🔍 Palavra Escondida'), actions:[IconButton(icon: Text('🔊'), onPressed: ()=> VozDaAlice.falar('Palavra escondida. Dica começa com ${palavra[0]} e termina com ${palavra[palavra.length-1]}'))]), body: Padding(padding: EdgeInsets.all(20), child: Column(children:[
      Text(escondida, style: TextStyle(fontSize:32, letterSpacing:8)), SizedBox(height:12),
      TextField(decoration: InputDecoration(labelText: 'Qual a palavra?', border: OutlineInputBorder()), onChanged: (v)=> tentativa=v.toUpperCase(), onTap: ()=> VozDaAlice.falar('Digite a palavra')),
      SizedBox(height:12), Text(msg), SizedBox(height:12),
      ElevatedButton(onPressed: (){
        if(tentativa==palavra){ widget.onGanha(); setState(()=> msg='🎉 Acertou $palavra! +1 ⭐'); VozDaAlice.falar('Acertou $palavra'); Future.delayed(Duration(seconds:1), ()=> setState((){ idx++; tentativa=''; msg=''; })); }
        else { setState(()=> msg='Quase! Tenta de novo. Aqui pode errar vale estrela!'); widget.onGanha(); VozDaAlice.falar('Tenta de novo'); }
      }, child: Text('CONFIRMAR')),
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
  List<Color> cores = [];
  @override
  void initState(){ super.initState(); _nova(); }
  void _nova(){ setState((){ qtd = rand.nextInt(8)+2; resp=0; msg='Conte os blocos 🟦'; cores = List.generate(qtd, (_) => Colors.primaries[rand.nextInt(Colors.primaries.length)]); }); VozDaAlice.falar('Conte os blocos. Quantos blocos tem?');}
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('🟦 Contando Blocos'), actions: [IconButton(icon: Text('🔊', style: TextStyle(fontSize:24)), onPressed: ()=> VozDaAlice.falar('Contando blocos. Quantos blocos? $qtd blocos na tela.'))]), body: Padding(padding: EdgeInsets.all(16), child: Column(children:[
      InkWell(onTap: ()=> VozDaAlice.falar('Quantos blocos? $qtd blocos'), child: Text('Quantos blocos?', style: TextStyle(fontSize:20, fontWeight: FontWeight.bold))),
      SizedBox(height:12),
      Wrap(spacing:8, runSpacing:8, children: List.generate(qtd, (i)=> Container(width:50, height:50, decoration: BoxDecoration(color: cores.isNotEmpty ? cores[i] : Colors.blue, borderRadius: BorderRadius.circular(8), border: Border.all(width:2)), child: Center(child: Text('🧱'))))),
      SizedBox(height:20),
      Wrap(alignment: WrapAlignment.center, spacing:8, runSpacing:8, children: List.generate(10, (i)=> SizedBox(width:60, height:45, child: ElevatedButton(onPressed: ()=> setState(()=> resp=i+1), child: Text('${i+1}', style: TextStyle(fontSize:18)))))),
      SizedBox(height:12), Text('Você escolheu: $resp', style: TextStyle(fontSize:20)), Text(msg, style: TextStyle(fontWeight: FontWeight.bold)),
      SizedBox(height:12),
      ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF8A2BE2), foregroundColor: Colors.white), onPressed: (){
        if(resp==qtd){ widget.onGanha(); setState(()=> msg='🎉 Acertou! $qtd blocos! +1 ⭐ +2 💎'); VozDaAlice.falar('Acertou $qtd blocos'); Future.delayed(Duration(seconds:1), _nova); }
        else { setState(()=> msg='Quase! Conta de novo. Aqui pode errar, vale estrela mesmo assim!'); widget.onGanha(); VozDaAlice.falar('Quase, conta de novo'); }
      }, child: Text('CONFIRMAR')),
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
  void _nova(){ setState((){a=rand.nextInt(5)+1; b=rand.nextInt(5)+1; resp=0; msg='';}); VozDaAlice.falar('Você tem $a Robux, ganhou mais $b, quanto tem agora?');}
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('🏪 Lojinha da Aventura'), actions: [IconButton(icon: Text('🔊', style: TextStyle(fontSize:24)), onPressed: ()=> VozDaAlice.falar('Lojinha da aventura. Você tem $a Robux, ganhou mais $b Robux, quanto tem agora? $a mais $b é quanto?'))]), body: Padding(padding: EdgeInsets.all(20), child: Column(children:[
      InkWell(onTap: ()=> VozDaAlice.falar('Você tem $a Robux, ganhou mais $b Robux, quanto tem agora? $a mais $b é igual a quanto?'), child: Container(padding: EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.yellow.shade100, borderRadius: BorderRadius.circular(16)), child: Column(children:[
        Text('Você tem $a 💎 Robux', style: TextStyle(fontSize:20)), Text('Ganhou mais $b 💎', style: TextStyle(fontSize:20)), SizedBox(height:12),
        Text('Quanto tem agora?', style: TextStyle(fontWeight: FontWeight.bold)), SizedBox(height:8),
        Text('$a + $b = ?', style: TextStyle(fontSize:28, fontWeight: FontWeight.bold)),
      ]))),
      SizedBox(height:20),
      Wrap(alignment: WrapAlignment.center, spacing:8, runSpacing:8, children: List.generate(10, (i)=> SizedBox(width:60, height:45, child: ElevatedButton(onPressed: ()=> setState(()=> resp=i+1), child: Text('${i+1}', style: TextStyle(fontSize:18)))))),
      SizedBox(height:12), Text('Resposta: $resp', style: TextStyle(fontSize:22)), Text(msg, style: TextStyle(fontWeight: FontWeight.bold)),
      SizedBox(height:12),
      ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(horizontal:32, vertical:14)), onPressed: (){
        if(resp==a+b){ widget.onGanha(); setState(()=> msg='🎉 Isso! ${a+b} Robux! +1 ⭐ +2 💎'); VozDaAlice.falar('Isso! ${a+b} Robux'); Future.delayed(Duration(seconds:1), _nova); }
        else { setState(()=> msg='Ops, tenta somar com os dedinhos! Aqui pode errar.'); widget.onGanha(); VozDaAlice.falar('Tenta somar com os dedinhos'); }
      }, child: Text('COMPRAR 🛒')),
    ])));
  }
}

class MemoriaGame extends StatefulWidget {
  final VoidCallback onGanha;
  const MemoriaGame({super.key, required this.onGanha});
  @override
  State<MemoriaGame> createState() => _MemoriaGameState();
}
class _MemoriaGameState extends State<MemoriaGame> {
  int acertos=0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('🧩 Memória')), body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children:[
      Text('Jogo da Memória em breve!', style: TextStyle(fontSize:20)),
      SizedBox(height:12),
      ElevatedButton(onPressed: (){ widget.onGanha(); setState(()=> acertos++); if(acertos>=20){ Navigator.pop(context); } }, child: Text('Ganhar ponto $acertos/20')),
    ])));
  }
}
class CacaGame extends StatefulWidget {
  final VoidCallback onGanha;
  const CacaGame({super.key, required this.onGanha});
  @override
  State<CacaGame> createState() => _CacaGameState();
}
class _CacaGameState extends State<CacaGame> {
  int acertos=0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('🔎 Caça Palavras')), body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children:[
      Text('Caça Palavras em breve!', style: TextStyle(fontSize:20)),
      ElevatedButton(onPressed: (){ widget.onGanha(); setState(()=> acertos++); if(acertos>=20) Navigator.pop(context); }, child: Text('Ganhar ponto $acertos/20')),
    ])));
  }
}
class TurboGame extends StatefulWidget {
  final VoidCallback onGanha;
  const TurboGame({super.key, required this.onGanha});
  @override
  State<TurboGame> createState() => _TurboGameState();
}
class _TurboGameState extends State<TurboGame> {
  int acertos=0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('🚀 Turbo')), body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children:[
      Text('Matemática Turbo em breve!', style: TextStyle(fontSize:20)),
      ElevatedButton(onPressed: (){ widget.onGanha(); setState(()=> acertos++); if(acertos>=20) Navigator.pop(context); }, child: Text('Ganhar ponto $acertos/20')),
    ])));
  }
