
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MundoAliceApp());

class MundoAliceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mundo da Alice - Roblox',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF18191A),
        primaryColor: Color(0xFFE22326),
        fontFamily: 'Roboto',
      ),
      home: TelaEscolhaRoblox(),
    );
  }
}

// ============ TELA INICIAL ROBLOX.COM ============
class TelaEscolhaRoblox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF18191A),
      body: Column(
        children: [
          // HEADER ROBLOX
          Container(
            height: 60,
            color: Color(0xFF232527),
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Color(0xFFE22326), borderRadius: BorderRadius.circular(6)),
                  child: Text("ROBLOX", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white, letterSpacing: 1)),
                ),
                SizedBox(width: 10),
                Text("MUNDO DA ALICE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white70)),
                Spacer(),
                Icon(Icons.search, color: Colors.white54),
                SizedBox(width: 12),
                Icon(Icons.settings, color: Colors.white54),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BANNER
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Color(0xFFE22326), Color(0xFFFF6B6B)]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text("MUNDO DA ALICE", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
                            SizedBox(height: 6),
                            Text("Complete tarefas, tire fotos e libere jogos estilo Roblox!", style: TextStyle(color: Colors.white70, fontSize: 14)),
                            SizedBox(height: 12),
                            Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)), child: Text("7 anos • Aprender brincando", style: TextStyle(fontSize: 12))),
                          ]),
                        ),
                        Text("🌈", style: TextStyle(fontSize: 60)),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text("ESCOLHA SEU PERFIL", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 12),
                  // CARD ALICE - ESTILO ROBLOX GAME CARD
                  _RobloxCard(
                    cor: Color(0xFF00A2FF),
                    titulo: "SOU A ALICE",
                    subtitulo: "Jogar e fazer tarefas com foto",
                    descricao: "4 tarefas com foto • 4 jogos • Lojinha Robux",
                    icone: "🎮",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TelaAliceRoblox())),
                  ),
                  SizedBox(height: 12),
                  _RobloxCard(
                    cor: Color(0xFF393B3D),
                    titulo: "RESPONSÁVEL",
                    subtitulo: "Ver fotos, progresso e liberar Roblox",
                    descricao: "Senha: 1234 • Ver horários • Aprovar tarefas",
                    icone: "🔒",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TelaLoginFamilia())),
                  ),
                  SizedBox(height: 20),
                  Text("COMO FUNCIONA", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white54)),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Color(0xFF232527), borderRadius: BorderRadius.circular(8)),
                    child: Column(children: [
                      _PassoRoblox(n: "1", txt: "Alice entra e tira foto das 4 tarefas do dia"),
                      _PassoRoblox(n: "2", txt: "Cada foto libera 1 jogo (20 questões cada)"),
                      _PassoRoblox(n: "3", txt: "Cada acerto = +2 Robux, bônus +10 quando faz 20/20"),
                      _PassoRoblox(n: "4", txt: "Fazendo 80/80 libera Roblox por 20 min"),
                      _PassoRoblox(n: "5", txt: "Na lojinha compra jogos novos com Robux"),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RobloxCard extends StatelessWidget {
  final Color cor;
  final String titulo, subtitulo, descricao, icone;
  final VoidCallback onTap;
  _RobloxCard({required this.cor, required this.titulo, required this.subtitulo, required this.descricao, required this.icone, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(color: Color(0xFF232527), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
        child: Row(children: [
          Container(width: 70, height: 70, decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(12)), child: Center(child: Text(icone, style: TextStyle(fontSize: 32)))),
          SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(titulo, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white)),
              Text(subtitulo, style: TextStyle(fontSize: 13, color: Colors.white70)),
              SizedBox(height: 4),
              Text(descricao, style: TextStyle(fontSize: 11, color: Colors.white38)),
            ]),
          ),
          Icon(Icons.play_arrow, color: Colors.white54),
        ]),
      ),
    );
  }
}

