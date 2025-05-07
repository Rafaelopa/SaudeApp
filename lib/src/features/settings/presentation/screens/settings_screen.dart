import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:saude_app/src/features/authentication/application/auth_service.dart"; 
import "package:saude_app/src/features/authentication/presentation/screens/login_screen.dart"; 
import "package:saude_app/src/features/settings/presentation/screens/edit_profile_screen.dart";
import "package:saude_app/src/features/settings/presentation/screens/change_password_screen.dart";
import "package:saude_app/src/features/settings/presentation/screens/notification_settings_screen.dart";
import "package:saude_app/src/features/settings/presentation/screens/about_app_screen.dart";
import "package:saude_app/src/features/settings/presentation/screens/delete_account_screen.dart";
import "package:saude_app/src/features/settings/presentation/screens/subscription_details_screen.dart";

// TODO: Definir provedor para AuthService se não existir globalmente
// Exemplo: final authServiceProvider = Provider<AuthService>((ref) => AuthService(FirebaseAuth.instance));

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    try {
      // TODO: Descomentar e ajustar se o authServiceProvider estiver disponível e configurado
      // final authService = ref.read(authServiceProvider);
      // await authService.signOut();
      // Navigator.of(context).pushAndRemoveUntil(
      //   MaterialPageRoute(builder: (context) => const LoginScreen()),
      //   (Route<dynamic> route) => false,
      // );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Logout simulado com sucesso! Implementação real pendente.")),
      );
       // Simulação de navegação para login após logout
       Navigator.of(context).pushAndRemoveUntil(
         MaterialPageRoute(builder: (context) => const LoginScreen()), // Assumindo que LoginScreen existe
         (Route<dynamic> route) => false,
       );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao fazer logout: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configurações"),
      ),
      body: ListView(
        children: <Widget>[
          _buildSectionTitle(context, "Conta"),
          _buildSettingsItem(context, Icons.person_outline, "Meu Perfil", () {
            _navigateTo(context, const EditProfileScreen());
          }),
          _buildSettingsItem(context, Icons.lock_outline, "Alterar Senha", () {
            _navigateTo(context, const ChangePasswordScreen());
          }),
          _buildSettingsItem(context, Icons.subscriptions_outlined, "Minha Assinatura", () {
            _navigateTo(context, const SubscriptionDetailsScreen());
          }),
           _buildSettingsItem(context, Icons.delete_forever_outlined, "Excluir Conta", () {
            _navigateTo(context, const DeleteAccountScreen());
          }, color: Colors.redAccent),

          _buildSectionTitle(context, "Preferências do Aplicativo"),
          _buildSettingsItem(context, Icons.notifications_outlined, "Notificações", () {
            _navigateTo(context, const NotificationSettingsScreen());
          }),
          // _buildSettingsItem(context, Icons.palette_outlined, "Aparência (Tema)", () {}), // MVP+
          // _buildSettingsItem(context, Icons.language_outlined, "Idioma", () {}), // MVP+

          _buildSectionTitle(context, "Privacidade e Segurança"),
          _buildSettingsItem(context, Icons.privacy_tip_outlined, "Política de Privacidade", () {
            // TODO: Abrir link ou tela com a política
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Visualização da Política de Privacidade ainda não implementada.")),
            );
          }),
          _buildSettingsItem(context, Icons.gavel_outlined, "Termos de Uso", () {
            // TODO: Abrir link ou tela com os termos
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Visualização dos Termos de Uso ainda não implementada.")),
            );
          }),
          // _buildSettingsItem(context, Icons.fingerprint_outlined, "Autenticação Biométrica", () {}), // MVP+

          _buildSectionTitle(context, "Suporte e Informações"),
          _buildSettingsItem(context, Icons.info_outline, "Sobre o Saúde App", () {
            _navigateTo(context, const AboutAppScreen());
          }),
          _buildSettingsItem(context, Icons.feedback_outlined, "Enviar Feedback", () {
            // TODO: Abrir formulário ou email
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Funcionalidade Enviar Feedback ainda não implementada.")),
            );
          }),
          _buildSettingsItem(context, Icons.quiz_outlined, "Perguntas Frequentes (FAQ)", () {
            // TODO: Abrir link ou tela com FAQ
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Visualização do FAQ ainda não implementada.")),
            );
          }),

          const Divider(height: 30, thickness: 1),
          ListTile(
            leading: const Icon(Icons.exit_to_app_outlined, color: Colors.blueAccent),
            title: const Text("Sair (Logout)", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w500)),
            onTap: () => _logout(context, ref),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 16.0, right: 16.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Theme.of(context).iconTheme.color),
      title: Text(title, style: TextStyle(color: color)),
      trailing: const Icon(Icons.chevron_right_outlined),
      onTap: onTap,
    );
  }
}

