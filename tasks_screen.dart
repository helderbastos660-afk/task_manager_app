import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class TasksScreen extends StatefulWidget {
  final Database database;
  const TasksScreen({super.key, required this.database});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Map<String, dynamic>> tasks = [];
  final TextEditingController controller = TextEditingController();

  Future<void> loadTasks() async {
    final data = await widget.database.query('tarefas');
    setState(() => tasks = data);
  }

  Future<void> addTask() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    await widget.database.insert('tarefas', {'titulo': text});
    controller.clear();
    loadTasks();
  }

  Future<void> deleteTask(int id) async {
    await widget.database.delete('tarefas', where: 'id = ?', whereArgs: [id]);
    loadTasks();
  }

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: "Adicionar tarefa",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: addTask,
                child: const Text("Add"),
              )
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: loadTasks,
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final t = tasks[index];
                return ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(t['titulo']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteTask(t['id']),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
