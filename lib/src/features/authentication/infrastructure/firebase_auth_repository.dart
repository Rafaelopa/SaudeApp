import 'package:firebase_auth/firebase_auth.dart';
import 'package:saude_app/src/features/authentication/domain/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthRepository(this._firebaseAuth);

  @override
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    // TODO: Implement signInWithEmailAndPassword
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return User(uid: userCredential.user!.uid, email: userCredential.user!.email);
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  @override
  Future<User?> createUserWithEmailAndPassword(String email, String password) async {
    // TODO: Implement createUserWithEmailAndPassword
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      return User(uid: userCredential.user!.uid, email: userCredential.user!.email);
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    // TODO: Implement signOut
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  @override
  Stream<User?> get authStateChanges {
    // TODO: Implement authStateChanges
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) return null;
      return User(uid: firebaseUser.uid, email: firebaseUser.email);
    });
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      // Handle error, e.g., throw a custom exception or log the error
      print('Error sending password reset email: $e');
      rethrow; // Or handle it more gracefully depending on your app's needs
    }
  }
}

