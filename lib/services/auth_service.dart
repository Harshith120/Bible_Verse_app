import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException(this.message, [this.code]);

  @override
  String toString() => 'AuthException: $message ${code != null ? '(Code: $code)' : ''}';
}

class AuthService {
  final FirebaseAuth? _customAuth;

  AuthService({FirebaseAuth? firebaseAuth})
      : _customAuth = firebaseAuth;

  FirebaseAuth get _instance {
    if (_customAuth != null) return _customAuth!;
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      throw AuthException('Firebase Auth is not initialized yet.');
    }
  }

  /// Current user getter
  UserModel? get currentUser {
    try {
      final user = _instance.currentUser;
      return user != null ? UserModel.fromFirebaseUser(user) : null;
    } catch (_) {
      return null;
    }
  }

  /// Auth state changes stream
  Stream<UserModel?> get authStateChanges {
    try {
      return _instance.authStateChanges().map(
            (user) => user != null ? UserModel.fromFirebaseUser(user) : null,
          );
    } catch (_) {
      return Stream.value(null);
    }
  }

  /// Sign in with Email and Password
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        return UserModel.fromFirebaseUser(credential.user!);
      } else {
        throw AuthException('Failed to sign in. User is null.');
      }
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('An unexpected error occurred during sign in: ${e.toString()}');
    }
  }

  /// Register / Sign up with Email and Password
  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        return UserModel.fromFirebaseUser(credential.user!);
      } else {
        throw AuthException('Failed to register. User is null.');
      }
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('An unexpected error occurred during registration: ${e.toString()}');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _instance.signOut();
    } catch (e) {
      // Gracefully handle sign out error if auth instance is not active
    }
  }

  /// Maps FirebaseAuthException codes to user-friendly messages
  AuthException _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthException('No user found with this email address.', e.code);
      case 'wrong-password':
        return AuthException('Incorrect password provided.', e.code);
      case 'email-already-in-use':
        return AuthException('An account already exists for this email.', e.code);
      case 'invalid-email':
        return AuthException('The email address format is invalid.', e.code);
      case 'weak-password':
        return AuthException('Password must be at least 6 characters.', e.code);
      case 'user-disabled':
        return AuthException('This user account has been disabled.', e.code);
      case 'too-many-requests':
        return AuthException('Too many unsuccessful attempts. Please try again later.', e.code);
      case 'network-request-failed':
        return AuthException('Network error. Please check your internet connection.', e.code);
      default:
        return AuthException(e.message ?? 'Authentication failed.', e.code);
    }
  }
}
