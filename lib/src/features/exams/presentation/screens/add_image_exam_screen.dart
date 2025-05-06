import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
// TODO: Importar provedores e modelos necessários quando forem criados

class AttachedFile {
  final File file;
  final String fileName;
  // TODO: Adicionar status de upload
  AttachedFile({required this.file, required this.fileName});
}

class AddImageExamScreen extends ConsumerStatefulWidget {
  final String patientProfileId;
  final String patientName;

  const AddImageExamScreen({
    Key? key,
    required this.patientProfileId,
    required this.patientName,
  }) : super(key: key);

  @override
  _AddImageExamScreenState createState() => _AddImageExamScreenState();
}

class _AddImageExamScreenState extends ConsumerState<AddImageExamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _examTitleController = TextEditingController();
  final _examDateController = TextEditingController();
  final _clinicNameController = TextEditingController();
  final _notesController = TextEditingController();

  List<AttachedFile> _attachedFiles = [];
  DateTime? _selectedDate;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _examTitleController.dispose();
    _examDateController.dispose();
    _clinicNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _examDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _pickFiles() async {
    // TODO: Adicionar suporte para outros tipos de arquivo (PDF) usando file_picker
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        for (var pickedFile in pickedFiles) {
          _attachedFiles.add(AttachedFile(file: File(pickedFile.path), fileName: pickedFile.name));
        }
      });
    }
  }

  void _removeFile(int index) {
    setState(() {
      _attachedFiles.removeAt(index);
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_attachedFiles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, adicione pelo menos um arquivo de exame.')),
        );
        return;
      }
      // TODO: Implementar lógica de salvamento com Firebase (metadados no Firestore, arquivos no Storage)
      // Coletar dados:
      // String examTitle = _examTitleController.text;
      // DateTime examDate = _selectedDate!;
      // String clinicName = _clinicNameController.text;
      // String notes = _notesController.text;
      // List<File> filesToUpload = _attachedFiles.map((af) => af.file).toList();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Salvando exame de imagem...')),
      );
      // Simulação de salvamento
      Future.delayed(const Duration(seconds: 1), () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exame salvo com sucesso! (Simulado)')),
        );
        Navigator.of(context).pop(); // TODO: Navegar para a lista de exames
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Exame de Imagem'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              Text('Perfil: ${widget.patientName}', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              TextFormField(
                controller: _examTitleController,
                decoration: const InputDecoration(labelText: 'Título do Exame*'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o título do exame';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _examDateController,
                decoration: const InputDecoration(labelText: 'Data da Realização*'),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione a data de realização';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _clinicNameController,
                decoration: const InputDecoration(labelText: 'Clínica/Hospital'),
              ),
              const SizedBox(height: 20),
              Text('Arquivos do Exame*', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Adicionar Arquivos (Imagem, PDF)'),
                onPressed: _pickFiles,
              ),
              const SizedBox(height: 10),
              if (_attachedFiles.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _attachedFiles.length,
                  itemBuilder: (context, index) {
                    final attachedFile = _attachedFiles[index];
                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.insert_drive_file_outlined), // TODO: Melhorar ícone por tipo
                        title: Text(attachedFile.fileName),
                        // TODO: Adicionar indicador de progresso de upload
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () => _removeFile(index),
                        ),
                      ),
                    );
                  },
                ),
              if (_attachedFiles.isEmpty && _formKey.currentState?.validate() == false && _formKey.currentState?.errors['files'] != null) // Tentativa de mostrar erro se submetido sem arquivos
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Por favor, adicione pelo menos um arquivo.',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ), 
              const SizedBox(height: 20),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notas/Observações'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Salvar Exame'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

