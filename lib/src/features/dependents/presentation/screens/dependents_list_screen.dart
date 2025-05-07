// lib/src/features/dependents/presentation/screens/dependents_list_screen.dart

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:saude_app/src/features/dependents/domain/dependent_model.dart";
import "package:saude_app/src/features/dependents/presentation/providers/dependent_providers.dart";
import "package:saude_app/src/features/dependents/presentation/screens/add_dependent_screen.dart";
import "package:saude_app/src/features/dependents/presentation/screens/view_edit_dependent_screen.dart";

class DependentsListScreen extends ConsumerWidget {
  const DependentsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDependents = ref.watch(dependentsListStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Meus Dependentes"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: "Adicionar Dependente",
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AddDependentScreen()),
              );
            },
          ),
        ],
      ),
      body: asyncDependents.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Erro ao carregar dependentes: $err", textAlign: TextAlign.center),
          ),
        ),
        data: (dependents) {
          if (dependents.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildDependentsList(context, dependents);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.people_outline, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            Text(
              "Você ainda não adicionou nenhum dependente.",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "Adicione perfis para seus filhos ou outros dependentes para gerenciar o histórico de saúde deles.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Adicionar Dependente"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AddDependentScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDependentsList(BuildContext context, List<Dependent> dependents) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: dependents.length,
      itemBuilder: (context, index) {
        final dependent = dependents[index];
        final age = DateTime.now().year - dependent.dateOfBirth.year; // Basic age calculation
        // TODO: Refine age calculation (consider months/days and birthday passed this year)

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: dependent.photoUrl != null && dependent.photoUrl!.isNotEmpty 
                  ? NetworkImage(dependent.photoUrl!) 
                  : null,
              backgroundColor: Colors.grey[300],
              child: (dependent.photoUrl == null || dependent.photoUrl!.isEmpty) 
                  ? Text(dependent.name.isNotEmpty ? dependent.name[0].toUpperCase() : "?", style: const TextStyle(fontSize: 24))
                  : null,
            ),
            title: Text(dependent.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${dependent.relationship == "Outro" && dependent.customRelationship != null && dependent.customRelationship!.isNotEmpty ? dependent.customRelationship : dependent.relationship} - $age anos"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              if (dependent.id != null) {
                 Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ViewEditDependentScreen(dependentId: dependent.id!, initialDependentData: dependent),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Erro: ID do dependente não encontrado.")),
                );
              }
            },
          ),
        );
      },
    );
  }
}

