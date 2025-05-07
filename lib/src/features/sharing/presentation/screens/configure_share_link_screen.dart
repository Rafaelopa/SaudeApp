import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saude_app/src/features/sharing/application/sharing_service.dart';
import 'package:saude_app/src/features/sharing/domain/sharing_model.dart';
import 'package:saude_app/src/features/sharing/presentation/providers/sharing_providers.dart';
import 'package:saude_app/src/features/sharing/presentation/screens/share_link_generated_screen.dart';

class ConfigureShareLinkScreen extends ConsumerStatefulWidget {
  final String patientProfileId;
  final String patientName;
  final List<String>? examIdsToShare;
  final bool shareFullProfile;

  const ConfigureShareLinkScreen({
    super.key,
    required this.patientProfileId,
    required this.patientName,
    this.examIdsToShare,
    this.shareFullProfile = false,
  });

  @override
  _ConfigureShareLinkScreenState createState() => _ConfigureShareLinkScreenState();
}

enum ShareDuration {
  hours24,
  days7,
  days30,
  singleAccess
}

class _ConfigureShareLinkScreenState extends ConsumerState<ConfigureShareLinkScreen> {
  final _formKey = GlobalKey<FormState>();
  ShareDuration _selectedDuration = ShareDuration.hours24;
  bool _requirePassword = false;
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  // bool _allowDownload = false; // MVP+ Opcional

  String getShareSummary() {
    if (widget.shareFullProfile) {
      return "Compartilhando histórico completo de ${widget.patientName}.";
    }
    if (widget.examIdsToShare != null && widget.examIdsToShare!.isNotEmpty) {
      if (widget.examIdsToShare!.length == 1) {
        return "Compartilhando 1 exame de ${widget.patientName}."; // Idealmente, buscar nome do exame
      }
      return "Compartilhando ${widget.examIdsToShare!.length} exames de ${widget.patientName}.";
    }
    return "Nenhum item selecionado para compartilhar.";
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _generateLink() async {
    if (_formKey.currentState!.validate()) {
      if (_requirePassword && _passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, defina uma senha ou desative a opção.')),
        );
        return;
      }

      ref.read(shareOperationLoadingProvider.notifier).state = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gerando link de compartilhamento...')),
      );

      try {
        final sharingService = ref.read(sharingServiceProvider);
        SharedItemType itemType;
        if (widget.shareFullProfile) {
          itemType = SharedItemType.fullProfile;
        } else if (widget.examIdsToShare != null && widget.examIdsToShare!.length > 1) {
          itemType = SharedItemType.multipleExams;
        } else {
          itemType = SharedItemType.singleExam;
        }

        final generatedLinkModel = await sharingService.createShareLink(
          patientProfileId: widget.patientProfileId,
          patientName: widget.patientName,
          sharedItemType: itemType,
          sharedExamIds: widget.shareFullProfile ? null : widget.examIdsToShare,
          duration: _selectedDuration,
          requirePassword: _requirePassword,
          password: _requirePassword ? _passwordController.text : null,
        );

        ref.read(generatedShareLinkDetailsProvider.notifier).state = generatedLinkModel;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ShareLinkGeneratedScreen(
              shareLink: generatedLinkModel.shareUrl,
              password: _requirePassword ? _passwordController.text : null, // Passar a senha em claro para exibição, não o hash
              expiresAt: generatedLinkModel.expiresAt.toDate(),
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao gerar link: ${e.toString()}')),
        );
      } finally {
        ref.read(shareOperationLoadingProvider.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(shareOperationLoadingProvider);

    // TODO: Adicionar verificação de assinatura do usuário aqui ou antes de navegar para esta tela.
    // Exemplo: final subscriptionState = ref.watch(userSubscriptionProvider);
    // if (!subscriptionState.isPremium) { ... exibir diálogo de assinatura ... }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Compartilhamento'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Você está compartilhando:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                getShareSummary(),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              Text(
                'Validade do Link:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              RadioListTile<ShareDuration>(
                title: const Text('24 Horas'),
                value: ShareDuration.hours24,
                groupValue: _selectedDuration,
                onChanged: isLoading ? null : (ShareDuration? value) {
                  setState(() { _selectedDuration = value!; });
                },
              ),
              RadioListTile<ShareDuration>(
                title: const Text('7 Dias'),
                value: ShareDuration.days7,
                groupValue: _selectedDuration,
                onChanged: isLoading ? null : (ShareDuration? value) {
                  setState(() { _selectedDuration = value!; });
                },
              ),
              RadioListTile<ShareDuration>(
                title: const Text('30 Dias'),
                value: ShareDuration.days30,
                groupValue: _selectedDuration,
                onChanged: isLoading ? null : (ShareDuration? value) {
                  setState(() { _selectedDuration = value!; });
                },
              ),
              RadioListTile<ShareDuration>(
                title: const Text('Acesso Único (expira após 1º uso ou 24h)'),
                value: ShareDuration.singleAccess,
                groupValue: _selectedDuration,
                onChanged: isLoading ? null : (ShareDuration? value) {
                  setState(() { _selectedDuration = value!; });
                },
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text('Exigir Senha para Acesso'),
                value: _requirePassword,
                onChanged: isLoading ? null : (bool value) {
                  setState(() {
                    _requirePassword = value;
                    if (!value) {
                      _passwordController.clear();
                      _confirmPasswordController.clear();
                    }
                  });
                },
              ),
              if (_requirePassword)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(labelText: 'Definir Senha', border: OutlineInputBorder()),
                        obscureText: true,
                        enabled: !isLoading,
                        validator: (value) {
                          if (_requirePassword && (value == null || value.isEmpty)) {
                            return 'Por favor, defina uma senha.';
                          }
                          if (_requirePassword && value != null && value.length < 6) {
                            return 'A senha deve ter pelo menos 6 caracteres.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: const InputDecoration(labelText: 'Confirmar Senha', border: OutlineInputBorder()),
                        obscureText: true,
                        enabled: !isLoading,
                        validator: (value) {
                          if (_requirePassword && value != _passwordController.text) {
                            return 'As senhas não coincidem.';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 30),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _generateLink,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  child: const Text('Gerar Link de Compartilhamento', style: TextStyle(fontSize: 16)),
                ),
              const SizedBox(height: 12),
              if (!isLoading)
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
                  child: const Text('Cancelar'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

