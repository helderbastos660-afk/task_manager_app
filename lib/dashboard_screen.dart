import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DashboardScreen extends StatefulWidget {
  final Database database;
  const DashboardScreen({super.key, required this.database});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int total = 0;
  int vencidas = 0;
  int abertas = 0;
  String proxima = "Nenhuma";

  Future<void> carregarResumo() async {
    final tarefas = await widget.database.query('tarefas');

    total = tarefas.length;

    final agora = DateTime.now();

    vencidas = tarefas.where((t) {
      try {
        final prazo = DateTime.parse(t['prazo']).toLocal();
        return prazo.isBefore(agora);
      } catch (_) {
        return false;
      }
    }).length;

    abertas = tarefas.length - vencidas;

    // Próxima a vencer (ignora entradas sem prazo)
    final comPrazo = tarefas.where((t) {
      final p = t['prazo'] as String?;
      return p != null && p.isNotEmpty;
    }).toList();

    comPrazo.sort((a, b) {
      try {
        final pa = DateTime.parse(a['prazo']).toUtc();
        final pb = DateTime.parse(b['prazo']).toUtc();
        return pa.compareTo(pb);
      } catch (_) {
        return 0;
      }
    });

    if (comPrazo.isNotEmpty) {
      try {
        final p = DateTime.parse(comPrazo.first['prazo']).toLocal();
        proxima =
            "${p.day.toString().padLeft(2,'0')}/${p.month.toString().padLeft(2,'0')}/${p.year} • ${p.hour.toString().padLeft(2,'0')}:${p.minute.toString().padLeft(2,'0')}";
      } catch (_) {
        proxima = "Nenhuma";
      }
    } else {
      proxima = "Nenhuma";
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    carregarResumo();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: carregarResumo,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Dashboard",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          Card(
            color: Colors.indigo.shade50,
            child: ListTile(
              leading: const Icon(Icons.list, size: 40),
              title: const Text("Total de Tarefas"),
              subtitle: Text("$total tarefas"),
            ),
          ),

          const SizedBox(height: 10),

          Card(
            color: Colors.green.shade50,
            child: ListTile(
              leading: const Icon(Icons.check_circle, size: 40),
              title: const Text("Tarefas Dentro do Prazo"),
              subtitle: Text("$abertas tarefas"),
            ),
          ),

          const SizedBox(height: 10),

          Card(
            color: Colors.red.shade50,
            child: ListTile(
              leading: const Icon(Icons.warning, size: 40),
              title: const Text("Tarefas Vencidas"),
              subtitle: Text("$vencidas tarefas"),
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: ListTile(
              leading: const Icon(Icons.schedule, size: 40),
              title: const Text("Próxima tarefa a vencer"),
              subtitle: Text(proxima),
            ),
          ),
        ],
      ),
    );
  }
}
