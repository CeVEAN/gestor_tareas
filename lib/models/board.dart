class Board {
  final String id;
  final String name;

  const Board({required this.id, required this.name});

  factory Board.fromMap(Map<String, dynamic> map) =>
      Board(id: map['id'] as String, name: map['name'] as String);
}
