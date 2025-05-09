// Domain layer for authentication (e.g., User model, AuthRepository interface)

class User {
  final String uid;
  final String? email;
  // Adicione outros campos relevantes do usuário do seu domínio aqui

  User({required this.uid, this.email});
}

abstract class AuthRepository {
  Future<User?> signInWithEmailAndPassword(String email, String password);
  Future<User?> createUserWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Stream<User?> get authStateChanges; // Deve retornar o User do domínio
  Future<void> sendPasswordResetEmail(String email);
  // Se precisar do usuário atual do Firebase, a implementação pode buscar, mas a interface foca no domínio
  // User? get currentUser; // Se for um requisito do domínio ter o usuário atual de forma síncrona
}

