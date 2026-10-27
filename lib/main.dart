import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MundoAliceApp());

class MundoAliceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mundo da Alice',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.pink, fontFamily: 'Roboto'),
      home: TelaLoginFamilia(),
    );
  }
}

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
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> TelaPrincipal(usuario: nomeSelecionado)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Senha incorreta! Use 1234")));
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.pink[50],
      body: Center(
        child: Card(
          margin: EdgeInsets.all(20),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text("Mundo da Alice", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.pink)),
              SizedBox(height: 10),
              Text("Quem esta usando?", style: TextStyle(fontSize: 16)),
              DropdownButton<String>(
                value: nomeSelecionado,
                items: familia.map((f)=> DropdownMenuItem(value: f["nome"], child: Text(f["nome"]!))).toList(),
                onChanged: (v){ setState(()=> nomeSelecionado=v!); },
              ),
              TextField(controller: senhaCtrl, obscureText: true, decoration: InputDecoration(labelText: "Senha (1234)")),
              SizedBox(height: 15),
              ElevatedButton(onPressed: entrar, style: ElevatedButton.styleFrom(backgroundColor: Colors.pink), child: Text("Entrar", style: TextStyle(color: Colors.white))),
              SizedBox(height: 10),
              Text("Alice nao precisa de senha, so escolher jogo depois", style: TextStyle(fontSize: 11, color: Colors.grey))
            ]),
          ),
        ),
      ),
    );
  }
}

class TelaPrincipal extends StatefulWidget {
  final String usuario;
  TelaPrincipal({required this.usuario});
  @override
  _TelaPrincipalState createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  SharedPreferences? prefs;
  int robux = 0;
  Map<String,bool> tarefas = {"Chegada":false,"Brincar":false,"Leitura":false,"Numeros":false};
  Map<String,String> fotosHora = {};
  Map<String,int> progresso = {"Silabas":0,"Palavra":0,"Blocos":0,"Lojinha":0};
  Map<String,int> acertosHoje = {"Silabas":0,"Palavra":0,"Blocos":0,"Lojinha":0};
  String dataHoje = "";
  bool liberadoRoblox = false;
  Map<String,bool> jogosComprados = {"Memoria":false,"Caca":false,"Turbo":false};
  FlutterTts tts = FlutterTts();