class _PassoRoblox extends StatelessWidget {
  final String n, txt;
  _PassoRoblox({required this.n, required this.txt});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Container(width: 22, height: 22, decoration: BoxDecoration(color: Color(0xFF393B3D), shape: BoxShape.circle), child: Center(child: Text(n, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))),
        SizedBox(width: 8),
        Expanded(child: Text(txt, style: TextStyle(fontSize: 12, color: Colors.white70))),
      ]),
    );
  }
}

// LOGIN FAMILIA
class TelaLoginFamilia extends StatefulWidget {
  @override
  _TelaLoginFamiliaState createState() => _TelaLoginFamiliaState();
}
class _TelaLoginFamiliaState extends State<TelaLoginFamilia> {
  final List<Map<String,String>> familia = [
    {"nome":"Ana Beatriz","senha":"1234"},
    {"nome":"Matheus","senha":"1234"},
    {"nome":"Jean","senha":"1234"},
    {"nome":"Vó","senha":"1234"},
  ];
  String nomeSelecionado = "Ana Beatriz";
  TextEditingController senhaCtrl = TextEditingController();
  void entrar() async {
    var fam = familia.firstWhere((f)=> f["nome"]==nomeSelecionado);
    if(senhaCtrl.text == fam["senha"]){
      SharedPreferences p = await SharedPreferences.getInstance();
      await p.setString("usuario_logado", nomeSelecionado);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> TelaResponsavelRoblox(usuario: nomeSelecionado)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Senha incorreta! Use 1234")));
    }
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Color(0xFF18191A),
      appBar: AppBar(title: Text("Área Responsável"), backgroundColor: Color(0xFF232527)),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Quem está entrando?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: Color(0xFF232527), borderRadius: BorderRadius.circular(8)),
            child: DropdownButton<String>(
              value: nomeSelecionado,
              isExpanded: true,
              dropdownColor: Color(0xFF232527),
              underline: SizedBox(),
              items: familia.map((f)=> DropdownMenuItem(value: f["nome"], child: Text(f["nome"]!))).toList(),
              onChanged: (v)=> setState(()=> nomeSelecionado=v!),
            ),
          ),
          SizedBox(height: 20),
          TextField(controller: senhaCtrl, obscureText: true, decoration: InputDecoration(labelText: "Senha (1234)", filled: true, fillColor: Color(0xFF232527), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)), style: TextStyle(color: Colors.white)),
          SizedBox(height: 20),
          SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: entrar, style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFE22326)), child: Text("Entrar", style: TextStyle(fontWeight: FontWeight.bold)))),
        ]),
      ),
    );
  }
}

// ============ TELA ALICE - ROBLOX STYLE COM FOTO ============
class TelaAliceRoblox extends StatefulWidget {
  @override
  _TelaAliceRobloxState createState() => _TelaAliceRobloxState();
}
class _TelaAliceRobloxState extends State<TelaAliceRoblox> {
  List<Map<String,dynamic>> tarefas = [];
  int robux = 0;
  Map<String,int> progressos = {"memoria":0,"palavra":0,"blocos":0,"lojinha":0};
  Map<String,bool> jogosComprados = {"memoria":true,"palavra":true,"blocos":false,"lojinha":false,"parkour":false,"obby":false};
  final picker = ImagePicker();

  @override
  void initState(){ super.initState(); carregar(); }

  Future<void> carregar() async {
    SharedPreferences p = await SharedPreferences.getInstance();
    setState((){
      robux = p.getInt("robux_alice") ?? 0;
      progressos = {
        "memoria": p.getInt("prog_memoria") ?? 0,
        "palavra": p.getInt("prog_palavra") ?? 0,
        "blocos": p.getInt("prog_blocos") ?? 0,
        "lojinha": p.getInt("prog_lojinha") ?? 0,
      };
      String? tarefasJson = p.getString("tarefas_alice_v4");
      if(tarefasJson!=null){
        tarefas = List<Map<String,dynamic>>.from(jsonDecode(tarefasJson).map((e)=> Map<String,dynamic>.from(e)));
      } else {
        tarefas = [
          {"titulo":"Arrumar a cama","feita":false,"hora":"","foto":""},
          {"titulo":"Escovar os dentes","feita":false,"hora":"","foto":""},
          {"titulo":"Guardar brinquedos","feita":false,"hora":"","foto":""},
          {"titulo":"Dever de casa","feita":false,"hora":"","foto":""},
        ];
      }
      jogosComprados["blocos"] = p.getBool("comp_blocos") ?? false;
      jogosComprados["lojinha"] = p.getBool("comp_lojinha") ?? false;
      jogosComprados["parkour"] = p.getBool("comp_parkour") ?? false;
      jogosComprados["obby"] = p.getBool("comp_obby") ?? false;
    });
  }

