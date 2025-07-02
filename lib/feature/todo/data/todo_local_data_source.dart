import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../shared/services/database_service.dart';
import '../domain/todo_model.dart';

class LocalTodoDataSource {
  final dbFuture = DatabaseService.instance.database;

  Future<void> insertTodo(TodoModel todo) async {
    final db = await dbFuture;
    await db.insert('todos', todo.toMap());
  }

  Future<List<TodoModel>> fetchAllTodos() async {
    final db = await dbFuture;
    final result = await db.query('todos', orderBy: 'id DESC');
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

  Future<void> deleteTodo(int id) async {
    final db = await dbFuture;
    await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
