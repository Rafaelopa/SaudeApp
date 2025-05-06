import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";
import "package:saude_app_mobile/src/features/sharing/application/sharing_service.dart";
import "package:saude_app_mobile/src/features/sharing/domain/sharing_model.dart";
import "package:saude_app_mobile/src/features/sharing/presentation/providers/sharing_providers.dart";

class ManageSharedLinksScreen extends ConsumerWidget {
  const ManageSharedLinksScreen({Key? key}) : super(key: key);

  Future<void> _revokeLink(BuildContext context, WidgetRef ref, String linkId) async {
    final bool confirmRevoke = await showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              title: const Text("Confirmar Revogação"),
              content: const Text("Tem certeza que deseja revogar este link de compartilhamento? O destinatário não poderá mais acessar os exames."),
              actions: <Widget>[
                TextButton(
                  child: const Text("Cancelar"),
                  onPressed: () => Navigator.of(ctx).pop(false),
                ),
                TextButton(
                  child: const Text("Revogar", style: TextStyle(color: Colors.red)),
                  onPressed: () => Navigator.of(ctx).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirmRevoke) {
      ref.read(shareOperationLoadingProvider.notifier).state = true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Revogando link $linkId...")),
      );
      try {
        await ref.read(sharingServiceProvider).revokeShareLink(linkId);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Link revogado com sucesso!")),
        );
        ref.invalidate(userSharedLinksStreamProvider); // Atualiza a lista
      } catch (e) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao revogar link: ${e.toString()}")),
        );
      } finally {
        ref.read(shareOperationLoadingProvider.notifier).state = false;
      }
    }
  }

  void _showLinkDetails(BuildContext context, WidgetRef ref, SharedLinkModel linkInfo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        // Usar um Consumer para acessar o ref dentro do builder do BottomSheet
        return Consumer(
          builder: (context, bottomSheetRef, child) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(linkInfo.patientName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  Text("Exames de: ${linkInfo.patientName}", style: Theme.of(context).textTheme.titleMedium),
                  if (linkInfo.sharedItemType == SharedItemType.singleExam)
                     Text("Item: 1 Exame", style: Theme.of(context).textTheme.bodySmall)
                  else if (linkInfo.sharedItemType == SharedItemType.multipleExams)
                     Text("Itens: ${linkInfo.sharedExamIds?.length ?? 0} Exames", style: Theme.of(context).textTheme.bodySmall)
                  else if (linkInfo.sharedItemType == SharedItemType.fullProfile)
                     Text("Item: Histórico Completo", style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 16),
                  _buildDetailRow("Link:", linkInfo.shareUrl, onCopy: () {
                    Clipboard.setData(ClipboardData(text: linkInfo.shareUrl));
                    ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text("Link copiado!")));
                  }),
                  if (linkInfo.accessPasswordHash != null && linkInfo.accessPasswordHash!.isNotEmpty)
                    _buildDetailRow("Senha:", "******", onCopy: () {
                       // Por segurança, não copiamos a senha (hash) diretamente.
                       // Poderia copiar a senha original se ela fosse passada para este ponto (não recomendado)
                       ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text("Senha definida (não exibida por segurança).")));
                    }),
                  _buildDetailRow("Criado em:", DateFormat("dd/MM/yyyy HH:mm").format(linkInfo.createdAt.toDate())),
                  _buildDetailRow("Expira em:", DateFormat("dd/MM/yyyy HH:mm").format(linkInfo.expiresAt.toDate())),
                  _buildDetailRow("Status:", linkInfo.status.name.toUpperCase(), color: _getStatusColor(linkInfo.status)),
                  const SizedBox(height: 24),
                  if (linkInfo.status == ShareLinkStatus.active)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.link_off_outlined, color: Colors.white),
                      label: const Text("Revogar Link Agora"),
                      onPressed: () {
                        Navigator.of(ctx).pop(); // Fecha o bottom sheet
                        _revokeLink(context, ref, linkInfo.id!); 
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, minimumSize: const Size(double.infinity, 45)),
                    ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text("Fechar", style: TextStyle(fontSize: 16)),
                    style: TextButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {VoidCallback? onCopy, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          Expanded(child: Text(value, style: TextStyle(fontSize: 15, color: color))),
          if (onCopy != null)
            IconButton(icon: const Icon(Icons.copy_all_outlined, size: 18), onPressed: onCopy, splashRadius: 20, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
        ],
      ),
    );
  }

  Color _getStatusColor(ShareLinkStatus status) {
    switch (status) {
      case ShareLinkStatus.active:
        return Colors.green;
      case ShareLinkStatus.revoked:
        return Colors.orange;
      case ShareLinkStatus.expired:
      case ShareLinkStatus.accessed: // Se single use e já acessado, pode ser considerado "usado/expirado"
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _getStatusIcon(ShareLinkStatus status) {
     switch (status) {
      case ShareLinkStatus.active:
        return Icons.link_outlined;
      case ShareLinkStatus.revoked:
        return Icons.link_off_outlined;
      case ShareLinkStatus.expired:
        return Icons.timer_off_outlined;
      case ShareLinkStatus.accessed:
        return Icons.check_circle_outline; // Acessado (para single_use)
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSharedLinks = ref.watch(userSharedLinksStreamProvider);
    final isLoadingOperation = ref.watch(shareOperationLoadingProvider);

    return DefaultTabController(
      length: 2, // Ativos e Expirados/Revogados
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Meus Compartilhamentos"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "ATIVOS"),
              Tab(text: "OUTROS"), // Expirados/Revogados/Acessados
            ],
          ),
        ),
        body: Stack(
          children: [
            asyncSharedLinks.when(
              data: (links) {
                final activeLinks = links.where((l) => l.status == ShareLinkStatus.active).toList();
                final otherLinks = links.where((l) => l.status != ShareLinkStatus.active).toList();

                if (links.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        "Você ainda não compartilhou nenhum exame ou histórico. Quando compartilhar, os links aparecerão aqui para gerenciamento.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 17, color: Colors.grey),
                      ),
                    ),
                  );
                }

                return TabBarView(
                  children: [
                    _buildLinksList(context, ref, activeLinks, isLoadingOperation: isLoadingOperation),
                    _buildLinksList(context, ref, otherLinks, isInactiveList: true, isLoadingOperation: isLoadingOperation),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text("Erro ao carregar links: $err")),
            ),
            if(isLoadingOperation)
              const Opacity(
                opacity: 0.5,
                child: ModalBarrier(dismissible: false, color: Colors.black54),
              ),
            if(isLoadingOperation)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  Widget _buildLinksList(BuildContext context, WidgetRef ref, List<SharedLinkModel> links, {bool isInactiveList = false, required bool isLoadingOperation}) {
    if (links.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            isInactiveList ? "Nenhum link expirado, revogado ou acessado." : "Nenhum link ativo no momento.",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, color: Colors.grey),
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12.0),
      itemCount: links.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final link = links[index];
        final statusColor = _getStatusColor(link.status);
        final statusIcon = _getStatusIcon(link.status);

        return Opacity(
          opacity: isLoadingOperation ? 0.5 : 1.0,
          child: AbsorbPointer(
            absorbing: isLoadingOperation,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: Icon(statusIcon, color: statusColor, size: 32),
                title: Text(link.patientName, style: const TextStyle(fontWeight: FontWeight.w600)),
                 subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Expira em: ${DateFormat("dd/MM/yyyy HH:mm").format(link.expiresAt.toDate())}"),
                    Text("Status: ${link.status.name.toUpperCase()}", style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                  ],
                ),
                trailing: const Icon(Icons.more_vert_outlined),
                onTap: () => _showLinkDetails(context, ref, link),
              ),
            ),
          ),
        );
      },
    );
  }
}