  Future<void> salvar() async {
    SharedPreferences p = await SharedPreferences.getInstance();
    await p.setInt("robux_alice", robux);
    await p.setString("tarefas_alice_v4", jsonEncode(tarefas));
    await p.setInt("prog_memoria", progressos["memoria"]!);
    await p.setInt("prog_palavra", progressos["palavra"]!);
    await p.setInt("prog_blocos", progressos["blocos"]!);
    await p.setInt("prog_lojinha", progressos["lojinha"]!);
    await p.setBool("comp_blocos", jogosComprados["blocos"]!);
    await p.setBool("comp_lojinha", jogosComprados["lojinha"]!);
    await p.setBool("comp_parkour", jogosComprados["parkour"]!);
    await p.setBool("comp_obby", jogosComprados["obby"]!);
  }

  Future<void> tirarFoto(int idx) async {
    try{
      final XFile? file = await picker.pickImage(source: ImageSource.camera, imageQuality: 60);
      if(file==null) return;
      final bytes = await file.readAsBytes();
      final base64Img = base64Encode(bytes);
      setState((){
        tarefas[idx]["feita"]=true;
        tarefas[idx]["hora"]= TimeOfDay.now().format(context);
        tarefas[idx]["foto"]= base64Img;
        robux+=5;
      });
      await salvar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Foto salva! +5 Robux!"), backgroundColor: Colors.green));
    }catch(e){
      // Fallback galeria para WEB
      try{
        final XFile? file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 60);
        if(file==null) return;
        final bytes = await file.readAsBytes();
        final base64Img = base64Encode(bytes);
        setState((){
          tarefas[idx]["feita"]=true;
          tarefas[idx]["hora"]= TimeOfDay.now().format(context);
          tarefas[idx]["foto"]= base64Img;
          robux+=5;
        });
        await salvar();
      }catch(e2){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao tirar foto: $e2")));
      }
    }
  }

  void onAcerto(String jogo){
    setState((){
      progressos[jogo]= progressos[jogo]!+1;
      robux+=2;
      if(progressos[jogo]==20){ robux+=10; }
    });
    salvar();
  }

  bool get todasFotosFeitas => tarefas.where((t)=> t["feita"]==true).length >= tarefas.length;
  int get totalFeito => progressos.values.reduce((a,b)=> a+b);
  bool get liberaRoblox => totalFeito>=80 && todasFotosFeitas;

  void comprarJogo(String id, int preco){
    if(robux>=preco && jogosComprados[id]==false){
      setState((){
        robux-=preco;
        jogosComprados[id]=true;
      });
      salvar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Jogo comprado!"), backgroundColor: Colors.green));
    } else if(jogosComprados[id]==true){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Você já tem esse jogo!")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Robux insuficiente! Faça tarefas e jogos"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Color(0xFF18191A),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Container(
          color: Color(0xFF232527),
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 12, right: 12),
          child: Row(children: [
            IconButton(icon: Icon(Icons.arrow_back), onPressed: ()=> Navigator.pop(context)),
            Container(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Color(0xFFE22326), borderRadius: BorderRadius.circular(4)), child: Text("ALICE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12))),
            SizedBox(width: 8),
            Text("Mundo da Alice", style: TextStyle(fontWeight: FontWeight.bold)),
            Spacer(),
            Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Color(0xFF393B3D), borderRadius: BorderRadius.circular(20)), child: Row(children: [Icon(Icons.diamond, size: 16, color: Color(0xFF00A2FF)), SizedBox(width: 4), Text("$robux", style: TextStyle(fontWeight: FontWeight.bold))])),
          ]),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // STATUS
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(color: Color(0xFF232527), borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("TAREFAS COM FOTO", style: TextStyle(fontSize: 11, color: Colors.white54)), Text("${tarefas.where((t)=>t["feita"]==true).length}/${tarefas.length} feitas", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))])),
              Container(width: 1, height: 30, color: Colors.white10),
              SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("JOGOS", style: TextStyle(fontSize: 11, color: Colors.white54)), Text("$totalFeito/80", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))])),
              Container(width: 1, height: 30, color: Colors.white10),
              SizedBox(width: 12),
              Column(children: [Text("ROBLOX", style: TextStyle(fontSize: 11, color: Colors.white54)), Icon(liberaRoblox? Icons.check_circle : Icons.lock, color: liberaRoblox? Colors.green : Colors.white24)]),
            ]),
          ),
          SizedBox(height: 16),
          Text("📸 MINHAS TAREFAS - TIRE FOTO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.1, crossAxisSpacing: 10, mainAxisSpacing: 10),
            itemCount: tarefas.length,
            itemBuilder: (ctx,i){
              var t = tarefas[i];
              bool feita = t["feita"];
              return Container(
                decoration: BoxDecoration(color: Color(0xFF232527), borderRadius: BorderRadius.circular(12), border: Border.all(color: feita? Colors.green : Colors.white10)),
                child: Column(children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(color: Color(0xFF393B3D), borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
                      child: feita && t["foto"]!="" ? ClipRRect(borderRadius: BorderRadius.vertical(top: Radius.circular(12)), child: Image.memory(base64Decode(t["foto"]), fit: BoxFit.cover)) : Center(child: Text(feita? "✅" : "📷", style: TextStyle(fontSize: 30))),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(children: [
                      Text(t["titulo"], style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 2),
                      SizedBox(height: 4),
                      feita ? Text("Feito às ${t["hora"]}", style: TextStyle(fontSize: 10, color: Colors.green)) :
                      SizedBox(width: double.infinity, height: 32, child: ElevatedButton(onPressed: ()=> tirarFoto(i), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF00A2FF), padding: EdgeInsets.zero), child: Text("TIRAR FOTO", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)))),
                    ]),
                  ),
                ]),
              );
            },
          ),
          SizedBox(height: 16),
          Text("🎮 MEUS JOGOS - ESTILO ROBLOX", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          SizedBox(height: 8),
          // JOGOS GRID
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 0.85,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _GameCardRoblox(titulo: "Memória", progresso: progressos["memoria"]!, liberado: tarefas.length>0 && tarefas[0]["feita"], preco: 0, comprado: jogosComprados["memoria"]!, cor: Colors.pink, onPlay: (){ if(tarefas[0]["feita"]) Navigator.push(context, MaterialPageRoute(builder: (_)=> JogoMemoria(onAcerto: ()=> onAcerto("memoria"), progresso: progressos["memoria"]!))); }, onBuy: (){}),
              _GameCardRoblox(titulo: "Palavra", progresso: progressos["palavra"]!, liberado: tarefas.length>1 && tarefas[1]["feita"], preco: 0, comprado: jogosComprados["palavra"]!, cor: Colors.blue, onPlay: (){ if(tarefas.length>1 && tarefas[1]["feita"]) Navigator.push(context, MaterialPageRoute(builder: (_)=> JogoPalavra(onAcerto: ()=> onAcerto("palavra"), progresso: progressos["palavra"]!))); }, onBuy: (){}),
              _GameCardRoblox(titulo: "Blocos", progresso: progressos["blocos"]!, liberado: tarefas.length>2 && tarefas[2]["feita"], preco: 70, comprado: jogosComprados["blocos"]!, cor: Colors.purple, onPlay: (){ if(jogosComprados["blocos"]==true) Navigator.push(context, MaterialPageRoute(builder: (_)=> JogoBlocos(onAcerto: ()=> onAcerto("blocos"), progresso: progressos["blocos"]!))); }, onBuy: ()=> comprarJogo("blocos",70)),
              _GameCardRoblox(titulo: "Lojinha", progresso: progressos["lojinha"]!, liberado: tarefas.length>3 && tarefas[3]["feita"], preco: 70, comprado: jogosComprados["lojinha"]!, cor: Colors.green, onPlay: (){ if(jogosComprados["lojinha"]==true) Navigator.push(context, MaterialPageRoute(builder: (_)=> JogoLojinha(onAcerto: ()=> onAcerto("lojinha"), progresso: progressos["lojinha"]!))); }, onBuy: ()=> comprarJogo("lojinha",70)),
              _GameCardRoblox(titulo: "Parkour", progresso: 0, liberado: false, preco: 100, comprado: jogosComprados["parkour"]!, cor: Colors.orange, isNew: true, onPlay: (){}, onBuy: ()=> comprarJogo("parkour",100)),
              _GameCardRoblox(titulo: "Obby", progresso: 0, liberado: false, preco: 120, comprado: jogosComprados["obby"]!, cor: Colors.red, isNew: true, onPlay: (){}, onBuy: ()=> comprarJogo("obby",120)),
            ],
          ),
          SizedBox(height: 16),
          // BOTAO ROBLOX
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: liberaRoblox ? () async {
                const url = "https://www.roblox.com/";
                if(await canLaunchUrl(Uri.parse(url))){ await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication); }
              } : null,
              style: ElevatedButton.styleFrom(backgroundColor: liberaRoblox? Color(0xFFE22326) : Color(0xFF393B3D), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(liberaRoblox? Icons.play_arrow : Icons.lock, size: 28),
                SizedBox(width: 8),
                Text(liberaRoblox? "JOGAR ROBLOX AGORA - 20 MIN" : "COMPLETE ${80-totalFeito} JOGOS + ${tarefas.where((t)=>!t["feita"]).length} FOTOS PARA LIBERAR", style: TextStyle(fontWeight: FontWeight.w900, fontSize: liberaRoblox? 14 : 10)),
              ]),
            ),
          ),
          SizedBox(height: 30),
        ]),
      ),
    );
  }
}

