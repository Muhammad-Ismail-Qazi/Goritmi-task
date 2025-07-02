import 'package:flutter/cupertino.dart';
import '../data/auth_repository_impl.dart';
import '../domain/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepositoryImpl _authRepository = AuthRepositoryImpl();

  String? _error;
  String? get error => _error;

  UserModel? get user => _authRepository.currentUser;

  void setError(String? msg) {
    _error = msg;
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    try {
      final result = await _authRepository.login(email, password);
      if (result != null) {
        setError(null); // clear old error
        notifyListeners();
        return null;
      } else {
        setError("Invalid credentials");
        return "Invalid credentials";
      }
    } catch (e) {
      setError("Something went wrong. Please try again.");
      debugPrint('Login error: $e');
      return "Unexpected error occurred";
    }
  }

  Future<String?> signup(String email, String password) async {
    try {
      final error = await _authRepository.signup(email, password);
      setError(error);
      return error;
    } catch (e) {
      setError("Signup failed. Please try again.");
      debugPrint('Signup error: $e');
      return "Unexpected error occurred";
    }
  }

  void logout() {
    try {
      _authRepository.logout();
      _error = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }
}
