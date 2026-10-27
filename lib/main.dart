import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

void main() => runApp(AppAlice());

class AppAlice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mundo da Alice',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: TelaMundos(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TelaMundos extends StatefulWidget {
  @override
  _TelaMundosState createState() => _TelaMundosState();
}

class _TelaMundosState extends State<TelaMundos> {
  bool mundo1Ok = false;
  bool mundo2Ok = false;
  bool mundo3Ok = false;
  bool mundo4Ok = false;
  int segundosRoblox = 40 * 60;
  Timer? timer;
  bool robloxLiberado = false;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  carregar() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      mundo1Ok = prefs.getBool('m1') ?? false;
      mundo2Ok = prefs.getBool('m2') ?? false;
      mundo3Ok = prefs.getBool('m3') ?? false;
      mundo4Ok = prefs.getBool('m4') ?? false;
      robloxLiberado = prefs.getBool('roblox') ?? false;
    });
  }

  salvar() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setBool('m1', mundo1Ok);
    await prefs.setBool('m2', mundo2Ok);
    await prefs.setBool('m3', mundo3Ok);
    await prefs.setBool('m4', mundo4Ok);
    await prefs.setBool('roblox', robloxLiberado);
  }

  void completarMundo(int num) {
    setState(() {
      if (num == 1) mundo1Ok = true;
      if (num == 2) mundo2Ok = true;
      if (num == 3) mundo3Ok = true;
      if (num == 4) {
        mundo4Ok = true;
        robloxLiberado = true;
        iniciarTimer();
      }
    });
    salvar();
  }

  void iniciarTimer() {
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      setState(() {
        if (segundosRoblox > 0) {
          segundosRoblox--;
        } else {
          robloxLiberado = false;
          timer?.cancel();
          salvar();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool todosOk = mundo1Ok && mundo2Ok && mundo3Ok && mundo4Ok;
    String tempo = "${(segundosRoblox ~/ 60).toString().padLeft(2,'0')}:${(segundosRoblox % 60).toString().padLeft(2,'0')}";
    
    return Scaffold(
      backgroundColor: Color(0xFFF8F5FF),
      appBar: AppBar(
        title: Text('Mundo da Alice - So Touch'),
        backgroundColor: Color(0xFF8B7ABF),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Card(child: ListTile(title: Text('Mundo 1 - Chegada'), trailing: mundo1Ok ? Icon(Icons.check, color: Colors.green) : ElevatedButton(onPressed: ()=>completarMundo(1), child: Text('FIZ! Foto')))),
          Card(child: ListTile(title: Text('Mundo 2 - Higiene e Agua'), enabled: mundo1Ok, trailing: !mundo1Ok ? Icon(Icons.lock) : mundo2Ok ? Icon(Icons.check, color: Colors.green) : ElevatedButton(onPressed: ()=>completarMundo(2), child: Text('FIZ!')))),
          Card(child: ListTile(title: Text('Mundo 3 - Leitura'), enabled: mundo1Ok && mundo2Ok, trailing: !(mundo1Ok && mundo2Ok) ? Icon(Icons.lock) : mundo3Ok ? Icon(Icons.check, color: Colors.green) : ElevatedButton(onPressed: ()=>completarMundo(3), child: Text('FIZ!')))),
          Card(child: ListTile(title: Text('Mundo 4 - Numeros'), enabled: mundo1Ok && mundo2Ok && mundo3Ok, trailing: !(mundo1Ok && mundo2Ok && mundo3Ok) ? Icon(Icons.lock) : mundo4Ok ? Icon(Icons.check, color: Colors.green) : ElevatedButton(onPressed: ()=>completarMundo(4), child: Text('FIZ!')))),
          SizedBox(height: 20),
          if (!todosOk)
            Card(color: Colors.orange[100], child: Padding(padding: EdgeInsets.all(16), child: Text('Ops! Termine sua aventura primeiro para liberar seu tempo de Roblox. Aqui pode errar!', style: TextStyle(fontSize: 16)))),
          if (todosOk)
            Card(
              color: Colors.yellow[100],
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Roblox Liberado!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Text('Recomendado: 40 min ate 18:30 para proteger o sono', style: TextStyle(fontSize: 12)),
                    SizedBox(height: 10),
                    Text(tempo, style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                    Text(robloxLiberado ? 'Pode jogar!' : 'Tempo acabou! Hora do banho e historia'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
