import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa sqlite para desktop (sqflite_common_ffi)
  sqfliteFfiInit();
  var databaseFactory = databaseFactoryFfi;

  // Abre ou cria o banco de dados com a coluna `prazo`
  final database = await databaseFactory.openDatabase(
    join(await databaseFactory.getDatabasesPath(), 'habitos.db'),
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE tarefas(id INTEGER PRIMARY KEY AUTOINCREMENT, titulo TEXT, prazo TEXT)',
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

  @override
  void initState() {
    super.initState();
    _carregarTarefas();
  }

  Future<void> _carregarTarefas() async {
    final List<Map<String, dynamic>> maps = await widget.database.query(
      'tarefas',
      orderBy: 'prazo ASC', // opcional: ordena por prazo (mais urgente primeiro)
    );
    setState(() => tarefas = maps);
  }

  Future<void> _adicionarTarefa(String titulo, DateTime prazo) async {
    await widget.database.insert('tarefas', {
      'titulo': titulo,
      'prazo': prazo.toIso8601String(),
    });
    controller.clear();
    await _carregarTarefas();
  }

  Future<void> _deletarTarefa(int id) async {
    await widget.database.delete('tarefas', where: 'id = ?', whereArgs: [id]);
    await _carregarTarefas();
  }

  // Seleciona data + hora (DatePicker + TimePicker)
  Future<DateTime?> _selecionarPrazo(BuildContext context) async {
    final now = DateTime.now();

    DateTime? data = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2100),
    );

    if (data == null) return null;

    TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (hora == null) return null;

    return DateTime(data.year, data.month, data.day, hora.hour, hora.minute);
  }

  // Formata a data/hora para exibição
  String _formatarPrazo(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final dia = dt.day.toString().padLeft(2, '0');
      final mes = dt.month.toString().padLeft(2, '0');
      final ano = dt.year;
      final hora = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      return '$dia/$mes/$ano • $hora:$min';
    } catch (e) {
      return iso;
    }
  }

  // Mostra diálogo para confirmar exclusão
  Future<bool> _confirmarExclusao(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Confirmar'),
            content: const Text('Deseja realmente excluir esta tarefa?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Não')),
              ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Sim')),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestor de Hábitos e Tarefas'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo para texto da tarefa
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Adicionar nova tarefa',
                border: OutlineInputBorder(),
                hintText: 'Escreva o título da tarefa',
              ),
            ),
            const SizedBox(height: 10),

            // Botões: escolher prazo e adicionar
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.schedule),
                    label: const Text('Escolher prazo'),
                    onPressed: () async {
                      final texto = controller.text.trim();
                      if (texto.isEmpty) {
                        // pede para digitar título primeiro
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Digite o título antes de escolher o prazo.')),
                        );
                        return;
                      }
                      final prazo = await _selecionarPrazo(context);
                      if (prazo == null) return;
                      await _adicionarTarefa(texto, prazo);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                // Botão rápido: escolher prazo automático de 24h (exemplo)
                ElevatedButton(
                  onPressed: () async {
                    final texto = controller.text.trim();
                    if (texto.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Digite o título antes de adicionar.')),
                      );
                      return;
                    }
                    final prazo = DateTime.now().add(const Duration(hours: 24));
                    await _adicionarTarefa(texto, prazo);
                  },
                  child: const Text('+24h'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Lista de tarefas
            Expanded(
              child: tarefas.isEmpty
                  ? const Center(child: Text('Nenhuma tarefa. Adicione usando o campo acima.'))
                  : RefreshIndicator(
                      onRefresh: _carregarTarefas,
                      child: ListView.builder(
                        itemCount: tarefas.length,
                        itemBuilder: (context, index) {
                          final tarefa = tarefas[index];
                          final titulo = tarefa['titulo'] as String? ?? '';
                          final prazoIso = tarefa['prazo'] as String? ?? '';
                          DateTime? prazo;
                          bool expirou = false;
                          if (prazoIso.isNotEmpty) {
                            try {
                              prazo = DateTime.parse(prazoIso).toLocal();
                              expirou = DateTime.now().isAfter(prazo);
                            } catch (e) {
                              prazo = null;
                            }
                          }

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            color: expirou ? Colors.red.withOpacity(0.12) : null,
                            child: ListTile(
                              leading: Icon(
                                expirou ? Icons.warning : Icons.check_circle,
                                color: expirou ? Colors.red : Colors.green,
                              ),
                              title: Text(
                                titulo,
                                style: TextStyle(
                                  decoration: expirou ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              subtitle: prazo != null
                                  ? Text('Prazo: ${_formatarPrazo(prazo.toIso8601String())}')
                                  : const Text('Sem prazo'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () async {
                                      final ok = await _confirmarExclusao(context);
                                      if (!ok) return;
                                      await _deletarTarefa(tarefa['id'] as int);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
