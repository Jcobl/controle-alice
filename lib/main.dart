
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:math';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() => runApp(const AliceApp());
const String GEMINI_API_KEY = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

class AliceApp extends StatelessWidget {
  const AliceApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Alice 1040',
      theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: const Color(0xFFD6C6FF)),
      home: const RobloxHome(),
    );
  }
}

class Atividade {
  final String id;
  final String pergunta;
  final List<String> opcoes;
  final String correta;
  final String dica;
  Atividade(this.id, this.pergunta, this.opcoes, this.correta, this.dica);
}

class MensagemIA {
  final String texto;
  final bool daAlice;
  final String? img;
  MensagemIA(this.texto, this.daAlice, {this.img});
}

class Historia {
  final String titulo;
  final String nivel;
  final List<String> paginas;
  Historia(this.titulo, this.nivel, this.paginas);
}

class RobloxHome extends StatefulWidget {
  const RobloxHome({super.key});
  @override
  State<RobloxHome> createState() => _RobloxHomeState();
}

class _RobloxHomeState extends State<RobloxHome> {
  final roxoEscuro = const Color(0xFF2B2452);
  final rosa = const Color(0xFFFF4D8D);
  final roxo = const Color(0xFF8B5CF6);
  final rosaClaro = const Color(0xFFFFD6E8);

  String licaoAtual = 'Português';
  String tela = 'jogos';
  int historiaAberta = -1;
  int paginaAtual = 0;

  final picker = ImagePicker();
  final perguntaCtrl = TextEditingController();
  List<MensagemIA> chatIA = [];
  bool carregandoIA = false;

  Map<String, Set<String>> feitas = {
    'Português': {},
    'Matemática': {},
    'Leitura': {},
    'Escrita': {}
  };
  Map<String, int> nivelPorLicao = {
    'Português': 1,
    'Matemática': 1,
    'Leitura': 1,
    'Escrita': 1
  };

  List<Historia> historias = [
    Historia('A CASA DO GATO', 'Nivel Iniciante', [
      'Pagina 1 de 5: Era uma vez um gato que morava numa casa rosa.',
      'Pagina 2 de 5: A casa tinha porta rosa e janela azul.',
      'Pagina 3 de 5: Todo dia o gato lia BOLA e CASA. BO + LA = BOLA!',
      'Pagina 4 de 5: Os amigos vieram ler junto. O SOL brilha!',
      'Pagina 5 de 5: Fim! O gato aprendeu a ler e ficou feliz!'
    ]),
    Historia('O SOL E A LUA', 'Nivel 1', [
      'Pagina 1 de 3: O SOL brilha de dia.',
      'Pagina 2 de 3: A LUA brilha de noite.',
      'Pagina 3 de 3: SOL e LUA sao amigos!'
    ]),
    Historia('A BOLA PULA', 'Nivel 1', [
      'Pagina 1 de 3: A BOLA azul pula alto.',
      'Pagina 2 de 3: Alice joga a BOLA.',
      'Pagina 3 de 3: BOLA, CASA, SOL!'
    ]),
  ];

  late final Map<String, Map<int, List<Atividade>>> banco = _gerarBanco();