class _GameCardRoblox extends StatelessWidget {
  final String titulo;
  final int progresso, preco;
  final bool liberado, comprado;
  final Color cor;
  final bool isNew;
  final VoidCallback onPlay, onBuy;
  _GameCardRoblox({required this.titulo, required this.progresso, required this.liberado, required this.preco, required this.comprado, required this.cor, required this.onPlay, required this.onBuy, this.isNew=false});
  @override
  Widget build(BuildContext context){
    return Container(
      decoration: BoxDecoration(color: Color(0xFF232527), borderRadius: BorderRadius.circular(12), border: Border.all(color: liberado? Colors.white24 : Colors.white10)),
      child: Column(children: [
        // IMAGEM JOGO
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(color: cor.withOpacity(0.3), borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
            child: Stack(children: [
              Center(child: Text(titulo[0], style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: cor))),
              if(isNew) Positioned(top: 6, left: 6, child: Container(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.yellow, borderRadius: BorderRadius.circular(4)), child: Text("NOVO", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black)))),
              if(!liberado && preco==0) Positioned.fill(child: Container(decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.vertical(top: Radius.circular(12))), child: Center(child: Icon(Icons.lock, color: Colors.white)))),
            ]),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(titulo, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            SizedBox(height: 2),
            if(preco==0) ...[
              LinearProgressIndicator(value: progresso/20, backgroundColor: Colors.white10, color: cor),
              SizedBox(height: 4),
              Text("$progresso/20", style: TextStyle(fontSize: 11, color: Colors.white54)),
              SizedBox(height: 6),
              SizedBox(width: double.infinity, height: 32, child: ElevatedButton(onPressed: liberado? onPlay : null, style: ElevatedButton.styleFrom(backgroundColor: liberado? Colors.white : Color(0xFF393B3D), foregroundColor: liberado? Colors.black : Colors.white54, padding: EdgeInsets.zero), child: Text(liberado? "JOGAR" : "TIRE FOTO", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)))),
            ] else ...[
              Row(children: [Icon(Icons.diamond, size: 12, color: Color(0xFF00A2FF)), SizedBox(width: 4), Text("$preco", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))]),
              SizedBox(height: 6),
              SizedBox(width: double.infinity, height: 32, child: ElevatedButton(onPressed: comprado? onPlay : onBuy, style: ElevatedButton.styleFrom(backgroundColor: comprado? Colors.green : Color(0xFF00A2FF), padding: EdgeInsets.zero), child: Text(comprado? (liberado? "JOGAR" : "TIRE FOTO") : "COMPRAR", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)))),
            ],
          ]),
        ),
      ]),
    );
  }
}

