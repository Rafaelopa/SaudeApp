import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saude_app/src/features/authentication/domain/auth_repository.dart'; // Import direto
import 'package:saude_app/src/features/authentication/domain/user_model.dart'; // Import direto para User
import 'package:saude_app/src/features/authentication/infrastructure/firebase_auth_repository.dart';
import 'package:saude_app/src/features/authentication/application/auth_service.dart';

final firebaseAuthProvider = Provider<fb_auth.FirebaseAuth>((ref) {
  return fb_auth.FirebaseAuth.instance;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) { // Sem alias
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return FirebaseAuthRepository(firebaseAuth);
});

final authServiceProvider = Provider<AuthService>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthService(authRepository);
});

// Provider for authStateChanges usando o User do domínio diretamente
final authStateChangesProvider = StreamProvider<User?>((ref) { // User do domínio
  final authService = ref.watch(authServiceProvider);
  // Precisa garantir que authService.authStateChanges retorne Stream<User?> do domínio
  return authService.authStateChanges;
});

