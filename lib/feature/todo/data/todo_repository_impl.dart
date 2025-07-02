import '../domain/todo_model.dart';
import '../domain/todo_repository.dart';
import 'todo_local_data_source.dart';

class TodoRepositoryImpl implements TodoRepository {
  final LocalTodoDataSource _dataSource = LocalTodoDataSource();

  @override
  Future<void> addTodo(TodoModel todo) async {
    try {
      await _dataSource.insertTodo(todo);
    } catch (e) {
      print('❌ Error adding todo: $e');
      rethrow;
    }
  }

  @override
  Future<List<TodoModel>> getAllTodos(int userId) async {
    try {
      return await _dataSource.fetchTodosForUser(userId);
    } catch (e) {
      print('❌ Error fetching todos for user $userId: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateTodo(TodoModel todo) async {
    try {
      await _dataSource.updateTodo(todo);
    } catch (e) {
      print('❌ Error updating todo: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteTodo(int id, int userId) async {
    try {
      await _dataSource.deleteTodo(id, userId);
    } catch (e) {
      print('❌ Error deleting todo with id $id for user $userId: $e');
      rethrow;
    }
  }
}
