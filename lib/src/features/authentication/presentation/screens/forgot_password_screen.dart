// Presentation layer - Forgot Password Screen

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:saude_app/src/features/authentication/presentation/widgets/auth_gate.dart"; // For authServiceProvider

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  bool _isError = false;

  Future<void> _sendResetEmail() async {
    setState(() {
      _message = null;
      _isError = false;
    });
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final authService = ref.read(authServiceProvider);
        await authService.sendPasswordResetEmail(_emailController.text.trim());
        if (mounted) {
          setState(() {
            _message = "Email de redefinição de senha enviado com sucesso para ${_emailController.text.trim()}. Verifique sua caixa de entrada.";
            _isError = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _message = "Falha ao enviar email: ${e.toString().replaceFirst("Exception: ", "")}";
            _isError = true;
          });
        }
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recuperar Senha")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  "Redefina sua senha",
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  "Insira seu email abaixo para receber um link de redefinição de senha.",
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty || !value.contains("@")) {
                      return "Por favor, insira um email válido.";
                    }
                    return null;
                  },
                ),
                if (_message != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      _message!,
                      style: TextStyle(color: _isError ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        onPressed: _sendResetEmail,
                        child: const Text("Enviar Email de Redefinição"),
                      ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Go back to Login Screen
                  },
                  child: const Text("Voltar para o Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

