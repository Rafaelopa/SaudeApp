import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saude_app/src/features/authentication/domain/auth_repository.dart';
import 'package:saude_app/src/features/authentication/infrastructure/firebase_auth_repository.dart'; // Added import for FirebaseAuthRepository
import 'package:saude_app/src/features/authentication/application/auth_service.dart'; // Added import for AuthService

// Provider for FirebaseAuth instance
final firebaseAuthProvider = Provider<fb_auth.FirebaseAuth>((ref) {
  return fb_auth.FirebaseAuth.instance;
});

// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return FirebaseAuthRepository(firebaseAuth);
});

// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthService(authRepository);
});

// Provider for authStateChanges
final authStateChangesProvider = StreamProvider<fb_auth.User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  // Assuming authStateChanges in AuthService returns a Stream<fb_auth.User?>
  // If it returns Stream<User?>, ensure User is correctly typed or aliased.
  return authService.authStateChanges; 
});

