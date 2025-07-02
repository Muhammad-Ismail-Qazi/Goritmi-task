import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../shared/services/database_service.dart';
import '../domain/user_model.dart';

class LocalAuthDataSource {
  final dbService = DatabaseService();

  /// Register a user (throws Exception if user already exists)
  Future<void> registerUser(UserModel user) async {
    final db = await dbService.database;

    // Check if user already exists
    final existingUser = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [user.email],
    );

    if (existingUser.isNotEmpty) {
      print('⚠️ User already exists in DB');
      throw Exception("User already exists");
    }

    try {
      await db.insert(
        'users',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } catch (e) {
      print('❌ DB Insert Error: $e');
      throw Exception("Failed to register user: $e");
    }
  }


  /// Login a user with email and password
  Future<UserModel?> loginUser(String email, String password) async {
    final db = await dbService.database;

    try {
      final result = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );

      if (result.isNotEmpty) {
        return UserModel.fromMap(result.first);
      }
      return null;
    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }
}
