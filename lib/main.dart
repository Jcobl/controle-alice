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
      title: 'Mundo da Alice',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.pink, fontFamily: 'Roboto'),
      home: TelaEscolhaInicial(),
    );
  }
}

// TELA INICIAL COM 2 BOTOES GRANDES
class TelaEscolhaInicial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF6B9D), Color(0xFFC44569), Color(0xFFF8B500)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0,5))],
                    ),
                    child: Column(children: [
                      Text("🌈", style: TextStyle(fontSize: 50)),
                      Text("MUNDO", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFFFF6B9D), letterSpacing: 2)),
                      Text("DA ALICE", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFFF8B500), letterSpacing: 2)),
                      SizedBox(height: 10),
                      Text("Aprender brincando!", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                    ]),
                  ),
                  SizedBox(height: 40),
                  // BOTAO ALICE
                  Container(
                    width: double.infinity,
                    height: 120,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TelaAlice())),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color(0xFFFF6B9D),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 8,
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text("🎮", style: TextStyle(fontSize: 40)),
                        SizedBox(width: 15),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text("SOU A ALICE", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                          Text("Quero jogar!", style: TextStyle(fontSize: 14)),
                        ]),
                      ]),
                    ),
                  ),
                  SizedBox(height: 20),
                  // BOTAO RESPONSAVEL
                  Container(
                    width: double.infinity,
                    height: 120,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TelaLoginFamilia())),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2C3E50),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 8,
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text("🔒", style: TextStyle(fontSize: 40)),
                        SizedBox(width: 15),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text("RESPONSAVEL", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                          Text("Ver tarefas e fotos", style: TextStyle(fontSize: 13)),
                        ]),
                      ]),
                    ),
                  ),
                  SizedBox(height: 30),
                  Text("Toque em quem voce e", style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      ),
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
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> TelaResponsavel(usuario: nomeSelecionado)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Senha incorreta! Use 1234")));
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text("Area dos Responsaveis"), backgroundColor: Color(0xFF2C3E50)),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.blueGrey[50]!, Colors.white], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: Center(
          child: Card(
            margin: EdgeInsets.all(20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.family_restroom, size: 50, color: Color(0xFF2C3E50)),
                SizedBox(height: 10),
                Text("Quem esta usando?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 15),
                DropdownButton<String>(
                  value: nomeSelecionado,
                  isExpanded: true,
                  items: familia.map((f)=> DropdownMenuItem(value: f["nome"], child: Text(f["nome"]!))).toList(),
                  onChanged: (v){ setState(()=> nomeSelecionado=v!); },
                ),
                SizedBox(height: 10),
                TextField(controller: senhaCtrl, obscureText: true, decoration: InputDecoration(labelText: "Senha (1234)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                SizedBox(height: 20),
                Container(width: double.infinity, child: ElevatedButton(onPressed: entrar, style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF2C3E50), padding: EdgeInsets.all(15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text("Entrar", style: TextStyle(color: Colors.white, fontSize: 18)))),
                SizedBox(height: 10),
                TextButton(onPressed: ()=> Navigator.pop(context), child: Text("Voltar")),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// AREA DA ALICE - SO JOGAR
class TelaAlice extends StatefulWidget {
  @override
  _TelaAliceState createState() => _TelaAliceState();
}
class _TelaAliceState extends State<TelaAlice> {
  SharedPreferences? prefs;
  int robux = 0;
  Map<String,bool> tarefas = {"Chegada":false,"Brincar":false,"Leitura":false,"Numeros":false};
  Map<String,int> progresso = {"Silabas":0,"Palavra":0,"Blocos":0,"Lojinha":0};
  bool liberadoRoblox = false;
  Map<String,bool> jogosComprados = {"Memoria":false,"Caca":false,"Turbo":false};

  @override
  void initState(){ super.initState(); carregar(); }

  Future<void> carregar() async {
    prefs = await SharedPreferences.getInstance();
    setState((){
      robux = prefs!.getInt("robux") ?? 0;
      tarefas["Chegada"] = prefs!.getBool("tarefa_Chegada") ?? false;
      tarefas["Brincar"] = prefs!.getBool("tarefa_Brincar") ?? false;
      tarefas["Leitura"] = prefs!.getBool("tarefa_Leitura") ?? false;
      tarefas["Numeros"] = prefs!.getBool("tarefa_Numeros") ?? false;
      progresso["Silabas"] = prefs!.getInt("prog_Silabas") ?? 0;
      progresso["Palavra"] = prefs!.getInt("prog_Palavra") ?? 0;
      progresso["Blocos"] = prefs!.getInt("prog_Blocos") ?? 0;
      progresso["Lojinha"] = prefs!.getInt("prog_Lojinha") ?? 0;
      liberadoRoblox = prefs!.getBool("liberadoRoblox") ?? false;
      jogosComprados["Memoria"] = prefs!.getBool("compra_Memoria") ?? false;
      jogosComprados["Caca"] = prefs!.getBool("compra_Caca") ?? false;
      jogosComprados["Turbo"] = prefs!.getBool("compra_Turbo") ?? false;
    });
  }

  bool jogoLiberado(String jogo){
    if(jogo=="Silabas") return tarefas["Chegada"]==true;
    if(jogo=="Palavra") return tarefas["Brincar"]==true;
    if(jogo=="Blocos") return tarefas["Leitura"]==true;
    if(jogo=="Lojinha") return tarefas["Numeros"]==true;
    return true;
  }

  void completarQuestao(String jogo) async {
    if((progresso[jogo] ?? 0) >= 20) return;
    int novo = (progresso[jogo] ?? 0) + 1;
    int novoRobux = robux + 2;
    await prefs!.setInt("prog_"+jogo, novo);
    await prefs!.setInt("robux", novoRobux);
    setState((){
      progresso[jogo]=novo;
      robux=novoRobux;
    });
    if(novo==20){
      int bonus = robux + 10;
      await prefs!.setInt("robux", bonus);
      setState(()=> robux=bonus);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Parabens pelo seu esforco! +10 Robux bonus em "+jogo), backgroundColor: Colors.green));
    }
    if((progresso["Silabas"]??0)>=20 && (progresso["Palavra"]??0)>=20 && (progresso["Blocos"]??0)>=20 && (progresso["Lojinha"]??0)>=20){
      if(!liberadoRoblox){
        int total = robux + 20;
        await prefs!.setInt("robux", total);
        await prefs!.setBool("liberadoRoblox", true);
        setState((){
          liberadoRoblox=true;
          robux=total;
        });
        showDialog(context: context, builder: (_)=> AlertDialog(
          title: Text("🎉 TUDO COMPLETO!"),
          content: Text("Alice completou 20/20 nos 4 jogos hoje! Roblox liberado +20 Robux!"),
          actions: [TextButton(onPressed: ()=> Navigator.pop(context), child: Text("OK"))],
        ));
      }
    }
  }

  void abrirJogo(String nome){
    if(!jogoLiberado(nome)){
      String falta = "";
      if(nome=="Silabas") falta="Chegada na escola - pecas pro responsavel tirar foto";
      if(nome=="Palavra") falta="Brincar";
      if(nome=="Blocos") falta="Leitura";
      if(nome=="Lojinha") falta="Numeros";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Bloqueado! Faca a tarefa "+falta+" com o responsavel")));
      return;
    }
    if(nome=="Silabas") Navigator.push(context, MaterialPageRoute(builder: (_)=> JogoSilabas(onAcerto: ()=> completarQuestao("Silabas"), progresso: progresso["Silabas"]??0))).then((_)=> carregar());
    if(nome=="Palavra") Navigator.push(context, MaterialPageRoute(builder: (_)=> JogoPalavra(onAcerto: ()=> completarQuestao("Palavra"), progresso: progresso["Palavra"]??0))).then((_)=> carregar());
    if(nome=="Blocos") Navigator.push(context, MaterialPageRoute(builder: (_)=> JogoBlocos(onAcerto: ()=> completarQuestao("Blocos"), progresso: progresso["Blocos"]??0))).then((_)=> carregar());
    if(nome=="Lojinha") Navigator.push(context, MaterialPageRoute(builder: (_)=> JogoLojinha(onAcerto: ()=> completarQuestao("Lojinha"), progresso: progresso["Lojinha"]??0))).then((_)=> carregar());
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFF6B9D),
        title: Row(children: [Text("Mundo da Alice"), SizedBox(width: 10), Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Text("💎 "+robux.toString(), style: TextStyle(color: Color(0xFFFF6B9D), fontWeight: FontWeight.bold)))]),
        actions: [IconButton(icon: Icon(Icons.logout), onPressed: ()=> Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=> TelaEscolhaInicial()), (r)=> false))],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFFFE3EC), Colors.white], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if(liberadoRoblox)
              Container(width: double.infinity, padding: EdgeInsets.all(16), decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.green[400]!, Colors.green[600]!]), borderRadius: BorderRadius.circular(16)), child: Row(children: [Icon(Icons.check_circle, color: Colors.white, size: 30), SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("ROBLOX LIBERADO HOJE!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text("Voce fez tudo! +20 Robux", style: TextStyle(color: Colors.white70, fontSize: 12))]))])),
            SizedBox(height: 15),
            Text("🎯 MINHA MISSAO HOJE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF2C3E50))),
            SizedBox(height: 8),
            Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]), child: Text("Peca para o responsavel tirar foto das suas tarefas para liberar os jogos!", style: TextStyle(fontSize: 13))),
            SizedBox(height: 15),
            Row(children: [
              Expanded(child: _statusTarefa("Chegada", "Escola", Icons.school, tarefas["Chegada"]??false)),
              SizedBox(width: 8),
              Expanded(child: _statusTarefa("Brincar", "Parque", Icons.sports_soccer, tarefas["Brincar"]??false)),
            ]),
            SizedBox(height: 8),
            Row(children: [
              Expanded(child: _statusTarefa("Leitura", "Livro", Icons.book, tarefas["Leitura"]??false)),
              SizedBox(width: 8),
              Expanded(child: _statusTarefa("Numeros", "Contas", Icons.calculate, tarefas["Numeros"]??false)),
            ]),
            SizedBox(height: 20),
            Text("🎮 MEUS JOGOS - 20 por dia", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF2C3E50))),
            SizedBox(height: 10),
            _cardJogoAlice("Silabas", "Silabas Magicas", "CASA, BOLA, AGUA", Colors.orange, progresso["Silabas"]??0),
            _cardJogoAlice("Palavra", "Palavra Escondida", "Adivinhe a palavra", Colors.blue, progresso["Palavra"]??0),
            _cardJogoAlice("Blocos", "Contando Blocos", "Quantos blocos?", Colors.purple, progresso["Blocos"]??0),
            _cardJogoAlice("Lojinha", "Lojinha da Alice", "Pagar na lojinha", Colors.green, progresso["Lojinha"]??0),
            SizedBox(height: 20),
            Text("🛍️ LOJINHA", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            SizedBox(height: 8),
            _cardLojaAlice("Memoria", "Jogo da Memoria", 50),
            _cardLojaAlice("Caca", "Caca Palavras", 70),
            _cardLojaAlice("Turbo", "Turbo Matematica", 100),
            if(liberadoRoblox)
              Container(width: double.infinity, margin: EdgeInsets.only(top: 15), child: ElevatedButton(onPressed: () async {
                var uri = Uri.parse("https://www.roblox.com");
                if(await canLaunchUrl(uri)) await launchUrl(uri);
              }, style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text("🎮 ABRIR ROBLOX - LIBERADO!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
            SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }

  Widget _statusTarefa(String nome, String desc, IconData icone, bool feito){
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(color: feito? Colors.green[50] : Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: feito? Colors.green : Colors.grey[300]!)),
      child: Column(children: [
        Icon(icone, color: feito? Colors.green : Colors.grey),
        SizedBox(height: 4),
        Text(nome, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        Text(feito? "Liberado!" : "Bloqueado", style: TextStyle(fontSize: 10, color: feito? Colors.green : Colors.grey)),
      ]),
    );
  }

  Widget _cardJogoAlice(String id, String titulo, String desc, Color cor, int prog){
    bool liberado = jogoLiberado(id);
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)]),
      child: ListTile(
        leading: Container(width: 50, height: 50, decoration: BoxDecoration(color: liberado? cor : Colors.grey[300], borderRadius: BorderRadius.circular(12)), child: Icon(liberado? Icons.play_arrow : Icons.lock, color: Colors.white, size: 30)),
        title: Text(titulo, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(desc, style: TextStyle(fontSize: 11)),
          SizedBox(height: 4),
          Row(children: [Expanded(child: LinearProgressIndicator(value: prog/20, backgroundColor: Colors.grey[200], color: cor, minHeight: 6)), SizedBox(width: 8), Text(prog.toString()+"/20", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))]),
        ]),
        trailing: liberado? Icon(Icons.arrow_forward_ios, size: 16) : null,
        onTap: ()=> abrirJogo(id),
      ),
    );
  }

  Widget _cardLojaAlice(String id, String titulo, int preco){
    bool comprado = jogosComprados[id]??false;
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: comprado? Colors.green[200]! : Colors.orange[200]!)),
      child: ListTile(
        leading: Icon(comprado? Icons.check_circle : Icons.shopping_bag, color: comprado? Colors.green : Colors.orange),
        title: Text(titulo, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        subtitle: Text(comprado? "Comprado! Toque para jogar" : "Preco: "+preco.toString()+" 💎"),
        trailing: comprado? Icon(Icons.play_arrow) : null,
        onTap: (){},
      ),
    );
  }
}

