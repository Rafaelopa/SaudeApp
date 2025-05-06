// lib/src/features/dependents/domain/dependent_model.dart

import "package:cloud_firestore/cloud_firestore.dart";

class Dependent {
  final String? id; // Firestore document ID
  final String userId; // ID of the parent user
  final String name;
  final DateTime dateOfBirth;
  final String? biologicalSex;
  final String relationship; // e.g., "Filho(a)", "Enteado(a)"
  final String? customRelationship; // If relationship is "Outro"
  final String? photoUrl; // URL of the profile picture in Firebase Storage
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Dependent({
    this.id,
    required this.userId,
    required this.name,
    required this.dateOfBirth,
    this.biologicalSex,
    required this.relationship,
    this.customRelationship,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor to create a Dependent from a Firestore DocumentSnapshot
  factory Dependent.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    final data = snapshot.data();
    return Dependent(
      id: snapshot.id,
      userId: data?["userId"],
      name: data?["name"],
      dateOfBirth: (data?["dateOfBirth"] as Timestamp).toDate(),
      biologicalSex: data?["biologicalSex"],
      relationship: data?["relationship"],
      customRelationship: data?["customRelationship"],
      photoUrl: data?["photoUrl"],
      createdAt: data?["createdAt"] ?? Timestamp.now(), // Provide default if null
      updatedAt: data?["updatedAt"] ?? Timestamp.now(), // Provide default if null
    );
  }

  // Method to convert a Dependent instance to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      "userId": userId,
      "name": name,
      "dateOfBirth": Timestamp.fromDate(dateOfBirth),
      if (biologicalSex != null) "biologicalSex": biologicalSex,
      "relationship": relationship,
      if (customRelationship != null) "customRelationship": customRelationship,
      if (photoUrl != null) "photoUrl": photoUrl,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }

  Dependent copyWith({
    String? id,
    String? userId,
    String? name,
    DateTime? dateOfBirth,
    String? biologicalSex,
    String? relationship,
    String? customRelationship,
    String? photoUrl,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    bool setCustomRelationshipToNull = false,
    bool setBiologicalSexToNull = false,
    bool setPhotoUrlToNull = false,
  }) {
    return Dependent(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      biologicalSex: setBiologicalSexToNull ? null : biologicalSex ?? this.biologicalSex,
      relationship: relationship ?? this.relationship,
      customRelationship: setCustomRelationshipToNull ? null : customRelationship ?? this.customRelationship,
      photoUrl: setPhotoUrlToNull ? null : photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

