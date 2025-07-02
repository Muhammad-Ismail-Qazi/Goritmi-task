
import 'package:todo_desktop_app/feature/todo/domain/todo_model.dart';

abstract class TodoRepository {
  Future<void> addTodo(TodoModel todo);
  Future<List<TodoModel>> getAllTodos();
  Future<void> updateTodo(TodoModel todo);
  Future<void> deleteTodo(int id);
}
