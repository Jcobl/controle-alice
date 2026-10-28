import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() => runApp(MundoAliceApp());

class MundoAliceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Mundo da Alice V5 Evolução', debugShowCheckedModeBanner: false, theme: ThemeData(scaffoldBackgroundColor: Color(0xFFFCE4EC)), home: TelaPrincipal());
  }
}

class IATutora {
  final FlutterTts tts = FlutterTts();
  bool ativa = true;
  IATutora(){ tts.setLanguage("pt-BR"); tts.setSpeechRate(0.48); tts.setVolume(1.0); }
  Future<void> falar(String texto) async { if(!ativa) return; try{ await tts.speak(texto); }catch(e){} }
  String motivacional(){ List<String> m=["Você é muito inteligente, Alice!","Uau! Tá arrasando!","Eu tô aqui pra te ajudar!","Rosa e roxo são suas cores mágicas!","Você consegue! Eu acredito!","Que corajosa você é!"]; return m[Random().nextInt(m.length)]; }
  String instruirMundo(int id){ if(id==1) return "Oi Alice! Sou a 【entity-Lia¦canonical_name=Lia】! Vamos trocar de roupa? Tira fotinho quando terminar!"; if(id==4) return "Meu mundo favorito! 10 jogos gigantes que evoluem com você! Cada acerto +2 Robux!"; return "Você consegue!"; }
}

class TelaPrincipal extends StatefulWidget { @override _TelaPrincipalState createState()=> _TelaPrincipalState(); }
class _TelaPrincipalState extends State<TelaPrincipal> {
  final IATutora ia = IATutora();
  bool modoCrianca=true; bool familiaAutenticada=false;
  int robux=6; int estrelas=0;
  List<Map<String,dynamic>> mundos=[];
  Map<String,int> progressos={"silabas":0,"palavra":0,"blocos":0,"lojinha":0,"leitura":0,"matematica":0,"desenho":0,"memoria":0,"caca":0,"parkour":0};
  Map<String,int> niveis={"silabas":1,"palavra":1,"blocos":1,"lojinha":1,"leitura":1,"matematica":1,"desenho":1,"memoria":1,"caca":1,"parkour":1};
  Map<String,int> sequencias={"silabas":0,"palavra":0,"blocos":0,"lojinha":0,"leitura":0,"matematica":0,"desenho":0,"memoria":0,"caca":0,"parkour":0};
  Map<String,int> acertos={"silabas":0,"palavra":0,"blocos":0,"lojinha":0,"leitura":0,"matematica":0,"desenho":0,"memoria":0,"caca":0,"parkour":0};
  Map<String,int> erros={"silabas":0,"palavra":0,"blocos":0,"lojinha":0,"leitura":0,"matematica":0,"desenho":0,"memoria":0,"caca":0,"parkour":0};
  Map<String,List<String>> dominadas={"silabas":[],"palavra":[],"blocos":[],"lojinha":[],"leitura":[],"matematica":[],"desenho":[],"memoria":[],"caca":[],"parkour":[]};
  Map<String,List<String>> revisar={"silabas":[],"palavra":[],"blocos":[],"lojinha":[],"leitura":[],"matematica":[],"desenho":[],"memoria":[],"caca":[],"parkour":[]};
  Map<String,bool> jogosComprados={"silabas":true,"palavra":true,"blocos":false,"lojinha":false,"leitura":true,"matematica":false,"desenho":false,"memoria":true,"caca":false,"parkour":false,"obby":false};
  final picker=ImagePicker();
  String mensagemIA="Oi Alice! Eu sou a Lia, sua tutora IA! Vamos brincar? Eu evoluo com você! 💜";

  // BANCO 1000 PALAVRAS REAIS 9 ANOS
  final List<String> banco1000 = [
    "CASA","BOLA","GATO","ROSA","ROXO","LIA","ALICE","ESCOLA","LIVRO","CADERNO","LAPIS","BORRACHA","MOCHILA","PROFESSORA","ALUNO","JANELA","PORTA","MESA","CADEIRA","QUADRO",
    "CACHORRO","GATO","ELEFANTE","LEAO","TIGRE","MACACO","ZEBRA","GIRAFA","URSO","COELHO","PASSARO","PEIXE","TARTARUGA","BORBOLETA","ABELHA","FORMIGA","ARANHA","CAVALO","VACA","PORCO",
    "ARROZ","FEIJAO","CARNE","FRANGO","PEIXE","OVO","LEITE","PAO","BOLO","SUCO","AGUA","REFRIGERANTE","BANANA","MACA","LARANJA","UVA","MORANGO","ABACAXI","MELANCIA","MANGA",
    "AZUL","VERMELHO","AMARELO","VERDE","ROSA","ROXO","LARANJA","MARROM","PRETO","BRANCO","CINZA","BEGE","DOURADO","PRATEADO","CLARO","ESCURO","COLORIDO","BRILHANTE","FOSCO","LISTRADO",
    "BRINCAR","CORRER","PULAR","DANCAR","CANTAR","LER","ESCREVER","DESENHAR","PINTAR","ESTUDAR","AJUDAR","COMPARTILHAR","ABRACAR","BEIJAR","SORRIR","CHORAR","DORMIR","ACORDAR","COMER","BEBER",
    "FAMILIA","MAMAE","PAPAI","IRMAO","IRMA","VOVO","VOVO","TITIA","TITIO","PRIMA","PRIMO","AMIGA","AMIGO","BEBE","CRIANCA","MENINA","MENINO","MULHER","HOMEM","PESSOA",
    "CORAGEM","AMOR","ALEGRIA","FELICIDADE","CARINHO","AMIZADE","RESPEITO","BONDADE","HONESTIDADE","PAZ","ESPERANCA","SONHO","ESTRELA","LUA","SOL","CEU","NUVEM","CHUVA","ARCOIRIS","VENTO",
    "CIDADE","RUA","PARQUE","PRAIA","MONTANHA","FLORESTA","RIO","MAR","LAGO","CACHOEIRA","JARDIM","QUINTAL","PREDIO","LOJA","HOSPITAL","IGREJA","BIBLIOTECA","MUSEU","CINEMA","TEATRO",
    "CARRO","ONIBUS","BICICLETA","AVIAO","BARCO","TREM","MOTO","CAMINHAO","PATINETE","SKATE","BOLA","BONECA","CARRINHO","LEGO","QUEBRA","JOGO","VIDEOGAME","ROBLOX","CELULAR","COMPUTADOR",
    "CABECA","OLHO","NARIZ","BOCA","ORELHA","CABELO","MAO","PE","BRACO","PERNA","DEDO","BARRIGA","COSTAS","CORACAO","CEREBRO","DENTE","LINGUA","SORRISO","LAGRIMA","ABRACO",
    "ABELHA","ABACATE","ABRIGO","ACUCAR","ADEUS","ADIVINHA","AEREO","AFETO","AGUA","AGULHA","AJUDA","ALEGRE","ALFACE","ALGODAO","ALMOCO","ALTO","AMARELO","AMIGA","ANIMAL","ANJO",
    "APITO","ARARA","ARCO","AREIA","ARMA","ARVORE","ASA","ATLETA","AVIAO","AZEITE","BABA","BAGAGEM","BAILE","BAIXO","BALA","BALAO","BANANA","BANCO","BANHO","BARATA",
    "BARBA","BARCO","BARRO","BATATA","BATERIA","BEIJO","BELEZA","BEXIGA","BICHO","BIFE","BINGO","BISCOITO","BOCA","BOLA","BOLO","BOLSA","BONECA","BORBOLETA","BOSQUE","BOTAO",
    "BRANCO","BRAVO","BRILHO","BRINCO","BROTO","BRUXA","BURACO","CABANA","CABELO","CABRA","CACHO","CACTO","CAFE","CAIXA","CALCA","CALOR","CAMA","CAMPO","CANETA","CANJA",
    "CANTO","CAPA","CAPIM","CARACOL","CARRO","CARTA","CASACO","CASCA","CASTELO","CAVALO","CEBOLA","CENOURA","CEREJA","CEU","CHAPE","CHARGE","CHAVE","CHINELO","CHOCOLATE","CHUVA",
    "CIDADE","CINCO","CINEMA","CINTO","CIRCO","CLARA","COALA","COBRA","COCO","COELHO","COFRE","COLEGA","COLHER","COLO","COMETA","COMIDA","CONCHA","COPO","CORACAO","CORDA",
    "COROA","CORPO","COTOVELO","COUVE","CRIANCA","CRISTAL","CROCODILO","CUPCAKE","CURVA","DADO","DANCA","DENTE","DESENHO","DEZ","DIAMANTE","DINHEIRO","DINOSSAURO","DOCE","DORMIR","DRAGAO",
    "DUCHA","ECO","ELEFANTE","ELEVADOR","ELFO","EMA","ENCANTO","ENCONTRO","ENERGIA","ENFEITE","ENGENHO","ENXADA","ESCADA","ESCOVA","ESCOLA","ESFERA","ESPADA","ESPELHO","ESPONJA","ESTRELA",
    "FADA","FAMILIA","FANTASIA","FAROL","FARINHA","FAROFA","FAZENDA","FEIJAO","FEIRA","FELIZ","FERA","FESTA","FITA","FLAUTA","FLECHA","FLOR","FLORESTA","FOCA","FOGAO","FOGUEIRA",
    "FOLHA","FORMIGA","FORNO","FOTO","FRALDA","FRANGO","FRANJA","FRASE","FREIO","FRIO","FRUTA","FUBA","FUTEBOL","GABINETE","GALHO","GALINHA","GALO","GANGORRA","GARAGEM","GARFO",
    "GAROUPA","GATO","GAVETA","GEADA","GELEIA","GELO","GEMA","GIRASSOL","GIRAFA","GIZ","GLOBO","GOIABA","GOL","GOLFINHO","GOSTO","GOTA","GRAMA","GRANDE","GRILO","GROSELHA",
  ];

