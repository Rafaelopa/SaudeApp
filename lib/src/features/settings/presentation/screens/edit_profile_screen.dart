import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";
// import "package:saude_app/src/features/authentication/application/auth_service.dart"; // Para buscar dados do usuário
// import "package:saude_app/src/features/settings/application/user_profile_service.dart"; // Para atualizar dados do perfil

// TODO: Definir provedores para UserProfileService e para o estado do perfil do usuário

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _dobController; // Data de Nascimento

  String? _selectedGender;
  DateTime? _selectedDate;
  bool _isLoading = false;
  bool _isEditable = true; // Para controlar a edição após carregar dados

  // Simulação de dados do usuário - substituir por dados reais do provedor
  String _initialName = "Usuário Exemplo";
  String _initialEmail = "usuario@exemplo.com";
  DateTime? _initialDob = DateTime(1990, 5, 15);
  String? _initialGender = "Masculino";

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _initialName);
    _emailController = TextEditingController(text: _initialEmail);
    _dobController = TextEditingController();
    if (_initialDob != null) {
      _selectedDate = _initialDob;
      _dobController.text = DateFormat("dd/MM/yyyy").format(_initialDob!);
    }
    _selectedGender = _initialGender;

    // TODO: Carregar dados reais do usuário aqui
    // _loadUserData();
  }

  // Future<void> _loadUserData() async {
  //   setState(() { _isLoading = true; });
  //   try {
  //     // final userProfile = await ref.read(userProfileServiceProvider).getCurrentUserProfile();
  //     // if (userProfile != null) {
  //     //   _nameController.text = userProfile.displayName ?? "";
  //     //   _emailController.text = userProfile.email ?? ""; // FirebaseUser.email
  //     //   if (userProfile.dateOfBirth != null) {
  //     //     _selectedDate = userProfile.dateOfBirth.toDate();
  //     //     _dobController.text = DateFormat("dd/MM/yyyy").format(_selectedDate!);
  //     //   }
  //     //   _selectedGender = userProfile.gender;
  //     // }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao carregar dados do perfil: ${e.toString()}")));
  //   } finally {
  //     setState(() { _isLoading = false; });
  //   }
  // }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: "Selecione a Data de Nascimento",
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat("dd/MM/yyyy").format(picked);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; _isEditable = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Salvando perfil...")),
      );
      try {
        // TODO: Implementar a lógica de salvar o perfil
        // final profileService = ref.read(userProfileServiceProvider);
        // await profileService.updateUserProfile(
        //   displayName: _nameController.text,
        //   email: _emailController.text, // Lidar com reautenticação se o email mudar
        //   dateOfBirth: _selectedDate,
        //   gender: _selectedGender,
        // );
        await Future.delayed(const Duration(seconds: 1)); // Simulação
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Perfil atualizado com sucesso!")),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao salvar perfil: ${e.toString()}")),
        );
      } finally {
        setState(() { _isLoading = false; _isEditable = true; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Meu Perfil"),
      ),
      body: _isLoading && !_isEditable // Mostra loading apenas no carregamento inicial
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // TODO: Adicionar campo para foto de perfil (Opcional MVP+)
                    // CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
                    // SizedBox(height: 10),
                    // TextButton(onPressed: () {}, child: Text("Alterar Foto")),
                    // SizedBox(height: 20),

                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: "Nome Completo", border: OutlineInputBorder()),
                      enabled: _isEditable,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Por favor, insira seu nome completo.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
                      keyboardType: TextInputType.emailAddress,
                      enabled: _isEditable,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Por favor, insira seu email.";
                        }
                        if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value)) {
                           return "Por favor, insira um email válido.";
                        }
                        return null;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                      child: Text(
                        "A alteração do email pode exigir verificação.",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      ),
                    ),
                    TextFormField(
                      controller: _dobController,
                      decoration: const InputDecoration(labelText: "Data de Nascimento", border: OutlineInputBorder()),
                      readOnly: true,
                      enabled: _isEditable,
                      onTap: _isEditable ? () => _selectDate(context) : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: "Gênero (Opcional)", border: OutlineInputBorder()),
                      value: _selectedGender,
                      hint: const Text("Selecione seu gênero"),
                      items: ["Masculino", "Feminino", "Outro", "Prefiro não informar"].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: _isEditable ? (String? newValue) {
                        setState(() {
                          _selectedGender = newValue;
                        });
                      } : null,
                    ),
                    const SizedBox(height: 30),
                    if (_isLoading && _isEditable) // Mostra loading no botão durante o salvamento
                      const Center(child: CircularProgressIndicator())
                    else
                      ElevatedButton(
                        onPressed: _isEditable ? _saveProfile : null,
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                        child: const Text("Salvar Alterações", style: TextStyle(fontSize: 16)),
                      ),
                    const SizedBox(height: 12),
                    if (_isEditable)
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

