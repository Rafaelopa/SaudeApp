import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart'; // Using image_picker for now, consider file_picker for PDFs
import 'package:intl/intl.dart';
import 'package:saude_app_mobile/src/features/exams/application/exam_service.dart';
import 'package:saude_app_mobile/src/features/exams/presentation/providers/exam_providers.dart';

// Using XFile from image_picker directly for simplicity in this MVP stage
// class AttachedFile {
//   final File file;
//   final String fileName;
//   AttachedFile({required this.file, required this.fileName});
// }

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

  List<XFile> _pickedFiles = []; // Store XFile directly
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

  Future<void> _pickMedia() async {
    // For MVP, let's stick to multi-image. PDF would require file_picker and more handling.
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null && images.isNotEmpty) {
      setState(() {
        _pickedFiles.addAll(images);
      });
    }
    // TODO: Implement file_picker for PDFs if required beyond MVP
    // final result = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png']);
    // if (result != null) {
    //   setState(() {
    //     _pickedFiles.addAll(result.paths.map((path) => File(path!)).toList());
    //   });
    // }
  }

  void _removeFile(int index) {
    setState(() {
      _pickedFiles.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_pickedFiles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, adicione pelo menos um arquivo de exame.')),
        );
        return;
      }
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione a data de realização.')),
        );
        return;
      }

      ref.read(examSavingProvider.notifier).state = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Salvando exame de imagem...')),
      );

      try {
        final examService = ref.read(examServiceProvider);
        List<File> filesToUpload = _pickedFiles.map((xfile) => File(xfile.path)).toList();

        await examService.addImageExam(
          patientProfileId: widget.patientProfileId,
          patientName: widget.patientName,
          examTitle: _examTitleController.text,
          examDate: _selectedDate!,
          clinicName: _clinicNameController.text.isEmpty ? null : _clinicNameController.text,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          imageFilesToUpload: filesToUpload,
        );

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exame de imagem salvo com sucesso!')),
        );
        Navigator.of(context).pop(); // Volta para a tela de seleção de tipo
      } catch (e) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar exame: ${e.toString()}')),
        );
      } finally {
        ref.read(examSavingProvider.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(examSavingProvider);

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
                decoration: const InputDecoration(labelText: 'Título do Exame*', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o título do exame';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _examDateController,
                decoration: const InputDecoration(labelText: 'Data da Realização*', border: OutlineInputBorder()),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione a data de realização';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _clinicNameController,
                decoration: const InputDecoration(labelText: 'Clínica/Hospital', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              Text('Arquivos do Exame*', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Adicionar Arquivos (Imagem/PDF)'), // Label genérico
                onPressed: _pickMedia,
              ),
              const SizedBox(height: 10),
              if (_pickedFiles.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _pickedFiles.length,
                  itemBuilder: (context, index) {
                    final xFile = _pickedFiles[index];
                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: ListTile(
                        leading: const Icon(Icons.insert_drive_file_outlined), // TODO: Melhorar ícone por tipo de arquivo
                        title: Text(xFile.name, overflow: TextOverflow.ellipsis),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                          onPressed: () => _removeFile(index),
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notas/Observações', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              if (isSaving)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                  child: const Text('Salvar Exame', style: TextStyle(fontSize: 16)),
                ),
              const SizedBox(height: 8),
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