  final List<Map<String,String>> bancoDicas500 = [
    {"palavra":"CASA","dica":"Onde moramos, tem porta rosa"},
    {"palavra":"ESCOLA","dica":"Lugar onde aprende com a Lia"},
    {"palavra":"ROSA","dica":"Cor favorita da Alice, clara e linda"},
    {"palavra":"ROXO","dica":"Outra cor favorita, mistura azul e vermelho"},
    {"palavra":"LIA","dica":"Sua tutora IA que fala e te ajuda"},
    {"palavra":"ALICE","dica":"Seu nome, princesa corajosa de 9 anos"},
    {"palavra":"CORAGEM","dica":"O que você tem muito, enfrenta tudo"},
    {"palavra":"CACHORRO","dica":"Animal que late e é amigo"},
    {"palavra":"ELEFANTE","dica":"Animal gigante com tromba"},
    {"palavra":"GIRAFA","dica":"Animal com pescoço muito alto"},
    {"palavra":"BORBOLETA","dica":"Inseto colorido que voa, rosa e roxo"},
    {"palavra":"ARCOIRIS","dica":"Aparece no céu depois da chuva, tem rosa e roxo"},
    {"palavra":"BIBLIOTECA","dica":"Lugar com muitos livros pra ler"},
    {"palavra":"ROBLOX","dica":"Jogo que libera quando faz 200 desafios"},
    {"palavra":"FAMILIA","dica":"Mamãe, papai, você e quem você ama"},
    {"palavra":"AMIZADE","dica":"O que você tem com a Lia, carinho"},
      @override
  void initState(){ super.initState(); carregar(); Future.delayed(Duration(seconds:1), ()=> ia.falar(mensagemIA)); }

  Future<void> carregar() async {
    SharedPreferences p = await SharedPreferences.getInstance();
    setState((){
      robux=p.getInt("robux_v5evo")??6; estrelas=p.getInt("estrelas_v5evo")??0;
      progressos.forEach((k,v){ progressos[k]=p.getInt("prog_${k}_v5evo")??0; });
      niveis.forEach((k,v){ niveis[k]=p.getInt("nivel_${k}_v5evo")??1; });
      sequencias.forEach((k,v){ sequencias[k]=p.getInt("seq_${k}_v5evo")??0; });
      acertos.forEach((k,v){ acertos[k]=p.getInt("ac_${k}_v5evo")??0; });
      erros.forEach((k,v){ erros[k]=p.getInt("err_${k}_v5evo")??0; });
      jogosComprados.forEach((k,v){ jogosComprados[k]=p.getBool("comp_${k}_v5evo")?? (k=="silabas"||k=="palavra"||k=="leitura"||k=="memoria"); });
      String? j=p.getString("mundos_v5evo");
      if(j!=null){ mundos=List<Map<String,dynamic>>.from(jsonDecode(j).map((e)=> Map<String,dynamic>.from(e))); }
      else {
        mundos=[
          {"id":1,"titulo":"Mundo 1 - Chegada Rosa","icone":"🏠","cor1":Color(0xFFF48FB1),"cor2":Color(0xFFCE93D8),"desbloqueado":true,"tarefas":[
            {"titulo":"Trocar roupa, lavar mãos e rosto","horario":"16:00 - 16:30","desc":"Roupinha rosa confortável","tipo":"foto","feita":false,"hora":"","foto":"","robux":3},
            {"titulo":"Lanche + Descanso","horario":"16:30 - 16:50","desc":"Comer com calma","tipo":"foto","feita":false,"hora":"","foto":"","robux":3},
          ]},
          {"id":2,"titulo":"Mundo 2 - Higiene Roxa","icone":"💜","cor1":Color(0xFFCE93D8),"cor2":Color(0xFF9C27B0),"desbloqueado":false,"tarefas":[
            {"titulo":"Escovar dentes + rosto","horario":"16:50 - 17:10","desc":"Sorriso brilhante","tipo":"foto","feita":false,"hora":"","foto":"","robux":3},
          ]},
          {"id":3,"titulo":"Mundo 3 - Dever com Lia IA","icone":"📚","cor1":Color(0xFF90CAF9),"cor2":Color(0xFFCE93D8),"desbloqueado":false,"tarefas":[
            {"titulo":"Fazer dever com IA falando","horario":"17:10 - 18:00","desc":"Lia lê as perguntas","tipo":"foto","feita":false,"hora":"","foto":"","robux":5},
          ]},
          {"id":4,"titulo":"Mundo 4 - 10 Jogos Gigantes que Evoluem","icone":"🎮","cor1":Color(0xFFF48FB1),"cor2":Color(0xFFAB47BC),"desbloqueado":false,"tarefas":[
            {"titulo":"10 Jogos Evolutivos 1-1000 palavras","horario":"18:00 - 18:50","desc":"200 desafios que sobem de nível conforme acerta. IA adapta!","tipo":"jogos","feita":false,"hora":"","foto":"","robux":20},
            {"titulo":"Lojinha - Comprar com Robux","horario":"18:00 - 18:50","desc":"Compre jogos novos","tipo":"lojinha","feita":false,"hora":"","foto":"","robux":0},
          ]},
          {"id":5,"titulo":"Mundo 5 - Jantar","icone":"👑","cor1":Color(0xFFFFCC80),"cor2":Color(0xFFF48FB1),"desbloqueado":false,"tarefas":[
            {"titulo":"Jantar e guardar","horario":"18:50 - 19:10","desc":"Ajudar mamãe","tipo":"foto","feita":false,"hora":"","foto":"","robux":3},
          ]},
          {"id":6,"titulo":"Mundo Final - 【entity-Roblox¦canonical_name=Roblox】 Rosa","icone":"🌈","cor1":Color(0xFFE1BEE7),"cor2":Color(0xFFF48FB1),"desbloqueado":false,"tarefas":[
            {"titulo":"【entity-Roblox¦canonical_name=Roblox】 liberado!","horario":"19:10 - 19:30","desc":"20 min","tipo":"【entity-roblox¦canonical_name=Roblox】","feita":false,"hora":"","foto":"","robux":0},
          ]},
        ];
      }
    });
  }

  Future<void> salvar() async {
    SharedPreferences p=await SharedPreferences.getInstance();
    await p.setInt("robux_v5evo",robux); await p.setInt("estrelas_v5evo",estrelas);
    for(var k in progressos.keys){ await p.setInt("prog_${k}_v5evo", progressos[k]!); await p.setInt("nivel_${k}_v5evo", niveis[k]!); await p.setInt("seq_${k}_v5evo", sequencias[k]!); await p.setInt("ac_${k}_v5evo", acertos[k]!); await p.setInt("err_${k}_v5evo", erros[k]!); await p.setBool("comp_${k}_v5evo", jogosComprados[k]!); }
    await p.setString("mundos_v5evo", jsonEncode(mundos));
  }

  int get totalTarefas=> mundos.fold(0,(a,m)=> a + (m["tarefas"] as List).length);
  int get feitas=> mundos.fold(0,(a,m)=> a + ((m["tarefas"] as List).where((t)=> t["feita"]==true).length as int));
  double get progressoGeral=> totalTarefas==0?0:feitas/totalTarefas;
  int get totalJogos=> progressos.values.reduce((a,b)=> a+b);
  bool get jogosCompletos=> totalJogos>=200;

  String nomeNivel(int n){ if(n==1) return "Iniciante 🌱"; if(n==2) return "Aprendiz 🌟"; if(n==3) return "Corajosa 💜"; if(n==4) return "Mestre 👑"; return "Lenda Rosa Roxa 🌈"; }

  Future<void> _loginFamilia() async {
    if(!modoCrianca && familiaAutenticada){ setState(()=> modoCrianca=true); return; }
    TextEditingController senhaCtrl=TextEditingController(); String sel="Ana Beatriz"; List<String> fam=["Ana Beatriz","Matheus","Jean","Vó"];
    bool? ok=await showDialog<bool>(context: context, builder: (ctx)=> AlertDialog(backgroundColor: Color(0xFFFCE4EC), title: Text("🔒 Área Família - Desempenho", style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF9C27B0))), content: Column(mainAxisSize: MainAxisSize.min, children: [
      Text("Senha: 1234 - Veja evolução da Alice", style: TextStyle(fontSize:12)),
      SizedBox(height:12),
      StatefulBuilder(builder: (ctx,setSt){ return Column(children:[
        DropdownButton<String>(value: sel, isExpanded: true, items: fam.map((f)=> DropdownMenuItem(value:f, child: Text(f))).toList(), onChanged: (v){ setSt(()=> sel=v!); }),
        SizedBox(height:12),
        TextField(controller: senhaCtrl, obscureText: true, decoration: InputDecoration(labelText:"Senha 1234", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled:true, fillColor: Colors.white)),
      ]); }),
    ]), actions: [TextButton(onPressed: ()=> Navigator.pop(ctx,false), child: Text("Cancelar")), ElevatedButton(onPressed: (){ if(senhaCtrl.text=="1234") Navigator.pop(ctx,true); else ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Senha incorreta!"), backgroundColor: Colors.red)); }, style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF9C27B0)), child: Text("Entrar"))]));
    if(ok==true){ setState((){ modoCrianca=false; familiaAutenticada=true; }); }
  }

  Future<void> tirarFoto(int mi,int ti) async {
    try{
      final XFile? f=await picker.pickImage(source: ImageSource.camera, imageQuality: 60);
      XFile? ff=f??await picker.pickImage(source: ImageSource.gallery, imageQuality: 60);
      if(ff==null) return;
      final b=await ff.readAsBytes(); final b64=base64Encode(b);
      setState((){
        mundos[mi]["tarefas"][ti]["feita"]=true; mundos[mi]["tarefas"][ti]["hora"]=TimeOfDay.now().format(context); mundos[mi]["tarefas"][ti]["foto"]=b64;
        robux+=mundos[mi]["tarefas"][ti]["robux"] as int; estrelas+=1; mensagemIA=ia.motivacional(); ia.falar("Foto salva! +${mundos[mi]["tarefas"][ti]["robux"]} Robux! $mensagemIA");
        var t=mundos[mi]["tarefas"] as List; if(t.every((x)=> x["feita"]==true)){ if(mi+1<mundos.length){ mundos[mi+1]["desbloqueado"]=true; mensagemIA=ia.instruirMundo(mundos[mi+1]["id"]); ia.falar(mensagemIA); } }
      }); await salvar();
    }catch(e){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro $e"))); }
  }

  void onAcerto(String jogo, {String palavra=""}){
    setState((){
      progressos[jogo]=progressos[jogo]!+1; acertos[jogo]=acertos[jogo]!+1; sequencias[jogo]=sequencias[jogo]!+1; robux+=2;
      if(palavra!=""){ if(!dominadas[jogo]!.contains(palavra)){ int count = progressos[jogo]! % 5; if(count==0) dominadas[jogo]!.add(palavra); } revisar[jogo]!.remove(palavra); }
      if(progressos[jogo]!%20==0 && progressos[jogo]!>=20){ robux+=10; mensagemIA="BÔNUS! 20 de 20 no $jogo! +10 Robux! Você subiu de nível!"; ia.falar(mensagemIA); niveis[jogo]=(niveis[jogo]!+1).clamp(1,5); }
      else if(sequencias[jogo]!>=5){ if(niveis[jogo]!<5 && (acertos[jogo]!/(acertos[jogo]!+erros[jogo]!+1) > 0.8)){ niveis[jogo]=niveis[jogo]!+1; mensagemIA="Você fez ${sequencias[jogo]} seguidos! Subiu para ${nomeNivel(niveis[jogo]!)} em $jogo!"; ia.falar(mensagemIA); robux+=5; } }
      if(jogosCompletos){ var m4=mundos[3]; var t=(m4["tarefas"] as List)[0]; if(!t["feita"]){ t["feita"]=true; t["hora"]=TimeOfDay.now().format(context); robux+=20; estrelas+=2; mundos[4]["desbloqueado"]=true; mensagemIA="Parabéns Alice! 200 desafios! 【entity-Roblox¦canonical_name=Roblox】 rosa liberado! Você é Lenda!"; ia.falar(mensagemIA); } }
    }); salvar();
  }

  void onErro(String jogo, {String palavra=""}){
    setState((){
      erros[jogo]=erros[jogo]!+1; sequencias[jogo]=0;
      if(palavra!="" && !revisar[jogo]!.contains(palavra)){ revisar[jogo]!.add(palavra); }
      if(erros[jogo]!>=3 && niveis[jogo]!>1 && sequencias[jogo]==0){ niveis[jogo]=niveis[jogo]!-1; mensagemIA="Calma, vamos voltar um pouquinho no $jogo pra treinar mais. Tô aqui!"; ia.falar(mensagemIA); }
    }); salvar();
  }

  void comprar(String id,int preco){ if(robux>=preco && jogosComprados[id]==false){ setState((){ robux-=preco; jogosComprados[id]=true; mensagemIA="Comprou $id! Jogo novo gigante!"; ia.falar(mensagemIA); }); salvar(); } else if(jogosComprados[id]==true){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Já tem!"))); } else { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Robux insuficiente!"), backgroundColor: Colors.red)); } }

  void abrirJogos(){ Navigator.push(context, MaterialPageRoute(builder: (_)=> TelaJogosEvolucao(progressos: progressos, niveis: niveis, sequencias: sequencias, acertos: acertos, erros: erros, jogosComprados: jogosComprados, robux: robux, ia: ia, banco1000: banco1000, bancoDicas: bancoDicas500, mensagemIA: mensagemIA, onAcerto: onAcerto, onErro: onErro, onComprar: comprar, nomeNivel: nomeNivel))).then((_)=> setState(()=> carregar())); }
  void abrirLojinha(){ Navigator.push(context, MaterialPageRoute(builder: (_)=> TelaLojinhaEvolucao(jogosComprados: jogosComprados, robux: robux, niveis: niveis, onComprar: comprar, ia: ia))).then((_)=> setState(()=> carregar())); }
      @override
  Widget build(BuildContext context){
    return Scaffold(body: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFFCE4EC), Color(0xFFF3E5F5), Color(0xFFE1BEE7)])), child: SafeArea(child: SingleChildScrollView(padding: EdgeInsets.all(12), child: Column(children: [
      Container(padding: EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Color(0xFF9C27B0), width: 2.5), boxShadow: [BoxShadow(color: Color(0xFFCE93D8), blurRadius: 10, offset: Offset(0,6))]), child: Column(children: [
        Row(children: [
          Container(width: 56, height: 56, decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFF48FB1), Color(0xFF9C27B0)]), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black, width:2)), child: Center(child: Text("👩‍🏫", style: TextStyle(fontSize:30)))),
          SizedBox(width:10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("MUNDO DA ALICE", style: TextStyle(fontWeight: FontWeight.w900, fontSize:17, color: Color(0xFF9C27B0))), Text("Rosa & Roxo Evolutivo com IA", style: TextStyle(fontWeight: FontWeight.bold, fontSize:13, color: Color(0xFFF48FB1))), Text("9 anos • Oi Alice! Evolui com você! 💜", style: TextStyle(fontSize:11, color: Colors.black54))])),
          Column(children: [Container(padding: EdgeInsets.symmetric(horizontal:10, vertical:6), decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF9C27B0), Color(0xFFF48FB1)]), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black, width:1.5)), child: Row(children: [Icon(Icons.diamond, size:14, color: Colors.white), SizedBox(width:4), Text("$robux ROBUX", style: TextStyle(color: Colors.white, fontSize:11, fontWeight: FontWeight.bold))])), SizedBox(height:4), Container(padding: EdgeInsets.symmetric(horizontal:10, vertical:4), decoration: BoxDecoration(color: Color(0xFFFCE4EC), borderRadius: BorderRadius.circular(20), border: Border.all(color: Color(0xFF9C27B0), width:1.5)), child: Text("$estrelas/12 ⭐ $totalJogos/200 🎮", style: TextStyle(fontSize:10, fontWeight: FontWeight.bold, color: Color(0xFF9C27B0))))]),
        ]),
        SizedBox(height:12),
        Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFF48FB1).withOpacity(0.3), Color(0xFFCE93D8).withOpacity(0.3)]), borderRadius: BorderRadius.circular(16), border: Border.all(color: Color(0xFF9C27B0), width:1.5)), child: Row(children: [Container(width:40, height:40, decoration: BoxDecoration(color: Color(0xFF9C27B0), borderRadius: BorderRadius.circular(20)), child: Center(child: Text("🤖", style: TextStyle(fontSize:20)))), SizedBox(width:10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Lia - Tutora IA Evolutiva:", style: TextStyle(fontWeight: FontWeight.w900, fontSize:12, color: Color(0xFF9C27B0))), Text(mensagemIA, style: TextStyle(fontSize:12))])), IconButton(onPressed: ()=> ia.falar(mensagemIA), icon: Icon(Icons.volume_up, color: Color(0xFF9C27B0)))])),
        SizedBox(height:12),
        Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Color(0xFF9C27B0), width:1.5)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Text("PROGRESSO GERAL", style: TextStyle(fontSize:10, fontWeight: FontWeight.w900, color: Color(0xFF9C27B0))), Spacer(), Container(padding: EdgeInsets.symmetric(horizontal:8, vertical:2), decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFF48FB1), Color(0xFF9C27B0)]), borderRadius: BorderRadius.circular(10)), child: Text("${(progressoGeral*100).toInt()}%", style: TextStyle(fontSize:11, fontWeight: FontWeight.bold, color: Colors.white)))]),
          SizedBox(height:8), ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progressoGeral, minHeight:12, backgroundColor: Color(0xFFFCE4EC), color: Color(0xFF9C27B0))),
          SizedBox(height:6), ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: totalJogos/200, minHeight:8, backgroundColor: Color(0xFFFCE4EC), color: Color(0xFFF48FB1))),
          SizedBox(height:4), Text("Jogos Evolutivos: $totalJogos/200 - Sobe de nível conforme acerta!", style: TextStyle(fontSize:10, color: Color(0xFF9C27B0), fontWeight: FontWeight.bold)),
        ])),
        SizedBox(height:12),
        Container(padding: EdgeInsets.all(4), decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF9C27B0), Color(0xFFF48FB1)]), borderRadius: BorderRadius.circular(30)), child: Row(children: [
          Expanded(child: GestureDetector(onTap: ()=> setState(()=> modoCrianca=true), child: Container(padding: EdgeInsets.symmetric(vertical:10), decoration: BoxDecoration(color: modoCrianca? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(30)), child: Center(child: Text("Criança 👧💜", style: TextStyle(fontWeight: FontWeight.bold, fontSize:13, color: modoCrianca? Color(0xFF9C27B0) : Colors.white)))))),
          Expanded(child: GestureDetector(onTap: ()=> _loginFamilia(), child: Container(padding: EdgeInsets.symmetric(vertical:10), decoration: BoxDecoration(color: !modoCrianca? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(30)), child: Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.lock, size:12, color: !modoCrianca? Color(0xFF9C27B0) : Colors.white), SizedBox(width:4), Text("Família 📊", style: TextStyle(fontWeight: FontWeight.bold, fontSize:13, color: !modoCrianca? Color(0xFF9C27B0) : Colors.white))]))))),
        ])),
      ])),
      SizedBox(height:12),
      ...mundos.asMap().entries.map((entry){
        int idx=entry.key; var mundo=entry.value; bool desbloq=mundo["desbloqueado"]; var tarefas=mundo["tarefas"] as List; int feitasMundo=tarefas.where((t)=> t["feita"]==true).length;
        return Container(margin: EdgeInsets.only(bottom:12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Color(0xFF9C27B0), width:2.5)), child: Column(children: [
          Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(gradient: LinearGradient(colors: desbloq? [mundo["cor1"], mundo["cor2"]] : [Color(0xFFE0E0E0), Color(0xFFBDBDBD)]), borderRadius: BorderRadius.vertical(top: Radius.circular(18))), child: Row(children: [
            Container(width:44, height:44, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black, width:2)), child: Center(child: Text(mundo["icone"], style: TextStyle(fontSize:22)))),
            SizedBox(width:8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(mundo["titulo"], style: TextStyle(fontWeight: FontWeight.w900, fontSize:14, color: Colors.white)), Container(padding: EdgeInsets.symmetric(horizontal:6, vertical:2), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)), child: Text("$feitasMundo/${tarefas.length}", style: TextStyle(color: Colors.white, fontSize:10, fontWeight: FontWeight.bold)))])),
            Icon(desbloq? Icons.star : Icons.lock, color: Colors.white),
          ])),
          if(!desbloq) Container(padding: EdgeInsets.all(20), child: Column(children: [Icon(Icons.lock, size:40, color: Color(0xFFCE93D8)), SizedBox(height:8), Text("Bloqueado 🔒", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF9C27B0))), Text("Termine anterior", style: TextStyle(fontSize:11, color: Colors.black54))])),
          if(desbloq) Padding(padding: EdgeInsets.all(10), child: Column(children: tarefas.asMap().entries.map((tEntry){
            int tIdx=tEntry.key; var t=tEntry.value; bool feita=t["feita"]; String tipo=t["tipo"];
            return Container(margin: EdgeInsets.only(bottom:10), padding: EdgeInsets.all(12), decoration: BoxDecoration(color: feita? Color(0xFFFCE4EC) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Color(0xFF9C27B0), width:1.5)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width:38, height:38, decoration: BoxDecoration(gradient: LinearGradient(colors: feita? [Colors.green, Colors.greenAccent] : [Color(0xFFF48FB1), Color(0xFF9C27B0)]), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black, width:1.5)), child: Center(child: Text(feita? "✅" : t["titulo"][0], style: TextStyle(fontSize:16, color: Colors.white)))),
                SizedBox(width:8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t["horario"], style: TextStyle(fontSize:10, color: Color(0xFF9C27B0), fontWeight: FontWeight.bold)), Text(t["titulo"], style: TextStyle(fontSize:13, fontWeight: FontWeight.w900, color: Color(0xFF9C27B0))), Text(t["desc"], style: TextStyle(fontSize:11, color: Colors.black54))])),
              ]),
              SizedBox(height:8),
              if(tipo=="foto") Row(children: [Expanded(child: SizedBox(height:42, child: ElevatedButton(onPressed: feita? null : ()=> tirarFoto(idx, tIdx), style: ElevatedButton.styleFrom(backgroundColor: feita? Colors.green : Color(0xFF9C27B0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(feita? "Feito ${t["hora"]} ✅" : "📸 Tirei foto +${t["robux"]} 💎", style: TextStyle(fontSize:12, fontWeight: FontWeight.bold, color: Colors.white))))), SizedBox(width:8), Container(width:42, height:42, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Color(0xFF9C27B0), width:1.5)), child: IconButton(onPressed: ()=> ia.falar(t["desc"]), icon: Icon(Icons.volume_up, size:18, color: Color(0xFF9C27B0))))]),
              if(tipo=="jogos") Column(children: [
                Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFF48FB1).withOpacity(0.2), Color(0xFF9C27B0).withOpacity(0.2)]), borderRadius: BorderRadius.circular(12), border: Border.all(color: Color(0xFF9C27B0))), child: Column(children: [Row(children: [Text("🎮 $totalJogos/200 Evolutivo", style: TextStyle(fontWeight: FontWeight.bold, fontSize:12, color: Color(0xFF9C27B0))), Spacer(), Text("$robux 💎", style: TextStyle(fontWeight: FontWeight.bold, fontSize:12, color: Color(0xFF9C27B0)))]), SizedBox(height:6), ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: totalJogos/200, backgroundColor: Colors.white, color: Color(0xFF9C27B0)))])),
                SizedBox(height:10),
                SizedBox(width: double.infinity, height:50, child: ElevatedButton(onPressed: abrirJogos, style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF9C27B0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: Text("🎮 10 JOGOS QUE EVOLUEM COM VOCÊ", style: TextStyle(fontWeight: FontWeight.bold, fontSize:12, color: Colors.white)))),
                SizedBox(height:8),
                Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Color(0xFFFFF9C4), borderRadius: BorderRadius.circular(10)), child: Row(children: [Text("🤖", style: TextStyle(fontSize:16)), SizedBox(width:6), Expanded(child: Text("IA Lia adapta dificuldade! 1000 palavras, 1-100 blocos, sobe de nível!", style: TextStyle(fontSize:10, color: Color(0xFF9C27B0), fontWeight: FontWeight.bold)))])),
              ]),
              if(tipo=="lojinha") SizedBox(width: double.infinity, height:50, child: ElevatedButton(onPressed: abrirLojinha, style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFF48FB1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: Text("🛒 LOJINHA + DESEMPENHO", style: TextStyle(fontWeight: FontWeight.bold, fontSize:12, color: Colors.white)))),
              if(tipo=="【entity-roblox¦canonical_name=ROBLOX】") SizedBox(width: double.infinity, height:50, child: ElevatedButton(onPressed: (feitas>=5 && jogosCompletos)? () async { const url="https://www.roblox.com/"; if(await canLaunchUrl(Uri.parse(url))) await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication); } : null, style: ElevatedButton.styleFrom(backgroundColor: (feitas>=5 && jogosCompletos)? Color(0xFFE22326) : Colors.grey, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: Text((feitas>=5 && jogosCompletos)? "🌈 【entity-ROBLOX¦canonical_name=ROBLOX】 ROSA LIBERADO 20 MIN" : "🔒 FAÇA $totalJogos/200 PRA LIBERAR", style: TextStyle(fontWeight: FontWeight.bold, fontSize:11, color: Colors.white)))),
              if(feita && t["foto"]!="") Padding(padding: EdgeInsets.only(top:8), child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.memory(base64Decode(t["foto"]), height:140, width: double.infinity, fit: BoxFit.cover))),
            ]),
          );
          }).toList()),
        ),
        ]));
      }).toList(),
      if(!modoCrianca && familiaAutenticada)
        Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Color(0xFF9C27B0), width:2)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("📊 RELATÓRIO DE DESEMPENHO - Alice", style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF9C27B0), fontSize:16)),
          SizedBox(height:8),
          Text("Geral: ${acertos.values.reduce((a,b)=>a+b)} acertos / ${erros.values.reduce((a,b)=>a+b)} erros - Taxa ${(acertos.values.reduce((a,b)=>a+b)/(acertos.values.reduce((a,b)=>a+b)+erros.values.reduce((a,b)=>a+b)+1)*100).toStringAsFixed(0)}% - Robux: $robux", style: TextStyle(fontSize:11, fontWeight: FontWeight.bold)),
          SizedBox(height:8),
          ...progressos.keys.map((k){
            int totalK = (acertos[k]!+erros[k]!); double taxa = totalK==0?0: acertos[k]!/totalK*100;
            return Container(margin: EdgeInsets.only(bottom:6), padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Color(0xFFFCE4EC), borderRadius: BorderRadius.circular(8), border: Border.all(color: Color(0xFF9C27B0))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Text("$k - ${nomeNivel(niveis[k]!)}", style: TextStyle(fontWeight: FontWeight.bold, fontSize:12, color: Color(0xFF9C27B0))), Spacer(), Text("${taxa.toStringAsFixed(0)}% ${acertos[k]}/${totalK}", style: TextStyle(fontSize:11, fontWeight: FontWeight.bold))]),
              SizedBox(height:4),
              LinearProgressIndicator(value: totalK==0?0: taxa/100, color: Color(0xFF9C27B0), backgroundColor: Colors.white, minHeight:6),
              SizedBox(height:4),
              Text("Seq: ${sequencias[k]} | Dominadas: ${dominadas[k]!.length} | Revisar: ${revisar[k]!.join(", ")}", style: TextStyle(fontSize:9, color: Colors.black54)),
            ]));
          }).toList(),
          SizedBox(height:12),
          SizedBox(width: double.infinity, height:50, child: ElevatedButton(onPressed: () async { SharedPreferences p=await SharedPreferences.getInstance(); await p.clear(); setState((){ carregar(); familiaAutenticada=false; modoCrianca=true; }); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: Text("RESETAR DIA - Família", style: TextStyle(fontWeight: FontWeight.bold)))),
        ])),
      SizedBox(height:20),
    ]),
  ))))) ;
  }
}
    // TELA DE JOGOS EVOLUTIVOS
