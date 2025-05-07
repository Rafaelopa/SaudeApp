import "dart:math";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:saude_app/src/features/sharing/domain/sharing_model.dart";
import "package:saude_app/src/features/sharing/infrastructure/sharing_repository.dart";
import "package:saude_app/src/features/sharing/presentation/screens/configure_share_link_screen.dart"; // Para o enum ShareDuration

// Idealmente, a URL base da sua função/página web de visualização
const String _baseShareUrl = "https://SUA_FUNCAO_CLOUD_OU_DOMINIO_WEB/viewShare";

class SharingService {
  final SharingRepository _sharingRepository;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  SharingService(this._sharingRepository);

  String _generateSecureToken(int length) {
    final random = Random.secure();
    const chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  Future<User> _getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("Usuário não autenticado. Não é possível compartilhar.");
    }
    return user;
  }

  Future<SharedLinkModel> createShareLink({
    required String patientProfileId,
    required String patientName,
    required SharedItemType sharedItemType,
    List<String>? sharedExamIds,
    required ShareDuration duration,
    bool requirePassword = false,
    String? password,
    // bool allowDownload = false, // MVP+
  }) async {
    final currentUser = await _getCurrentUser();

    // TODO: Verificar status da assinatura do usuário antes de prosseguir
    // Ex: if (!await _checkUserSubscription(currentUser.uid)) { throw Exception("Assinatura necessária para compartilhar."); }

    String? passwordHash;
    if (requirePassword && password != null && password.isNotEmpty) {
      // TODO: Implementar hashing de senha seguro (ex: com bcrypt ou scrypt via Cloud Function se não for possível no Dart puro de forma segura)
      // Para MVP, podemos armazenar em texto claro, mas NÃO RECOMENDADO PARA PRODUÇÃO.
      // AVISO: Armazenar senhas em texto claro é uma falha de segurança grave.
      // Idealmente, a senha é enviada para uma Cloud Function que faz o hash e armazena apenas o hash.
      passwordHash = password; // Placeholder - NÃO FAÇA ISSO EM PRODUÇÃO
    }

    DateTime expiresAt;
    DateTime now = DateTime.now();
    switch (duration) {
      case ShareDuration.hours24:
        expiresAt = now.add(const Duration(hours: 24));
        break;
      case ShareDuration.days7:
        expiresAt = now.add(const Duration(days: 7));
        break;
      case ShareDuration.days30:
        expiresAt = now.add(const Duration(days: 30));
        break;
      case ShareDuration.singleAccess:
        // Expira em 24h ou no primeiro acesso. A lógica de "primeiro acesso" será na Cloud Function.
        expiresAt = now.add(const Duration(hours: 24)); 
        break;
    }

    final shareToken = _generateSecureToken(32); // Token para a URL
    final shareUrl = "$_baseShareUrl?token=$shareToken";

    final newLink = SharedLinkModel(
      userId: currentUser.uid,
      patientProfileId: patientProfileId,
      patientName: patientName,
      sharedItemType: sharedItemType,
      sharedExamIds: sharedExamIds,
      accessPasswordHash: passwordHash,
      expiresAt: Timestamp.fromDate(expiresAt),
      accessType: duration == ShareDuration.singleAccess ? ShareAccessType.singleUse : ShareAccessType.timeLimited,
      // permissions: {"canDownload": allowDownload}, // MVP+
      status: ShareLinkStatus.active,
      createdAt: Timestamp.fromDate(now),
      updatedAt: Timestamp.fromDate(now),
      shareToken: shareToken,
      shareUrl: shareUrl,
    );

    return await _sharingRepository.createShareLink(newLink);
  }

  Stream<List<SharedLinkModel>> getUserSharedLinks() async* {
    final currentUser = await _getCurrentUser();
    yield* _sharingRepository.getUserSharedLinks(currentUser.uid);
  }

  Future<void> revokeShareLink(String linkId) async {
    await _getCurrentUser(); // Garante autenticação
    // TODO: Adicionar verificação se o link pertence ao usuário atual antes de revogar (regra de segurança no Firestore também)
    await _sharingRepository.updateShareLinkStatus(linkId, ShareLinkStatus.revoked);
  }

  // Métodos para a Cloud Function/Página Web (não chamados diretamente do app, mas a lógica estaria aqui ou na CF)
  Future<SharedLinkModel?> validateAndGetLinkDetails(String token) async {
    final link = await _sharingRepository.getSharedLinkByToken(token);
    if (link == null) return null;

    if (link.status != ShareLinkStatus.active) return null; // Já revogado, acessado (se single_use), etc.
    if (link.expiresAt.toDate().isBefore(DateTime.now())) {
      await _sharingRepository.updateShareLinkStatus(link.id!, ShareLinkStatus.expired);
      return null;
    }
    return link;
  }

  Future<bool> verifyPassword(SharedLinkModel link, String providedPassword) async {
    if (link.accessPasswordHash == null) return true; // Sem senha
    // TODO: Comparar hash da senha de forma segura (Cloud Function)
    // AVISO: Comparação em texto claro é falha de segurança.
    return link.accessPasswordHash == providedPassword; // Placeholder - NÃO FAÇA ISSO EM PRODUÇÃO
  }

  Future<void> recordLinkAccess(String linkId, bool isSingleUse) async {
    await _sharingRepository.incrementAccessCount(linkId);
    if (isSingleUse) {
      await _sharingRepository.updateShareLinkStatus(linkId, ShareLinkStatus.accessed);
    }
  }

  // TODO: Adicionar método para verificar assinatura do usuário
  // Future<bool> _checkUserSubscription(String userId) async { ... }
}

