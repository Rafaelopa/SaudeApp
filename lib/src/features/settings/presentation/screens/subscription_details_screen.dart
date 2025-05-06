import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
// import "package:saude_app_mobile/src/features/subscription/application/subscription_service.dart"; // Para buscar dados da assinatura
// import "package:url_launcher/url_launcher.dart"; // Para abrir links externos

// TODO: Definir provedor para SubscriptionService e para o estado da assinatura do usuário

class SubscriptionDetailsScreen extends ConsumerStatefulWidget {
  const SubscriptionDetailsScreen({Key? key}) : super(key: key);

  @override
  _SubscriptionDetailsScreenState createState() => _SubscriptionDetailsScreenState();
}

class _SubscriptionDetailsScreenState extends ConsumerState<SubscriptionDetailsScreen> {
  bool _isLoading = false;

  // Simulação de dados da assinatura - substituir por dados reais do provedor
  String _subscriptionStatus = "Premium Mensal";
  String _startDate = "01/04/2024";
  String _expiresDate = "01/05/2025";
  String _managedBy = "Google Play"; // ou "App Store"
  List<String> _benefits = [
    "Armazenamento ilimitado de exames",
    "Compartilhamento com múltiplos médicos",
    "Perfis de dependentes ilimitados",
    "Suporte prioritário"
  ];

  @override
  void initState() {
    super.initState();
    // TODO: Carregar dados reais da assinatura do usuário
    // _loadSubscriptionData();
  }

  // Future<void> _loadSubscriptionData() async {
  //   setState(() { _isLoading = true; });
  //   try {
  //     // final subscription = await ref.read(subscriptionServiceProvider).getUserSubscription();
  //     // if (subscription != null) {
  //     //   setState(() {
  //     //     _subscriptionStatus = subscription.status;
  //     //     _startDate = DateFormat("dd/MM/yyyy").format(subscription.startDate.toDate());
  //     //     _expiresDate = subscription.expiresAt != null ? DateFormat("dd/MM/yyyy").format(subscription.expiresAt.toDate()) : "Vitalício";
  //     //     _managedBy = subscription.managedBy ?? "Não especificado";
  //     //     _benefits = subscription.benefitsList;
  //     //   });
  //     // }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao carregar dados da assinatura: ${e.toString()}")));
  //   } finally {
  //     setState(() { _isLoading = false; });
  //   }
  // }

  Future<void> _manageSubscription() async {
    // TODO: Implementar a lógica para abrir a página de gerenciamento da loja
    // Exemplo: String url = "https://play.google.com/store/account/subscriptions";
    // if (await canLaunchUrl(Uri.parse(url))) {
    //   await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Não foi possível abrir a página de gerenciamento.")));
    // }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Gerenciamento de assinatura ainda não implementado.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Minha Assinatura"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildInfoCard(
                    context,
                    title: "Status da Assinatura",
                    content: _subscriptionStatus,
                    icon: Icons.star_border_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    context,
                    title: "Data de Início/Renovação",
                    content: _startDate,
                    icon: Icons.calendar_today_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    context,
                    title: "Expira em",
                    content: _expiresDate,
                    icon: Icons.event_busy_outlined,
                  ),
                  const SizedBox(height: 16),
                   _buildInfoCard(
                    context,
                    title: "Gerenciada por",
                    content: _managedBy,
                    icon: Icons.store_mall_directory_outlined,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Benefícios do seu Plano:",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _benefits.map((benefit) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                              const SizedBox(width: 10),
                              Expanded(child: Text(benefit, style: const TextStyle(fontSize: 15))),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.settings_outlined),
                    label: const Text("Gerenciar Assinatura", style: TextStyle(fontSize: 16)),
                    onPressed: _manageSubscription,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      // backgroundColor: Theme.of(context).colorScheme.secondary,
                      // foregroundColor: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // TextButton(
                  //   onPressed: () {
                  //     // TODO: Navegar para tela de ver todos os planos
                  //      ScaffoldMessenger.of(context).showSnackBar(
                  //       const SnackBar(content: Text("Tela de planos ainda não implementada.")),
                  //     );
                  //   },
                  //   child: const Text("Ver todos os Planos"),
                  //   style: TextButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
                  // ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required String title, required String content, IconData? icon}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

