
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() => runApp(const AliceApp());

// CHAVE VEM DO SECRET - NÃO COLA DIRETO
const String GEMINI_API_KEY = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

class AliceApp extends StatelessWidget {
  const AliceApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Alice Roblox 1040 IA',
      theme: ThemeData(useMaterial3: true, fontFamily: 'Roboto', scaffoldBackgroundColor: const Color(0xFFDDD0FF)),
      home: const RobloxHome(),
    );
  }
}

class Atividade {
  final String id; final String pergunta; final List<String> opcoes; final String correta; final String dica;
  Atividade(this.id, this.pergunta, this.opcoes, this.correta, this.dica);
}
class MensagemIA { final String texto; final bool daAlice; final String? imagemPath; MensagemIA(this.texto, this.daAlice, {this.imagemPath}); }

class RobloxHome extends StatefulWidget {
  const RobloxHome({super.key});
  @override
  State<RobloxHome> createState() => _RobloxHomeState();
}

class _RobloxHomeState extends State<RobloxHome> {
  // Cores Roblox dos prints
  final roxoEscuro = const Color(0xFF2B2452);
  final rosa = const Color(0xFFFF4D8D);
  final roxo = const Color(0xFF8B5CF6);
  final roxoClaro = const Color(0xFFE9D6FF);
  final rosaClaro = const Color(0xFFFFD6E8);

  String abaTopo = 'JOGOS'; // JOGOS, LEITURA, HISTORIAS
  String licaoAtual = 'Português';
  String tela = 'jogos'; // jogos, ia
  final picker = ImagePicker();
  final perguntaCtrl = TextEditingController();
  List<MensagemIA> chatIA = [];
  bool carregandoIA = false;

  Map<String, Set<String>> feitas = {'Português': {}, 'Matemática': {}, 'Leitura': {}, 'Escrita': {}};
  Map<String, int> nivelPorLicao = {'Português': 1, 'Matemática': 1, 'Leitura': 1, 'Escrita': 1};

  // BANCO 1040 ÚNICOS - 260 por matéria = 13 níveis x 20
  late final Map<String, Map<int, List<Atividade>>> banco = _gerarBanco();

  Map<String, Map<int, List<Atividade>>> _gerarBanco() {
    Map<String, Map<int, List<Atividade>>> b = {
      'Português': {}, 'Matemática': {}, 'Leitura': {}, 'Escrita': {}
    };
    for (var k in b.keys) {
      for (int nv=1; nv<=13; nv++) b[k]![nv] = [];
    }
    List silabas = [["BO","LA","BOLA"],["CA","SA","CASA"],["SO","L","SOL"],["LU","A","LUA"],["GA","TO","GATO"],["CA","RRO","CARRO"],["BO","NE","BONECA"],["PE","IXE","PEIXE"],["CA","JU","CAJU"],["ME","SA","MESA"],["PA","TO","PATO"],["RA","TO","RATO"]];
    int id=1;
    for (int nv=1; nv<=13; nv++) {
      for (int i=0; i<20; i++) {
        var s = silabas[(id+i)%silabas.length];
        String pergunta = i%3==0 ? "Junte: ${s[0]} + ${s[1]} = ?" : i%3==1 ? "Qual começa com ${s[0]}?" : "Escreva ${s[2]}";
        b['Português']![nv]!.add(Atividade('P$nv-$id', pergunta, [s[2], s[2].substring(0,s[2].length-1)+"A", "BOLA"], s[2], "${s[0]}+${s[1]}"));
        b['Matemática']![nv]!.add(Atividade('M$nv-$id', "${(id%10)+1} + ${(i%5)+1} = ?", ["${(id%10)+1 + (i%5)+1}", "${(id%10)+2 + (i%5)+1}", "${(id%10)+1 + (i%5)+2}"], "${(id%10)+1 + (i%5)+1}", "Conta com maçãs 🍎"));
        String frase = ["O SOL brilha","A CASA é bonita","A BOLA pula","O GATO mia","A LUA à noite"][i%5];
        b['Leitura']![nv]!.add(Atividade('L$nv-$id', "Leia: $frase", [frase, "O SOL é bonito", "A BOLA é azul"], frase, frase));
        b['Escrita']![nv]!.add(Atividade('E$nv-$id', "Escreva ${s[2]}", [s[2], "Eu amo ${s[2]}", "A ${s[2]} é bonita"], s[2], "Escreve ${s[2]}"));
        id++;
      }
    }
    return b;
  }

