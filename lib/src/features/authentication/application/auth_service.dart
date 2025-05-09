import 'package:saude_app/src/features/authentication/domain/auth_repository.dart';
import 'package:saude_app/src/features/authentication/domain/user_model.dart'; // Importa o User do domínio

class AuthService {
  final AuthRepository _authRepository;

  AuthService(this._authRepository);

  // Agora retorna Stream<User?> do domínio, conforme AuthRepository
  Stream<User?> get authStateChanges => _authRepository.authStateChanges;

  // Agora retorna Future<User?> do domínio
  Future<User?> signInWithEmailAndPassword(String email, String password) {
    return _authRepository.signInWithEmailAndPassword(email, password);
  }

  Future<void> signOut() {
    return _authRepository.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _authRepository.sendPasswordResetEmail(email);
  }

  // Agora retorna Future<User?> do domínio
  Future<User?> createUserWithEmailAndPassword(String email, String password) {
    return _authRepository.createUserWithEmailAndPassword(email, password);
  }

  // Se for necessário obter o usuário atual de forma síncrona, 
  // adicione `User? get currentUser;` à interface AuthRepository 
  // e implemente em FirebaseAuthRepository.
  // Exemplo: 
  // User? get currentUser => _authRepository.currentUser; 
}