  @override
  void initState(){
    super.initState();
    init();
    checarAtualizacao();
  }

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
        acertosHoje = {"Silabas":0,"Palavra":0,"Blocos":0,"Lojinha":0};
        prefs!.setString("data_hoje", hoje);
      } else {
        progresso["Silabas"] = prefs!.getInt("prog_Silabas") ?? 0;
        progresso["Palavra"] = prefs!.getInt("prog_Palavra") ?? 0;
        progresso["Blocos"] = prefs!.getInt("prog_Blocos") ?? 0;
        progresso["Lojinha"] = prefs!.getInt("prog_Lojinha") ?? 0;
      }
    });
    await tts.setLanguage("pt-BR");
    await tts.setSpeechRate(0.5);
  }

  Future<void> checarAtualizacao() async {
    try {
      var url = Uri.parse("https://raw.githubusercontent.com/Jcobl/controle-alice/main/version.json");
      var r = await http.get(url).timeout(Duration(seconds: 5));
      if(r.statusCode==200){
        var j = json.decode(r.body);
        int vServer = j["versionCode"] ?? 0;
        if(vServer > 68){
          if(mounted){
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("🆕 Atualizacao disponivel! Baixe no GitHub")));
          }
        }
      }
    } catch(e){}
  }

  void falar(String texto) async {
    await tts.speak(texto);
  }

  Future<void> tirarFoto(String tarefa) async {
    final picker = ImagePicker();
    final XFile? foto = await picker.pickImage(source: ImageSource.camera);
    if(foto!=null){
      String hora = TimeOfDay.now().format(context);
      String agora = DateTime.now().toString();
      await prefs!.setBool("tarefa_"+tarefa, true);
      await prefs!.setString("foto_"+tarefa, "Feito as "+hora+" em "+agora.substring(0,16));
      setState((){
        tarefas[tarefa]=true;
        fotosHora[tarefa]="Feito as "+hora;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tarefa+" concluida! Jogo liberado")));
    }
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
          content: Text("Alice completou 20/20 nos 4 jogos hoje! 【entity-Roblox¦canonical_name=Roblox】 liberado +20 Robux!"),
          actions: [TextButton(onPressed: ()=> Navigator.pop(context), child: Text("OK"))],
        ));
      }
    }
  }

  void abrirJogo(String nome){
    if(!jogoLiberado(nome)){
      String falta = "";
      if(nome=="Silabas") falta="Chegada na escola";
      if(nome=="Palavra") falta="Brincar";
      if(nome=="Blocos") falta="Leitura";
      if(nome=="Lojinha") falta="Numeros";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Faca a tarefa "+falta+" e tire foto para liberar!")));
      return;
    }
    if(nome=="Silabas") Navigator.push(context, MaterialPageRoute(builder: (_)=> JogoSilabas(falar: falar, onAcerto: ()=> completarQuestao("Silabas"), progresso: progresso["Silabas"]??0)));
    if(nome=="Palavra") Navigator.push(context, MaterialPageRoute(builder: (_)=> JogoPalavra(falar: falar, onAcerto: ()=> completarQuestao("Palavra"), progresso: progresso["Palavra"]??0)));
    if(nome=="Blocos") Navigator.push(context, MaterialPageRoute(builder: (_)=> JogoBlocos(falar: falar, onAcerto: ()=> completarQuestao("Blocos"), progresso: progresso["Blocos"]??0)));
    if(nome=="Lojinha") Navigator.push(context, MaterialPageRoute(builder: (_)=> JogoLojinha(falar: falar, onAcerto: ()=> completarQuestao("Lojinha"), progresso: progresso["Lojinha"]??0)));
  }

  void comprarJogo(String nome, int preco) async {
    if((jogosComprados[nome]??false)==true){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Voce ja comprou "+nome)));
      return;
    }
    if(robux < preco){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Robux insuficiente! Precisa de "+preco.toString()+" e voce tem "+robux.toString())));
      return;
    }
    int novo = robux - preco;
    await prefs!.setInt("robux", novo);
    await prefs!.setBool("compra_"+nome, true);
    setState((){
      robux=novo;
      jogosComprados[nome]=true;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(nome+" comprado!"), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Mundo da Alice - "+widget.usuario),
        backgroundColor: Colors.pink,
        actions: [
          Center(child: Padding(padding: EdgeInsets.all(8), child: Text("R\$ "+robux.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)))),
          IconButton(icon: Icon(Icons.logout), onPressed: ()=> Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> TelaLoginFamilia())))
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            if(liberadoRoblox)
              Card(color: Colors.green[100], child: ListTile(leading: Icon(Icons.check_circle, color: Colors.green), title: Text("Roblox Liberado Hoje! +20 Robux ganhos"), subtitle: Text("Parabens pelo esforco da Alice"))),
            Text("TAREFAS DO DIA - Tire foto para liberar jogos", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 8),
            Row(children: [
              Expanded(child: _cardTarefa("Chegada", Icons.school, "Silabas Magicas")),
              Expanded(child: _cardTarefa("Brincar", Icons.sports_soccer, "Palavra Escondida")),
            ]),
            Row(children: [
              Expanded(child: _cardTarefa("Leitura", Icons.book, "Contando Blocos")),
              Expanded(child: _cardTarefa("Numeros", Icons.calculate, "Lojinha")),
            ]),
            Divider(),
            Text("JOGOS - 20 questoes por dia", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 8),
            _cardJogo("Silabas", "Silabas Magicas", "Chegada libera", Colors.orange, progresso["Silabas"]??0),
            _cardJogo("Palavra", "Palavra Escondida", "Brincar libera", Colors.blue, progresso["Palavra"]??0),
            _cardJogo("Blocos", "Contando Blocos", "Leitura libera", Colors.purple, progresso["Blocos"]??0),
            _cardJogo("Lojinha", "Lojinha da Alice", "Numeros libera", Colors.green, progresso["Lojinha"]??0),
            Divider(),
            Text("LOJINHA - Compre jogos extras com Robux", style: TextStyle(fontWeight: FontWeight.bold)),
            _cardLoja("Memoria", "Jogo da Memoria", 50),
            _cardLoja("Caca", "Caca Palavras", 70),
            _cardLoja("Turbo", "Turbo Matematica", 100),
            if(liberadoRoblox)
              ElevatedButton(onPressed: () async {
                var uri = Uri.parse("https://www.roblox.com");
                if(await canLaunchUrl(uri)) await launchUrl(uri);
              }, child: Text("Abrir Roblox - Liberado!")),
          ],
        ),
      ),
    );
  }

  Widget _cardTarefa(String nome, IconData icone, String libera){
    bool feito = tarefas[nome]??false;
    return Card(
      color: feito? Colors.green[100] : Colors.white,
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(children: [
          Icon(icone, color: feito? Colors.green : Colors.grey),
          Text(nome, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          Text(libera, style: TextStyle(fontSize: 10)),
          if(fotosHora[nome]!=null && fotosHora[nome]!="") Text(fotosHora[nome]!, style: TextStyle(fontSize: 9, color: Colors.blue)),
          ElevatedButton(onPressed: ()=> tirarFoto(nome), child: Text(feito? "Refazer foto" : "Tirar foto")),
        ]),
      ),
    );
  }

  Widget _cardJogo(String id, String titulo, String desc, Color cor, int prog){
    bool liberado = jogoLiberado(id);
    return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundColor: liberado? cor : Colors.grey, child: Icon(Icons.play_arrow, color: Colors.white)),
        title: Text(titulo+" ("+prog.toString()+"/20)"),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(liberado? desc : "Bloqueado - faca tarefa"),
          LinearProgressIndicator(value: prog/20, backgroundColor: Colors.grey[300], color: cor),
        ]),
        trailing: IconButton(icon: Icon(Icons.volume_up), onPressed: ()=> falar(titulo)),
        onTap: ()=> abrirJogo(id),
      ),
    );
  }

  Widget _cardLoja(String id, String titulo, int preco){
    bool comprado = jogosComprados[id]??false;
    return Card(
      child: ListTile(
        leading: Icon(Icons.shopping_cart, color: comprado? Colors.green : Colors.orange),
        title: Text(titulo),
        subtitle: Text(comprado? "Comprado!" : "Preco: "+preco.toString()+" Robux"),
        trailing: ElevatedButton(
          onPressed: ()=> comprarJogo(id, preco),
          child: Text(comprado? "Jogar" : "Comprar"),
        ),
      ),
    );
  }
}

