import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TimeManagementProvider extends ChangeNotifier {
  final List<TaskModel> _tasks = [];

  List<TaskModel> get tasks => _tasks;

  void addTask(TaskModel task) {
    _tasks.add(task);
    notifyListeners();
  }

  void toggleTask(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index] = TaskModel(
        id: _tasks[index].id,
        title: _tasks[index].title,
        completed: !_tasks[index].completed,
        dueDate: _tasks[index].dueDate,
      );
      notifyListeners();
    }
  }
}