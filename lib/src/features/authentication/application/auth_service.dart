import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import 'package:saude_app/src/features/authentication/domain/auth_repository.dart';

class AuthService {
  final AuthRepository _authRepository;

  AuthService(this._authRepository);

  Stream<fb_auth.User?> get authStateChanges => _authRepository.authStateChanges;

  Future<fb_auth.User?> signInWithEmailAndPassword(String email, String password) {
    return _authRepository.signInWithEmailAndPassword(email, password);
  }

  Future<void> signOut() {
    return _authRepository.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _authRepository.sendPasswordResetEmail(email);
  }

  Future<fb_auth.User?> createUserWithEmailAndPassword(String email, String password) {
    return _authRepository.createUserWithEmailAndPassword(email, password);
  }

  fb_auth.User? get currentUser => _authRepository.currentUser;
}
