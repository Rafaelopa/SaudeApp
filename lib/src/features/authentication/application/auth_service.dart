// Application layer for authentication (e.g., AuthService)

import 'package:saude_app/src/features/authentication/domain/auth_repository.dart';

class AuthService {
  final AuthRepository _authRepository;

  AuthService(this._authRepository);

  Stream<User?> get authStateChanges => _authRepository.authStateChanges;

  Future<User?> signInWithEmailAndPassword(String email, String password) {
    // Add any business logic, validation, or logging here before calling the repository
    return _authRepository.signInWithEmailAndPassword(email, password);
  }

  Future<User?> createUserWithEmailAndPassword(String email, String password) {
    // Add any business logic, validation, or logging here
    return _authRepository.createUserWithEmailAndPassword(email, password);
  }

  Future<void> signOut() {
    return _authRepository.signOut();
  }
}

