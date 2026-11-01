import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/board.dart';
import '../models/task.dart';
import '../services/task_service.dart';

const _statusLabels = {
  'todo': 'Pendiente',
  'doing': 'En progreso',
  'done': 'Completada',
};

class TasksScreen extends StatefulWidget {
  final Board board;
  const TasksScreen({super.key, required this.board});
  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _service = TaskService();
  late Future<List<Task>> _tasks;
  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _tasks = _service.list(widget.board.id);
    });
  }

  Future<void> _open(Widget screen) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
    if (changed == true && mounted) _reload();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.board.name)),
    floatingActionButton: FloatingActionButton(
      onPressed: () => _open(TaskFormScreen(board: widget.board)),
      tooltip: 'Crear tarea',
      child: const Icon(Icons.add),
    ),
    body: FutureBuilder<List<Task>>(
      future: _tasks,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done)
          return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError)
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('No se pudieron cargar las tareas'),
                TextButton(onPressed: _reload, child: const Text('Reintentar')),
              ],
            ),
          );
        final tasks = snapshot.data!;
        if (tasks.isEmpty)
          return const Center(child: Text('Este tablero aún no tiene tareas.'));
        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(tasks[index].title),
              subtitle: Text(_statusLabels[tasks[index].status] ?? tasks[index].status),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _open(
              TaskDetailScreen(board: widget.board, task: tasks[index]),
            ),
          ),
        );
      },
    ),
  );
}

class TaskDetailScreen extends StatefulWidget {
  final Board board;
  final Task task;
  const TaskDetailScreen({super.key, required this.board, required this.task});
  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  Future<void> _edit() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TaskFormScreen(board: widget.board, task: widget.task),
      ),
    );
    if (changed == true && mounted) Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: const Text('¿Quieres eliminar esta tarea?'),
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
    if (confirmed != true) return;
    try {
      await TaskService().delete(widget.task);
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo eliminar la tarea')),
        );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Detalle de tarea'),
      actions: [
        IconButton(
          onPressed: _edit,
          icon: const Icon(Icons.edit),
          tooltip: 'Editar',
        ),
        IconButton(
          onPressed: _delete,
          icon: const Icon(Icons.delete),
          tooltip: 'Eliminar',
        ),
      ],
    ),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.task.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text('Estado: ${_statusLabels[widget.task.status] ?? widget.task.status}'),
          const SizedBox(height: 16),
          Text(
            widget.task.description?.isNotEmpty == true
                ? widget.task.description!
                : 'Sin descripción',
          ),
        ],
      ),
    ),
  );
}

class TaskFormScreen extends StatefulWidget {
  final Board board;
  final Task? task;
  const TaskFormScreen({super.key, required this.board, this.task});
  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late String _status;
  bool _saving = false;
  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.task?.title);
    _description = TextEditingController(text: widget.task?.description);
    _status = widget.task?.status ?? 'todo';
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final service = TaskService();
      final description = _description.text.trim();
      if (widget.task == null) {
        await service.create(
          boardId: widget.board.id,
          title: _title.text,
          description: description.isEmpty ? null : description,
          status: _status,
        );
      } else {
        await service.update(
          widget.task!,
          title: _title.text,
          description: description.isEmpty ? null : description,
          status: _status,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo guardar: ${error.message}')),
        );
      }
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo guardar la tarea. Revisa los datos y la conexión.',
            ),
          ),
        );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.task == null ? 'Nueva tarea' : 'Editar tarea'),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'El título es obligatorio'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _description,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(
                labelText: 'Estado',
                border: OutlineInputBorder(),
              ),
              items: _statusLabels.entries.map((entry) => DropdownMenuItem(value: entry.key, child: Text(entry.value))).toList(),
              onChanged: _saving ? null : (value) {
                if (value != null) setState(() => _status = value);
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Guardando...' : 'Guardar'),
            ),
          ],
        ),
      ),
    ),
  );
}
