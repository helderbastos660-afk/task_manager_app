import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  sqfliteFfiInit();
  var databaseFactory = databaseFactoryFfi;

  final database = await databaseFactory.openDatabase(
    join(await databaseFactory.getDatabasesPath(), 'habitos.db'),
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE tarefas(id INTEGER PRIMARY KEY AUTOINCREMENT, titulo TEXT)',
        );
      },
    ),
  );

  runApp(MyApp(database: database));
}

class MyApp extends StatelessWidget {
  final Database database;
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
  final Database database;
  const HomePage({super.key, required this.database});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> tarefas = [];
  final TextEditingController controller = TextEditingController();

  Future<void> _carregarTarefas() async {
    final List<Map<String, dynamic>> maps = await widget.database.query('tarefas');
    setState(() => tarefas = maps);
  }

  Future<void> _adicionarTarefa(String titulo) async {
    await widget.database.insert('tarefas', {'titulo': titulo});
    controller.clear();
    _carregarTarefas();
  }

  Future<void> _deletarTarefa(int id) async {
    await widget.database.delete('tarefas', where: 'id = ?', whereArgs: [id]);
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
      appBar: AppBar(title: const Text('Gestor de Hábitos e Tarefas')),
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
                if (controller.text.isNotEmpty) _adicionarTarefa(controller.text);
              },
              child: const Text('Adicionar'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: tarefas.length,
                itemBuilder: (context, index) {
                  final tarefa = tarefas[index];
                  return ListTile(
                    leading: const Icon(Icons.check_circl_