// RESPONSAVEL ROBLOX STYLE
class TelaResponsavelRoblox extends StatefulWidget {
  final String usuario;
  TelaResponsavelRoblox({required this.usuario});
  @override
  _TelaResponsavelRobloxState createState() => _TelaResponsavelRobloxState();
}
class _TelaResponsavelRobloxState extends State<TelaResponsavelRoblox> {
  List<Map<String,dynamic>> tarefas = [];
  Map<String,int> progressos = {};
  int robux=0;
  @override
  void initState(){ super.initState(); carregar(); }
  Future<void> carregar() async {
    SharedPreferences p = await SharedPreferences.getInstance();
    setState((){
      robux = p.getInt("robux_alice") ?? 0;
      progressos = {
        "memoria": p.getInt("prog_memoria") ?? 0,
        "palavra": p.getInt("prog_palavra") ?? 0,
        "blocos": p.getInt("prog_blocos") ?? 0,
        "lojinha": p.getInt("prog_lojinha") ?? 0,
      };
      String? tJson = p.getString("tarefas_alice_v4");
      if(tJson!=null) tarefas = List<Map<String,dynamic>>.from(jsonDecode(tJson).map((e)=> Map<String,dynamic>.from(e)));
    });
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Color(0xFF18191A),
      appBar: AppBar(title: Text("Responsável: ${widget.usuario} - ${tarefas.where((t)=>t["feita"]==true).length}/${tarefas.length} fotos"), backgroundColor: Color(0xFF232527)),
      body: ListView(
        padding: EdgeInsets.all(12),
        children: [
          Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Color(0xFF232527), borderRadius: BorderRadius.circular(10)), child: Row(children: [Text("Robux da Alice: $robux 💎", style: TextStyle(fontWeight: FontWeight.bold)), Spacer(), Text("Progresso: ${progressos.values.fold(0,(a,b)=>a+b)}/80") ])),
          SizedBox(height: 12),
          ...tarefas.map((t)=> Container(margin: EdgeInsets.only(bottom: 10), padding: EdgeInsets.all(10), decoration: BoxDecoration(color: Color(0xFF232527), borderRadius: BorderRadius.circular(10)), child: Row(children: [
            t["foto"]!="" ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.memory(base64Decode(t["foto"]), width: 70, height: 70, fit: BoxFit.cover)) : Container(width: 70, height: 70, decoration: BoxDecoration(color: Color(0xFF393B3D), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.photo, color: Colors.white24)),
            SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t["titulo"], style: TextStyle(fontWeight: FontWeight.bold)), Text(t["feita"]? "Feito às ${t["hora"]}" : "Não feito", style: TextStyle(fontSize: 12, color: t["feita"]? Colors.green : Colors.white38))])),
            Icon(t["feita"]? Icons.check_circle : Icons.pending, color: t["feita"]? Colors.green : Colors.white24),
          ]))),
          SizedBox(height: 20),
          SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () async { SharedPreferences p = await SharedPreferences.getInstance(); await p.clear(); carregar(); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Dia resetado!"))); }, style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFE22326)), child: Text("RESETAR DIA"))),
        ],
      ),
    );
  }
}