// AREA RESPONSAVEL
class TelaResponsavel extends StatefulWidget {
  final String usuario;
  TelaResponsavel({required this.usuario});
  @override
  _TelaResponsavelState createState() => _TelaResponsavelState();
}
class _TelaResponsavelState extends State<TelaResponsavel> {
  SharedPreferences? prefs;
  int robux = 0;
  Map<String,bool> tarefas = {"Chegada":false,"Brincar":false,"Leitura":false,"Numeros":false};
  Map<String,String> fotosHora = {};
  Map<String,int> progresso = {"Silabas":0,"Palavra":0,"Blocos":0,"Lojinha":0};
  String dataHoje = "";
  bool liberadoRoblox = false;
  Map<String,bool> jogosComprados = {"Memoria":false,"Caca":false,"Turbo":false};

  @override
  void initState(){ super.initState(); init(); }

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    String hoje = DateTime.now().toIso8601String().substring(0,10);
    dataHoje = hoje;
    setState((){
      robux = prefs!.getInt("robux") ?? 0;
      tarefas["Chegada"] = prefs!.getBool("tarefa_Chegada") ?? false;
      tarefas["Brincar"] = prefs!.getBool("tarefa_Brincar") ?? false;
      tarefas["Leitura"] = prefs!.getBool("tarefa_Leitura") ?? false;
      tarefas["Numeros"] = prefs!.getBool("tarefa_Numeros") ?? false;
      fotosHora["Chegada"] = prefs!.getString("foto_Chegada") ?? "";
      fotosHora["Brincar"] = prefs!.getString("foto_Brincar") ?? "";
      fotosHora["Leitura"] = prefs!.getString("foto_Leitura") ?? "";
      fotosHora["Numeros"] = prefs!.getString("foto_Numeros") ?? "";
      liberadoRoblox = prefs!.getBool("liberadoRoblox") ?? false;
      jogosComprados["Memoria"] = prefs!.getBool("compra_Memoria") ?? false;
      jogosComprados["Caca"] = prefs!.getBool("compra_Caca") ?? false;
      jogosComprados["Turbo"] = prefs!.getBool("compra_Turbo") ?? false;
      String dataSalva = prefs!.getString("data_hoje") ?? "";
      if(dataSalva != hoje){
        progresso = {"Silabas":0,"Palavra":0,"Blocos":0,"Lojinha":0};
        prefs!.setString("data_hoje", hoje);
        prefs!.setInt("prog_Silabas", 0);
        prefs!.setInt("prog_Palavra", 0);
        prefs!.setInt("prog_Blocos", 0);
        prefs!.setInt("prog_Lojinha", 0);
      } else {
        progresso["Silabas"] = prefs!.getInt("prog_Silabas") ?? 0;
        progresso["Palavra"] = prefs!.getInt("prog_Palavra") ?? 0;
        progresso["Blocos"] = prefs!.getInt("prog_Blocos") ?? 0;
        progresso["Lojinha"] = prefs!.getInt("prog_Lojinha") ?? 0;
      }
    });
  }

  Future<void> tirarFoto(String tarefa) async {
    final picker = ImagePicker();
    final XFile? foto = await picker.pickImage(source: ImageSource.camera);
    if(foto!=null){
      String hora = TimeOfDay.now().format(context);
      String agora = DateTime.now().toString().substring(0,16);
      await prefs!.setBool("tarefa_"+tarefa, true);
      await prefs!.setString("foto_"+tarefa, "Feito as "+hora+" - "+agora);
      setState((){
        tarefas[tarefa]=true;
        fotosHora[tarefa]="Feito as "+hora;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tarefa+" liberada!"), backgroundColor: Colors.green));
    }
  }

  void resetarDia() async {
    await prefs!.setBool("tarefa_Chegada", false);
    await prefs!.setBool("tarefa_Brincar", false);
    await prefs!.setBool("tarefa_Leitura", false);
    await prefs!.setBool("tarefa_Numeros", false);
    await prefs!.setBool("liberadoRoblox", false);
    setState((){
      tarefas = {"Chegada":false,"Brincar":false,"Leitura":false,"Numeros":false};
      fotosHora = {};
      liberadoRoblox=false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Dia resetado!")));
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Area "+widget.usuario+" - R\$ "+robux.toString()),
        backgroundColor: Color(0xFF2C3E50),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: resetarDia),
          IconButton(icon: Icon(Icons.logout), onPressed: ()=> Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=> TelaEscolhaInicial()), (r)=> false)),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(padding: EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)), child: Row(children: [Icon(Icons.info, color: Colors.blue), SizedBox(width: 10), Expanded(child: Text("Tire foto das tarefas da Alice para liberar os jogos dela. Voce pode ver o progresso aqui.", style: TextStyle(fontSize: 13)))])),
          SizedBox(height: 16),
          Text("📸 TAREFAS DO DIA", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 0.85,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _cardTarefaResp("Chegada", "Chegada na escola", Icons.school, "Libera Silabas"),
              _cardTarefaResp("Brincar", "Brincar no parque", Icons.sports_soccer, "Libera Palavra"),
              _cardTarefaResp("Leitura", "Leitura do dia", Icons.book, "Libera Blocos"),
              _cardTarefaResp("Numeros", "Tarefa de Numeros", Icons.calculate, "Libera Lojinha"),
            ],
          ),
          SizedBox(height: 20),
          Text("📊 PROGRESSO DA ALICE HOJE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          SizedBox(height: 10),
          _cardProgresso("Silabas Magicas", progresso["Silabas"]??0, Colors.orange),
          _cardProgresso("Palavra Escondida", progresso["Palavra"]??0, Colors.blue),
          _cardProgresso("Contando Blocos", progresso["Blocos"]??0, Colors.purple),
          _cardProgresso("Lojinha da Alice", progresso["Lojinha"]??0, Colors.green),
          SizedBox(height: 15),
          Container(padding: EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)), child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Total Robux:"), Text("💎 "+robux.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))]),
            SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Roblox liberado:"), Text(liberadoRoblox? "SIM ✅" : "NAO ❌", style: TextStyle(fontWeight: FontWeight.bold))]),
          ])),
          SizedBox(height: 20),
          Container(width: double.infinity, child: ElevatedButton.icon(onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> TelaAlice())), icon: Icon(Icons.play_arrow), label: Text("Ver como a Alice ve"), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFF6B9D), padding: EdgeInsets.all(14)))),
        ]),
      ),
    );
  }

  Widget _cardTarefaResp(String id, String titulo, IconData icone, String libera){
    bool feito = tarefas[id]??false;
    return Container(
      decoration: BoxDecoration(color: feito? Colors.green[50] : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: feito? Colors.green : Colors.grey[300]!), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icone, size: 32, color: feito? Colors.green : Colors.grey),
          SizedBox(height: 6),
          Text(titulo, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          SizedBox(height: 2),
          Text(libera, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
          SizedBox(height: 6),
          if(fotosHora[id]!=null && fotosHora[id]!="") Text(fotosHora[id]!, style: TextStyle(fontSize: 9, color: Colors.blue), textAlign: TextAlign.center),
          SizedBox(height: 8),
          Container(width: double.infinity, child: ElevatedButton(onPressed: ()=> tirarFoto(id), style: ElevatedButton.styleFrom(backgroundColor: feito? Colors.green : Color(0xFF2C3E50), padding: EdgeInsets.symmetric(vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: Text(feito? "Refazer" : "Tirar Foto", style: TextStyle(fontSize: 11, color: Colors.white)))),
        ]),
      ),
    );
  }

  Widget _cardProgresso(String titulo, int prog, Color cor){
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(titulo, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), Text(prog.toString()+"/20", style: TextStyle(fontWeight: FontWeight.bold))]),
        SizedBox(height: 6),
        LinearProgressIndicator(value: prog/20, backgroundColor: Colors.grey[200], color: cor, minHeight: 8),
      ]),
    );
  }
}

