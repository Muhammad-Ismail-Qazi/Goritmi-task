import 'package:todo_desktop_app/feature/auth/domain/user_model.dart';

abstract class AuthRepository {
  Future<String?> signup(String email, String password);
  Future<UserModel?> login(String email, String password);
  void logout();
  UserModel? get currentUser;
}
