import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/board.dart';

class BoardService {
  final _client = Supabase.instance.client;

  Future<List<Board>> list() async {
    final user = _client.auth.currentUser;
    if (user == null) throw StateError('Debes iniciar sesión');
    final rows = await _client
        .from('boards')
        .select()
        .eq('user_id', user.id)
        .order('created_at');
    return rows.map(Board.fromMap).toList();
  }

  Future<void> create(String name) async {
    final user = _client.auth.currentUser;
    if (user == null) throw StateError('Debes iniciar sesión');
    await _client.from('boards').insert({
      'name': name.trim(),
      'user_id': user.id,
    });
  }
}
