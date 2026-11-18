import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../services/auth_service.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated, authenticating, error }

class AppAuthProvider with ChangeNotifier {
  final AuthRepository repository;
  StreamSubscription<UserModel?>? _authSubscription;

  AuthStatus _status = AuthStatus.uninitialized;
  UserModel? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isAuthenticating => _status == AuthStatus.authenticating;

  AppAuthProvider({AuthRepository? repository})
      : repository = repository ?? AuthRepository() {
    _init();
  }

  void _init() {
    try {
      _user = repository.currentUser;
      _status = _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;

      _authSubscription = repository.authStateChanges.listen((user) {
        _user = user;
        _status = user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
        notifyListeners();
      }, onError: (error) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      });
    } catch (_) {
      // In testing environments or without Firebase config initialized
      _status = AuthStatus.unauthenticated;
    }
  }

  /// Sign in with Email and Password
  Future<bool> signIn(String email, String password) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await repository.signIn(email, password);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Sign in failed. Please check your credentials.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Register / Sign Up with Email and Password
  Future<bool> signUp(String email, String password) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await repository.signUp(email, password);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Registration failed. Please try again.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    try {
      await repository.signOut();
      _user = null;
      _status = AuthStatus.unauthenticated;
    } catch (e) {
      _errorMessage = 'Sign out failed.';
    } finally {
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
