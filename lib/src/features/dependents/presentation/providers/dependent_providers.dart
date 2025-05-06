// lib/src/features/dependents/presentation/providers/dependent_providers.dart

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:saude_app/src/features/dependents/domain/dependent_model.dart";
import "package:saude_app/src/features/dependents/infrastructure/dependent_repository.dart";

// Provider for FirebaseAuth instance
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

// Provider for FirebaseFirestore instance
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

// Provider for DependentRepository
final dependentRepositoryProvider = Provider<DependentRepository>((ref) {
  return DependentRepository(ref.watch(firebaseFirestoreProvider), ref.watch(firebaseAuthProvider));
});

// StreamProvider to get the list of dependents for the current user
final dependentsListStreamProvider = StreamProvider<List<Dependent>>((ref) {
  final repository = ref.watch(dependentRepositoryProvider);
  return repository.getDependentsStream();
});

// FutureProvider to get a single dependent by ID (can be used for details screen if needed)
// Not strictly necessary if we pass the Dependent object directly during navigation
final dependentDetailsProvider = FutureProvider.family<Dependent?, String>((ref, dependentId) async {
  final repository = ref.watch(dependentRepositoryProvider);
  return repository.getDependentById(dependentId);
});

// StateNotifierProvider for managing the state of adding/editing a dependent form
// This could be more complex if we need to manage loading/error states for form submission
// For now, the screens will handle their own _isLoading state, but a provider could centralize this.

// Provider for simple actions like add, update, delete that might involve async operations
// and can be called from UI.
// Example: A provider that exposes methods from the repository.
final dependentActionsProvider = Provider((ref) {
  return ref.watch(dependentRepositoryProvider); // Exposes the repository directly for actions
});

