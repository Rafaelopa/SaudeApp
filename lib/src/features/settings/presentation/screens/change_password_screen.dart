import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
// import "package:saude_app_mobile/src/features/authentication/application/auth_service.dart"; // Para o serviço de alteração de senha

// TODO: Definir provedor para AuthService

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Alterando senha...")),
      );
      try {
        // TODO: Implementar a lógica real de alteração de senha
        // final authService = ref.read(authServiceProvider);
        // await authService.changePassword(
        //   currentPassword: _currentPasswordController.text,
        //   newPassword: _newPasswordController.text,
        // );
        await Future.delayed(const Duration(seconds: 1)); // Simulação
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Senha alterada com sucesso!")),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao alterar senha: ${e.toString()}")),
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
        title: const Text("Alterar Senha"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _currentPasswordController,
                decoration: const InputDecoration(labelText: "Senha Atual", border: OutlineInputBorder()),
                obscureText: true,
                enabled: !_isLoading,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor, insira sua senha atual.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                decoration: const InputDecoration(labelText: "Nova Senha", border: OutlineInputBorder()),
                obscureText: true,
                enabled: !_isLoading,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor, insira a nova senha.";
                  }
                  if (value.length < 6) {
                    return "A nova senha deve ter pelo menos 6 caracteres.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmNewPasswordController,
                decoration: const InputDecoration(labelText: "Confirmar Nova Senha", border: OutlineInputBorder()),
                obscureText: true,
                enabled: !_isLoading,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor, confirme a nova senha.";
                  }
                  if (value != _newPasswordController.text) {
                    return "As senhas não coincidem.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _changePassword,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                  child: const Text("Alterar Senha", style: TextStyle(fontSize: 16)),
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