// JOGOS (mantidos iguais mas sem cortar)
class JogoSilabas extends StatefulWidget {
  final Function onAcerto;
  final int progresso;
  JogoSilabas({required this.onAcerto, required this.progresso});
  @override
  _JogoSilabasState createState() => _JogoSilabasState();
}
class _JogoSilabasState extends State<JogoSilabas> {
  List<Map<String,dynamic>> perguntas = [
    {"palavra":"CASA","silaba":"CA","opcoes":["CA","BO","DA"]},
    {"palavra":"BOLA","silaba":"BO","opcoes":["CA","BO","LA"]},
    {"palavra":"AGUA","silaba":"A","opcoes":["A","E","O"]},
    {"palavra":"GATO","silaba":"GA","opcoes":["GA","TO","MI"]},
    {"palavra":"PATO","silaba":"PA","opcoes":["PA","TI","GO"]},
    {"palavra":"MALA","silaba":"MA","opcoes":["MA","LA","TA"]},
    {"palavra":"FADA","silaba":"FA","opcoes":["FA","DA","BA"]},
    {"palavra":"LUA","silaba":"LU","opcoes":["LU","A","BO"]},
    {"palavra":"SOL","silaba":"SOL","opcoes":["SOL","LUA","MAR"]},
    {"palavra":"MAR","silaba":"MAR","opcoes":["MAR","SOL","PAO"]},
  ];
  int idx = 0;
  Random rnd = Random();

