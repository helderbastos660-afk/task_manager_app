import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/task.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});
  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late ApiService api;
  bool loading = true;
  List<Task> tasks = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    api = Provider.of<ApiService>(context);
    fetch();
  }

  Future<void> fetch() async {
    setState(() => loading = true);
    tasks = await api.fetchTasks();
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: fetch,
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (c, i) {
                final t = tasks[i];
                return ListTile(
                  leading: Checkbox(value: t.completed, onChanged: (v) {}),
                  title: Text(t.title),
                  subtitle: Text('ID: ${t.id}'),
                );
              },
            ),
          );
  }
}