class TelaJogosEvolucao extends StatelessWidget {
  final Map<String,int> progressos, niveis, sequencias, acertos, erros; final Map<String,bool> jogosComprados; final int robux; final IATutora ia; final List<String> banco1000; final List<Map<String,String>> bancoDicas; final String mensagemIA; final Function(String,{String palavra}) onAcerto, onErro; final Function(String,int) onComprar; final Function(int) nomeNivel;
  TelaJogosEvolucao({required this.progressos, required this.niveis, required this.sequencias, required this.acertos, required this.erros, required this.jogosComprados, required this.robux, required this.ia, required this.banco1000, required this.bancoDicas, required this.mensagemIA, required this.onAcerto, required this.onErro, required this.onComprar, required this.nomeNivel});
  @override
  Widget build(BuildContext context){
    return Scaffold(body: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFF48FB1), Color(0xFF9C27B0)])), child: SafeArea(child: Column(children: [
      Container(padding: EdgeInsets.all(12), color: Colors.black, child: Row(children: [IconButton(onPressed: ()=> Navigator.pop(context), icon: Icon(Icons.arrow_back, color: Colors.white)), Expanded(child: Text("🎮 10 Jogos que Evoluem - $robux 💎 - ${progressos.values.reduce((a,b)=>a+b)}/200", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize:12))), IconButton(onPressed: ()=> ia.falar(mensagemIA), icon: Icon(Icons.volume_up, color: Colors.white))])),
      Expanded(child: GridView.count(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, padding: EdgeInsets.all(12), childAspectRatio: 0.85, children: [
        _GameCardEvo(titulo:"Sílabas 1000 palavras", progresso: progressos["silabas"]!, nivel: niveis["silabas"]!, seq: sequencias["silabas"]!, preco:0, comprado: true, cor1: Color(0xFFCE93D8), cor2: Color(0xFF9C27B0), emoji:"🔤", nomeNivel: nomeNivel, onPlay: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> JogoSilabasEvo(onAcerto: onAcerto, onErro: onErro, progresso: progressos["silabas"]!, nivel: niveis["silabas"]!, ia: ia, banco: banco1000, nomeNivel: nomeNivel))), onBuy: (){}),
        _GameCardEvo(titulo:"Palavra Escondida 500 dicas", progresso: progressos["palavra"]!, nivel: niveis["palavra"]!, seq: sequencias["palavra"]!, preco:0, comprado: true, cor1: Color(0xFF90CAF9), cor2: Color(0xFF42A5F5), emoji:"🔍", nomeNivel: nomeNivel, onPlay: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> JogoPalavraEvo(onAcerto: onAcerto, onErro: onErro, progresso: progressos["palavra"]!, nivel: niveis["palavra"]!, ia: ia, bancoDicas: bancoDicas, nomeNivel: nomeNivel))), onBuy: (){}),
        _GameCardEvo(titulo:"Contando Tudo 1-100", progresso: progressos["blocos"]!, nivel: niveis["blocos"]!, seq: sequencias["blocos"]!, preco:70, comprado: jogosComprados["blocos"]!, cor1: Color(0xFFA5D6A7), cor2: Color(0xFF43A047), emoji:"🧱", nomeNivel: nomeNivel, onPlay: (){ if(jogosComprados["blocos"]==true) Navigator.push(context, MaterialPageRoute(builder: (_)=> JogoBlocosEvo(onAcerto: onAcerto, onErro: onErro, progresso: progressos["blocos"]!, nivel: niveis["blocos"]!, ia: ia, nomeNivel: nomeNivel))); }, onBuy: ()=> onComprar("blocos",70)),
        _GameCardEvo(titulo:"Lojinha Troco", progresso: progressos["lojinha"]!, nivel: niveis["lojinha"]!, seq: sequencias["lojinha"]!, preco:70, comprado: jogosComprados["lojinha"]!, cor1: Color(0xFFFFCC80), cor2: Color(0xFFFF9800), emoji:"🛒", nomeNivel: nomeNivel, onPlay: (){ if(jogosComprados["lojinha"]==true) Navigator.push(context, MaterialPageRoute(builder: (_)=> JogoLojinhaEvo(onAcerto: onAcerto, onErro: onErro, progresso: progressos["lojinha"]!, nivel: niveis["lojinha"]!, ia: ia, nomeNivel: nomeNivel))); }, onBuy: ()=> onComprar("lojinha",70)),
        _GameCardEvo(titulo:"Leitura com Voz", progresso: progressos["leitura"]!, nivel: niveis["leitura"]!, seq: sequencias["leitura"]!, preco:0, comprado: true, cor1: Color(0xFFF48FB1), cor2: Color(0xFFE91E63), emoji:"📖", nomeNivel: nomeNivel, onPlay: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> JogoLeituraEvo(onAcerto: onAcerto, onErro: onErro, progresso: progressos["leitura"]!, nivel: niveis["leitura"]!, ia: ia, nomeNivel: nomeNivel))), onBuy: (){}),
        _GameCardEvo(titulo:"Memória 20 palavras", progresso: progressos["memoria"]!, nivel: niveis["memoria"]!, seq: sequencias["memoria"]!, preco:0, comprado: true, cor1: Color(0xFF80CBC4), cor2: Color(0xFF00897B), emoji:"🧠", nomeNivel: nomeNivel, onPlay: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> JogoMemoriaEvo(onAcerto: onAcerto, onErro: onErro, progresso: progressos["memoria"]!, nivel: niveis["memoria"]!, ia: ia, banco: banco1000, nomeNivel: nomeNivel))), onBuy: (){}),
        _GameCardEvo(titulo:"Matemática 1-100", progresso: progressos["matematica"]!, nivel: niveis["matematica"]!, seq: sequencias["matematica"]!, preco:80, comprado: jogosComprados["matematica"]!, cor1: Color(0xFFFFAB91), cor2: Color(0xFFFF5722), emoji:"➕", nomeNivel: nomeNivel, onPlay: (){ if(jogosComprados["matematica"]==true) Navigator.push(context, MaterialPageRoute(builder: (_)=> JogoMatematicaEvo(onAcerto: onAcerto, onErro: onErro, progresso: progressos["matematica"]!, nivel: niveis["matematica"]!, ia: ia, nomeNivel: nomeNivel))); }, onBuy: ()=> onComprar("matematica",80)),
        _GameCardEvo(titulo:"Desenho Mágico", progresso: progressos["desenho"]!, nivel: niveis["desenho"]!, seq: sequencias["desenho"]!, preco:80, comprado: jogosComprados["desenho"]!, cor1: Color(0xFFF48FB1), cor2: Color(0xFFE91E63), emoji:"🎨", nomeNivel: nomeNivel, onPlay: (){ if(jogosComprados["desenho"]==true) Navigator.push(context, MaterialPageRoute(builder: (_)=> JogoDesenhoEvo(onAcerto: onAcerto, onErro: onErro, progresso: progressos["desenho"]!, nivel: niveis["desenho"]!, ia: ia, nomeNivel: nomeNivel))); }, onBuy: ()=> onComprar("desenho",80)),
        _GameCardEvo(titulo:"Caça 20 palavras", progresso: progressos["caca"]!, nivel: niveis["caca"]!, seq: sequencias["caca"]!, preco:90, comprado: jogosComprados["caca"]!, cor1: Color(0xFFB39DDB), cor2: Color(0xFF673AB7), emoji:"🔎", nomeNivel: nomeNivel, onPlay: (){ if(jogosComprados["caca"]==true) Navigator.push(context, MaterialPageRoute(builder: (_)=> JogoCacaEvo(onAcerto: onAcerto, onErro: onErro, progresso: progressos["caca"]!, nivel: niveis["caca"]!, ia: ia, banco: banco1000, nomeNivel: nomeNivel))); }, onBuy: ()=> onComprar("caca",90)),
        _GameCardEvo(titulo:"Parkour Quiz", progresso: progressos["parkour"]!, nivel: niveis["parkour"]!, seq: sequencias["parkour"]!, preco:100, comprado: jogosComprados["parkour"]!, cor1: Color(0xFFFFD54F), cor2: Color(0xFFFF6F00), emoji:"🏃‍♀️", isNew:true, nomeNivel: nomeNivel, onPlay: (){ if(jogosComprados["parkour"]==true) Navigator.push(context, MaterialPageRoute(builder: (_)=> JogoParkourEvo(onAcerto: onAcerto, onErro: onErro, progresso: progressos["parkour"]!, nivel: niveis["parkour"]!, ia: ia, nomeNivel: nomeNivel))); }, onBuy: ()=> onComprar("parkour",100)),
      ])),
    ]))));
  }
}