  String removerAcento(String s){
    s = s.replaceAll("Á","A").replaceAll("À","A").replaceAll("Ã","A").replaceAll("Â","A");
    s = s.replaceAll("É","E").replaceAll("Ê","E");
    s = s.replaceAll("Í","I");
    s = s.replaceAll("Ó","O").replaceAll("Ô","O").replaceAll("Õ","O");
    s = s.replaceAll("Ú","U");
    return s;
  }

  void responder(String resp){
    String correta = perguntas[idx]["silaba"];
    if(removerAcento(resp.toUpperCase())==removerAcento(correta.toUpperCase())){
      widget.onAcerto();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Correto! +2 Robux"), backgroundColor: Colors.green));
      setState(()=> idx = rnd.nextInt(perguntas.length));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Tente de novo! E "+correta), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context){
    var p = perguntas[idx];
    return Scaffold(
      appBar: AppBar(title: Text("Silabas Magicas "+widget.progresso.toString()+"/20"), backgroundColor: Colors.orange),
      body: Column(children: [
        LinearProgressIndicator(value: widget.progresso/20),
        Container(color: Colors.yellow[200], width: double.infinity, padding: EdgeInsets.all(16), child: Text("Qual a primeira silaba de "+p["palavra"]+"?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        SizedBox(height: 30),
        Text(p["palavra"], style: TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: Colors.orange[800])),
        SizedBox(height: 30),
        Wrap(alignment: WrapAlignment.center, children: (p["opcoes"] as List).map((op)=> Padding(padding: EdgeInsets.all(12), child: ElevatedButton(onPressed: ()=> responder(op), style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20), backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(op, style: TextStyle(fontSize: 28, color: Colors.white))))).toList()),
      ]),
    );
  }
}

class JogoPalavra extends StatefulWidget {
  final Function onAcerto;
  final int progresso;
  JogoPalavra({required this.onAcerto, required this.progresso});
  @override
  _JogoPalavraState createState() => _JogoPalavraState();
}
class _JogoPalavraState extends State<JogoPalavra> {
  List<Map<String,String>> palavras = [
    {"dica":"Animal que late","palavra":"CACHORRO"},
    {"dica":"Fruta amarela","palavra":"BANANA"},
    {"dica":"Cor do ceu","palavra":"AZUL"},
    {"dica":"Voce mora aqui","palavra":"CASA"},
  ];
  int idx = 0;
  TextEditingController ctrl = TextEditingController();
  Random rnd = Random();

