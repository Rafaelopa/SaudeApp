import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:saude_app/src/features/exams/application/exam_service.dart';
import 'package:saude_app/src/features/exams/domain/exam_model.dart';
import 'package:saude_app/src/features/exams/presentation/providers/exam_providers.dart';

class AddImageExamScreen extends ConsumerStatefulWidget {
  final String patientProfileId;
  final String patientName;
  final ExamModel? examToEdit;

  const AddImageExamScreen({
    super.key,
    required this.patientProfileId,
    required this.patientName,
    this.examToEdit,
  });

  @override
  _AddImageExamScreenState createState() => _AddImageExamScreenState();
}

class _AddImageExamScreenState extends ConsumerState<AddImageExamScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _examTitleController;
  late TextEditingController _examDateController;
  late TextEditingController _clinicNameController;
  late TextEditingController _notesController;

  final List<XFile> _pickedFiles = []; // Para novos arquivos a serem adicionados
  List<ImageFileAttachment> _existingImageFiles = []; // Para arquivos existentes no modo de edição
  DateTime? _selectedDate;
  final ImagePicker _picker = ImagePicker();
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.examToEdit != null;

    _examTitleController = TextEditingController(text: _isEditMode ? widget.examToEdit!.examTitle : 

'');
    _examDateController = TextEditingController();
    _clinicNameController = TextEditingController(text: _isEditMode ? widget.examToEdit!.clinicName : 

'');
    _notesController = TextEditingController(text: _isEditMode ? widget.examToEdit!.notes : 

'');

    if (_isEditMode) {
      _selectedDate = widget.examToEdit!.examDate.toDate();
      _examDateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
      if (widget.examToEdit!.imageFiles != null) {
        _existingImageFiles = List.from(widget.examToEdit!.imageFiles!);
      }
    }
  }

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
    final List<XFile> images = await _picker.pickMultiImage();
    if (images != null && images.isNotEmpty) {
      setState(() {
        _pickedFiles.addAll(images);
      });
    }
  }

  void _removeNewFile(int index) {
    setState(() {
      _pickedFiles.removeAt(index);
    });
  }

  void _removeExistingFile(int index) {
    setState(() {
      _existingImageFiles.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_pickedFiles.isEmpty && _existingImageFiles.isEmpty && _isEditMode) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, adicione pelo menos um arquivo de exame.')));
        return;
      }
       if (_pickedFiles.isEmpty && !_isEditMode) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, adicione pelo menos um arquivo de exame.')));
        return;
      }
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione a data de realização.')));
        return;
      }

      ref.read(examSavingProvider.notifier).state = true;
      final snackBarMsg = _isEditMode ? 'Atualizando exame de imagem...' : 'Salvando exame de imagem...';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(snackBarMsg)));

      try {
        final examService = ref.read(examServiceProvider);
        List<File> filesToUpload = _pickedFiles.map((xfile) => File(xfile.path)).toList();

        if (_isEditMode) {
          await examService.updateImageExam(
            examIdToUpdate: widget.examToEdit!.examId!,
            patientProfileId: widget.patientProfileId,
            patientName: widget.patientName, // Pode ser atualizado
            examTitle: _examTitleController.text,
            examDate: _selectedDate!,
            clinicName: _clinicNameController.text.isEmpty ? null : _clinicNameController.text,
            notes: _notesController.text.isEmpty ? null : _notesController.text,
            newImageFilesToUpload: filesToUpload, // Apenas os novos
            existingImageFiles: widget.examToEdit!.imageFiles ?? [], // Os que estavam antes
            currentUIFilesState: _existingImageFiles, // Os que permaneceram na UI após remoção pelo usuário
          );
        } else {
          await examService.addImageExam(
            patientProfileId: widget.patientProfileId,
            patientName: widget.patientName,
            examTitle: _examTitleController.text,
            examDate: _selectedDate!,
            clinicName: _clinicNameController.text.isEmpty ? null : _clinicNameController.text,
            notes: _notesController.text.isEmpty ? null : _notesController.text,
            imageFilesToUpload: filesToUpload,
          );
        }

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        final successMsg = _isEditMode ? 'Exame de imagem atualizado com sucesso!' : 'Exame de imagem salvo com sucesso!';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(successMsg)));
        
        int popCount = 0;
        Navigator.of(context).popUntil((_) => popCount++ >= (_isEditMode ? 2 : 1));

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
    final String appBarTitle = _isEditMode ? 'Editar Exame de Imagem' : 'Novo Exame de Imagem';
    final String buttonText = _isEditMode ? 'Salvar Alterações' : 'Salvar Exame';

    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle)),
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
                  if (value == null || value.isEmpty) return 'Por favor, insira o título do exame';
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
                  if (value == null || value.isEmpty) return 'Por favor, selecione a data de realização';
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
              // Lista de arquivos existentes (no modo de edição)
              if (_isEditMode && _existingImageFiles.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _existingImageFiles.length,
                  itemBuilder: (context, index) {
                    final existingFile = _existingImageFiles[index];
                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: ListTile(
                        leading: const Icon(Icons.insert_drive_file_outlined, color: Colors.blueGrey),
                        title: Text(existingFile.fileName, overflow: TextOverflow.ellipsis),
                        subtitle: const Text("Arquivo existente"),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                          onPressed: () => _removeExistingFile(index),
                        ),
                      ),
                    );
                  },
                ),
              // Lista de novos arquivos selecionados
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
                        leading: const Icon(Icons.attach_file_outlined, color: Colors.green),
                        title: Text(xFile.name, overflow: TextOverflow.ellipsis),
                        subtitle: const Text("Novo arquivo"),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                          onPressed: () => _removeNewFile(index),
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Adicionar Novos Arquivos'),
                onPressed: _pickMedia,
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
                  child: Text(buttonText, style: const TextStyle(fontSize: 16)),
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

