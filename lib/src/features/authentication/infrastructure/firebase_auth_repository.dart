import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:saude_app/src/features/authentication/domain/auth_repository.dart';
import 'package:saude_app/src/features/authentication/domain/user_model.dart'; // Garanta que este é o User do seu domínio

class FirebaseAuthRepository implements AuthRepository {
  final fb_auth.FirebaseAuth _firebaseAuth;

  FirebaseAuthRepository(this._firebaseAuth);

  @override
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null) {
        // Mapeia do fb_auth.User para o seu User do domínio
        return User(uid: userCredential.user!.uid, email: userCredential.user!.email);
      }
      return null;
    } catch (e) {
      // Considere um tratamento de erro mais robusto ou logging
      print('Error signing in: $e');
      rethrow; // Ou retorne um erro específico do seu domínio
    }
  }

  @override
  Future<User?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null) {
        // Mapeia do fb_auth.User para o seu User do domínio
        return User(uid: userCredential.user!.uid, email: userCredential.user!.email);
      }
      return null;
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  @override
  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) return null;
      // Mapeia do fb_auth.User para o seu User do domínio
      return User(uid: firebaseUser.uid, email: firebaseUser.email);
    });
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error sending password reset email: $e');
      rethrow;
    }
  }

  // Se você decidir adicionar currentUser à interface AuthRepository:
  /*
  @override
  User? get currentUser {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser == null) return null;
    return User(uid: fbUser.uid, email: fbUser.email);
  }
  */
}

