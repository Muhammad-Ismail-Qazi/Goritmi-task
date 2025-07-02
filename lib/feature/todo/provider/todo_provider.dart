import 'package:flutter/material.dart';
import '../data/todo_repository_impl.dart';
import '../domain/todo_model.dart';

class TodoProvider with ChangeNotifier {
  final TodoRepositoryImpl _repository = TodoRepositoryImpl();

  List<TodoModel> _tasks = [];
  List<TodoModel> get tasks => _tasks;

  String? _error;
  String? get error => _error;

  /// Load all tasks from DB for a specific user
  Future<void> loadTasks(int userId) async {
    try {
      _tasks = await _repository.getAllTodos(userId); // ✅ fixed method name
      print('✅ Loaded ${_tasks.length} tasks for user $userId');
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
      await loadTasks(todo.userId); // ✅ reload tasks for that user
    } catch (e) {
      _error = "Failed to add task";
      notifyListeners();
    }
  }

  /// Update an existing task
  Future<void> updateTask(TodoModel todo) async {
    try {
      await _repository.updateTodo(todo);
      await loadTasks(todo.userId); // ✅ reload tasks for that user
    } catch (e) {
      _error = "Failed to update task";
      notifyListeners();
    }
  }

  /// Delete a task by ID and user ID
  Future<void> deleteTask(int id, int userId) async {
    try {
      await _repository.deleteTodo(id, userId); // ✅ pass userId
      await loadTasks(userId); // ✅ reload tasks for that user
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
