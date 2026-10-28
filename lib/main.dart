
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
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFFFF8E7),
        fontFamily: 'Roboto',
        brightness: Brightness.light,
      ),
      home: TelaPrincipal(),
    );
  }
}

class TelaPrincipal extends StatefulWidget {
  @override
  _TelaPrincipalState createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  bool modoCrianca = true;
  int robux = 0;
  int estrelas = 0;
  List<Map<String,dynamic>> mundos = [];
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    SharedPreferences p = await SharedPreferences.getInstance();
    setState(() {
      robux = p.getInt("robux_fases") ?? 6;
      estrelas = p.getInt("estrelas_fases") ?? 0;
      String? jsonStr = p.getString("mundos_fases_v96");
      if(jsonStr != null){
        mundos = List<Map<String,dynamic>>.from(jsonDecode(jsonStr).map((e)=> Map<String,dynamic>.from(e)));
      } else {
        mundos = [
          {
            "id":1,
            "titulo":"Mundo 1 - Chegada da Escola",
            "icone":"🏠",
            "desbloqueado":true,
            "tarefas":[
              {"titulo":"Trocar roupa, lavar mãos e rosto","horario":"16:00 - 16:30","desc":"Cheguei! Roupinha confortável, mãos e rostinho limpos.","feita":false,"hora":"","foto":"","robux":3},
              {"titulo":"Lanche + Descanso livre","horario":"16:30 - 16:50","desc":"Comer com calma e brincar um pouquinho pra relaxar.","feita":false,"hora":"","foto":"","robux":3},
            ]
          },
          {
            "id":2,
            "titulo":"Mundo 2 - Higiene",
            "icone":"💧",
            "desbloqueado":false,
            "tarefas":[
              {"titulo":"Escovar os dentes","horario":"16:50 - 17:00","desc":"Dentinhos limpinhos e cheirosos!","feita":false,"hora":"","foto":"","robux":3},
              {"titulo":"Lavar o rosto","horario":"17:00 - 17:10","desc":"Rostinho de princesa limpo!","feita":false,"hora":"","foto":"","robux":3},
            ]
          },
          {
            "id":3,
            "titulo":"Mundo 3 - Dever de Casa",
            "icone":"📚",
            "desbloqueado":false,
            "tarefas":[
              {"titulo":"Fazer o dever","horario":"17:10 - 18:00","desc":"Caprichar no dever com calma e letra bonita.","feita":false,"hora":"","foto":"","robux":5},
            ]
          },
          {
            "id":4,
            "titulo":"Mundo 4 - Brincar e Jogos",
            "icone":"🎮",
            "desbloqueado":false,
            "tarefas":[
              {"titulo":"Jogar os 4 jogos da Alice","horario":"18:00 - 18:40","desc":"Memória, Palavra, Blocos e Lojinha - 20 cada = 80 total","feita":false,"hora":"","foto":"","robux":10},
            ]
          },
          {
            "id":5,
            "titulo":"Mundo 5 - Jantar",
            "icone":"🍽️",
            "desbloqueado":false,
            "tarefas":[
              {"titulo":"Jantar e ajudar a guardar","horario":"18:40 - 19:10","desc":"Comer tudinho e ajudar mamãe!","feita":false,"hora":"","foto":"","robux":3},
            ]
          },
          {
            "id":6,
            "titulo":"Mundo Final - Roblox",
            "icone":"🌈",
            "desbloqueado":false,
            "tarefas":[
              {"titulo":"Roblox liberado!","horario":"19:10 - 19:30","desc":"Você conseguiu! Roblox por 20 min","feita":false,"hora":"","foto":"","robux":0},
            ]
          },
        ];
      }
    });
  }

  Future<void> salvar() async {
    SharedPreferences p = await SharedPreferences.getInstance();
    await p.setInt("robux_fases", robux);
    await p.setInt("estrelas_fases", estrelas);
    await p.setString("mundos_fases_v96", jsonEncode(mundos));
  }

  int get totalTarefas => mundos.fold(0, (a,m)=> a + (m["tarefas"] as List).length);
  int get feitas => mundos.fold(0, (a,m)=> a + ((m["tarefas"] as List).where((t)=> t["feita"]==true).length as int));
  double get progressoGeral => totalTarefas==0 ? 0 : feitas/totalTarefas;

  Future<void> tirarFoto(int mundoIdx, int tarefaIdx) async {
    try{
      final XFile? file = await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
      XFile? finalFile = file;
      if(finalFile==null){
        finalFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
      }
      if(finalFile==null) return;
      final bytes = await finalFile.readAsBytes();
      final b64 = base64Encode(bytes);
      setState((){
        mundos[mundoIdx]["tarefas"][tarefaIdx]["feita"]=true;
        mundos[mundoIdx]["tarefas"][tarefaIdx]["hora"]= TimeOfDay.now().format(context);
        mundos[mundoIdx]["tarefas"][tarefaIdx]["foto"]=b64;
        robux += mundos[mundoIdx]["tarefas"][tarefaIdx]["robux"] as int;
        estrelas += 1;
        // Desbloqueia proximo mundo se terminou esse
        var tarefasMundo = mundos[mundoIdx]["tarefas"] as List;
        if(tarefasMundo.every((t)=> t["feita"]==true)){
          if(mundoIdx+1 < mundos.length){
            mundos[mundoIdx+1]["desbloqueado"]=true;
          }
        }
      });
      await salvar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Foto salva! +${mundos[mundoIdx]["tarefas"][tarefaIdx]["robux"]} Robux!"), backgroundColor: Colors.green));
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e")));
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Color(0xFFFFF8E7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              // HEADER - IGUAL FOTO
              Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black, width: 2), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 0, offset: Offset(0,4))]),
                child: Column(
                  children: [
                    Row(children: [
                      Container(width: 50, height: 50, decoration: BoxDecoration(color: Color(0xFFFFE082), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black, width: 2)), child: Center(child: Text("📦", style: TextStyle(fontSize: 26)))),
                      SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text("MUNDO DA ALICE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5)),
                        Text("Aventura por Fases", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.purple)),
                        Text("9 anos • Oi Alice! Você é corajosa 💜", style: TextStyle(fontSize: 11, color: Colors.black54)),
                      ])),
                      Column(children: [
                        Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)), child: Row(children: [Icon(Icons.diamond, size: 14, color: Colors.white), SizedBox(width: 4), Text("$robux ROBUX", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))])),
                        SizedBox(height: 4),
                        Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Color(0xFFFFF9C4), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black, width: 1.5)), child: Text("$estrelas/12 ⭐", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                      ]),
                    ]),
                    SizedBox(height: 12),
                    // PROGRESSO GERAL
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Color(0xFFFFF8E7), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.black, width: 1.5)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Text("PROGRESSO GERAL", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                          Spacer(),
                          Container(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Color(0xFFFFD54F), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black)), child: Text("${(progressoGeral*100).toInt()}%", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                        ]),
                        SizedBox(height: 8),
                        ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progressoGeral, minHeight: 10, backgroundColor: Colors.white, color: Colors.black)),
                        SizedBox(height: 10),
                        Wrap(spacing: 6, runSpacing: 6, children: mundos.map((m){
                          bool desbloq = m["desbloqueado"];
                          bool feito = (m["tarefas"] as List).every((t)=> t["feita"]==true);
                          return Container(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: feito? Color(0xFFA5D6A7) : desbloq? Colors.white : Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black, width: 1.2)), child: Row(mainAxisSize: MainAxisSize.min, children: [Text(desbloq? (feito? "✅" : "🔓") : "🔒", style: TextStyle(fontSize: 10)), SizedBox(width: 3), Text("Mundo ${m["id"]}", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: desbloq? Colors.black : Colors.black38))]));
                        }).toList()),
                        SizedBox(height: 8),
                        Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.bedtime, size: 14), SizedBox(width: 4), Text("Dorme 19:30 • Roblox até 19:30 • Bloqueio de recompensa ON", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))])),
                      ]),
                    ),
                    SizedBox(height: 12),
                    // MODO CRIANCA / FAMILIA
                    Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(30)),
                      child: Row(children: [
                        Expanded(child: GestureDetector(onTap: ()=> setState(()=> modoCrianca=true), child: Container(padding: EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: modoCrianca? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(30)), child: Center(child: Text("Modo Criança 👧", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: modoCrianca? Colors.black : Colors.white)))))),
                        Expanded(child: GestureDetector(onTap: ()=> setState(()=> modoCrianca=false), child: Container(padding: EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: !modoCrianca? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(30)), child: Center(child: Text("Modo Família 👨‍👩‍👧", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: !modoCrianca? Colors.black : Colors.white)))))),
                      ]),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              // DICA WHATSAPP
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.black, width: 1.5)),
                child: Row(children: [
                  Text("⚠️", style: TextStyle(fontSize: 20)),
                  SizedBox(width: 8),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text("Dica pra família: se abriu no WhatsApp", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    Text("Toque nos 3 pontinhos ⋮ e em Abrir no navegador. Funciona melhor lá!", style: TextStyle(fontSize: 10, color: Colors.black54)),
                  ])),
                  Icon(Icons.close, size: 16),
                ]),
              ),
              SizedBox(height: 10),
              // INFO PODE ERRAR
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.black, width: 1.5)),
                child: Row(children: [
                  Container(width: 32, height: 32, decoration: BoxDecoration(color: Color(0xFFFFF9C4), shape: BoxShape.circle, border: Border.all(color: Colors.black)), child: Center(child: Text("💛", style: TextStyle(fontSize: 16)))),
                  SizedBox(width: 8),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text("Aqui pode errar. Toda tentativa vale estrela!", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    Text("Mundos 1-4 primeiro, depois Roblox 40 min até 18:30. Dorme 19:30!", style: TextStyle(fontSize: 9, color: Colors.black54)),
                  ])),
                ]),
              ),
              SizedBox(height: 12),
              // MUNDOS
              ...mundos.asMap().entries.map((entry){
                int idx = entry.key;
                var mundo = entry.value;
                bool desbloq = mundo["desbloqueado"];
                var tarefas = mundo["tarefas"] as List;
                int feitasMundo = tarefas.where((t)=> t["feita"]==true).length;
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black, width: 2)),
                  child: Column(
                    children: [
                      // Header Mundo
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(color: desbloq? Color(0xFFFFE082) : Color(0xFFE0E0E0), borderRadius: BorderRadius.vertical(top: Radius.circular(18)), border: Border(bottom: BorderSide(color: Colors.black, width: 2))),
                        child: Row(children: [
                          Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black, width: 2)), child: Center(child: Text(mundo["icone"], style: TextStyle(fontSize: 20)))),
                          SizedBox(width: 8),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(mundo["titulo"], style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                            Container(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)), child: Text("$feitasMundo/${tarefas.length}", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                          ])),
                          Icon(desbloq? Icons.star : Icons.lock, color: desbloq? Colors.amber : Colors.black26),
                        ]),
                      ),
                      if(!desbloq)
                        Container(
                          padding: EdgeInsets.all(20),
                          child: Column(children: [
                            Icon(Icons.lock, size: 40, color: Colors.black26),
                            SizedBox(height: 8),
                            Text("Bloqueado", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text("Termine o mundo anterior pra liberar", style: TextStyle(fontSize: 11, color: Colors.black54)),
                          ]),
                        )
                      else
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: tarefas.asMap().entries.map((tEntry){
                              int tIdx = tEntry.key;
                              var t = tEntry.value;
                              bool feita = t["feita"];
                              return Container(
                                margin: EdgeInsets.only(bottom: 10),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(color: feita? Color(0xFFE8F5E9) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black, width: 1.5)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Container(width: 36, height: 36, decoration: BoxDecoration(color: feita? Colors.green : Color(0xFFFFCCBC), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black, width: 1.5)), child: Center(child: Text(feita? "✅" : t["titulo"][0], style: TextStyle(fontSize: 16)))),
                                      SizedBox(width: 8),
                                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Text(t["horario"], style: TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.bold)),
                                        Text(t["titulo"], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                                        Text(t["desc"], style: TextStyle(fontSize: 11, color: Colors.black54)),
                                      ])),
                                    ]),
                                    SizedBox(height: 8),
                                    Row(children: [
                                      Expanded(
                                        child: SizedBox(
                                          height: 40,
                                          child: ElevatedButton(
                                            onPressed: feita? null : ()=> tirarFoto(idx, tIdx),
                                            style: ElevatedButton.styleFrom(backgroundColor: feita? Colors.green : Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                                            child: Text(feita? "Feito às ${t["hora"]} ✅" : "📸 Tirei foto +${t["robux"]} 💎", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black, width: 1.5)), child: Icon(Icons.volume_up, size: 18)),
                                    ]),
                                    if(feita && t["foto"]!="")
                                      Padding(padding: EdgeInsets.only(top: 8), child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.memory(base64Decode(t["foto"]), height: 120, width: double.infinity, fit: BoxFit.cover))),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
              // FOOTER ROBUX
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black, width: 2)),
                child: Row(children: [
                  Container(width: 36, height: 36, decoration: BoxDecoration(color: Color(0xFFFFD54F), shape: BoxShape.circle, border: Border.all(color: Colors.black, width: 2)), child: Center(child: Text("💎", style: TextStyle(fontSize: 18)))),
                  SizedBox(width: 8),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("$robux Robux da Coragem", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)), Text("$estrelas% • MT+/6 • 40:00 • 🎮", style: TextStyle(fontSize: 11, color: Colors.black54))])),
                  Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black)), child: Row(children: [Icon(Icons.lock, size: 14), SizedBox(width: 4), Text("${mundos.length} mundos", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))])),
                ]),
              ),
              SizedBox(height: 20),
              if(modoCrianca==false)
                SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () async { SharedPreferences p = await SharedPreferences.getInstance(); await p.clear(); setState((){ carregar(); }); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: Text("RESETAR DIA - Família", style: TextStyle(fontWeight: FontWeight.bold)))),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