// ============ JOGOS (iguais antes, mas com tema escuro) ============
class JogoMemoria extends StatefulWidget {
  final Function onAcerto; final int progresso;
  JogoMemoria({required this.onAcerto, required this.progresso});
  @override
  _JogoMemoriaState createState() => _JogoMemoriaState();
}
class _JogoMemoriaState extends State<JogoMemoria> {
  List<String> emojis = ["🐶","🐱","🐶","🐱","🐰","🐰","🦊","🦊"];
  List<bool> revelado = List.filled(8,false);
  List<int> selecionados = [];
  @override
  void initState(){ super.initState(); emojis.shuffle(); }
  void clicar(int i){
    if(revelado[i] || selecionados.length>=2) return;
    setState(()=> selecionados.add(i));
    if(selecionados.length==2){
      Future.delayed(Duration(milliseconds: 800),(){
        if(emojis[selecionados[0]]==emojis[selecionados[1]]){
          setState((){
            revelado[selecionados[0]]=true;
            revelado[selecionados[1]]=true;
            selecionados=[];
            widget.onAcerto();
            if(revelado.every((e)=>e)){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Memória completa! +10 bônus"), backgroundColor: Colors.green)); }
          });
        } else { setState(()=> selecionados=[]); }
      });
    }
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(backgroundColor: Color(0xFF18191A), appBar: AppBar(title: Text("Memória ${widget.progresso}/20"), backgroundColor: Colors.pink), body: Column(children: [LinearProgressIndicator(value: widget.progresso/20), Expanded(child: GridView.count(crossAxisCount: 4, padding: EdgeInsets.all(20), children: List.generate(8, (i)=> GestureDetector(onTap: ()=> clicar(i), child: Container(margin: EdgeInsets.all(8), decoration: BoxDecoration(color: revelado[i] || selecionados.contains(i) ? Colors.pink[200] : Color(0xFF232527), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(revelado[i] || selecionados.contains(i) ? emojis[i] : "❓", style: TextStyle(fontSize: 32))))))]));
  }
}

class JogoPalavra extends StatefulWidget {
  final Function onAcerto; final int progresso;
  JogoPalavra({required this.onAcerto, required this.progresso});
  @override
  _JogoPalavraState createState() => _JogoPalavraState();
}
class _JogoPalavraState extends State<JogoPalavra> {
  List<Map<String,String>> palavras = [
    {"palavra":"CASA","dica":"Onde moramos"},
    {"palavra":"BOLA","dica":"Brinquedo redondo"},
    {"palavra":"GATO","dica":"Animal que mia"},
    {"palavra":"SOL","dica":"Ilumina o dia"},
  ];
  int idx=0; TextEditingController ctrl=TextEditingController();
  @override
  void initState(){ super.initState(); idx=Random().nextInt(palavras.length); }
  void verificar(){
    if(ctrl.text.toUpperCase().trim()==palavras[idx]["palavra"]){
      widget.onAcerto();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Correto! +2"), backgroundColor: Colors.green));
      setState((){ idx=Random().nextInt(palavras.length); ctrl.clear(); });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Tente de novo"), backgroundColor: Colors.red));
    }
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(backgroundColor: Color(0xFF18191A), appBar: AppBar(title: Text("Palavra ${widget.progresso}/20"), backgroundColor: Colors.blue), body: Padding(padding: EdgeInsets.all(20), child: Column(children: [LinearProgressIndicator(value: widget.progresso/20), SizedBox(height: 20), Container(width: double.infinity, padding: EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.blue[900], borderRadius: BorderRadius.circular(16)), child: Text("Dica: "+palavras[idx]["dica"]!, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white))), SizedBox(height: 30), TextField(controller: ctrl, decoration: InputDecoration(labelText: "Digite a palavra", filled: true, fillColor: Color(0xFF232527), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), style: TextStyle(fontSize: 20, color: Colors.white)), SizedBox(height: 20), SizedBox(width: double.infinity, height: 60, child: ElevatedButton(onPressed: verificar, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue), child: Text("Verificar", style: TextStyle(fontSize: 20))))])));
  }
}