  Map<String, Map<int, List<Atividade>>> _gerarBanco() {
    Map<String, Map<int, List<Atividade>>> b = {
      'Português': {},
      'Matemática': {},
      'Leitura': {},
      'Escrita': {}
    };
    for (var k in b.keys) {
      for (int nv = 1; nv <= 13; nv++) {
        b[k]![nv] = [];
      }
    }
    List sil = [
      ["BO", "LA", "BOLA"],
      ["CA", "SA", "CASA"],
      ["SO", "L", "SOL"],
      ["LU", "A", "LUA"],
      ["GA", "TO", "GATO"]
    ];
    int id = 1;
    for (int nv = 1; nv <= 13; nv++) {
      for (int i = 0; i < 20; i++) {
        var s = sil[(id + i) % sil.length];
        var opP = [s[2], 'BALA', 'BOLO'];
        opP.shuffle(Random(id * 3 + i));
        b['Português']![nv]!.add(Atividade(
            'P${nv}-$id',
            'Junte: ${s[0]} + ${s[1]} = ?',
            opP,
            s[2],
            '${s[0]}+${s[1]}'));
        int a = (id % 10) + 1;
        int b2 = (i % 5) + 1;
        var opM = ['${a + b2}', '${a + b2 + 1}', '${a + b2 + 2}'];
        opM.shuffle(Random(id * 7 + i));
        b['Matemática']![nv]!.add(Atividade(
            'M${nv}-$id',
            '$a + $b2 = ?',
            opM,
            '${a + b2}',
            'Macas'));
        String frase = ["O SOL brilha", "A CASA e bonita", "A BOLA pula"][i % 3];
        var opL = [frase, 'O SOL bonito', 'A BOLA azul'];
        opL.shuffle(Random(id * 11 + i));
        b['Leitura']![nv]!.add(Atividade('L${nv}-$id', 'Leia: $frase',
            opL, frase, frase));
        var opE = [s[2], 'Eu amo ${s[2]}', 'CASA'];
        opE.shuffle(Random(id * 13 + i));
        b['Escrita']![nv]!.add(Atividade(
            'E${nv}-$id', 'Escreva ${s[2]}', opE, s[2], s[2]));
        id++;
      }
    }
    return b;
  }

  Atividade? get proxima {
    var lista = banco[licaoAtual]?[nivelPorLicao[licaoAtual]] ?? [];
    var f = feitas[licaoAtual] ?? {};
    for (var a in lista) {
      if (!f.contains(a.id)) return a;
    }
    return null;
  }

  int get prog {
    var setFeitas = feitas[licaoAtual] ?? {};
    var idsNivel = (banco[licaoAtual]?[nivelPorLicao[licaoAtual]] ?? [])
        .map((e) => e.id)
        .toSet();
    return setFeitas.intersection(idsNivel).length;
  }

  int get total => feitas.values.fold(0, (s, set) => s + set.length);

