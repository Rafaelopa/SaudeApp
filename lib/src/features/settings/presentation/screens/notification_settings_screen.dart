import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
// import "package:saude_app_mobile/src/features/settings/application/settings_service.dart"; // Para salvar as preferências

// TODO: Definir provedores para SettingsService e para o estado das configurações de notificação

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  _NotificationSettingsScreenState createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  bool _generalNotificationsEnabled = true;
  bool _examRemindersEnabled = true; // Opcional MVP+
  bool _sharingNotificationsEnabled = true; // Opcional MVP+
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // TODO: Carregar as configurações de notificação salvas do usuário
    // _loadNotificationSettings();
  }

  // Future<void> _loadNotificationSettings() async {
  //   setState(() { _isLoading = true; });
  //   try {
  //     // final settings = await ref.read(settingsServiceProvider).getNotificationSettings();
  //     // setState(() {
  //     //   _generalNotificationsEnabled = settings.generalNotificationsEnabled;
  //     //   _examRemindersEnabled = settings.examRemindersEnabled;
  //     //   _sharingNotificationsEnabled = settings.sharingNotificationsEnabled;
  //     // });
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao carregar configurações: ${e.toString()}")));
  //   } finally {
  //     setState(() { _isLoading = false; });
  //   }
  // }

  Future<void> _saveNotificationSettings() async {
    setState(() { _isLoading = true; });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Salvando configurações...")),
    );
    try {
      // TODO: Implementar a lógica real de salvar as configurações
      // await ref.read(settingsServiceProvider).updateNotificationSettings(
      //   generalNotificationsEnabled: _generalNotificationsEnabled,
      //   examRemindersEnabled: _examRemindersEnabled,
      //   sharingNotificationsEnabled: _sharingNotificationsEnabled,
      // );
      await Future.delayed(const Duration(seconds: 1)); // Simulação
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Configurações de notificação salvas!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao salvar configurações: ${e.toString()}")),
      );
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configurações de Notificações"),
      ),
      body: _isLoading && ModalRoute.of(context)?.isCurrent != true // Evita mostrar loading se não for a tela atual (ex: ao carregar inicialmente)
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              children: <Widget>[
                SwitchListTile(
                  title: const Text("Notificações Gerais do Aplicativo"),
                  subtitle: const Text("Receba novidades e informações importantes."),
                  value: _generalNotificationsEnabled,
                  onChanged: _isLoading ? null : (bool value) {
                    setState(() {
                      _generalNotificationsEnabled = value;
                    });
                    _saveNotificationSettings(); // Salva automaticamente ao mudar
                  },
                  secondary: const Icon(Icons.notifications_active_outlined),
                ),
                const Divider(),
                // Opções MVP+
                SwitchListTile(
                  title: const Text("Lembretes de Exames Periódicos"),
                  subtitle: const Text("Seja lembrado de realizar exames de rotina."),
                  value: _examRemindersEnabled,
                  onChanged: _isLoading ? null : (bool value) {
                    setState(() {
                      _examRemindersEnabled = value;
                    });
                     _saveNotificationSettings();
                  },
                  secondary: const Icon(Icons.event_note_outlined),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text("Notificações de Compartilhamento"),
                  subtitle: const Text("Saiba quando seus links compartilhados são acessados."),
                  value: _sharingNotificationsEnabled,
                  onChanged: _isLoading ? null : (bool value) {
                    setState(() {
                      _sharingNotificationsEnabled = value;
                    });
                     _saveNotificationSettings();
                  },
                  secondary: const Icon(Icons.share_outlined),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "As alterações são salvas automaticamente.",
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
    );
  }
}