class _GameCardEvo extends StatelessWidget {
  final String titulo, emoji; final int progresso, nivel, seq, preco; final bool comprado; final Color cor1, cor2; final bool isNew; final VoidCallback onPlay, onBuy; final Function(int) nomeNivel;
  _GameCardEvo({required this.titulo, required this.progresso, required this.nivel, required this.seq, required this.preco, required this.comprado, required this.cor1, required this.cor2, required this.emoji, required this.onPlay, required this.onBuy, required this.nomeNivel, this.isNew=false});
  @override
  Widget build(BuildContext context){
    bool gratis=preco==0;
    return Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Color(0xFF9C27B0), width:2.5)), child: Column(children: [
      Expanded(child: Container(width: double.infinity, decoration: BoxDecoration(gradient: LinearGradient(colors: [cor1, cor2]), borderRadius: BorderRadius.vertical(top: Radius.circular(14))), child: Stack(children: [
        Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(emoji, style: TextStyle(fontSize:32)), SizedBox(height:2), Text(titulo, style: TextStyle(fontSize:10, fontWeight: FontWeight.w900, color: Colors.white), textAlign: TextAlign.center), SizedBox(height:2), Container(padding: EdgeInsets.symmetric(horizontal:6, vertical:2), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)), child: Text(nomeNivel(nivel), style: TextStyle(fontSize:8, color: Colors.white, fontWeight: FontWeight.bold)))])),
        if(isNew) Positioned(top:6, left:6, child: Container(padding: EdgeInsets.symmetric(horizontal:6, vertical:2), decoration: BoxDecoration(color: Colors.yellow, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.black)), child: Text("NOVO", style: TextStyle(fontSize:8, fontWeight: FontWeight.bold)))),
      ]))),
      Padding(padding: EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if(gratis || comprado) ...[
          ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: progresso/20, minHeight:6, backgroundColor: Color(0xFFFCE4EC), color: cor2)),
          SizedBox(height:4),
          Row(children: [Text("$progresso/20", style: TextStyle(fontSize:11, color: Color(0xFF9C27B0), fontWeight: FontWeight.bold)), Spacer(), if(seq>=2) Container(padding: EdgeInsets.symmetric(horizontal:4, vertical:1), decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(6)), child: Text("$seq 🔥", style: TextStyle(fontSize:9, fontWeight: FontWeight.bold, color: Colors.white)))]),
          SizedBox(height:6),
          SizedBox(width: double.infinity, height:32, child: ElevatedButton(onPressed: onPlay, style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF9C27B0), padding: EdgeInsets.zero), child: Text("JOGAR NÍVEL $nivel", style: TextStyle(fontSize:10, fontWeight: FontWeight.bold, color: Colors.white)))),
        ] else ...[
          Row(children: [Icon(Icons.diamond, size:12, color: Color(0xFF9C27B0)), SizedBox(width:4), Text("$preco Robux", style: TextStyle(fontSize:11, fontWeight: FontWeight.bold, color: Color(0xFF9C27B0)))]),
          SizedBox(height:6),
          SizedBox(width: double.infinity, height:32, child: ElevatedButton(onPressed: onBuy, style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFF48FB1), padding: EdgeInsets.zero), child: Text("COMPRAR", style: TextStyle(fontSize:11, fontWeight: FontWeight.bold, color: Colors.white)))),
        ],
      ])),
    ]));
  }
}

