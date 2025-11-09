import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = openDatabase(
    join(await getDatabasesPath(), 'habitos.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE tarefas(id INTEGER PRIMARY KEY AUTOINCREMENT, titulo TEXT)',
      );
    },
    version: 1,
  );

  runApp(MyApp(database: database));
}

class MyApp extends StatelessWidget {
  final Future<Database> database;
  const MyApp({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestor de Hábitos e Tarefas - Guilherme Datovo',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: HomePage(database: database),
    );
  }
}

class HomePage extends StatefulWidget {
  final Future<Database> database;
  const HomePage({super.key, required this.database});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> tarefas = [];
  final TextEditingController controller = TextEditingController();

  Future<void> _carregarTarefas() async {
    final db = await widget.database;
    final List<Map<String, dynamic>> maps = await db.query('tarefas');
    setState(() => tarefas = maps);
  }

  Future<void> _adicionarTarefa(String titulo) async {
    final db = await widget.database;
    await db.insert('tarefas', {'titulo': titulo},
        conflictAlgorithm: ConflictAlgorithm.replace);
    controller.clear();
    _carregarTarefas();
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