  void verificar(){
    if(ctrl.text.toUpperCase().trim() == palavras[idx]["palavra"]){
      widget.onAcerto();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Correto! +2 Robux"), backgroundColor: Colors.green));
      setState((){
        idx = rnd.nextInt(palavras.length);
        ctrl.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errou! Dica: "+palavras[idx]["dica"]!), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text("Palavra Escondida "+widget.progresso.toString()+"/20"), backgroundColor: Colors.blue),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(children: [
          LinearProgressIndicator(value: widget.progresso/20),
          SizedBox(height: 20),
          Container(width: double.infinity, padding: EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(16)), child: Text("Dica: "+palavras[idx]["dica"]!, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
          SizedBox(height: 30),
          TextField(controller: ctrl, decoration: InputDecoration(labelText: "Digite a palavra", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), textCapitalization: TextCapitalization.characters, style: TextStyle(fontSize: 20)),
          SizedBox(height: 20),
          Container(width: double.infinity, height: 60, child: ElevatedButton(onPressed: verificar, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text("Verificar", style: TextStyle(fontSize: 20)))),
        ]),
      ),
    );
  }
}

class JogoBlocos extends StatefulWidget {
  final Function onAcerto;
  final int progresso;
  JogoBlocos({required this.onAcerto, required this.progresso});
  @override
  _JogoBlocosState createState() => _JogoBlocosState();
}
class _JogoBlocosState extends State<JogoBlocos> {
  Random rnd = Random();
  int quantidade = 3;
  int corFixa = 0;
  List<Color> cores = [Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple];

