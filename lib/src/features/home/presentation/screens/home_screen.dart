// Placeholder for Home Screen

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:saude_app/src/features/authentication/application/auth_service.dart"; // For signOut

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    // TODO: Get user details if needed from another provider

    return Scaffold(
      appBar: AppBar(
        title: const Text("Página Inicial"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              // AuthGate will handle navigation to LoginScreen
            },
          ),
        ],
      ),
      body: const Center(
        child: Text("Bem-vindo(a) ao Saúde App!"),
      ),
    );
  }
}

