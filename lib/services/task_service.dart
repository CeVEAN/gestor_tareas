import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/task.dart';

class TaskService {
  final _client = Supabase.instance.client;

  String get _userId =>
      _client.auth.currentUser?.id ??
      (throw StateError('Debes iniciar sesión'));

  Future<List<Task>> list(String boardId) async {
    final rows = await _client
        .from('tasks')
        .select()
        .eq('board_id', boardId)
        .eq('user_id', _userId)
        .order('created_at');
    return rows.map(Task.fromMap).toList();
  }

  Future<void> create({
    required String boardId,
    required String title,
    String? description,
    required String status,
  }) async {
    await _client.from('tasks').insert({
      'board_id': boardId,
      'user_id': _userId,
      'title': title.trim(),
      'description': description,
      'status': status,
    });
  }

  Future<void> update(
    Task task, {
    required String title,
    String? description,
    required String status,
  }) async {
    await _client
        .from('tasks')
        .update({
          'title': title.trim(),
          'description': description,
          'status': status,
        })
        .eq('id', task.id)
        .eq('user_id', _userId);
  }

  Future<void> delete(Task task) async {
    await _client
        .from('tasks')
        .delete()
        .eq('id', task.id)
        .eq('user_id', _userId);
  }
}
