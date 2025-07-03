import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../shared/services/database_service.dart';
import '../domain/todo_model.dart';

class LocalTodoDataSource {
  final dbFuture = DatabaseService.instance.database;

  Future<void> insertTodo(TodoModel todo) async {
    final db = await dbFuture;
    await db.insert('todos', todo.toMap());
  }

  Future<List<TodoModel>> fetchTodosForUser(int userId) async {
    final db = await dbFuture;
    final result = await db.query(
      'todos',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return result.map((e) => TodoModel.fromMap(e)).toList();
  }


  Future<void> updateTodo(TodoModel todo) async {
    final db = await dbFuture;
    await db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<void> deleteTodo(int id, int userId) async {
    final db = await dbFuture;
    await db.delete(
      'todos',
      where: 'id = ? AND userId = ?', // ✅ ensures only deleting user's own task
      whereArgs: [id, userId],
    );
  }

}