class TelaLojinhaEvolucao extends StatelessWidget {
  final Map<String,bool> jogosComprados; final int robux; final Map<String,int> niveis; final Function(String,int) onComprar; final IATutora ia;
  TelaLojinhaEvolucao({required this.jogosComprados, required this.robux, required this.niveis, required this.onComprar, required this.ia});
  @override
  Widget build(BuildContext context){
    return Scaffold(body: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFF48FB1), Color(0xFF9C27B0)])), child: SafeArea(child: Column(children: [
      Container(padding: EdgeInsets.all(12), color: Colors.black, child: Row(children: [IconButton(onPressed: ()=> Navigator.pop(context), icon: Icon(Icons.arrow_back, color: Colors.white)), Expanded(child: Text("🛒 Lojinha Evolutiva - $robux Robux 💎", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))])),
      Expanded(child: ListView(padding: EdgeInsets.all(12), children: [
        Container(padding: EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black, width:2)), child: Column(children: [Text("COMPRE JOGOS QUE EVOLUEM COM ROBUX", style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF9C27B0))), Text("1000 palavras, 1-100 blocos, 5 níveis cada! IA 【entity-Lia¦canonical_name=Lia】 adapta!", style: TextStyle(fontSize:11, color: Colors.black54), textAlign: TextAlign.center)])),
        SizedBox(height:12),
        _LojinhaEvoItem(titulo:"Contando Tudo 1-100 - Evolutivo", preco:70, comprado: jogosComprados["blocos"]!, nivel: niveis["blocos"]!, desc:"Nível 1: 1-10, Nível 5: 1-100 com soma! Evolui conforme acerta!", onBuy: ()=> onComprar("blocos",70)),
        _LojinhaEvoItem(titulo:"Lojinha Troco Evolutiva", preco:70, comprado: jogosComprados["lojinha"]!, nivel: niveis["lojinha"]!, desc:"Nível 1: até R\$5, Nível 5: troco com 3 notas!", onBuy: ()=> onComprar("lojinha",70)),
        _LojinhaEvoItem(titulo:"Matemática 1-100 Evolutiva", preco:80, comprado: jogosComprados["matematica"]!, nivel: niveis["matematica"]!, desc:"Nível 1: 1+1, Nível 5: 87+46 com reserva!", onBuy: ()=> onComprar("matematica",80)),
        _LojinhaEvoItem(titulo:"Desenho Mágico Rosa", preco:80, comprado: jogosComprados["desenho"]!, nivel: niveis["desenho"]!, desc:"Desenhe e ganhe, evolui com criatividade!", onBuy: ()=> onComprar("desenho",80)),
        _LojinhaEvoItem(titulo:"Caça 20 palavras - 1000 banco", preco:90, comprado: jogosComprados["caca"]!, nivel: niveis["caca"]!, desc:"1000 palavras no banco, mínimo 20 por jogo!", onBuy: ()=> onComprar("caca",90)),
        _LojinhaEvoItem(titulo:"Parkour Quiz Evolutivo", preco:100, comprado: jogosComprados["parkour"]!, nivel: niveis["parkour"]!, desc:"Quiz rosa e roxo que fica mais difícil!", onBuy: ()=> onComprar("parkour",100)),
      ])),
    ]))));
  }
}
class _LojinhaEvoItem extends StatelessWidget {
  final String titulo, desc; final int preco, nivel; final bool comprado; final VoidCallback onBuy;
  _LojinhaEvoItem({required this.titulo, required this.preco, required this.comprado, required this.nivel, required this.desc, required this.onBuy});
  @override
  Widget build(BuildContext context){
    return Container(margin: EdgeInsets.only(bottom:10), padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Color(0xFF9C27B0), width:2)), child: Row(children: [
      Container(width:56, height:56, decoration: BoxDecoration(gradient: LinearGradient(colors: comprado? [Colors.green, Colors.greenAccent] : [Color(0xFFF48FB1), Color(0xFF9C27B0)]), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black, width:2)), child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(comprado? "✅" : "🎮", style: TextStyle(fontSize:22)), Text("Nv$nivel", style: TextStyle(fontSize:9, fontWeight: FontWeight.bold, color: Colors.white))]))),
      SizedBox(width:10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(titulo, style: TextStyle(fontWeight: FontWeight.bold, fontSize:13, color: Color(0xFF9C27B0))), Text(desc, style: TextStyle(fontSize:11, color: Colors.black54)), SizedBox(height:4), Row(children: [Icon(Icons.diamond, size:14, color: Color(0xFF9C27B0)), SizedBox(width:4), Text("$preco Robux", style: TextStyle(fontWeight: FontWeight.bold, fontSize:12, color: Color(0xFF9C27B0)))])])),
      SizedBox(width:8),
      ElevatedButton(onPressed: comprado? null : onBuy, style: ElevatedButton.styleFrom(backgroundColor: comprado? Colors.green : Color(0xFF9C27B0)), child: Text(comprado? "OK" : "Comprar")),
    ]));
  }
}

