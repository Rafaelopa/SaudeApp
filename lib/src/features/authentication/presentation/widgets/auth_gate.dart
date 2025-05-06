// Presentation layer - AuthGate to handle navigation based on auth state

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saude_app/src/features/authentication/application/auth_service.dart'; // Assuming AuthService is set up with Riverpod
import 'package:saude_app/src/features/authentication/domain/auth_repository.dart'; // For User model
import 'package:saude_app/src/features/authentication/infrastructure/firebase_auth_repository.dart'; // For concrete implementation
import 'package:saude_app/src/features/authentication/presentation/screens/login_screen.dart';
import 'package:saude_app/src/features/home/presentation/screens/home_screen.dart'; // Placeholder for home screen

// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository(); // Or any other implementation
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

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          // User is logged in, navigate to HomeScreen (placeholder)
          return const HomeScreen(); 
        } else {
          // User is not logged in, show LoginScreen
          return const LoginScreen();
        }
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(child: Text('Erro na autenticação: $error')),
      ),
    );
  }
}