class JogoBlocos extends StatefulWidget {
  final Function onAcerto; final int progresso;
  JogoBlocos({required this.onAcerto, required this.progresso});
  @override
  _JogoBlocosState createState() => _JogoBlocosState();
}
class _JogoBlocosState extends State<JogoBlocos> {
  Random rnd=Random(); int quantidade=3; int corFixa=0;
  List<Color> cores=[Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple];
  @override
  void initState(){ super.initState(); gerar(); }
  void gerar(){ setState((){ quantidade=rnd.nextInt(10)+1; corFixa=rnd.nextInt(cores.length); }); }
  void responder(int resp){
    if(resp==quantidade){ widget.onAcerto(); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Correto! +2"), backgroundColor: Colors.green)); gerar(); }
    else { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errou!"), backgroundColor: Colors.red)); }
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(backgroundColor: Color(0xFF18191A), appBar: AppBar(title: Text("Blocos ${widget.progresso}/20"), backgroundColor: Colors.purple), body: Column(children: [LinearProgressIndicator(value: widget.progresso/20), Container(color: Colors.purple[900], width: double.infinity, padding: EdgeInsets.all(16), child: Text("Quantos blocos?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))), Expanded(child: Padding(padding: EdgeInsets.all(20), child: GridView.count(crossAxisCount: 5, children: List.generate(quantidade, (i)=> Container(margin: EdgeInsets.all(6), decoration: BoxDecoration(color: cores[corFixa], borderRadius: BorderRadius.circular(8))))))), Padding(padding: EdgeInsets.all(16), child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [1,2,3,4,5].map((n)=> ElevatedButton(onPressed: ()=> responder(n), child: Text(n.toString()))).toList()), SizedBox(height: 12), Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [6,7,8,9,10].map((n)=> ElevatedButton(onPressed: ()=> responder(n), child: Text(n.toString()))).toList())]))]));
  }
}

class JogoLojinha extends StatefulWidget {
  final Function onAcerto; final int progresso;
  JogoLojinha({required this.onAcerto, required this.progresso});
  @override
  _JogoLojinhaState createState() => _JogoLojinhaState();
}
class _JogoLojinhaState extends State<JogoLojinha> {
  Random rnd=Random(); int preco=5; int pago=0;
  @override
  void initState(){ super.initState(); gerar(); }
  void gerar(){ setState((){ preco=rnd.nextInt(10)+1; pago=0; }); }
  void addNota(int v){ setState(()=> pago+=v); }
  void verificar(){
    if(pago==preco){ widget.onAcerto(); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Correto! +2"), backgroundColor: Colors.green)); gerar(); }
    else if(pago>preco){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Deu troco a mais!"), backgroundColor: Colors.red)); setState(()=> pago=0); }
    else { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Falta!"), backgroundColor: Colors.orange)); }
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(backgroundColor: Color(0xFF18191A), appBar: AppBar(title: Text("Lojinha ${widget.progresso}/20"), backgroundColor: Colors.green), body: Padding(padding: EdgeInsets.all(20), child: Column(children: [LinearProgressIndicator(value: widget.progresso/20), SizedBox(height: 20), Container(width: double.infinity, padding: EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.green[900], borderRadius: BorderRadius.circular(16)), child: Text("Preço: R\$ $preco - Quanto pagar?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white))), SizedBox(height: 30), Text("Pago: R\$ $pago", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)), SizedBox(height: 20), Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [1,2,5].map((n)=> ElevatedButton(onPressed: ()=> addNota(n), child: Text("R\$ $n"))).toList()), SizedBox(height: 30), Row(children: [Expanded(child: ElevatedButton(onPressed: verificar, style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: EdgeInsets.all(18)), child: Text("Pagar"))), SizedBox(width: 12), Expanded(child: ElevatedButton(onPressed: ()=> setState(()=> pago=0), style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, padding: EdgeInsets.all(18)), child: Text("Limpar")))] ) ])));
  }
}