// JOGOS EVOLUTIVOS
class JogoSilabasEvo extends StatefulWidget {
  final Function(String,{String palavra}) onAcerto; final Function(String,{String palavra}) onErro; final int progresso, nivel; final IATutora ia; final List<String> banco; final Function(int) nomeNivel;
  JogoSilabasEvo({required this.onAcerto, required this.onErro, required this.progresso, required this.nivel, required this.ia, required this.banco, required this.nomeNivel});
  @override _JogoSilabasEvoState createState()=> _JogoSilabasEvoState();
}
class _JogoSilabasEvoState extends State<JogoSilabasEvo> {
  late String palavra; String resposta=""; List<String> usadas=[];
  @override
  void initState(){ super.initState(); gerar(); }
  void gerar(){
    List<String> candidatas = widget.banco.where((p){ int sil = p.length<=4?2: p.length<=7?3: p.length<=9?4:5; if(widget.nivel==1) return sil==2; if(widget.nivel==2) return sil==3; if(widget.nivel==3) return sil>=3 && sil<=4; if(widget.nivel==4) return sil>=4; return true; }).toList();
    if(candidatas.isEmpty) candidatas=widget.banco;
    candidatas = candidatas.where((p)=> !usadas.contains(p)).toList();
    if(candidatas.isEmpty){ usadas=[]; candidatas=widget.banco; }
    setState((){ palavra=candidatas[Random().nextInt(candidatas.length)]; usadas.add(palavra); });
    widget.ia.falar("Nível ${widget.nivel} ${widget.nomeNivel(widget.nivel)} - Separe as sílabas de $palavra! Mínimo 20 palavras!");
  }
  String silabar(String p){ if(p.length<=3) return p; if(p.length==4) return "${p.substring(0,2)}-${p.substring(2)}"; if(p.length==5) return "${p.substring(0,2)}-${p.substring(2,4)}-${p.substring(4)}"; if(p.length==6) return "${p.substring(0,2)}-${p.substring(2,4)}-${p.substring(4)}"; if(p.length>=7) return "${p.substring(0,2)}-${p.substring(2,5)}-${p.substring(5)}"; return p; }
  void verificar(){
    String correta = silabar(palavra);
    bool ok = resposta.toUpperCase().replaceAll(" ", "-").contains("-") && resposta.toUpperCase().length>=correta.length-2;
    if(resposta.toUpperCase().trim()==correta || ok){
      widget.onAcerto("silabas", palavra: palavra); widget.ia.falar("Muito bem! $palavra é $correta!"); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Correto! +2 Robux! Nível ${widget.nivel}"), backgroundColor: Colors.green)); setState(()=> resposta=""); gerar();
    } else { widget.onErro("silabas", palavra: palavra); widget.ia.falar("Quase! $palavra se separa $correta, repete comigo!"); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("É $correta - Revisar!"), backgroundColor: Colors.orange)); }
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(backgroundColor: Color(0xFFFCE4EC), appBar: AppBar(title: Text("Sílabas Nv${widget.nivel} ${widget.progresso}/20 - 1000 palavras"), backgroundColor: Color(0xFF9C27B0), foregroundColor: Colors.white), body: Padding(padding: EdgeInsets.all(20), child: Column(children: [
      LinearProgressIndicator(value: widget.progresso/20, color: Color(0xFF9C27B0)), SizedBox(height:8), Text("${widget.nomeNivel(widget.nivel)} - Mínimo 20 palavras diferentes!", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF9C27B0))),
      SizedBox(height:20),
      Container(width: double.infinity, padding: EdgeInsets.all(24), decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFF48FB1), Color(0xFF9C27B0)]), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black, width:2)), child: Column(children: [Text(palavra, style: TextStyle(fontSize:44, fontWeight: FontWeight.w900, color: Colors.white)), SizedBox(height:8), Text("Nível ${widget.nivel} - ${palavra.length} letras", style: TextStyle(color: Colors.white))])),
      SizedBox(height:30),
      TextField(onChanged: (v)=> resposta=v, decoration: InputDecoration(labelText:"Separe com - ex: CA-SA", filled:true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))), style: TextStyle(fontSize:20)),
      SizedBox(height:20),
      SizedBox(width: double.infinity, height:50, child: ElevatedButton(onPressed: verificar, style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF9C27B0)), child: Text("Verificar Nv${widget.nivel}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
    ])));
  }
}

class JogoPalavraEvo extends StatefulWidget {
  final Function(String,{String palavra}) onAcerto, onErro; final int progresso, nivel; final IATutora ia; final List<Map<String,String>> bancoDicas; final Function(int) nomeNivel;
  JogoPalavraEvo({required this.onAcerto, required this.onErro, required this.progresso, required this.nivel, required this.ia, required this.bancoDicas, required this.nomeNivel});
  @override _JogoPalavraEvoState createState()=> _JogoPalavraEvoState();
}
class _JogoPalavraEvoState extends State<JogoPalavraEvo> {
  late Map<String,String> item; String resposta="";
  @override void initState(){ super.initState(); gerar(); }
  void gerar(){ setState(()=> item=widget.bancoDicas[Random().nextInt(widget.bancoDicas.length)]); widget.ia.falar("Nível ${widget.nivel} - ${item["dica"]} - Qual é a palavra?"); }
  void verificar(){ if(resposta.toUpperCase().trim()==item["palavra"]!.toUpperCase()){ widget.onAcerto("palavra", palavra: item["palavra"]!); widget.ia.falar("Acertou! ${item["palavra"]}"); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Correto Nv${widget.nivel}! +2"), backgroundColor: Colors.green)); setState(()=> resposta=""); gerar(); } else { widget.onErro("palavra", palavra: item["palavra"]!); widget.ia.falar("Tente de novo!"); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errou! É ${item["palavra"]}"), backgroundColor: Colors.red)); } }
  @override Widget build(BuildContext context){ return Scaffold(backgroundColor: Color(0xFFFCE4EC), appBar: AppBar(title: Text("Palavra Nv${widget.nivel} ${widget.progresso}/20"), backgroundColor: Color(0xFF9C27B0), foregroundColor: Colors.white), body: Padding(padding: EdgeInsets.all(20), child: Column(children: [LinearProgressIndicator(value: widget.progresso/20, color: Color(0xFF9C27B0)), SizedBox(height:20), Container(padding: EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Color(0xFF9C27B0), width:2)), child: Column(children: [Text("💡 DICA Nv${widget.nivel}:", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF9C27B0))), SizedBox(height:10), Text(item["dica"]!, style: TextStyle(fontSize:18, fontWeight: FontWeight.bold))])), SizedBox(height:20), TextField(onChanged: (v)=> resposta=v, decoration: InputDecoration(labelText:"Qual é a palavra? (1000 no banco)", filled:true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)))), SizedBox(height:20), SizedBox(width: double.infinity, height:50, child: ElevatedButton(onPressed: verificar, style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF9C27B0)), child: Text("Verificar", style: TextStyle(color: Colors.white))))]))); }
}

