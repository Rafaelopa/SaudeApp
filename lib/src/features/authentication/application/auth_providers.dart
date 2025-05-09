import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Alias the import for domain User to avoid any ambiguity
import 'package:saude_app/src/features/authentication/domain/auth_repository.dart' as domain_repo;
import 'package:saude_app/src/features/authentication/infrastructure/firebase_auth_repository.dart';
import 'package:saude_app/src/features/authentication/application/auth_service.dart';

final firebaseAuthProvider = Provider<fb_auth.FirebaseAuth>((ref) {
  return fb_auth.FirebaseAuth.instance;
});

// Ensure AuthRepository uses the aliased domain types if necessary within its definition
final authRepositoryProvider = Provider<domain_repo.AuthRepository>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return FirebaseAuthRepository(firebaseAuth);
});

// Ensure AuthService is correctly typed and uses aliased domain types if necessary
final authServiceProvider = Provider<AuthService>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthService(authRepository);
});

// Provider for authStateChanges using domain User explicitly with alias
final authStateChangesProvider = StreamProvider<domain_repo.User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  // authService.authStateChanges should return Stream<domain_repo.User?>
  return authService.authStateChanges;
});

