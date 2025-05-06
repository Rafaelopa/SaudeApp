// Domain layer for authentication (e.g., User model, AuthRepository interface)

class User {
  final String uid;
  final String? email;

  User({required this.uid, this.email});
}

abstract class AuthRepository {
  Future<User?> signInWithEmailAndPassword(String email, String password);
  Future<User?> createUserWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Stream<User?> get authStateChanges;
}