  @override
  void initState(){ super.initState(); gerar(); }

  void gerar(){ setState((){ quantidade = rnd.nextInt(10)+1; corFixa = rnd.nextInt(cores.length); }); }

  void responder(int resp){
    if(resp==quantidade){
      widget.onAcerto();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Correto! +2 Robux"), backgroundColor: Colors.green));
      gerar();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errou! Conte de novo"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text("Contando Blocos "+widget.progresso.toString()+"/20"), backgroundColor: Colors.purple),
      body: Column(children: [
        LinearProgressIndicator(value: widget.progresso/20),
        Container(color: Colors.yellow[200], width: double.infinity, padding: EdgeInsets.all(16), child: Text("Quantos blocos voce ve?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        SizedBox(height: 10),
        Expanded(child: Padding(padding: EdgeInsets.all(20), child: GridView.count(crossAxisCount: 5, children: List.generate(quantidade, (i)=> Container(margin: EdgeInsets.all(6), decoration: BoxDecoration(color: cores[corFixa], borderRadius: BorderRadius.circular(8))))))),
        Padding(padding: EdgeInsets.all(16), child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [1,2,3,4,5].map((n)=> ElevatedButton(onPressed: ()=> responder(n), style: ElevatedButton.styleFrom(padding: EdgeInsets.all(16)), child: Text(n.toString(), style: TextStyle(fontSize: 20)))).toList()),
          SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [6,7,8,9,10].map((n)=> ElevatedButton(onPressed: ()=> responder(n), style: ElevatedButton.styleFrom(padding: EdgeInsets.all(16)), child: Text(n.toString(), style: TextStyle(fontSize: 20)))).toList()),
          SizedBox(height: 20),
        ])),
      ]),
    );
  }
}

