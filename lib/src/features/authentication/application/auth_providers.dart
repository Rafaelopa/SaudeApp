import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saude_app/src/features/authentication/domain/auth_repository.dart'; // Imports domain.User
import 'package:saude_app/src/features/authentication/infrastructure/firebase_auth_repository.dart';
import 'package:saude_app/src/features/authentication/application/auth_service.dart';

final firebaseAuthProvider = Provider<fb_auth.FirebaseAuth>((ref) {
  return fb_auth.FirebaseAuth.instance;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return FirebaseAuthRepository(firebaseAuth);
});

final authServiceProvider = Provider<AuthService>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthService(authRepository);
});

// Provider for authStateChanges using domain User
final authStateChangesProvider = StreamProvider<User?>((ref) { // Changed fb_auth.User? to domain User?
  final authService = ref.watch(authServiceProvider);
  // authService.authStateChanges returns Stream<domain.User?>, which matches this type.
  return authService.authStateChanges;
});