  Atividade? get proxima {
    var lista = banco[licaoAtual]?[nivelPorLicao[licaoAtual]] ?? [];
    var f = feitas[licaoAtual] ?? {};
    for (var a in lista) if (!f.contains(a.id)) return a;
    return null;
  }
  int get prog => (feitas[licaoAtual] ?? {}).intersection((banco[licaoAtual]?[nivelPorLicao[licaoAtual]] ?? []).map((e) => e.id).toSet()).length;
  int get totalGeral => feitas.values.fold(0, (s, set) => s + set.length);

  void responder(Atividade atv, String escolha) async {
    if (escolha == atv.correta) {
      setState(() => feitas[licaoAtual]!.add(atv.id));
      final p = await SharedPreferences.getInstance();
      await p.setStringList('feitas_$licaoAtual', feitas[licaoAtual]!.toList());
      if (prog >= 20) {
        setState(() => nivelPorLicao[licaoAtual] = (nivelPorLicao[licaoAtual] ?? 1) + 1);
        await p.setInt('nivel_$licaoAtual', nivelPorLicao[licaoAtual]!);
        if (mounted) showDialog(context: context, builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: roxoEscuro, width: 4)),
          title: Text('🎉 Nível ${nivelPorLicao[licaoAtual]! - 1} completo!', style: TextStyle(color: roxoEscuro, fontWeight: FontWeight.w900)),
          content: Text('20 sem repetir! Nível ${nivelPorLicao[licaoAtual]} liberado! $totalGeral/1040'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Continuar', style: TextStyle(color: rosa, fontWeight: FontWeight.bold)))]
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Quase! Dica: ${atv.dica}'), backgroundColor: roxo));
    }
    setState(() {});
  }

  Future<void> explicarComGemini({String? perguntaTexto, String? imagemPath}) async {
    if (GEMINI_API_KEY.isEmpty) {
      setState(() => chatIA.add(MensagemIA("⚠️ Chave não configurada no Secret.\nVai em GitHub > Settings > Secrets > Actions > GEMINI_API_KEY\n\nVou explicar fofo por enquanto:\n1️⃣ Contamos 2 maçãs 🍎🍎\n2️⃣ Mais 3 maçãs 🍎🍎🍎\n3️⃣ Juntamos tudo: 2+3=5 ✅", false)));
      return;
    }
    setState(() => carregandoIA = true);
    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: GEMINI_API_KEY);
      String prompt = "Você é a IA Professora da Alice, 7 anos, estilo Roblox rosa/roxo do print. Explique o dever da foto passo a passo com maçãs 🍎, sem dar resposta direta de cara, 3 passos, curta, com emoji, final pergunta se quer tentar outra. Total ${totalGeral}/1040.";
      List<Content> conteudo;
      if (imagemPath != null) {
        final bytes = await File(imagemPath).readAsBytes();
        conteudo = [Content.multi([TextPart("$prompt Pergunta: ${perguntaTexto ?? 'Explique'}"), DataPart('image/jpeg', bytes)])];
      } else {
        conteudo = [Content.text("$prompt Pergunta: ${perguntaTexto ?? 'Ajuda dever'}")];
      }
      final resp = await model.generateContent(conteudo);
      setState(() => chatIA.add(MensagemIA(resp.text ?? "Não vi direito, tira outra foto! 📸", false)));
    } catch (e) {
      setState(() => chatIA.add(MensagemIA("Erro IA: $e - Verifica a chave no Secret!", false)));
    } finally {
      setState(() => carregandoIA = false);
    }
  }

  Future<void> tirarFotoDever() async {
    final XFile? img = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (img != null) {
      setState(() => chatIA.add(MensagemIA('Foto do meu dever 📸', true, imagemPath: img.path)));
      await explicarComGemini(imagemPath: img.path, perguntaTexto: perguntaCtrl.text.isNotEmpty ? perguntaCtrl.text : null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6C6FF),
      body: SafeArea(child: tela == 'ia' ? _buildIA() : _buildJogos()),
      bottomNavigationBar: tela == 'ia' ? null : _bottomNav(),
    );
  }

  // BLOCO ESTILO ROBLOX - igual print 1
  Widget bloco({required Widget child, required Color cor, bool selected=false, double radius=16}) {
    return Container(
      decoration: BoxDecoration(
        color: cor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: roxoEscuro, width: 4),
        boxShadow: [BoxShadow(color: roxoEscuro, offset: const Offset(4, 4))],
      ),
      child: child,
    );
  }

  Widget _buildJogos() {
    var atv = proxima;
    return SingleChildScrollView(
      child: Column(
        children: [
          // HEADER ALICE igual print 1
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: roxoEscuro, borderRadius: BorderRadius.circular(20), border: Border.all(color: roxoEscuro, width: 4)),
            child: Row(children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: rosa, borderRadius: BorderRadius.circular(8), border: Border.all(color: roxoEscuro, width: 2)), child: const Icon(Icons.view_module, color: Colors.white)),
              const SizedBox(width: 8),
              const Text('ALICE', style: TextStyle(color: Color(0xFFFF7AC1), fontWeight: FontWeight.w900, fontSize: 28, letterSpacing: 1)),
              const Spacer(),
              Icon(Icons.notifications, color: Color(0xFFFF7AC1)), const SizedBox(width: 8),
              Icon(Icons.star, color: Color(0xFFFF7AC1)), const SizedBox(width: 8),
              CircleAvatar(backgroundColor: rosaClaro, child: Icon(Icons.person, color: rosa)),
            ]),
          ),
          // ABAS JOGOS LEITURA HISTORIAS igual print 1
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(children: [
              Expanded(child: _topoTab('JOGOS', Icons.videogame_asset, true)),
              const SizedBox(width: 8),
              Expanded(child: _topoTab('LEITURA', Icons.menu_book, false)),
              const SizedBox(width: 8),
              Expanded(child: _topoTab('HISTORIAS', Icons.article, false)),
            ]),
          ),
          const SizedBox(height: 12),
          // CONTEUDO BRANCO COM BLOCOS
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFEDE0FF), borderRadius: BorderRadius.circular(20), border: Border.all(color: roxoEscuro, width: 4)),
            child: Column(children: [
              const Text('Jogando e Aprendendo! ✨', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Color(0xFF2B2452))),
              const Text('Aprenda sílabas e leia histórias de forma divertida!', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2B2452))),
              const SizedBox(height: 8),
              Text('Jogos de Sílabas', style: TextStyle(color: rosa, fontWeight: FontWeight.w900, fontSize: 18)),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _cardSiliba('BOLA', 'BO • LA', '3/4', '75%', Colors.blue)),
                const SizedBox(width: 10),
                Expanded(child: _cardSiliba('CASA', 'CA • SA', '2/4', '50%', const Color(0xFFFF9AA2))),
              ]),
              const SizedBox(height: 16),
              Text('Histórias para Ler 📖', style: TextStyle(color: rosa, fontWeight: FontWeight.w900, fontSize: 16)),
              const SizedBox(height: 8),
              bloco(cor: Colors.white, child: Padding(padding: const EdgeInsets.all(10), child: Row(children: [
                Container(width: 80, height: 60, decoration: BoxDecoration(color: rosaClaro, borderRadius: BorderRadius.circular(10), border: Border.all(color: roxoEscuro, width: 3)), child: const Icon(Icons.auto_stories, color: Colors.purple)),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('A CASA DO GATO', style: TextStyle(fontWeight: FontWeight.w900, color: roxoEscuro)),
                  Text('Leitura simples • 5 páginas • Nível Iniciante', style: TextStyle(fontSize: 10, color: roxoEscuro)),
                  const SizedBox(height: 4),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: rosa, borderRadius: BorderRadius.circular(8)), child: const Text('Nova História!', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                ])),
              ]))),
            ]),
          ),
          const SizedBox(height: 12),
          // PARTE DE NIVEL igual print 2
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: roxoEscuro, borderRadius: BorderRadius.circular(20), border: Border.all(color: roxoEscuro, width: 4)),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Alice - $licaoAtual\nNível ${nivelPorLicao[licaoAtual]}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFF4B3F81), borderRadius: BorderRadius.circular(20)), child: Text('$prog/20 | Total $totalGeral ⭐', style: TextStyle(color: roxoClaro, fontWeight: FontWeight.bold))),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                _materiaTab('Português', Icons.book, 'Português'),
                _materiaTab('Matemática', Icons.calculate, 'Matemática'),
                _materiaTab('Leitura', Icons.menu_book, 'Leitura'),
                _materiaTab('Escrita', Icons.edit, 'Escrita'),
              ]),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: rosaClaro, borderRadius: BorderRadius.circular(16), border: Border.all(color: roxoEscuro, width: 3)),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Nível ${nivelPorLicao[licaoAtual]} - $licaoAtual - Sem repetir', style: TextStyle(color: roxoEscuro, fontWeight: FontWeight.w900, fontSize: 12)),
                    const SizedBox(height: 4),
                    Row(children: [
                      Text('$prog/20', style: TextStyle(color: rosa, fontWeight: FontWeight.w900, fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: prog/20, minHeight: 20, backgroundColor: Colors.white, color: rosa))),
                    ]),
                  ])),
                  const SizedBox(width: 10),
                  Text('${20-prog} faltam para\nsubir de nível', style: TextStyle(color: rosa, fontWeight: FontWeight.w900, fontSize: 12), textAlign: TextAlign.right),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          // PERGUNTA igual print 2
          if (atv != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: rosa, width: 5), boxShadow: [BoxShadow(color: roxoEscuro, offset: const Offset(4,4))]),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.view_module, color: roxo), const SizedBox(width: 4), const Text('✨', style: TextStyle(fontSize: 20))]),
                const SizedBox(height: 8),
                Text(atv.pergunta, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26, color: roxoEscuro), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Row(children: atv.opcoes.map((op) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: GestureDetector(
                  onTap: () => responder(atv, op),
                  child: bloco(cor: Colors.white, radius: 12, child: Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text(op, textAlign: TextAlign.center, style: TextStyle(color: rosa, fontWeight: FontWeight.w900, fontSize: 18))))))))).toList()),
              ]),
            ),
          const SizedBox(height: 12),
          // BOTAO CONCLUI E TIRAR FOTO igual print 1
          GestureDetector(
            onTap: () => setState(() => tela = 'ia'),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: rosa, borderRadius: BorderRadius.circular(16), border: Border.all(color: roxoEscuro, width: 4), boxShadow: [BoxShadow(color: roxoEscuro, offset: const Offset(4,4))]),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                Icon(Icons.camera_alt, color: Colors.white), SizedBox(width: 8),
                Text('CONCLUI E TIRAR FOTO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
              ]),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _topoTab(String nome, IconData ic, bool ativo) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: ativo ? rosa : const Color(0xFFB18EFF), borderRadius: BorderRadius.circular(12), border: Border.all(color: roxoEscuro, width: 4), boxShadow: [BoxShadow(color: roxoEscuro, offset: const Offset(3,3))]),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(nome, style: TextStyle(color: ativo ? Colors.white : roxoEscuro, fontWeight: FontWeight.w900, fontSize: 12)),
        const SizedBox(width: 4), Icon(ic, size: 16, color: ativo ? Colors.white : roxoEscuro),
      ]),
    );
  }

  Widget _cardSiliba(String palavra, String sil, String prog, String pct, Color corIcone) {
    return bloco(cor: Colors.white, child: Padding(padding: const EdgeInsets.all(10), child: Column(children: [
      Container(width: 50, height: 50, decoration: BoxDecoration(color: corIcone.withOpacity(0.3), borderRadius: BorderRadius.circular(12)), child: Icon(palavra=='BOLA'? Icons.sports_soccer : Icons.home, color: corIcone, size: 30)),
      const SizedBox(height: 6),
      Text(palavra, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: roxoEscuro)),
      Text('Sílabas: $sil', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: roxoEscuro)),
      const SizedBox(height: 4),
      ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: palavra=='BOLA'?0.75:0.5, backgroundColor: const Color(0xFFE0D0FF), color: rosa, minHeight: 8)),
      Text('Progresso: $prog  ⭐ $pct', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: roxoEscuro)),
    ])));
  }

  Widget _materiaTab(String nome, IconData ic, String licao) {
    bool ativo = licaoAtual == licao;
    int lv = nivelPorLicao[licao] ?? 1;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() { licaoAtual = licao; }),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: ativo ? rosa : const Color(0xFFB18EFF), borderRadius: BorderRadius.circular(12), border: Border.all(color: roxoEscuro, width: 3), boxShadow: [BoxShadow(color: roxoEscuro, offset: const Offset(2,2))]),
        child: Column(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: roxoEscuro, borderRadius: BorderRadius.circular(6)), child: Text('LV$lv', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
          Icon(ic, color: roxoEscuro), Text(nome, style: TextStyle(color: roxoEscuro, fontWeight: FontWeight.w900, fontSize: 9), textAlign: TextAlign.center),
        ]),
      ),
    ));
  }

  Widget _bottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: roxoEscuro, borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), border: Border.all(color: roxoEscuro, width: 4)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Icon(Icons.home, color: rosa, size: 30),
        GestureDetector(onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Total $totalGeral/1040 ⭐'))), child: Icon(Icons.emoji_events, color: const Color(0xFF8B7AC1), size: 28)),
        GestureDetector(onTap: () => setState(() => tela='ia'), child: const Icon(Icons.settings, color: Color(0xFF8B7AC1), size: 28)),
      ]),
    );
  }

  // IA PROFESSORA igual print 3
  Widget _buildIA() {
    return Column(children: [
      Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: rosa, borderRadius: BorderRadius.circular(20), border: Border.all(color: roxoEscuro, width: 4), boxShadow: [BoxShadow(color: roxoEscuro, offset: const Offset(4,4))]),
        child: Row(children: [
          GestureDetector(onTap: () => setState(() => tela='jogos'), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: roxo, borderRadius: BorderRadius.circular(10), border: Border.all(color: roxoEscuro, width: 3)), child: const Icon(Icons.arrow_back, color: Colors.white))),
          const SizedBox(width: 10),
          const Expanded(child: Text('IA Professora\nda Alice', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18), textAlign: TextAlign.center)),
          Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFFFD6E8), borderRadius: BorderRadius.circular(20), border: Border.all(color: roxoEscuro, width: 3)), child: const Icon(Icons.face, color: roxo)),
        ]),
      ),
      if (carregandoIA) LinearProgressIndicator(color: rosa),
      Expanded(child: ListView.builder(padding: const EdgeInsets.all(12), itemCount: chatIA.length, itemBuilder: (_, i) {
        var m = chatIA[i];
        return Align(
          alignment: m.daAlice ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
            decoration: BoxDecoration(color: m.daAlice ? rosaClaro : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: roxoEscuro, width: 3), boxShadow: [BoxShadow(color: roxoEscuro, offset: const Offset(3,3))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (m.imagemPath != null) ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(File(m.imagemPath!), height: 120)),
              Text(m.texto, style: TextStyle(color: roxoEscuro, fontWeight: FontWeight.bold, fontSize: 13)),
            ]),
          ),
        );
      })),
      Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: rosaClaro, borderRadius: BorderRadius.circular(20), border: Border.all(color: roxoEscuro, width: 4)),
        child: Row(children: [
          GestureDetector(onTap: tirarFotoDever, child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: roxo, borderRadius: BorderRadius.circular(12), border: Border.all(color: roxoEscuro, width: 3)), child: const Icon(Icons.camera_alt, color: Colors.white))),
          const SizedBox(width: 8),
          Expanded(child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: roxoEscuro, width: 3)), child: TextField(controller: perguntaCtrl, decoration: const InputDecoration(hintText: 'Escreva seu dever...', border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 12))))),
          const SizedBox(width: 8),
          GestureDetector(onTap: () { if (perguntaCtrl.text.trim().isNotEmpty) { String t=perguntaCtrl.text; setState(() { chatIA.add(MensagemIA(t, true)); perguntaCtrl.clear(); }); explicarComGemini(perguntaTexto: t); } }, child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: roxo, borderRadius: BorderRadius.circular(12), border: Border.all(color: roxoEscuro, width: 3)), child: const Icon(Icons.send, color: Colors.white))),
        ]),
      ),
    ]);
  }
}
