// lib/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DashboardScreen extends StatefulWidget {
  final Database database;
  const DashboardScreen({super.key, required this.database});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int totalTarefas = 0;

  @override
  void initState() {
    super.initState();
    _carregarTotalTarefas();
  }

  Future<void> _carregarTotalTarefas() async {
    final countQuery = await widget.database.rawQuery('SELECT COUNT(*) AS total FROM tarefas');
    setState(() {
      totalTarefas = (countQuery.first['total'] ?? 0) as int;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              color: Colors.indigo.shade50,
              child: ListTile(
                leading: const Icon(Icons.checklist, color: Colors.indigo),
                title: const Text('Total de Tarefas'),
                trailing: Text(totalTarefas.toString(), style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              color: Colors.green.shade50,
              child: ListTile(
                leading: const Icon(Icons.done_all, color: Colors.green),
                title: const Text('Tarefas concluídas'),
                trailing: const Text('0', style: TextStyle(fontSize: 20)), // futuramente calcular
              ),
            ),
            const SizedBox(height: 20),
            Card(
              color: Colors.red.shade50,
              child: ListTile(
                leading: const Icon(Icons.warning, color: Colors.red),
                title: const Text('Tarefas expiradas'),
                trailing: const Text('0', style: TextStyle(fontSize: 20)), // futuramente calcular
              ),
            ),
          ],
        ),
      ),
    );
  }
}
