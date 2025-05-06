// lib/src/features/dependents/presentation/screens/add_dependent_screen.dart

import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart"; 
import "package:saude_app/src/features/dependents/domain/dependent_model.dart";
import "package:saude_app/src/features/dependents/presentation/providers/dependent_providers.dart";

class AddDependentScreen extends ConsumerStatefulWidget {
  const AddDependentScreen({super.key});

  @override
  ConsumerState<AddDependentScreen> createState() => _AddDependentScreenState();
}

class _AddDependentScreenState extends ConsumerState<AddDependentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _selectedDateOfBirth;
  String? _selectedBiologicalSex;
  String? _selectedRelationship;
  final _customRelationshipController = TextEditingController();
  bool _showCustomRelationshipField = false;
  bool _isLoading = false;

  final List<String> _biologicalSexOptions = ["Masculino", "Feminino", "Intersexo", "Prefiro não informar"];
  final List<String> _relationshipOptions = ["Filho(a)", "Enteado(a)", "Tutelado(a)", "Outro"];

  @override
  void dispose() {
    _nameController.dispose();
    _customRelationshipController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: "Selecione a Data de Nascimento",
      cancelText: "Cancelar",
      confirmText: "Confirmar",
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  void _saveDependent() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDateOfBirth == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Por favor, selecione a data de nascimento.")),
        );
        return;
      }
      if (_selectedRelationship == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Por favor, selecione o grau de parentesco.")),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      // userId will be set by the repository using the currently authenticated user
      final now = Timestamp.now();
      final newDependent = Dependent(
        userId: "", // Placeholder, will be set by repository
        name: _nameController.text.trim(),
        dateOfBirth: _selectedDateOfBirth!,
        biologicalSex: _selectedBiologicalSex == "Prefiro não informar" ? null : _selectedBiologicalSex,
        relationship: _selectedRelationship!,
        customRelationship: _showCustomRelationshipField ? _customRelationshipController.text.trim() : null,
        createdAt: now, // Will be set by repository, but good to have here
        updatedAt: now, // Will be set by repository
        // photoUrl and localPhotoFile to be handled later
      );

      try {
        final dependentRepository = ref.read(dependentRepositoryProvider);
        await dependentRepository.addDependent(newDependent);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Dependente ${_nameController.text.trim()} salvo com sucesso!")),
          );
          Navigator.of(context).pop(); 
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erro ao salvar dependente: $e")),
          );
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Adicionar Novo Dependente"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nome Completo *",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor, insira o nome completo.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Data de Nascimento *",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.calendar_today),
                  hintText: _selectedDateOfBirth == null
                      ? "Selecione a data"
                      : DateFormat("dd/MM/yyyy").format(_selectedDateOfBirth!),
                ),
                onTap: () => _pickDateOfBirth(context),
                validator: (value) {
                  if (_selectedDateOfBirth == null) {
                    return "Por favor, selecione a data de nascimento.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Sexo Biológico",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.wc),
                ),
                value: _selectedBiologicalSex,
                hint: const Text("Selecione (opcional)"),
                items: _biologicalSexOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedBiologicalSex = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Grau de Parentesco *",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.family_restroom),
                ),
                value: _selectedRelationship,
                hint: const Text("Selecione o parentesco"),
                items: _relationshipOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRelationship = newValue;
                    _showCustomRelationshipField = newValue == "Outro";
                    if (!_showCustomRelationshipField) {
                      _customRelationshipController.clear();
                    }
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor, selecione o grau de parentesco.";
                  }
                  return null;
                },
              ),
              if (_showCustomRelationshipField)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: TextFormField(
                    controller: _customRelationshipController,
                    decoration: const InputDecoration(
                      labelText: "Especifique o Parentesco *",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (_showCustomRelationshipField && (value == null || value.isEmpty)) {
                        return "Por favor, especifique o parentesco.";
                      }
                      return null;
                    },
                  ),
                ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text("Salvar Dependente"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      onPressed: _saveDependent,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