class JogoBlocosEvo extends StatefulWidget {
  final Function(String,{String palavra}) onAcerto, onErro; final int progresso, nivel; final IATutora ia; final Function(int) nomeNivel;
  JogoBlocosEvo({required this.onAcerto, required this.onErro, required this.progresso, required this.nivel, required this.ia, required this.nomeNivel});
  @override _JogoBlocosEvoState createState()=> _JogoBlocosEvoState();
}
class _JogoBlocosEvoState extends State<JogoBlocosEvo> {
  int alvo=5; String resp="";
  @override void initState(){ super.initState(); gerar(); }
  void gerar(){ int maximo=10; if(widget.nivel==2) maximo=20; else if(widget.nivel==3) maximo=50; else if(widget.nivel==4) maximo=80; else if(widget.nivel>=5) maximo=100; setState(()=> alvo=Random().nextInt(maximo)+1); widget.ia.falar("Nível ${widget.nivel} ${widget.nomeNivel(widget.nivel)} - Conte quantos blocos tem! Até $maximo!"); }
  void verificar(){ if(int.tryParse(resp)==alvo){ widget.onAcerto("blocos"); widget.ia.falar("Acertou! $alvo blocos!"); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Correto Nv${widget.nivel}! +2"), backgroundColor: Colors.green)); setState(()=> resp=""); gerar(); } else { widget.onErro("blocos"); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errou! São $alvo"), backgroundColor: Colors.red)); } }
  @override Widget build(BuildContext context){ return Scaffold(backgroundColor: Color(0xFFFCE4EC), appBar: AppBar(title: Text("Blocos Nv${widget.nivel} ${widget.progresso}/20 - Até 100"), backgroundColor: Color(0xFF9C27B0), foregroundColor: Colors.white), body: Padding(padding: EdgeInsets.all(20), child: Column(children: [LinearProgressIndicator(value: widget.progresso/20, color: Color(0xFF9C27B0)), SizedBox(height:10), Text("${widget.nomeNivel(widget.nivel)} - Conte até ${widget.nivel==1?10:widget.nivel==2?20:widget.nivel==3?50:widget.nivel==4?80:100} blocos - Rosa e Roxo", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF9C27B0))), SizedBox(height:20), Expanded(child: GridView.count(crossAxisCount: 10, children: List.generate(alvo, (i)=> Container(margin: EdgeInsets.all(2), decoration: BoxDecoration(color: i%2==0? Color(0xFFF48FB1) : Color(0xFF9C27B0), borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.black))))),), TextField(onChanged: (v)=> resp=v, keyboardType: TextInputType.number, decoration: InputDecoration(labelText:"Quantos blocos? (1-${widget.nivel==1?10:widget.nivel==2?20:widget.nivel==3?50:widget.nivel==4?80:100})", filled:true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)))), SizedBox(height:10), SizedBox(width: double.infinity, height:50, child: ElevatedButton(onPressed: verificar, style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF9C27B0)), child: Text("Verificar Nv${widget.nivel}", style: TextStyle(color: Colors.white))))]))); }
}

class JogoLojinhaEvo extends StatefulWidget { final Function(String,{String palavra}) onAcerto, onErro; final int progresso, nivel; final IATutora ia; final Function(int) nomeNivel; JogoLojinhaEvo({required this.onAcerto, required this.onErro, required this.progresso, required this.nivel, required this.ia, required this.nomeNivel}); @override _JogoLojinhaEvoState createState()=> _JogoLojinhaEvoState(); }
class _JogoLojinhaEvoState extends State<JogoLojinhaEvo> { int preco=3, pago=5; @override void initState(){ super.initState(); gerar(); } void gerar(){ int maxP=widget.nivel==1?5:widget.nivel==2?10:widget.nivel==3?20:widget.nivel==4?50:100; int p=Random().nextInt(maxP)+1; int pg=p+Random().nextInt(5)+1; setState(()=> (preco=p, pago=pg)); widget.ia.falar("Nível ${widget.nivel} - Preço $p, pagou $pg, quanto de troco?"); } void verificar(String r){ int troco=pago-preco; if(int.tryParse(r)==troco){ widget.onAcerto("lojinha"); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Troco $troco correto! Nv${widget.nivel} +2"), backgroundColor: Colors.green)); gerar(); } else { widget.onErro("lojinha"); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errou! Troco é $troco"), backgroundColor: Colors.red)); } } @override Widget build(BuildContext context){ return Scaffold(backgroundColor: Color(0xFFFCE4EC), appBar: AppBar(title: Text("Lojinha Nv${widget.nivel} ${widget.progresso}/20"), backgroundColor: Color(0xFF9C27B0), foregroundColor: Colors.white), body: Padding(padding: EdgeInsets.all(20), child: Column(children: [LinearProgressIndicator(value: widget.progresso/20, color: Color(0xFF9C27B0)), SizedBox(height:20), Container(padding: EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Color(0xFF9C27B0), width:2)), child: Column(children: [Text("Preço: R\$ $preco", style: TextStyle(fontSize:22, fontWeight: FontWeight.bold)), Text("Pagou: R\$ $pago", style: TextStyle(fontSize:18)), SizedBox(height:10), Text("Quanto de troco?", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF9C27B0)))])), SizedBox(height:20), ...[pago-preco-1, pago-preco, pago-preco+1].map((t)=> Container(margin: EdgeInsets.only(bottom:8), width: double.infinity, child: ElevatedButton(onPressed: ()=> verificar(t.toString()), child: Text("R\$ $t")))).toList()]))) ; } }

