import "package:cloud_firestore/cloud_firestore.dart";
import "package:saude_app/src/features/sharing/domain/sharing_model.dart";

class SharingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = "sharedLinks";

  Future<SharedLinkModel> createShareLink(SharedLinkModel linkModel) async {
    try {
      DocumentReference docRef = await _firestore.collection(_collectionPath).add(linkModel.toMap());
      // Retornar o modelo com o ID preenchido
      return SharedLinkModel(
        id: docRef.id,
        userId: linkModel.userId,
        patientProfileId: linkModel.patientProfileId,
        patientName: linkModel.patientName,
        sharedItemType: linkModel.sharedItemType,
        sharedExamIds: linkModel.sharedExamIds,
        accessPasswordHash: linkModel.accessPasswordHash,
        expiresAt: linkModel.expiresAt,
        accessType: linkModel.accessType,
        permissions: linkModel.permissions,
        status: linkModel.status,
        createdAt: linkModel.createdAt,
        updatedAt: linkModel.updatedAt,
        shareToken: linkModel.shareToken,
        accessCount: linkModel.accessCount,
        lastAccessedAt: linkModel.lastAccessedAt,
        shareUrl: linkModel.shareUrl, // A URL já deve conter o token correto
      );
    } catch (e) {
      print("Erro ao criar link de compartilhamento no Firestore: $e");
      rethrow;
    }
  }

  Stream<List<SharedLinkModel>> getUserSharedLinks(String userId) {
    return _firestore
        .collection(_collectionPath)
        .where("userId", isEqualTo: userId)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => SharedLinkModel.fromDocument(doc)).toList());
  }

  Future<void> updateShareLinkStatus(String linkId, ShareLinkStatus newStatus) async {
    try {
      await _firestore.collection(_collectionPath).doc(linkId).update({
        "status": newStatus.name,
        "updatedAt": Timestamp.now(),
      });
    } catch (e) {
      print("Erro ao atualizar status do link de compartilhamento: $e");
      rethrow;
    }
  }

  Future<SharedLinkModel?> getSharedLinkByToken(String token) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(_collectionPath)
          .where("shareToken", isEqualTo: token)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return SharedLinkModel.fromDocument(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      print("Erro ao buscar link de compartilhamento por token: $e");
      rethrow;
    }
  }

   Future<void> incrementAccessCount(String linkId) async {
    try {
      await _firestore.collection(_collectionPath).doc(linkId).update({
        "accessCount": FieldValue.increment(1),
        "lastAccessedAt": Timestamp.now(),
      });
    } catch (e) {
      print("Erro ao incrementar contador de acesso do link: $e");
      // Não re-lançar para não quebrar a visualização do destinatário por um erro de contagem
    }
  }
}