  void responder(Atividade atv, String escolha) async {
    if (escolha == atv.correta) {
      setState(() => feitas[licaoAtual]!.add(atv.id));
      final p = await SharedPreferences.getInstance();
      await p.setStringList('feitas_$licaoAtual', feitas[licaoAtual]!.toList());
      if (prog >= 20) {
        setState(() => nivelPorLicao[licaoAtual] = (nivelPorLicao[licaoAtual] ?? 1) + 1);
        await p.setInt('nivel_$licaoAtual', nivelPorLicao[licaoAtual]!);
        if (mounted) {
          showDialog(
              context: context,
              builder: (_) => AlertDialog(
                    title: Text('Nivel ${nivelPorLicao[licaoAtual]! - 1} completo!'),
                    content: Text(
                        '20 sem repetir! Liberou nivel ${nivelPorLicao[licaoAtual]}! Total $total/1040'),
                  ));
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Quase! Dica: ${atv.dica}'), backgroundColor: roxo));
    }
    setState(() {});
  }

  Future<void> explicarIA({String? txt, String? imgPath}) async {
    if (GEMINI_API_KEY.isEmpty) {
      setState(() => chatIA.add(MensagemIA(
          'Chave nao configurada no Secret. Vai em Settings > Secrets > Actions > GEMINI_API_KEY. Vou explicar: 2 macas + 3 macas = 5',
          false)));
      return;
    }
    setState(() => carregandoIA = true);
    try {
      final model =
          GenerativeModel(model: 'gemini-1.5-flash', apiKey: GEMINI_API_KEY);
      String prompt =
          'Voce e IA Professora da Alice 7 anos Roblox rosa roxa. Explique passo a passo com macas, 3 passos curtos. Total $total/1040.';
      List<Content> c;
      if (imgPath != null) {
        final bytes = await File(imgPath).readAsBytes();
        c = [
          Content.multi([
            TextPart('$prompt Pergunta: ${txt ?? 'Explique dever'}'),
            DataPart('image/jpeg', bytes)
          ])
        ];
      } else {
        c = [
          Content.text(
              '$prompt Pergunta: ${txt ?? 'Ajuda dever'} Historia: ${historiaAberta >= 0 ? historias[historiaAberta].paginas[paginaAtual] : ''}')
        ];
      }
      final r = await model.generateContent(c);
      setState(() => chatIA.add(MensagemIA(r.text ?? 'Tira outra foto!', false)));
    } catch (e) {
      setState(() => chatIA.add(MensagemIA('Erro IA: $e', false)));
    } finally {
      setState(() => carregandoIA = false);
    }
  }

  Future<void> tirarFoto() async {
    final XFile? img =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (img != null) {
      setState(() => chatIA.add(MensagemIA('Foto do meu dever', true, img: img.path)));
      await explicarIA(imgPath: img.path, txt: perguntaCtrl.text);
    }
  }

  Widget bloco({required Widget child, required Color cor}) {
    return Container(
      decoration: BoxDecoration(
          color: cor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: roxoEscuro, width: 4),
          boxShadow: [BoxShadow(color: roxoEscuro, offset: const Offset(4, 4))]),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6C6FF),
      body: SafeArea(
          child: tela == 'ia'
              ? _buildIA()
              : tela == 'historia'
                  ? _buildHistoriaLeitor()
                  : _buildJogos()),
      bottomNavigationBar: tela == 'jogos'
          ? Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                  color: roxoEscuro,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(Icons.home, color: rosa, size: 30),
                  GestureDetector(
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Total $total/1040'))),
                      child: const Icon(Icons.emoji_events,
                          color: Color(0xFF8B7AC1))),
                  GestureDetector(
                      onTap: () => setState(() => tela = 'ia'),
                      child: const Icon(Icons.smart_toy,
                          color: Color(0xFF8B7AC1)))
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildJogos() {
    var atv = proxima;
    String botaoTexto = 'CONCLUI E TIRAR FOTO';
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: roxoEscuro,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: roxoEscuro, width: 4)),
              child: Row(children: [
                Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: rosa, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.view_module, color: Colors.white)),
                const SizedBox(width: 8),
                const Text('ALICE',
                    style: TextStyle(
                        color: Color(0xFFFF7AC1),
                        fontWeight: FontWeight.w900,
                        fontSize: 28))
              ])),
          Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: const Color(0xFFEDE0FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: roxoEscuro, width: 4)),
              child: Column(children: [
                const Text('Jogando e Aprendendo!',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        color: Color(0xFF2B2452))),
                const SizedBox(height: 8),
                Text('Jogos de Silabas',
                    style: TextStyle(
                        color: rosa, fontWeight: FontWeight.w900, fontSize: 18)),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                      child: bloco(
                          cor: Colors.white,
                          child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(children: [
                                Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(12)),
                                    child: const Icon(Icons.sports_soccer,
                                        color: Colors.blue)),
                                Text('BOLA',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 22,
                                        color: roxoEscuro)),
                                const Text('Silabas: BO + LA',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold)),
                                LinearProgressIndicator(
                                    value: 0.75,
                                    color: rosa,
                                    backgroundColor: const Color(0xFFE0D0FF)),
                                const Text('Progresso: 3/4',
                                    style: TextStyle(
                                        fontSize: 9, fontWeight: FontWeight.bold))
                              ])))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: bloco(
                          cor: Colors.white,
                          child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(children: [
                                Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                        color: Colors.pink.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(12)),
                                    child: const Icon(Icons.home,
                                        color: Colors.pink)),
                                Text('CASA',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 22,
                                        color: roxoEscuro)),
                                const Text('Silabas: CA + SA',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold)),
                                LinearProgressIndicator(
                                    value: 0.5,
                                    color: rosa,
                                    backgroundColor: const Color(0xFFE0D0FF)),
                                const Text('Progresso: 2/4',
                                    style: TextStyle(
                                        fontSize: 9, fontWeight: FontWeight.bold))
                              ]))))
                ]),
                const SizedBox(height: 16),
                Text('Historias para Ler',
                    style: TextStyle(
                        color: rosa, fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(height: 8),
                ...historias.asMap().entries.map((entry) {
                  int idx = entry.key;
                  var h = entry.value;
                  return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                          onTap: () => setState(() {
                                tela = 'historia';
                                historiaAberta = idx;
                                paginaAtual = 0;
                              }),
                          child: bloco(
                              cor: Colors.white,
                              child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(children: [
                                    Container(
                                        width: 70,
                                        height: 50,
                                        decoration: BoxDecoration(
                                            color: rosaClaro,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                                color: roxoEscuro, width: 3)),
                                        child: const Icon(Icons.auto_stories,
                                            color: Colors.purple)),
                                    const SizedBox(width: 10),
                                    Expanded(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                          Text(h.titulo,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  color: roxoEscuro)),
                                          Text(
                                              'Leitura simples - ${h.paginas.length} paginas - ${h.nivel}',
                                              style: const TextStyle(
                                                  fontSize: 10)),
                                          Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                  color: rosa,
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              child: const Text('Ler agora!',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold)))
                                        ]))
                                  ])))));
                }).toList(),
              ])),
          const SizedBox(height: 12),
          Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: roxoEscuro,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: roxoEscuro, width: 4)),
              child: Column(children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Alice - $licaoAtual\nNivel ${nivelPorLicao[licaoAtual]}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 18)),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: const Color(0xFF4B3F81),
                              borderRadius: BorderRadius.circular(20)),
                          child: Text('$prog/20 | Total $total',
                              style: const TextStyle(
                                  color: Color(0xFFE9D6FF),
                                  fontWeight: FontWeight.bold)))
                    ]),
                const SizedBox(height: 12),
                Row(children: [
                  _matTab('Português', Icons.book, 'Português'),
                  _matTab('Matemática', Icons.calculate, 'Matemática'),
                  _matTab('Leitura', Icons.menu_book, 'Leitura'),
                  _matTab('Escrita', Icons.edit, 'Escrita')
                ]),
              ])),
          const SizedBox(height: 12),
          if (atv != null)
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: rosa, width: 5),
                    boxShadow: [
                      BoxShadow(color: roxoEscuro, offset: const Offset(4, 4))
                    ]),
                child: Column(children: [
                  Text(atv.pergunta,
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 26,
                          color: roxoEscuro),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  Row(
                      children: atv.opcoes
                          .map((op) => Expanded(
                              child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: GestureDetector(
                                      onTap: () => responder(atv, op),
                                      child: bloco(
                                          cor: Colors.white,
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16),
                                              child: Text(op,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: rosa,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontSize: 18))))))))
                          .toList())
                ])),
          const SizedBox(height: 12),
          GestureDetector(
              onTap: () => setState(() => tela = 'ia'),
              child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                      color: rosa,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: roxoEscuro, width: 4),
                      boxShadow: [
                        BoxShadow(color: roxoEscuro, offset: const Offset(4, 4))
                      ]),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.camera_alt, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(botaoTexto,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 18))
                      ]))),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _matTab(String nome, IconData ic, String licao) {
    bool ativo = licaoAtual == licao;
    int lv = nivelPorLicao[licao] ?? 1;
    return Expanded(
        child: GestureDetector(
            onTap: () => setState(() => licaoAtual = licao),
            child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                    color: ativo ? rosa : const Color(0xFFB18EFF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: roxoEscuro, width: 3)),
                child: Column(children: [
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: roxoEscuro,
                          borderRadius: BorderRadius.circular(6)),
                      child: Text('LV$lv',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold))),
                  Icon(ic, color: roxoEscuro),
                  Text(nome,
                      style: TextStyle(
                          color: roxoEscuro,
                          fontWeight: FontWeight.w900,
                          fontSize: 9),
                      textAlign: TextAlign.center)
                ]))));
  }

  Widget _buildHistoriaLeitor() {
    if (historiaAberta < 0) return const SizedBox();
    var h = historias[historiaAberta];
    String labelProxima;
    if (paginaAtual < h.paginas.length - 1) {
      labelProxima = 'Proxima';
    } else {
      labelProxima = 'Fim';
    }
    return Column(children: [
      Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: rosa,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: roxoEscuro, width: 4)),
          child: Row(children: [
            GestureDetector(
                onTap: () => setState(() => tela = 'jogos'),
                child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: roxo,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: roxoEscuro, width: 3)),
                    child: const Icon(Icons.arrow_back, color: Colors.white))),
            const SizedBox(width: 10),
            Expanded(
                child: Text(h.titulo,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16),
                    textAlign: TextAlign.center))
          ])),
      Expanded(
          child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: rosa, width: 5)),
              child: Column(children: [
                Text(h.paginas[paginaAtual],
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: roxoEscuro),
                    textAlign: TextAlign.center),
                const Spacer(),
                Text('${paginaAtual + 1}/${h.paginas.length}',
                    style: TextStyle(color: roxo, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                      child: GestureDetector(
                          onTap: () => setState(() {
                                if (paginaAtual > 0) paginaAtual--;
                              }),
                          child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFB18EFF),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: roxoEscuro, width: 3)),
                              child: const Center(
                                  child: Text('Voltar',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900)))))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: GestureDetector(
                          onTap: () => setState(() {
                                if (paginaAtual < h.paginas.length - 1) {
                                  paginaAtual++;
                                } else {
                                  tela = 'jogos';
                                }
                              }),
                          child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                  color: rosa,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: roxoEscuro, width: 3)),
                              child: Center(
                                  child: Text(labelProxima,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900))))))
                ]),
                const SizedBox(height: 10),
                GestureDetector(
                    onTap: () {
                      setState(() => tela = 'ia');
                      explicarIA(
                          txt:
                              'Me ajuda a ler a historia ${h.titulo} pagina ${paginaAtual + 1}: ${h.paginas[paginaAtual]}');
                    },
                    child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                            color: roxo,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: roxoEscuro, width: 3)),
                        child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.smart_toy,
                                  color: Colors.white, size: 18),
                              SizedBox(width: 6),
                              Text('Ler com IA Professora',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold))
                            ]))),
              ]))),
    ]);
  }

  Widget _buildIA() {
    return Column(children: [
      Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: rosa,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: roxoEscuro, width: 4)),
          child: Row(children: [
            GestureDetector(
                onTap: () => setState(() => tela = 'jogos'),
                child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: roxo,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: roxoEscuro, width: 3)),
                    child: const Icon(Icons.arrow_back, color: Colors.white))),
            const SizedBox(width: 10),
            const Expanded(
                child: Text('IA Professora da Alice',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18),
                    textAlign: TextAlign.center)),
          ])),
      if (carregandoIA) LinearProgressIndicator(color: rosa),
      Expanded(
          child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: chatIA.length,
              itemBuilder: (_, i) {
                var m = chatIA[i];
                return Align(
                    alignment: m.daAlice
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.85),
                        decoration: BoxDecoration(
                            color: m.daAlice ? rosaClaro : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: roxoEscuro, width: 3)),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (m.img != null)
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(File(m.img!),
                                        height: 120)),
                              Text(m.texto,
                                  style: TextStyle(
                                      color: roxoEscuro,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13))
                            ])));
              })),
      Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: rosaClaro,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: roxoEscuro, width: 4)),
          child: Row(children: [
            GestureDetector(
                onTap: tirarFoto,
                child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: roxo,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: roxoEscuro, width: 3)),
                    child: const Icon(Icons.camera_alt, color: Colors.white))),
            const SizedBox(width: 8),
            Expanded(
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: roxoEscuro, width: 3)),
                    child: TextField(
                        controller: perguntaCtrl,
                        decoration: const InputDecoration(
                            hintText: 'Escreva seu dever...',
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12))))),
            const SizedBox(width: 8),
            GestureDetector(
                onTap: () {
                  if (perguntaCtrl.text.trim().isNotEmpty) {
                    String t = perguntaCtrl.text;
                    setState(() {
                      chatIA.add(MensagemIA(t, true));
                      perguntaCtrl.clear();
                    });
                    explicarIA(txt: t);
                  }
                },
                child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: roxo,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: roxoEscuro, width: 3)),
                    child: const Icon(Icons.send, color: Colors.white)))
          ])),
    ]);
  }
