// Presentation layer - AuthGate to handle navigation based on auth state

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saude_app/src/features/authentication/application/auth_providers.dart'; // Updated to use central providers
import 'package:saude_app/src/features/authentication/domain/auth_repository.dart'; // For User model
import 'package:saude_app/src/features/authentication/presentation/screens/login_screen.dart';
import 'package:saude_app/src/features/home/presentation/screens/home_screen.dart'; 

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          // User is logged in, navigate to HomeScreen
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

