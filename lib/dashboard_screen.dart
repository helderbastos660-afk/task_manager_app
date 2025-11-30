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

    // ----- TAREFAS VENCIDAS -----
    vencidas = tarefas.where((t) {
      final prazoStr = t['prazo'] as String?;
      if (prazoStr == null || prazoStr.isEmpty) return false;

      try {
        final prazo = DateTime.parse(prazoStr).toLocal();
        return prazo.isBefore(agora);
      } catch (_) {
        return false;
      }
    }).length;

    abertas = total - vencidas;

    // ----- PRÓXIMA TAREFA -----
    final comPrazo = tarefas.where((t) {
      final prazoStr = t['prazo'] as String?;
      return prazoStr != null && prazoStr.isNotEmpty;
    }).toList();

    comPrazo.sort((a, b) {
      try {
        final pa = DateTime.parse(a['prazo'] as String).toUtc();
        final pb = DateTime.parse(b['prazo'] as String).toUtc();
        return pa.compareTo(pb);
      } catch (_) {
        return 0;
      }
    });

    if (comPrazo.isNotEmpty) {
      final prazoStr = comPrazo.first['prazo'] as String?;
      if (prazoStr != null) {
        try {
          final p = DateTime.parse(prazoStr).toLocal();
          proxima =
              "${p.day.toString().padLeft(2, '0')}/${p.month.toString().padLeft(2, '0')}/${p.year} • ${p.hour.toString().padLeft(2, '0')}:${p.minute.toString().padLeft(2, '0')}";
        } catch (_) {
          proxima = "Nenhuma";
        }
      }
    } else {
      proxima = "Nenhuma";
    }

    setState(() {
