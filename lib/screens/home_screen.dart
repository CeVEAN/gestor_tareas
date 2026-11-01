import 'package:flutter/material.dart';

import '../models/board.dart';
import '../services/auth_service.dart';
import '../services/board_service.dart';
import 'tasks_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = BoardService();
  late Future<List<Board>> _boards;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _boards = _service.list();
    });
  }

  Future<void> _create() async {
    var boardName = '';
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo tablero'),
        content: TextField(
          onChanged: (value) => boardName = value,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nombre del tablero'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, boardName.trim()),
            child: const Text('Crear'),
          ),
        ],
      ),
    );
    if (name == null) return;
    if (name.isEmpty) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El nombre es obligatorio')),
        );
      return;
    }
    try {
      await _service.create(name);
      if (mounted) _reload();
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo crear el tablero')),
        );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Mis tableros'),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Cerrar sesión',
          onPressed: () => AuthService().signOut(),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _create,
      tooltip: 'Crear tablero',
      child: const Icon(Icons.add),
    ),
    body: FutureBuilder<List<Board>>(
      future: _boards,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done)
          return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError)
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('No se pudieron cargar los tableros'),
                TextButton(onPressed: _reload, child: const Text('Reintentar')),
              ],
            ),
          );
        final boards = snapshot.data!;
        if (boards.isEmpty)
          return const Center(
            child: Text('Aún no tienes tableros. Crea uno para empezar.'),
          );
        return ListView.builder(
          itemCount: boards.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(boards[index].name),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TasksScreen(board: boards[index]),
              ),
            ),
          ),
        );
      },
    ),
  );
}
