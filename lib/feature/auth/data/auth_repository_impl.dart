import '../../auth/domain/auth_repository.dart';
import '../../auth/domain/user_model.dart';
import 'local_auth_db.dart';

class AuthRepositoryImpl implements AuthRepository {
  final LocalAuthDataSource _dataSource = LocalAuthDataSource();
  UserModel? _user;

  @override
  Future<String?> signup(String email, String password) async {
    try {
      await _dataSource.registerUser(UserModel(email: email, password: password));
      return null;
    } on Exception catch (e) {
      // You can distinguish exceptions if LocalAuthDataSource throws specific types
      return "User already exists or error occurred.";
    } catch (e) {
      // For unexpected errors
      return "Unexpected signup error: $e";
    }
  }

  @override
  Future<UserModel?> login(String email, String password) async {
    try {
      final result = await _dataSource.loginUser(email, password);
      _user = result;
      return result;
    } catch (e) {
      // Optionally handle unexpected login errors
      return null;
    }
  }

  @override
  void logout() {
    _user = null;
  }

  @override
  UserModel? get currentUser => _user;
}
