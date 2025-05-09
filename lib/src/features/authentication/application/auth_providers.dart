import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:saude_app/src/features/authentication/domain/auth_repository.dart';
import 'package:saude_app/src/features/authentication/infrastructure/firebase_auth_repository.dart';
import 'package:saude_app/src/features/authentication/application/auth_service.dart';

// Provider for FirebaseAuth instance
final firebaseAuthInstanceProvider = Provider<fb_auth.FirebaseAuth>((ref) {
  return fb_auth.FirebaseAuth.instance;
});

// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthInstanceProvider);
  return FirebaseAuthRepository(firebaseAuth);
});

// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthService(authRepository);
});

// Provider for authStateChanges stream
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

