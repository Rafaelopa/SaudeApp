import "package:cloud_firestore/cloud_firestore.dart";

// Enum para o tipo de item compartilhado
enum SharedItemType { singleExam, multipleExams, fullProfile }

// Enum para o tipo de acesso do link
enum ShareAccessType { timeLimited, singleUse }

// Enum para o status do link
enum ShareLinkStatus { active, expired, revoked, accessed }

class SharedLinkModel {
  final String? id; // ID do documento no Firestore (shareLinkId)
  final String userId; // ID do usuário que criou o link
  final String patientProfileId; // ID do perfil do paciente compartilhado
  final String patientName; // Nome do paciente para exibição rápida
  final SharedItemType sharedItemType;
  final List<String>? sharedExamIds; // IDs dos exames, se aplicável
  final String? accessPasswordHash; // Hash da senha, se definida
  final Timestamp expiresAt;
  final ShareAccessType? accessType; // Opcional MVP+
  final Map<String, bool>? permissions; // Ex: {"canDownload": true}, Opcional MVP+
  ShareLinkStatus status;
  final Timestamp createdAt;
  Timestamp updatedAt;
  final String shareToken; // Token único para a URL pública
  final int? accessCount; // Opcional MVP+
  final Timestamp? lastAccessedAt; // Opcional MVP+
  final String shareUrl; // URL completa de compartilhamento

  SharedLinkModel({
    this.id,
    required this.userId,
    required this.patientProfileId,
    required this.patientName,
    required this.sharedItemType,
    this.sharedExamIds,
    this.accessPasswordHash,
    required this.expiresAt,
    this.accessType,
    this.permissions,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.shareToken,
    this.accessCount,
    this.lastAccessedAt,
    required this.shareUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "patientProfileId": patientProfileId,
      "patientName": patientName,
      "sharedItemType": sharedItemType.name, // Salvar como string
      "sharedExamIds": sharedExamIds,
      "accessPasswordHash": accessPasswordHash,
      "expiresAt": expiresAt,
      "accessType": accessType?.name,
      "permissions": permissions,
      "status": status.name,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "shareToken": shareToken,
      "accessCount": accessCount,
      "lastAccessedAt": lastAccessedAt,
      "shareUrl": shareUrl,
    };
  }

  factory SharedLinkModel.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
    
    // Helper to safely get Timestamp or provide a default
    Timestamp _getTimestamp(dynamic value, {Timestamp? defaultValue}) {
      if (value is Timestamp) {
        return value;
      }
      return defaultValue ?? Timestamp.now(); // Default to now if null or unparseable
    }

    return SharedLinkModel(
      id: doc.id,
      userId: data["userId"] ?? "", // Fallback for required String
      patientProfileId: data["patientProfileId"] ?? "", // Fallback for required String
      patientName: data["patientName"] ?? "", // Corrected fallback
      sharedItemType: SharedItemType.values.firstWhere(
        (e) => e.name == data["sharedItemType"],
        orElse: () => SharedItemType.singleExam // Default if not found or null
      ),
      sharedExamIds: List<String>.from(data["sharedExamIds"] ?? []),
      accessPasswordHash: data["accessPasswordHash"],
      expiresAt: _getTimestamp(data["expiresAt"]), // Fallback for required Timestamp
      accessType: data["accessType"] != null
          ? ShareAccessType.values.firstWhere((e) => e.name == data["accessType"], orElse: () => ShareAccessType.timeLimited) // Added orElse for safety
          : null,
      permissions: Map<String, bool>.from(data["permissions"] ?? {}),
      status: ShareLinkStatus.values.firstWhere(
        (e) => e.name == data["status"],
        orElse: () => ShareLinkStatus.expired // Default if not found or null
      ),
      createdAt: _getTimestamp(data["createdAt"]), // Fallback for required Timestamp
      updatedAt: _getTimestamp(data["updatedAt"]), // Fallback for required Timestamp
      shareToken: data["shareToken"] ?? "", // Fallback for required String
      accessCount: data["accessCount"],
      lastAccessedAt: data["lastAccessedAt"] is Timestamp ? data["lastAccessedAt"] : null, // Ensure it's a Timestamp or null
      shareUrl: data["shareUrl"] ?? "", // Corrected fallback
    );
  }
}

