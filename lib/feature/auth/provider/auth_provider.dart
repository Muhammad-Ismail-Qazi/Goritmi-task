import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/auth_repository_impl.dart';
import '../domain/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepositoryImpl _authRepository = AuthRepositoryImpl();

  String? _error;
  String? get error => _error;
  bool obscurePassword = true;

  UserModel? get user => _authRepository.currentUser;

  void setError(String? msg) {
    _error = msg;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  Future<void> checkLoginStatus(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (isLoggedIn) {
      // You can reload user data if needed here
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacementNamed(context, '/home');
      });
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      final result = await _authRepository.login(email, password);
      if (result != null) {
        setError(null); // clear old error
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
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

  Future<void> logout() async {
    try {
      _authRepository.logout();
      _error = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('is_logged_in');
      notifyListeners();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }
}
