import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService authService;

  AuthRepository({AuthService? authService})
      : authService = authService ?? AuthService();

  UserModel? get currentUser => authService.currentUser;

  Stream<UserModel?> get authStateChanges => authService.authStateChanges;

  Future<UserModel> signIn(String email, String password) async {
    return await authService.signInWithEmail(email: email, password: password);
  }

  Future<UserModel> signUp(String email, String password) async {
    return await authService.registerWithEmail(email: email, password: password);
  }

  Future<void> signOut() async {
    await authService.signOut();
  }
}
