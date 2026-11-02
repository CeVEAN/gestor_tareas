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

  Future<void> _edit(Board board) async {
    var boardName = board.name;
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar tablero'),
        content: TextFormField(
          initialValue: board.name,
          onChanged: (value) => boardName = value,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nombre del tablero'),
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, boardName.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (!mounted || name == null) return;
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('El nombre es obligatorio')));
      return;
    }
    try {
      await _service.rename(board, name);
      if (!mounted) return;
      _reload();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Tablero actualizado')));
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo actualizar el tablero')),
        );
    }
  }

  Future<void> _delete(Board board) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar tablero'),
        content: const Text(
          '¿Estás seguro de borrar este tablero? Se borrarán todas las tareas asociadas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await _service.delete(board);
      if (!mounted) return;
      _reload();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Tablero eliminado')));
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo eliminar el tablero. Si tiene tareas, elimínalas primero.',
            ),
          ),
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
            trailing: PopupMenuButton<String>(
              tooltip: 'Opciones del tablero',
              onSelected: (action) {
                if (action == 'edit') _edit(boards[index]);
                if (action == 'delete') _delete(boards[index]);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Editar')),
                PopupMenuItem(value: 'delete', child: Text('Eliminar')),
              ],
            ),
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
