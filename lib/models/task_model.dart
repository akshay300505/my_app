class TaskModel {
  final String id;
  final String title;
  final bool completed;
  final DateTime dueDate;

  TaskModel({
    required this.id,
    required this.title,
    required this.completed,
    required this.dueDate,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      title: map['title'],
      completed: map['completed'],
      dueDate: DateTime.parse(map['dueDate']),
    );
  }

  Map<String, dynamic> toMap() => {
        "id": id,
        "title": title,
        "completed": completed,
        "dueDate": dueDate.toIso8601String(),
      };
}