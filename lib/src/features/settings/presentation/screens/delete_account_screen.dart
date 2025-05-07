import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
// import "package:saude_app/src/features/authentication/application/auth_service.dart"; // Para o serviço de exclusão
// import "package:saude_app/src/features/authentication/presentation/screens/login_screen.dart"; // Para navegar após exclusão

// TODO: Definir provedor para AuthService

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  _DeleteAccountScreenState createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _confirmDeletionCheckbox = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    if (!_confirmDeletionCheckbox) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Você precisa confirmar que entende as consequências da exclusão.")),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      // Segunda confirmação com diálogo
      final bool confirmDialog = await showDialog(
            context: context,
            builder: (BuildContext ctx) {
              return AlertDialog(
                title: const Text("Confirmar Exclusão da Conta"),
                content: const Text("Esta ação é DEFINITIVA e todos os seus dados serão perdidos. Tem certeza ABSOLUTA que deseja prosseguir?"),
                actions: <Widget>[
                  TextButton(
                    child: const Text("Cancelar"),
                    onPressed: () => Navigator.of(ctx).pop(false),
                  ),
                  TextButton(
                    child: const Text("Excluir Conta", style: TextStyle(color: Colors.red)),
                    onPressed: () => Navigator.of(ctx).pop(true),
                  ),
                ],
              );
            },
          ) ??
          false;

      if (!confirmDialog) return;

      setState(() { _isLoading = true; });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Excluindo sua conta... Isso pode levar alguns instantes.")),
      );
      try {
        // TODO: Implementar a lógica real de exclusão da conta
        // final authService = ref.read(authServiceProvider);
        // await authService.deleteUserAccount(password: _passwordController.text);
        await Future.delayed(const Duration(seconds: 2)); // Simulação
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sua conta foi excluída com sucesso.")),
        );
        // Navegar para a tela de login ou inicial
        // Navigator.of(context).pushAndRemoveUntil(
        //   MaterialPageRoute(builder: (context) => const LoginScreen()),
        //   (Route<dynamic> route) => false,
        // );
      } catch (e) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao excluir conta: ${e.toString()}")),
        );
      } finally {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Excluir Minha Conta"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                "Atenção: Excluir sua conta é uma ação irreversível!",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.red[700], fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                "Ao prosseguir, todos os seus dados, incluindo informações de perfil, perfis de dependentes, históricos de exames e quaisquer outros dados associados à sua conta serão permanentemente removidos do Saúde App.",
                style: TextStyle(fontSize: 15, height: 1.5),
              ),
              const SizedBox(height: 12),
              const Text(
                "Se você tiver uma assinatura ativa, ela será cancelada conforme os termos da loja de aplicativos (Google Play/App Store). Não haverá reembolso por períodos não utilizados.",
                style: TextStyle(fontSize: 15, height: 1.5),
              ),
              // TODO: Adicionar informação sobre período de carência se aplicável
              // const SizedBox(height: 12),
              // const Text(
              //   "Sua conta será agendada para exclusão em 7 dias. Você pode cancelar este processo fazendo login novamente durante este período.",
              //   style: TextStyle(fontSize: 15, height: 1.5, fontWeight: FontWeight.bold),
              // ),
              const SizedBox(height: 24),
              CheckboxListTile(
                title: const Text("Eu entendo que todos os meus dados serão excluídos permanentemente e desejo prosseguir com a exclusão da minha conta."),
                value: _confirmDeletionCheckbox,
                onChanged: _isLoading ? null : (bool? value) {
                  setState(() {
                    _confirmDeletionCheckbox = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Colors.red,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Digite sua senha para confirmar", border: OutlineInputBorder()),
                obscureText: true,
                enabled: !_isLoading && _confirmDeletionCheckbox,
                validator: (value) {
                  if (_confirmDeletionCheckbox && (value == null || value.isEmpty)) {
                    return "Por favor, insira sua senha para confirmar a exclusão.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              if (_isLoading)
                const Center(child: CircularProgressIndicator(color: Colors.red))
              else
                ElevatedButton(
                  onPressed: (_confirmDeletionCheckbox && !_isLoading) ? _deleteAccount : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("Excluir Minha Conta Permanentemente", style: TextStyle(fontSize: 16)),
                ),
              const SizedBox(height: 12),
              if (!_isLoading)
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancelar"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