class JogoLojinha extends StatefulWidget {
  final Function onAcerto;
  final int progresso;
  JogoLojinha({required this.onAcerto, required this.progresso});
  @override
  _JogoLojinhaState createState() => _JogoLojinhaState();
}
class _JogoLojinhaState extends State<JogoLojinha> {
  Random rnd = Random();
  int preco = 5;
  int pago = 0;
  List<int> notas = [1,2,5];

  @override
  void initState(){ super.initState(); gerar(); }

  void gerar(){ setState((){ preco = rnd.nextInt(10)+1; pago = 0; }); }

  void addNota(int v){ setState(()=> pago+=v); }

  void verificar(){
    if(pago==preco){
      widget.onAcerto();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Correto! +2 Robux"), backgroundColor: Colors.green));
      gerar();
    } else if(pago>preco){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Deu troco a mais! Tente de novo"), backgroundColor: Colors.red));
      setState(()=> pago=0);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Falta dinheiro!"), backgroundColor: Colors.orange));
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text("Lojinha "+widget.progresso.toString()+"/20"), backgroundColor: Colors.green),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(children: [
          LinearProgressIndicator(value: widget.progresso/20),
          SizedBox(height: 20),
          Container(width: double.infinity, padding: EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(16)), child: Text("Preco: R\$ "+preco.toString()+" - Quanto pagar?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
          SizedBox(height: 30),
          Text("Pago: R\$ "+pago.toString(), style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: notas.map((n)=> ElevatedButton(onPressed: ()=> addNota(n), style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16)), child: Text("R\$ "+n.toString(), style: TextStyle(fontSize: 18)))).toList()),
          SizedBox(height: 30),
          Row(children: [
            Expanded(child: ElevatedButton(onPressed: verificar, style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: EdgeInsets.all(18)), child: Text("Pagar", style: TextStyle(fontSize: 18)))),
            SizedBox(width: 12),
            Expanded(child: ElevatedButton(onPressed: ()=> setState(()=> pago=0), style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, padding: EdgeInsets.all(18)), child: Text("Limpar", style: TextStyle(fontSize: 18)))),
          ]),
        ]),
      ),
    );
  }
}
