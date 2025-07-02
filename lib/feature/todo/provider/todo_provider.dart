import 'package:flutter/material.dart';
import '../data/todo_repository_impl.dart';
import '../domain/todo_model.dart';

class TodoProvider with ChangeNotifier {
  final TodoRepositoryImpl _repository = TodoRepositoryImpl();

  List<TodoModel> _tasks = [];
  List<TodoModel> get tasks => _tasks;

  String? _error;
  String? get error => _error;

  /// Load all tasks from DB
  Future<void> loadTasks() async {
    try {
      _tasks = await _repository.getAllTodos();
      print('✅ Loaded ${_tasks.length} tasks');
      notifyListeners();
    } catch (e) {
      _error = "Failed to load tasks";
      notifyListeners();
    }
  }


  /// Add a new task
  Future<void> addTask(TodoModel todo) async {
    try {
      await _repository.addTodo(todo);
      await loadTasks();
    } catch (e) {
      _error = "Failed to add task";
      notifyListeners();
    }
  }

  /// Update an existing task
  Future<void> updateTask(TodoModel todo) async {
    try {
      await _repository.updateTodo(todo);
      await loadTasks();
    } catch (e) {
      _error = "Failed to update task";
      notifyListeners();
    }
  }

  /// Delete a task by ID
  Future<void> deleteTask(int id) async {
    try {
      await _repository.deleteTodo(id);
      await loadTasks();
    } catch (e) {
      _error = "Failed to delete task";
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
