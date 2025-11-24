import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestor de Hábitos e Tarefas - Guilherme Datovo',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> tarefas = [];
  final TextEditingController controller = TextEditingController();

  // Removido: carregamento de banco
  // Agora apenas inicializa uma lista vazia
  Future<void> _carregarTarefas() async {
    setState(() {});
  }

  // Adiciona uma tarefa apenas na lista
  Future<void> _adicionarTarefa(String titulo) async {
    setState(() {
      tarefas.add({'titulo': titulo});
    });
    controller.clear();
  }

  @override
  void initState() {
    super.initState();
    _carregarTarefas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestor de Hábitos e Tarefas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Adicionar nova tarefa',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  _adicionarTarefa(controller.text);
                }
              },
              child: const Text('Adicionar'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: tarefas.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.check_circle_outline),
                    title: Text(tarefas[index]['titulo']),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