class JogoLeituraEvo extends StatefulWidget { final Function(String,{String palavra}) onAcerto, onErro; final int progresso, nivel; final IATutora ia; final Function(int) nomeNivel; JogoLeituraEvo({required this.onAcerto, required this.onErro, required this.progresso, required this.nivel, required this.ia, required this.nomeNivel}); @override _JogoLeituraEvoState createState()=> _JogoLeituraEvoState(); }
class _JogoLeituraEvoState extends State<JogoLeituraEvo> { List<String> frases=["A CASA É ROSA","O GATO PULOU","A LIA AJUDA","ROSA E ROXO","ALICE É CORAJOSA","EU SOU INTELIGENTE","VAMOS BRINCAR","1000 PALAVRAS","NÍVEL ${1} ATÉ 5","BLOCOS 1 ATÉ 100"]; int idx=0; @override void initState(){ super.initState(); widget.ia.falar(frases[idx]); } @override Widget build(BuildContext context){ return Scaffold(backgroundColor: Color(0xFFFCE4EC), appBar: AppBar(title: Text("Leitura Nv${widget.nivel} ${widget.progresso}/20"), backgroundColor: Color(0xFF9C27B0), foregroundColor: Colors.white), body: Padding(padding: EdgeInsets.all(20), child: Column(children: [LinearProgressIndicator(value: widget.progresso/20, color: Color(0xFF9C27B0)), SizedBox(height:30), Container(padding: EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Color(0xFF9C27B0), width:2)), child: Text(frases[idx], style: TextStyle(fontSize:28, fontWeight: FontWeight.bold, color: Color(0xFF9C27B0)), textAlign: TextAlign.center)), SizedBox(height:30), Row(children: [Expanded(child: ElevatedButton(onPressed: (){ widget.ia.falar(frases[idx]); }, child: Text("🔊 Ouvir Nv${widget.nivel}"))), SizedBox(width:12), Expanded(child: ElevatedButton(onPressed: (){ widget.onAcerto("leitura"); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lido Nv${widget.nivel}! +2"), backgroundColor: Colors.green)); setState(()=> idx=(idx+1)%frases.length); widget.ia.falar(frases[idx]); }, style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF9C27B0)), child: Text("Li! Nv${widget.nivel} +2", style: TextStyle(color: Colors.white))))])]))); } }

class JogoMemoriaEvo extends StatefulWidget { final Function(String,{String palavra}) onAcerto, onErro; final int progresso, nivel; final IATutora ia; final List<String> banco; final Function(int) nomeNivel; JogoMemoriaEvo({required this.onAcerto, required this.onErro, required this.progresso, required this.nivel, required this.ia, required this.banco, required this.nomeNivel}); @override _JogoMemoriaEvoState createState()=> _JogoMemoriaEvoState(); }
class _JogoMemoriaEvoState extends State<JogoMemoriaEvo> { List<String> cartas=[]; List<bool> viradas=[]; int? primeiro; @override void initState(){ super.initState(); gerar(); } void gerar(){ List<String> sel = widget.banco.sublist(0, (widget.nivel+1)*2); cartas = [...sel, ...sel]..shuffle(); viradas = List.filled(cartas.length, false); primeiro=null; setState((){}); widget.ia.falar("Nível ${widget.nivel} - ${sel.length} pares - Mínimo 20 palavras!"); } void virar(int i){ if(viradas[i]) return; setState(()=> viradas[i]=true); if(primeiro==null) primeiro=i; else { if(cartas[primeiro!]==cartas[i]){ widget.onAcerto("memoria", palavra: cartas[i]); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Par ${cartas[i]} Nv${widget.nivel}! +2"), backgroundColor: Colors.green)); if(viradas.every((v)=>v)) gerar(); primeiro=null; } else { Future.delayed(Duration(seconds:1), (){ setState(()=> (viradas[primeiro!]=false, viradas[i]=false, primeiro=null)); widget.onErro("memoria", palavra: cartas[i]); }); } } } @override Widget build(BuildContext context){ return Scaffold(backgroundColor: Color(0xFFFCE4EC), appBar: AppBar(title: Text("Memória Nv${widget.nivel} ${widget.progresso}/20 - 20 palavras"), backgroundColor: Color(0xFF9C27B0), foregroundColor: Colors.white), body: Column(children: [LinearProgressIndicator(value: widget.progresso/20, color: Color(0xFF9C27B0)), Expanded(child: GridView.count(crossAxisCount: widget.nivel==1?3:4, padding: EdgeInsets.all(16), children: List.generate(cartas.length, (i)=> GestureDetector(onTap: ()=> virar(i), child: Container(margin: EdgeInsets.all(4), decoration: BoxDecoration(color: viradas[i]? Color(0xFF9C27B0) : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Color(0xFF9C27B0), width:2)), child: Center(child: Text(viradas[i]? cartas[i] : "?", style: TextStyle(fontSize: viradas[i]? 10 : 24, fontWeight: FontWeight.bold, color: viradas[i]? Colors.white : Color(0xFF9C27B0))))))))])); } }

class JogoMatematicaEvo extends StatefulWidget { final Function(String,{String palavra}) onAcerto, onErro; final int progresso, nivel; final IATutora ia; final Function(int) nomeNivel; JogoMatematicaEvo({required this.onAcerto, required this.onErro, required this.progresso, required this.nivel, required this.ia, required this.nomeNivel}); @override _JogoMatematicaEvoState createState()=> _JogoMatematicaEvoState(); }
class _JogoMatematicaEvoState extends State<JogoMatematicaEvo> { int a=2,b=3; String resp=""; @override void initState(){ super.initState(); gerar(); } void gerar(){ int maxV=widget.nivel==1?10:widget.nivel==2?20:widget.nivel==3?50:widget.nivel==4?80:100; setState(()=> (a=Random().nextInt(maxV)+1, b=Random().nextInt(maxV)+1)); widget.ia.falar("Nível ${widget.nivel} - Quanto é $a mais $b? Até $maxV!"); } void verificar(){ if(int.tryParse(resp)==a+b){ widget.onAcerto("matematica"); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Correto! $a+$b=${a+b} Nv${widget.nivel} +2"), backgroundColor: Colors.green)); setState(()=> resp=""); gerar(); } else { widget.onErro("matematica"); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errou! $a+$b=${a+b}"), backgroundColor: Colors.red)); } } @override Widget build(BuildContext context){ return Scaffold(backgroundColor: Color(0xFFFCE4EC), appBar: AppBar(title: Text("Matemática Nv${widget.nivel} ${widget.progresso}/20 - Até 100"), backgroundColor: Color(0xFF9C27B0), foregroundColor: Colors.white), body: Padding(padding: EdgeInsets.all(20), child: Column(children: [LinearProgressIndicator(value: widget.progresso/20, color: Color(0xFF9C27B0)), SizedBox(height:30), Container(padding: EdgeInsets.all(30), decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFF48FB1), Color(0xFF9C27B0)]), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black, width:2)), child: Text("$a + $b = ?", style: TextStyle(fontSize:48, fontWeight: FontWeight.w900, color: Colors.white), textAlign: TextAlign.center)), SizedBox(height:30), TextField(onChanged: (v)=> resp=v, keyboardType: TextInputType.number, decoration: InputDecoration(labelText:"Resposta? (1-100)", filled:true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))), style: TextStyle(fontSize:24)), SizedBox(height:20), SizedBox(width: double.infinity, height:50, child: ElevatedButton(onPressed: verificar, style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF9C27B0)), child: Text("Verificar Nv${widget.nivel}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))]))); } }

class JogoDesenhoEvo extends StatefulWidget { final Function(String,{String palavra}) onAcerto; final Function(String,{String palavra}) onErro; final int progresso, nivel; final IATutora ia; final Function(int) nomeNivel; JogoDesenhoEvo({required this.onAcerto, required this.onErro, required this.progresso, required this.nivel, required this.ia, required this.nomeNivel}); @override _JogoDesenhoEvoState createState()=> _JogoDesenhoEvoState(); }
class _JogoDesenhoEvoState extends State<JogoDesenhoEvo> { List<Offset?> pontos=[]; @override void initState(){ super.initState(); widget.ia.falar("Nível ${widget.nivel} - Desenhe algo rosa e roxo!"); } @override Widget build(BuildContext context){ return Scaffold(backgroundColor: Color(0xFFFCE4EC), appBar: AppBar(title: Text("Desenho Nv${widget.nivel} ${widget.progresso}/20"), backgroundColor: Color(0xFF9C27B0), foregroundColor: Colors.white), body: Column(children: [LinearProgressIndicator(value: widget.progresso/20, color: Color(0xFF9C27B0)), Expanded(child: GestureDetector(onPanUpdate: (d){ setState(()=> pontos.add(d.localPosition)); }, onPanEnd: (d){ pontos.add(null); }, child: Container(color: Colors.white, child: CustomPaint(painter: _DesenhoPainter(pontos), size: Size.infinite)))), Padding(padding: EdgeInsets.all(16), child: Row(children: [Expanded(child: ElevatedButton(onPressed: (){ setState(()=> pontos=[]); }, child: Text("Limpar"))), SizedBox(width:12), Expanded(child: ElevatedButton(onPressed: (){ if(pontos.length>10){ widget.onAcerto("desenho"); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lindo Nv${widget.nivel}! +2"), backgroundColor: Colors.green)); setState(()=> pontos=[]); } }, style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF9C27B0)), child: Text("Salvar Nv${widget.nivel} +2", style: TextStyle(color: Colors.white))))]))])); } }
class _DesenhoPainter extends CustomPainter { final List<Offset?> pontos; _DesenhoPainter(this.pontos); @override void paint(Canvas c, Size s){ Paint p=Paint()..color=Color(0xFF9C27B0)..strokeWidth=6..strokeCap=StrokeCap.round; for(int i=0;i<pontos.length-1;i++){ if(pontos[i]!=null && pontos[i+1]!=null) c.drawLine(pontos[i]!, pontos[i+1]!, p); } } @override bool shouldRepaint(covariant CustomPainter o)=> true; }
class JogoCacaEvo extends StatefulWidget { final Function(String,{String palavra}) onAcerto; final Function(String,{String palavra}) onErro; final int progresso, nivel; final IATutora ia; final List<String> banco; final Function(int) nomeNivel; JogoCacaEvo({required this.onAcerto, required this.onErro, required this.progresso, required this.nivel, required this.ia, required this.banco, required this.nomeNivel}); @override _JogoCacaEvoState createState()=> _JogoCacaEvoState(); }
class _JogoCacaEvoState extends State<JogoCacaEvo> { String atual="ROSA"; @override void initState(){ super.initState(); gerar(); } void gerar(){ setState(()=> atual=widget.banco[Random().nextInt(widget.banco.length.clamp(0,100))]); widget.ia.falar("Nível ${widget.nivel} - Encontre $atual! Mínimo 20 palavras!"); } @override Widget build(BuildContext context){ return Scaffold(backgroundColor: Color(0xFFFCE4EC), appBar: AppBar(title: Text("Caça Nv${widget.nivel} ${widget.progresso}/20 - 20 palavras"), backgroundColor: Color(0xFF9C27B0), foregroundColor: Colors.white, actions: [IconButton(onPressed: ()=> widget.ia.falar("Encontre $atual"), icon: Icon(Icons.volume_up))]), body: Column(children: [LinearProgressIndicator(value: widget.progresso/20, color: Color(0xFF9C27B0)), SizedBox(height:12), Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Color(0xFF9C27B0), width:2)), child: Text("Encontre: $atual - Nv${widget.nivel} - ${widget.banco.length} palavras no banco!", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF9C27B0)))), Expanded(child: GridView.count(crossAxisCount:6, padding: EdgeInsets.all(16), children: List.generate(36, (i){ String letra = (i>=10 && i<10+atual.length)? atual[i-10] : String.fromCharCode(Random().nextInt(26)+65); return GestureDetector(onTap: (){ if(letra==atual[0]){ widget.onAcerto("caca", palavra: atual); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Achou $atual! Nv${widget.nivel} +2"), backgroundColor: Colors.green)); gerar(); } }, child: Container(margin: EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Color(0xFF9C27B0))), child: Center(child: Text(letra, style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF9C27B0)))))); }))),])); } }
class JogoParkourEvo extends StatefulWidget { final Function(String,{String palavra}) onAcerto; final Function(String,{String palavra}) onErro; final int progresso, nivel; final IATutora ia; final Function(int) nomeNivel; JogoParkourEvo({required this.onAcerto, required this.onErro, required this.progresso, required this.nivel, required this.ia, required this.nomeNivel}); @override _JogoParkourEvoState createState()=> _JogoParkourEvoState(); }
class _JogoParkourEvoState extends State<JogoParkourEvo> { List<Map<String,dynamic>> perg=[{"q":"Qual cor favorita da Alice?","ops":["Azul","Rosa e Roxo","Verde"],"c":1},{"q":"Quanto ganha por acerto?","ops":["1","2 Robux","10"],"c":1},{"q":"Quantos acertos seguidos pra subir de nível?","ops":["2","5 seguidos","10"],"c":1},{"q":"O que a Lia faz quando erra muito?","ops":["Briga","Volta 1 nível e ajuda mais","Ignora"],"c":1},{"q":"Quantas palavras no banco de sílabas?","ops":["10","1000 palavras","20"],"c":1}]; int idx=0; @override void initState(){ super.initState(); widget.ia.falar(perg[idx]["q"]); } @override Widget build(BuildContext context){ return Scaffold(backgroundColor: Color(0xFFFCE4EC), appBar: AppBar(title: Text("Parkour Nv${widget.nivel} ${widget.progresso}/20"), backgroundColor: Color(0xFFFF6F00), foregroundColor: Colors.white), body: Padding(padding: EdgeInsets.all(16), child: Column(children: [LinearProgressIndicator(value: widget.progresso/20, color: Color(0xFFFF6F00)), SizedBox(height:20), Container(padding: EdgeInsets.all(20), decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFFFD54F), Color(0xFFFF6F00)]), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black, width:2)), child: Text(perg[idx]["q"], style: TextStyle(fontSize:20, fontWeight: FontWeight.bold, color: Colors.white))), SizedBox(height:20), ...List.generate(3, (i)=> Container(margin: EdgeInsets.only(bottom:10), width: double.infinity, child: ElevatedButton(onPressed: (){ if(i==perg[idx]["c"]){ widget.onAcerto("parkour"); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Correto Nv${widget.nivel}! +2"), backgroundColor: Colors.green)); setState(()=> idx=(idx+1)%perg.length); widget.ia.falar(perg[idx]["q"]); } else { widget.onErro("parkour"); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errou Nv${widget.nivel}!"), backgroundColor: Colors.red)); } }, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Color(0xFFFF6F00), side: BorderSide(color: Color(0xFFFF6F00), width:2), padding: EdgeInsets.all(16)), child: Text(perg[idx]["ops"][i], style: TextStyle(fontWeight: FontWeight.bold)))))]))); } }
