import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:saude_app/src/features/sharing/application/sharing_service.dart";
import "package:saude_app/src/features/sharing/domain/sharing_model.dart";
import "package:saude_app/src/features/sharing/infrastructure/sharing_repository.dart";

// Provedor para o SharingRepository
final sharingRepositoryProvider = Provider<SharingRepository>((ref) {
  return SharingRepository();
});

// Provedor para o SharingService
final sharingServiceProvider = Provider<SharingService>((ref) {
  final repository = ref.watch(sharingRepositoryProvider);
  return SharingService(repository);
});

// Provedor para a lista de links compartilhados do usuário (Stream)
final userSharedLinksStreamProvider = StreamProvider<List<SharedLinkModel>>((ref) {
  final sharingService = ref.watch(sharingServiceProvider);
  return sharingService.getUserSharedLinks();
});

// Provedor de estado para indicar se uma operação de compartilhamento está em andamento
final shareOperationLoadingProvider = StateProvider<bool>((ref) => false);

// Provedor para o link gerado (para passar para a tela de link gerado)
// Este pode ser um StateProvider ou você pode passar os dados diretamente via construtor da tela.
// Usar um StateProvider pode ser útil se a lógica de geração for mais complexa e assíncrona
// e você quiser mostrar um estado de carregamento na tela de configuração.
final generatedShareLinkDetailsProvider = StateProvider<SharedLinkModel?>((ref) => null);

