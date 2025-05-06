// lib/src/features/dependents/infrastructure/dependent_repository.dart

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:saude_app/src/features/dependents/domain/dependent_model.dart";

class DependentRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  DependentRepository(this._firestore, this._firebaseAuth);

  String? get _currentUserId => _firebaseAuth.currentUser?.uid;

  // Get the dependents collection reference
  CollectionReference<Dependent> _dependentsRef(String userId) {
    return _firestore
        .collection("users")
        .doc(userId)
        .collection("dependents")
        .withConverter<Dependent>(
          fromFirestore: Dependent.fromFirestore,
          toFirestore: (Dependent dependent, _) => dependent.toFirestore(),
        );
  }

  // Add a new dependent
  Future<void> addDependent(Dependent dependent) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception("Usuário não autenticado.");
    }
    // Ensure the dependent has the correct userId and timestamps before saving
    final now = Timestamp.now();
    final dependentWithMeta = dependent.copyWith(
      userId: userId,
      createdAt: now,
      updatedAt: now,
    );
    await _dependentsRef(userId).add(dependentWithMeta);
  }

  // Get a stream of dependents for the current user
  Stream<List<Dependent>> getDependentsStream() {
    final userId = _currentUserId;
    if (userId == null) {
      return Stream.value([]); // Or Stream.error(Exception("Usuário não autenticado."));
    }
    return _dependentsRef(userId)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Get a single dependent by ID (not typically needed if list is already fetched, but can be useful)
  Future<Dependent?> getDependentById(String dependentId) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception("Usuário não autenticado.");
    }
    final doc = await _dependentsRef(userId).doc(dependentId).get();
    return doc.data();
  }

  // Update an existing dependent
  Future<void> updateDependent(Dependent dependent) async {
    final userId = _currentUserId;
    if (userId == null || dependent.id == null) {
      throw Exception("Usuário não autenticado ou ID do dependente ausente.");
    }
    final dependentWithMeta = dependent.copyWith(updatedAt: Timestamp.now());
    await _dependentsRef(userId).doc(dependent.id).update(dependentWithMeta.toFirestore());
  }

  // Delete a dependent
  Future<void> deleteDependent(String dependentId) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception("Usuário não autenticado.");
    }
    await _dependentsRef(userId).doc(dependentId).delete();
    // TODO: Consider deleting associated photo from Firebase Storage if photoUrl exists
  }
}

