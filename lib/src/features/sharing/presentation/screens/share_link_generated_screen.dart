import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para Clipboard
// import 'package:share_plus/share_plus.dart'; // Para compartilhar via OS

// TODO: Definir provedores para o serviço de compartilhamento se necessário gerenciar estado do link aqui

class ShareLinkGeneratedScreen extends StatelessWidget {
  final String shareLink;
  final String? password; // Senha pode ser nula
  final DateTime expiresAt;

  const ShareLinkGeneratedScreen({
    Key? key,
    required this.shareLink,
    this.password,
    required this.expiresAt,
  }) : super(key: key);

  void _copyToClipboard(BuildContext context, String text, String type) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$type copiado para a área de transferência!')),
      );
    });
  }

  // void _shareViaOS(BuildContext context) {
  //   String textToShare = "Link para exames: $shareLink";
  //   if (password != null && password!.isNotEmpty) {
  //     textToShare += "\nSenha: $password";
  //   }
  //   Share.share(textToShare, subject: 'Link de Exames Compartilhados');
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Link Gerado com Sucesso!'),
        automaticallyImplyLeading: false, // Remover botão de voltar padrão
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            Text(
              'Seu link de compartilhamento está pronto!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildInfoCard(context, 'Link de Compartilhamento:', shareLink, () => _copyToClipboard(context, shareLink, 'Link')),
            if (password != null && password!.isNotEmpty)
              _buildInfoCard(context, 'Senha de Acesso:', password!, () => _copyToClipboard(context, password!, 'Senha')),
            const SizedBox(height: 12),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Validade do Link:', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey[700])),
                    const SizedBox(height: 4),
                    // TODO: Formatar a data e hora de expiração
                    Text(DateFormat('dd/MM/yyyy HH:mm').format(expiresAt), style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 12),
                    Text(
                      'Instruções: Compartilhe este link e a senha (se aplicável) com quem você deseja. Lembre-se que o link expirará na data e hora informadas.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            // ElevatedButton.icon(
            //   icon: const Icon(Icons.share_outlined),
            //   label: const Text('Compartilhar via...'),
            //   onPressed: () => _shareViaOS(context),
            //   style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
            // ),
            // const SizedBox(height: 12),
            ElevatedButton(
              child: const Text('Gerenciar Meus Links', style: TextStyle(fontSize: 16)),
              onPressed: () {
                // TODO: Navegar para ManageSharedLinksScreen
                // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ManageSharedLinksScreen()));
                 ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tela de Gerenciar Links ainda não implementada.')),
                  );
              },
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
            ),
            const SizedBox(height: 12),
            TextButton(
              child: const Text('Concluir', style: TextStyle(fontSize: 16)),
              onPressed: () {
                // Voltar para a tela anterior ao início do fluxo de compartilhamento
                // Isso pode ser a lista de exames, detalhes do exame, ou lista de dependentes
                int popCount = 0;
                Navigator.of(context).popUntil((route) => popCount++ >= 2); // Pop 2 vezes: esta tela e a de configuração
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String value, VoidCallback onCopy) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey[700])),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_all_outlined, size: 20),
                  onPressed: onCopy,
                  tooltip: 'Copiar',
                  splashRadius: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

