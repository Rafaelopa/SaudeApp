// lib/src/features/dependents/presentation/screens/view_edit_dependent_screen.dart

import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";
import "package:saude_app/src/features/dependents/domain/dependent_model.dart";
import "package:saude_app/src/features/dependents/presentation/providers/dependent_providers.dart";

class ViewEditDependentScreen extends ConsumerStatefulWidget {
  final String dependentId; 
  final Dependent initialDependentData; // Pass initial data to avoid re-fetch or for mock

  const ViewEditDependentScreen({
    super.key, 
    required this.dependentId, 
    required this.initialDependentData 
  });

  @override
  ConsumerState<ViewEditDependentScreen> createState() => _ViewEditDependentScreenState();
}

class _ViewEditDependentScreenState extends ConsumerState<ViewEditDependentScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  DateTime? _selectedDateOfBirth;
  String? _selectedBiologicalSex;
  String? _selectedRelationship;
  late TextEditingController _customRelationshipController;
  bool _showCustomRelationshipFieldInEdit = false;
  bool _isLoading = false;

  final List<String> _biologicalSexOptions = ["Masculino", "Feminino", "Intersexo", "Prefiro não informar"];
  final List<String> _relationshipOptions = ["Filho(a)", "Enteado(a)", "Tutelado(a)", "Outro"];

  late Dependent _currentDependent; 

  @override
  void initState() {
    super.initState();
    _currentDependent = widget.initialDependentData;
    _initializeEditControllers(_currentDependent);
  }

  void _initializeEditControllers(Dependent dependent) {
    _nameController = TextEditingController(text: dependent.name);
    _selectedDateOfBirth = dependent.dateOfBirth;
    _selectedBiologicalSex = dependent.biologicalSex;
    _selectedRelationship = dependent.relationship;
    _customRelationshipController = TextEditingController(text: dependent.customRelationship ?? "");
    _showCustomRelationshipFieldInEdit = dependent.relationship == "Outro";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _customRelationshipController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirthEdit(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDateOfBirth == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data de nascimento é obrigatória.")));
        return;
      }
       if (_selectedRelationship == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Grau de parentesco é obrigatório.")));
        return;
      }

      setState(() { _isLoading = true; });

      final updatedDependent = _currentDependent.copyWith(
        name: _nameController.text.trim(),
        dateOfBirth: _selectedDateOfBirth!,
        biologicalSex: _selectedBiologicalSex == "Prefiro não informar" ? null : _selectedBiologicalSex,
        setBiologicalSexToNull: _selectedBiologicalSex == "Prefiro não informar" || _selectedBiologicalSex == null,
        relationship: _selectedRelationship!,
        customRelationship: _showCustomRelationshipFieldInEdit ? _customRelationshipController.text.trim() : null,
        setCustomRelationshipToNull: !_showCustomRelationshipFieldInEdit,
        updatedAt: Timestamp.now(), // Update the timestamp
      );

      try {
        final dependentRepository = ref.read(dependentRepositoryProvider);
        await dependentRepository.updateDependent(updatedDependent);

        if (mounted) {
          setState(() {
            _currentDependent = updatedDependent; 
            _isEditing = false; 
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Perfil atualizado com sucesso!")));
        }
      } catch (e) {
        if (mounted) {
          setState(() { _isLoading = false; });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao atualizar: $e")));
        }
      }
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Excluir Dependente"),
          content: Text("Tem certeza que deseja excluir o perfil de ${_currentDependent.name}? Esta ação não poderá ser desfeita."),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text("Excluir", style: TextStyle(color: Theme.of(dialogContext).colorScheme.error)),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); 
                setState(() { _isLoading = true; });
                try {
                  final dependentRepository = ref.read(dependentRepositoryProvider);
                  if (_currentDependent.id != null) {
                    await dependentRepository.deleteDependent(_currentDependent.id!);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${_currentDependent.name} excluído(a) com sucesso.")));
                      Navigator.of(context).pop(); 
                    }
                  } else {
                     throw Exception("ID do dependente é nulo.");
                  }
                } catch (e) {
                  if (mounted) {
                    setState(() { _isLoading = false; });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao excluir: $e")));
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use a StreamProvider to listen to real-time updates for the specific dependent
    final dependentAsync = ref.watch(dependentDetailsProvider(widget.dependentId));

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "Editar Perfil" : _currentDependent.name),
        actions: _isLoading ? [] : [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: "Editar",
              onPressed: () {
                _initializeEditControllers(_currentDependent); 
                setState(() { _isEditing = true; });
              },
            ),
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
              tooltip: "Excluir",
              onPressed: _confirmDelete,
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: "Cancelar Edição",
              onPressed: () => setState(() { _isEditing = false; }),
            ),
        ],
      ),
      body: dependentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Erro ao carregar dados: $err")),
        data: (fetchedDependent) {
          if (fetchedDependent == null && !_isEditing) {
            // This might happen if the dependent was deleted elsewhere
            // Or if the initial fetch failed and we are not in edit mode (where we use _currentDependent)
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && Navigator.canPop(context)) {
                // Navigator.of(context).pop();
                 // It might be better to show a message or a specific state
              }
            });
            return const Center(child: Text("Dependente não encontrado ou foi removido."));
          }
          // Update _currentDependent if we are not editing, to reflect real-time changes
          if (!_isEditing && fetchedDependent != null) {
            _currentDependent = fetchedDependent;
          }
          
          return _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _isEditing 
                  ? _buildEditForm(context) 
                  : _buildViewDetails(context, _currentDependent);
        }
      )
    );
  }

  Widget _buildViewDetails(BuildContext context, Dependent dependent) {
    final now = DateTime.now();
    int age = now.year - dependent.dateOfBirth.year;
    if (now.month < dependent.dateOfBirth.month || 
        (now.month == dependent.dateOfBirth.month && now.day < dependent.dateOfBirth.day)) {
      age--;
    }
    age = age < 0 ? 0 : age; // Ensure age is not negative

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: CircleAvatar(
              radius: 60,
              backgroundImage: dependent.photoUrl != null && dependent.photoUrl!.isNotEmpty 
                  ? NetworkImage(dependent.photoUrl!) 
                  : null,
              backgroundColor: Colors.grey[300],
              child: (dependent.photoUrl == null || dependent.photoUrl!.isEmpty) 
                  ? Text(dependent.name.isNotEmpty ? dependent.name[0].toUpperCase() : "?", style: const TextStyle(fontSize: 40))
                  : null,
            ),
          ),
          const SizedBox(height: 24),
          _buildDetailItem(context, "Nome Completo", dependent.name),
          _buildDetailItem(context, "Data de Nascimento", DateFormat("dd/MM/yyyy").format(dependent.dateOfBirth)),
          _buildDetailItem(context, "Idade", "$age anos"), 
          if (dependent.biologicalSex != null && dependent.biologicalSex!.isNotEmpty)
            _buildDetailItem(context, "Sexo Biológico", dependent.biologicalSex!),
          _buildDetailItem(context, "Grau de Parentesco", 
            dependent.relationship == "Outro" && dependent.customRelationship != null && dependent.customRelationship!.isNotEmpty 
            ? dependent.customRelationship! 
            : dependent.relationship
          ),
          const SizedBox(height: 24),
          Text(
            "Histórico de Saúde (Em breve)", 
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 8),
          const Text("Aqui serão listados os exames e informações de saúde do dependente."),
        ],
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.grey[700])),
          const SizedBox(height: 2),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildEditForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Nome Completo *", border: OutlineInputBorder()),
              validator: (value) => (value == null || value.isEmpty) ? "Nome é obrigatório." : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Data de Nascimento *", 
                border: const OutlineInputBorder(),
                hintText: _selectedDateOfBirth == null ? "Selecione" : DateFormat("dd/MM/yyyy").format(_selectedDateOfBirth!)
              ),
              onTap: () => _pickDateOfBirthEdit(context),
              validator: (value) => _selectedDateOfBirth == null ? "Data de nascimento é obrigatória." : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Sexo Biológico", border: OutlineInputBorder()),
              value: _selectedBiologicalSex,
              hint: const Text("Selecione (opcional)"),
              items: _biologicalSexOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => _selectedBiologicalSex = val),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Grau de Parentesco *", border: OutlineInputBorder()),
              value: _selectedRelationship,
              hint: const Text("Selecione"),
              items: _relationshipOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() {
                _selectedRelationship = val;
                _showCustomRelationshipFieldInEdit = val == "Outro";
                if (!_showCustomRelationshipFieldInEdit) _customRelationshipController.clear();
              }),
              validator: (value) => (value == null || value.isEmpty) ? "Parentesco é obrigatório." : null,
            ),
            if (_showCustomRelationshipFieldInEdit)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextFormField(
                  controller: _customRelationshipController,
                  decoration: const InputDecoration(labelText: "Especifique o Parentesco *", border: OutlineInputBorder()),
                  validator: (value) => (_showCustomRelationshipFieldInEdit && (value == null || value.isEmpty)) ? "Especifique o parentesco." : null,
                ),
              ),
            const SizedBox(height: 32),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    icon: const Icon(Icons.save_alt_outlined),
                    label: const Text("Salvar Alterações"),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    onPressed: _saveChanges,
                  ),
          ],
        ),
      ),
    );
  }
}

