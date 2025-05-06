// Infrastructure layer for authentication using Firebase

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:saude_app/src/features/authentication/domain/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;

  FirebaseAuthRepository({firebase_auth.FirebaseAuth? firebaseAuth}) 
      : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;

  @override
  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) {
        return null;
      }
      return User(uid: firebaseUser.uid, email: firebaseUser.email);
    });
  }

  @override
  Future<User?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        return User(uid: userCredential.user!.uid, email: userCredential.user!.email);
      }
      return null;
    } catch (e) {
      // TODO: Handle specific Firebase exceptions
      print(e.toString());
      throw e; // Or a custom exception
    }
  }

  @override
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        return User(uid: userCredential.user!.uid, email: userCredential.user!.email);
      }
      return null;
    } catch (e) {
      // TODO: Handle specific Firebase exceptions
      print(e.toString());
      throw e; // Or a custom exception
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      // TODO: Handle specific Firebase exceptions
      print(e.toString());
      throw e; // Or a custom exception
    }
  }
}

