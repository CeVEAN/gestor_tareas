class Task {
  final String id;
  final String boardId;
  final String title;
  final String? description;
  final String status;

  const Task({
    required this.id,
    required this.boardId,
    required this.title,
    this.description,
    required this.status,
  });

  factory Task.fromMap(Map<String, dynamic> map) => Task(
    id: map['id'] as String,
    boardId: map['board_id'] as String,
    title: map['title'] as String,
    description: map['description'] as String?,
    status: map['status'] as String,
  );
}
