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
    return SharedLinkModel(
      id: doc.id,
      userId: data["userId"],
      patientProfileId: data["patientProfileId"],
      patientName: data["patientName"] ?? 

""; // Adicionar fallback
      sharedItemType: SharedItemType.values.firstWhere((e) => e.name == data["sharedItemType"], orElse: () => SharedItemType.singleExam), // Adicionar fallback
      sharedExamIds: List<String>.from(data["sharedExamIds"] ?? []),
      accessPasswordHash: data["accessPasswordHash"],
      expiresAt: data["expiresAt"],
      accessType: data["accessType"] != null ? ShareAccessType.values.firstWhere((e) => e.name == data["accessType"]) : null,
      permissions: Map<String, bool>.from(data["permissions"] ?? {}),
      status: ShareLinkStatus.values.firstWhere((e) => e.name == data["status"], orElse: () => ShareLinkStatus.expired), // Adicionar fallback
      createdAt: data["createdAt"],
      updatedAt: data["updatedAt"],
      shareToken: data["shareToken"],
      accessCount: data["accessCount"],
      lastAccessedAt: data["lastAccessedAt"],
      shareUrl: data["shareUrl"] ?? 

"", // Adicionar fallback
    );
  }
}

