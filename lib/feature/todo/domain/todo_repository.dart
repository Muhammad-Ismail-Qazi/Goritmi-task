import 'package:todo_desktop_app/feature/todo/domain/todo_model.dart';

abstract class TodoRepository {
  Future<void> addTodo(TodoModel todo);
  Future<List<TodoModel>> getAllTodos(int userId); // 👈 Pass userId to filter
  Future<void> updateTodo(TodoModel todo);
  Future<void> deleteTodo(int id, int userId); // 👈 Pass userId for secure deletion
}
