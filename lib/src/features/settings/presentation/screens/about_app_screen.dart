import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
// import "package:package_info_plus/package_info_plus.dart"; // Para obter a versão do app
// import "package:url_launcher/url_launcher.dart"; // Para abrir links

// TODO: Definir provedor para PackageInfo se for usar

class AboutAppScreen extends ConsumerStatefulWidget {
  const AboutAppScreen({Key? key}) : super(key: key);

  @override
  _AboutAppScreenState createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends ConsumerState<AboutAppScreen> {
  String _appVersion = "1.0.0"; // Placeholder
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // _loadAppInfo();
  }

  // Future<void> _loadAppInfo() async {
  //   setState(() { _isLoading = true; });
  //   try {
  //     // final packageInfo = await PackageInfo.fromPlatform();
  //     // setState(() {
  //     //   _appVersion = "${packageInfo.version} (${packageInfo.buildNumber})";
  //     // });
  //   } catch (e) {
  //     // Lidar com erro ao buscar informações do pacote
  //     print("Erro ao carregar informações do app: $e");
  //   } finally {
  //     setState(() { _isLoading = false; });
  //   }
  // }

  Future<void> _openLink(String url) async {
    // if (await canLaunchUrl(Uri.parse(url))) {
    //   await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text("Não foi possível abrir o link: $url")),
    //   );
    // }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Abertura de link ainda não implementada: $url")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sobre o Saúde App"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Adicionar o logo do aplicativo aqui
                  // Image.asset("assets/logo_saude_app.png", height: 100),
                  const SizedBox(height: 20),
                  Text(
                    "Saúde App",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Versão $_appVersion",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Desenvolvido com ❤️ pela Equipe Manus.", // Ou seu nome/empresa
                    style: TextStyle(fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  _buildInfoItem(context, "Política de Privacidade", () {
                    _openLink("https://seusite.com/privacidade"); // Substituir pelo link real
                  }),
                  _buildInfoItem(context, "Termos de Uso", () {
                    _openLink("https://seusite.com/termos"); // Substituir pelo link real
                  }),
                  _buildInfoItem(context, "Contato para Suporte", () {
                    _openLink("mailto:suporte@saudeapp.com.br"); // Substituir pelo email real
                  }),
                  _buildInfoItem(context, "Perguntas Frequentes (FAQ)", () {
                     _openLink("https://seusite.com/faq"); // Substituir pelo link real
                  }),
                  const SizedBox(height: 30),
                  Text(
                    "© ${DateTime.now().year} Saúde App. Todos os direitos reservados.",
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String title, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right_outlined),
        onTap: onTap,
      ),
    );
  }
}

