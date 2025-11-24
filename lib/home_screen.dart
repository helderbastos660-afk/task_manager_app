import 'package:flutter/material.dart';
import 'tasks_screen.dart';
import 'habits_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class HomeScreen extends StatefulWidget {
  final Database database;
  const HomeScreen({super.key, required this.database});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      TasksScreen(database: widget.database),
      HabitsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Gestão de Tarefas e Hábitos")),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.check_box), label: "Tarefas"),
          BottomNavigationBarItem(
              icon: Icon(Icons.track_changes), label: "Hábitos"),
        ],
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}
