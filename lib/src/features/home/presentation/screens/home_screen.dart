// lib/src/features/home/presentation/screens/home_screen.dart

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:saude_app/src/features/authentication/application/auth_service.dart"; 
import "package:saude_app/src/features/dependents/presentation/screens/dependents_list_screen.dart";

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    // final user = ref.watch(firebaseAuthProvider).currentUser; // To get user display name or email if needed

    return Scaffold(
      appBar: AppBar(
        title: const Text("Saúde App"), // Changed title
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Sair",
            onPressed: () async {
              await authService.signOut();
              // AuthGate will handle navigation to LoginScreen
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Could display user's name here if available
              // Text("Bem-vindo(a), ${user?.displayName ?? user?.email ?? "Usuário"}!", 
              //   style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
              // const SizedBox(height: 32),
              Text(
                "Gerencie o histórico de saúde da sua família em um só lugar.",
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                icon: const Icon(Icons.people_alt_outlined),
                label: const Text("Gerenciar Dependentes"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const DependentsListScreen()),
                  );
                },
              ),
              const SizedBox(height: 24),
              // Placeholder for other features
              OutlinedButton.icon(
                icon: const Icon(Icons.summarize_outlined),
                label: const Text("Meus Exames (Em Breve)"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: () {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Funcionalidade de gerenciamento de exames em desenvolvimento.")),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