class JogoSilabas extends StatefulWidget {
  final Function falar;
  final Function onAcerto;
  final int progresso;
  JogoSilabas({required this.falar, required this.onAcerto, required this.progresso});
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
    String r1 = removerAcento(resp.toUpperCase());
    String r2 = removerAcento(correta.toUpperCase());
    if(r1==r2){
      widget.onAcerto();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Correto! +2 Robux"), backgroundColor: Colors.green));
      setState((){
        idx = rnd.nextInt(perguntas.length);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Tente de novo! A silaba e "+correta), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context){
    var p = perguntas[idx];
    return Scaffold(
      appBar: AppBar(title: Text("Silabas Magicas "+widget.progresso.toString()+"/20"), backgroundColor: Colors.orange),
      body: Column(children: [
        LinearProgressIndicator(value: widget.progresso/20),
        GestureDetector(
          onTap: ()=> widget.falar("Qual a primeira silaba de "+p["palavra"]),
          child: Container(color: Colors.yellow[200], width: double.infinity, padding: EdgeInsets.all(16), child: Row(children: [
            Icon(Icons.volume_up),
            SizedBox(width: 8),
            Expanded(child: Text("Qual a primeira silaba de "+p["palavra"]+"?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ])),
        ),
        SizedBox(height: 20),
        Text(p["palavra"], style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
        SizedBox(height: 20),
        Wrap(children: (p["opcoes"] as List).map((op)=> Padding(padding: EdgeInsets.all(8), child: ElevatedButton(onPressed: ()=> responder(op), child: Text(op, style: TextStyle(fontSize: 24))))).toList())
      ]),
    );
  }
}

class JogoPalavra extends StatefulWidget {
  final Function falar;
  final Function onAcerto;
  final int progresso;
  JogoPalavra({required this.falar, required this.onAcerto, required this.progresso});
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
      body: Column(children: [
        LinearProgressIndicator(value: widget.progresso/20),
        GestureDetector(
          onTap: ()=> widget.falar("Dica: "+palavras[idx]["dica"]!),
          child: Container(color: Colors.yellow[200], width: double.infinity, padding: EdgeInsets.all(16), child: Row(children: [
            Icon(Icons.volume_up),
            SizedBox(width: 8),
            Expanded(child: Text("Dica: "+palavras[idx]["dica"]!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ])),
        ),
        SizedBox(height: 20),
        Padding(padding: EdgeInsets.all(12), child: TextField(controller: ctrl, decoration: InputDecoration(labelText: "Digite a palavra", border: OutlineInputBorder()), textCapitalization: TextCapitalization.characters)),
        SizedBox(height: 10),
        ElevatedButton(onPressed: verificar, child: Text("Verificar")),
      ]),
    );
  }
}

class JogoBlocos extends StatefulWidget {
  final Function falar;
  final Function onAcerto;
  final int progresso;
  JogoBlocos({required this.falar, required this.onAcerto, required this.progresso});
  @override
  _JogoBlocosState createState() => _JogoBlocosState();
}
class _JogoBlocosState extends State<JogoBlocos> {
  Random rnd = Random();
  int quantidade = 3;
  int corFixa = 0;
  List<Color> cores = [Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple];

  @override
  void initState(){
    super.initState();
    gerar();
  }

  void gerar(){
    setState((){
      quantidade = rnd.nextInt(10)+1;
      corFixa = rnd.nextInt(cores.length);
    });
  }

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
        GestureDetector(
          onTap: ()=> widget.falar("Quantos blocos voce ve?"),
          child: Container(color: Colors.yellow[200], width: double.infinity, padding: EdgeInsets.all(16), child: Row(children: [
            Icon(Icons.volume_up),
            SizedBox(width: 8),
            Text("Quantos blocos voce ve?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ])),
        ),
        SizedBox(height: 10),
        Expanded(
          child: GridView.count(
            crossAxisCount: 5,
            children: List.generate(quantidade, (i)=> Container(margin: EdgeInsets.all(4), color: cores[corFixa])),
          ),
        ),
        Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [1,2,3,4,5].map((n)=> ElevatedButton(onPressed: ()=> responder(n), child: Text(n.toString()))).toList()),
          SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [6,7,8,9,10].map((n)=> ElevatedButton(onPressed: ()=> responder(n), child: Text(n.toString()))).toList()),
          SizedBox(height: 20),
        ])
      ]),
    );
  }
}

class JogoLojinha extends StatefulWidget {
  final Function falar;
  final Function onAcerto;
  final int progresso;
  JogoLojinha({required this.falar, required this.onAcerto, required this.progresso});
  @override
  _JogoLojinhaState createState() => _JogoLojinhaState();
}
class _JogoLojinhaState extends State<JogoLojinha> {
  Random rnd = Random();
  int preco = 5;
  int pago = 0;
  List<int> notas = [1,2,5];

  @override
  void initState(){
    super.initState();
    gerar();
  }

  void gerar(){
    setState((){
      preco = rnd.nextInt(10)+1;
      pago = 0;
    });
  }

  void addNota(int v){
    setState(()=> pago+=v);
  }

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
      body: Column(children: [
        LinearProgressIndicator(value: widget.progresso/20),
        GestureDetector(
          onTap: ()=> widget.falar("O preco e "+preco.toString()+" reais, quanto vai pagar?"),
          child: Container(color: Colors.yellow[200], width: double.infinity, padding: EdgeInsets.all(16), child: Row(children: [
            Icon(Icons.volume_up),
            SizedBox(width: 8),
            Expanded(child: Text("Preco: R\$ "+preco.toString()+" - Quanto pagar?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ])),
        ),
        SizedBox(height: 20),
        Text("Pago: R\$ "+pago.toString(), style: TextStyle(fontSize: 24)),
        SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: notas.map((n)=> ElevatedButton(onPressed: ()=> addNota(n), child: Text("R\$ "+n.toString()))).toList()),
        SizedBox(height: 20),
        ElevatedButton(onPressed: verificar, child: Text("Pagar")),
        ElevatedButton(onPressed: ()=> setState(()=> pago=0), child: Text("Limpar")),
      ]),
    );
  }
}
